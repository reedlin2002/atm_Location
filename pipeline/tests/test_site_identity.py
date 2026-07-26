from __future__ import annotations

import gzip
import json
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any

from atm_catalog_builder import CatalogBuilder, CatalogRelease, SourceSnapshot

FIXTURES = Path(__file__).parent / "fixtures"


def test_trustworthy_source_key_keeps_site_id_after_address_correction(
    tmp_path: Path,
) -> None:
    prior_release = _publish(
        fixture=FIXTURES / "official_atms.csv",
        output=tmp_path / "prior",
        version="2026.07.24",
        source_date=date(2026, 7, 24),
    )
    prior_sites = _read_snapshot(prior_release.full_snapshot_path)
    prior_bank = next(site for site in prior_sites if site["institutionCode"] == "004")

    current_release = CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=date(2026, 7, 25),
                path=FIXTURES / "official_atms_changed.csv",
            )
        ],
        prior_catalog_path=prior_release.full_snapshot_path,
        output_directory=tmp_path / "current",
        dataset_version="2026.07.25",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/2026.07.25",
    )
    current_sites = _read_snapshot(current_release.full_snapshot_path)
    current_bank = next(
        site for site in current_sites if site["institutionCode"] == "004"
    )

    assert current_bank["displayAddress"].endswith("51 號")
    assert current_bank["id"] == prior_bank["id"]
    assert current_bank["sourceKeys"] == [
        {
            "source": "fixture-official-source",
            "recordId": "bank-machine-1",
        },
        {
            "source": "fixture-official-source",
            "recordId": "bank-machine-2",
        },
    ]
    report = json.loads(current_release.quality_report_path.read_text(encoding="utf-8"))
    assert report["decisions"][0]["idContinuity"] == "source_key"


def test_initial_ids_and_source_keys_do_not_depend_on_row_order(
    tmp_path: Path,
) -> None:
    original = _publish(
        fixture=FIXTURES / "official_atms.csv",
        output=tmp_path / "original-order",
        version="2026.07.24.original",
        source_date=date(2026, 7, 24),
    )
    reordered = _publish(
        fixture=FIXTURES / "official_atms_reordered.csv",
        output=tmp_path / "reverse-order",
        version="2026.07.24.reordered",
        source_date=date(2026, 7, 24),
    )

    def identity_map(path: Path) -> dict[tuple[str, str], tuple[str, object]]:
        return {
            (site["institutionCode"], site["displayAddress"]): (
                site["id"],
                site["sourceKeys"],
            )
            for site in _read_snapshot(path)
        }

    assert identity_map(original.full_snapshot_path) == identity_map(
        reordered.full_snapshot_path
    )


def test_fuzzy_continuity_is_only_a_review_candidate_and_does_not_reuse_id(
    tmp_path: Path,
) -> None:
    prior_release = _publish(
        fixture=FIXTURES / "official_atms.csv",
        output=tmp_path / "prior-fuzzy",
        version="2026.07.24",
        source_date=date(2026, 7, 24),
    )
    prior_bank = next(
        site
        for site in _read_snapshot(prior_release.full_snapshot_path)
        if site["institutionCode"] == "004"
    )

    current_release = CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=date(2026, 7, 25),
                path=FIXTURES / "official_atms_fuzzy_candidate.csv",
            )
        ],
        prior_catalog_path=prior_release.full_snapshot_path,
        output_directory=tmp_path / "current-fuzzy",
        dataset_version="2026.07.25.fuzzy",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/fuzzy",
    )

    (current_site,) = _read_snapshot(current_release.full_snapshot_path)
    assert current_site["id"] != prior_bank["id"]
    report = json.loads(current_release.quality_report_path.read_text(encoding="utf-8"))
    assert report["reviewCandidates"] == [
        {
            "sourceRecordId": "bank-machine-new",
            "candidateCanonicalId": prior_bank["id"],
            "reason": "fuzzy_text_continuity",
        }
    ]


def test_conflicting_coordinates_are_quarantined_instead_of_silently_merged(
    tmp_path: Path,
) -> None:
    release = _publish(
        fixture=FIXTURES / "official_atms_coordinate_conflict.csv",
        output=tmp_path / "coordinate-conflict",
        version="2026.07.25.conflict",
        source_date=date(2026, 7, 25),
    )

    (site,) = _read_snapshot(release.full_snapshot_path)
    assert site["latitude"] is None
    assert site["longitude"] is None
    report = json.loads(release.quality_report_path.read_text(encoding="utf-8"))
    assert report["counts"]["quarantined"] == 1
    assert report["decisions"][1]["outcome"] == "quarantined_coordinate_conflict"
    assert report["reviewCandidates"] == [
        {
            "sourceRecordId": "conflict-b",
            "candidateCanonicalId": site["id"],
            "reason": "coordinate_conflict",
        }
    ]


def _publish(
    *,
    fixture: Path,
    output: Path,
    version: str,
    source_date: date,
) -> CatalogRelease:
    return CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=source_date,
                path=fixture,
            )
        ],
        output_directory=output,
        dataset_version=version,
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url=f"https://catalog.example.test/{version}",
    )


def _read_snapshot(path: Path) -> list[dict[str, Any]]:
    with gzip.open(path, mode="rt", encoding="utf-8") as snapshot:
        return [json.loads(line) for line in snapshot if line.strip()]
