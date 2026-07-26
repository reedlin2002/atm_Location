from __future__ import annotations

import gzip
import hashlib
import json
import sys
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any, cast

import pytest

from atm_catalog_builder import CatalogBuilder, SourceSnapshot
from atm_catalog_builder.__main__ import main
from atm_catalog_builder.fisc import (
    DownloadedResource,
    FiscNationalAtmAdapter,
    SourceContractError,
)

FIXTURE = Path(__file__).parent / "fixtures" / "official_atms.csv"
FISC_FIXTURE = Path(__file__).parent / "fixtures" / "fisc_a2_location.csv"
FISC_SCHEMA_CHANGE_FIXTURE = (
    Path(__file__).parent / "fixtures" / "fisc_a2_location_extra_column.csv"
)


def test_official_fixture_publishes_an_importable_catalog_release(
    tmp_path: Path,
) -> None:
    release = CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=date(2026, 7, 24),
                path=FIXTURE,
            )
        ],
        output_directory=tmp_path,
        dataset_version="2026.07.25.1",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/releases/2026.07.25.1",
    )

    manifest = _read_json(release.manifest_path)
    assert manifest == {
        "schemaVersion": 1,
        "datasetVersion": "2026.07.25.1",
        "publishedAt": "2026-07-25T08:00:00Z",
        "recordCount": 4,
        "sources": [{"name": "fixture-official-source", "date": "2026-07-24"}],
        "fullSnapshot": {
            "url": (
                "https://catalog.example.test/releases/2026.07.25.1/"
                "catalog-2026.07.25.1.ndjson.gz"
            ),
            "sha256": hashlib.sha256(
                release.full_snapshot_path.read_bytes()
            ).hexdigest(),
        },
        "deltas": [],
    }

    sites = _read_gzip_ndjson(release.full_snapshot_path)
    assert len(sites) == 4
    assert len({site["id"] for site in sites}) == 4
    assert [site["institutionCode"] for site in sites].count("004") == 1
    assert [site["institutionCode"] for site in sites].count("812") == 1
    assert {site["placeCategory"] for site in sites} >= {
        "bank",
        "convenience_store",
        "post_office",
    }

    quality_report = _read_json(release.quality_report_path)
    assert quality_report["counts"] == {
        "raw": 5,
        "parsed": 5,
        "published": 4,
        "merged": 1,
        "quarantined": 0,
    }
    assert {
        decision["sourceRecordId"]: decision["outcome"]
        for decision in quality_report["decisions"]
    } == {
        "bank-machine-1": "published",
        "bank-machine-2": "merged",
        "store-machine-1": "published",
        "post-machine-1": "published",
        "other-bank-same-address": "published",
    }


def test_fisc_evidence_publishes_quality_counts_without_inventing_coordinates(
    tmp_path: Path,
) -> None:
    adapted_source = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=FISC_FIXTURE.read_bytes(),
                content_type="text/csv; charset=utf-8",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 24),
        raw_archive_directory=tmp_path / "raw",
    )

    release = CatalogBuilder().publish(
        sources=[adapted_source],
        output_directory=tmp_path / "release",
        dataset_version="2026.07.25.fisc",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/fisc",
    )

    report = _read_json(release.quality_report_path)
    assert report["counts"] == {
        "raw": 3,
        "parsed": 3,
        "published": 3,
        "merged": 0,
        "quarantined": 0,
    }
    sites = _read_gzip_ndjson(release.full_snapshot_path)
    assert {site["county"] for site in sites} == {"臺北市", "臺南市"}
    assert all(site["latitude"] is None for site in sites)
    assert all(site["longitude"] is None for site in sites)
    assert all(site["placeCategory"] == "unknown" for site in sites)


def test_fisc_source_contract_failure_keeps_previous_release(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    release_directory = tmp_path / "release"
    release_directory.mkdir()
    previous_release = {
        "manifest.json": b'{"datasetVersion":"previous"}\n',
        "catalog-previous.ndjson.gz": b"previous snapshot",
        "quality-report-previous.json": b'{"datasetVersion":"previous"}\n',
    }
    for name, content in previous_release.items():
        (release_directory / name).write_bytes(content)

    monkeypatch.setattr(
        sys,
        "argv",
        [
            "atm-catalog-builder",
            "--source",
            str(FISC_SCHEMA_CHANGE_FIXTURE),
            "--source-format",
            "fisc",
            "--source-name",
            "fisc-national-atm",
            "--source-date",
            "2026-07-25",
            "--output",
            str(release_directory),
            "--dataset-version",
            "2026.07.25.fisc",
            "--published-at",
            "2026-07-25T08:00:00Z",
            "--artifact-base-url",
            "https://catalog.example.test/fisc",
        ],
    )

    with pytest.raises(SourceContractError, match="欄位"):
        main()

    assert {
        path.name: path.read_bytes()
        for path in release_directory.iterdir()
        if path.is_file()
    } == previous_release


def _read_json(path: Path) -> dict[str, Any]:
    return cast(
        dict[str, Any],
        json.loads(path.read_text(encoding="utf-8")),
    )


def _read_gzip_ndjson(path: Path) -> list[dict[str, Any]]:
    with gzip.open(path, mode="rt", encoding="utf-8") as snapshot:
        return [json.loads(line) for line in snapshot if line.strip()]


class _StaticDownloader:
    def __init__(self, resource: DownloadedResource) -> None:
        self._resource = resource

    def download(self, url: str) -> DownloadedResource:
        return self._resource
