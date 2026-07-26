from __future__ import annotations

import gzip
import json
from dataclasses import replace
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any, Iterator
from urllib.request import Request

import pytest

from atm_catalog_builder import CatalogBuilder
from atm_catalog_builder.evidence import EvidenceAttribution
from atm_catalog_builder.fisc import DownloadedResource, FiscNationalAtmAdapter
from atm_catalog_builder.moda import ModaAtmAdapter, ModaAtmOverlay, SourceRowQuarantine

FISC_FIXTURE = Path(__file__).parent / "fixtures" / "fisc_a2_location.csv"
MODA_FIXTURE = Path(__file__).parent / "fixtures" / "moda_cash_atms.csv"


def test_official_exact_moda_match_enriches_without_overwriting_conflict(
    tmp_path: Path,
) -> None:
    backbone = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=FISC_FIXTURE.read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 24),
        raw_archive_directory=tmp_path / "fisc",
    )
    moda = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=MODA_FIXTURE.read_text(encoding="utf-8").encode("cp950"),
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path / "moda",
    )

    result = ModaAtmOverlay().apply(backbone=backbone, overlay=moda)

    assert len(result.records) == len(backbone.records)
    bank_site = next(
        record for record in result.records if record.institution_code == "004"
    )
    assert (bank_site.latitude, bank_site.longitude) == (25.0461, 121.5141)
    assert bank_site.place_category == "bank"
    assert bank_site.coordinate_evidence == EvidenceAttribution(
        source_name="moda-cash-atm",
        source_date=date(2025, 11, 3),
        confidence="official_exact",
    )
    assert bank_site.place_category_evidence == bank_site.coordinate_evidence

    assert all(record.institution_code != "999" for record in result.records)
    outcomes = {
        decision.source_record_id: decision.outcome for decision in result.decisions
    }
    assert outcomes["1"] == "enriched"
    assert outcomes["2"] == "quarantined"


def test_ambiguous_exact_overlay_match_is_quarantined_without_fuzzy_guess(
    tmp_path: Path,
) -> None:
    backbone = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=FISC_FIXTURE.read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 24),
        raw_archive_directory=tmp_path / "fisc",
    )
    duplicate_candidate = replace(
        backbone.records[0],
        source_record_id="duplicate-same-bank-address",
        place_name="同址第二機臺",
    )
    ambiguous_backbone = replace(
        backbone,
        records=(backbone.records[0], duplicate_candidate, *backbone.records[1:]),
    )
    moda = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=MODA_FIXTURE.read_text(encoding="utf-8").encode("cp950"),
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path / "moda",
    )

    result = ModaAtmOverlay().apply(
        backbone=ambiguous_backbone,
        overlay=moda,
    )

    decision = next(
        decision for decision in result.decisions if decision.source_record_id == "1"
    )
    assert decision.outcome == "quarantined"
    assert all(
        record.coordinate_evidence is None
        for record in result.records
        if record.institution_code == "004"
    )


def test_moda_provenance_and_unknown_category_are_published_without_event_capability(
    tmp_path: Path,
) -> None:
    backbone = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=FISC_FIXTURE.read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 24),
        raw_archive_directory=tmp_path / "fisc",
    )
    moda = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=MODA_FIXTURE.read_text(encoding="utf-8").encode("cp950"),
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path / "moda",
    )
    overlaid = ModaAtmOverlay().apply(backbone=backbone, overlay=moda)

    release = CatalogBuilder().publish(
        sources=[overlaid],
        output_directory=tmp_path / "release",
        dataset_version="2026.07.25.moda",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/moda",
    )

    sites = _read_snapshot(release.full_snapshot_path)
    bank_site = next(site for site in sites if site["institutionCode"] == "004")
    assert bank_site["coordinateEvidence"] == {
        "source": "moda-cash-atm",
        "date": "2025-11-03",
        "confidence": "official_exact",
    }
    assert bank_site["placeCategoryEvidence"] == bank_site["coordinateEvidence"]
    assert bank_site["capabilities"] == {}
    assert "serviceType" not in bank_site

    unknown_category_site = next(
        site for site in sites if site["institutionCode"] == "812"
    )
    assert unknown_category_site["placeCategory"] == "unknown"
    assert unknown_category_site["placeCategoryEvidence"] is None

    report = json.loads(release.quality_report_path.read_text(encoding="utf-8"))
    assert report["evidenceOverlays"]["moda-cash-atm"]["counts"] == {
        "raw": 3,
        "enriched": 2,
        "quarantined": 1,
        "unknownPlaceCategory": 1,
        "normalizedCoordinates": 0,
    }
    assert {
        decision["sourceRecordId"]: decision["outcome"]
        for decision in report["evidenceOverlays"]["moda-cash-atm"]["decisions"]
    } == {
        "1": "enriched",
        "2": "quarantined",
        "3": "enriched_unknown_place_category",
    }


def test_official_moda_download_identifies_the_catalog_client(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    resource = _UrlResponse(MODA_FIXTURE.read_text(encoding="utf-8").encode("cp950"))

    def open_official_source(request: Request) -> _UrlResponse:
        assert isinstance(request, Request)
        assert request.get_header("User-agent") == "Taiwan-ATM-Finder-Catalog/1.0"
        return resource

    monkeypatch.setattr(
        "atm_catalog_builder.moda.urlopen",
        open_official_source,
    )

    result = ModaAtmAdapter().fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path,
    )

    assert len(result.records) == 3


def test_invalid_moda_data_row_is_quarantined_without_losing_valid_rows(
    tmp_path: Path,
) -> None:
    valid_content = MODA_FIXTURE.read_text(encoding="utf-8").encode("cp950")
    lines = valid_content.splitlines()
    place_name = "館前分行".encode("cp950")
    invalid_row = lines[1].replace(place_name, b"\x81" + place_name[1:])
    downloaded = b"\r\n".join([*lines, invalid_row])

    result = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path,
    )

    assert len(result.records) == 3
    assert len(result.quarantined_rows) == 1
    assert result.quarantined_rows[0].row_number == 5
    assert result.quarantined_rows[0].reason == "invalid_cp950"


def test_official_spreadsheet_text_prefix_is_removed_from_coordinates(
    tmp_path: Path,
) -> None:
    downloaded = (
        MODA_FIXTURE.read_text(encoding="utf-8")
        .replace("121.514100,25.046100", "'121.514100,'25.046100", 1)
        .encode("cp950")
    )
    result = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path,
    )

    assert (result.records[0].latitude, result.records[0].longitude) == (
        25.0461,
        121.5141,
    )


def test_missing_district_uses_the_complete_official_address(
    tmp_path: Path,
) -> None:
    downloaded = (
        MODA_FIXTURE.read_text(encoding="utf-8")
        .replace(
            "館前分行,臺北市,中正區,館前路49號",
            "館前分行,臺北市,,臺北市中正區館前路49號",
            1,
        )
        .encode("cp950")
    )
    result = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path,
    )

    assert result.records[0].district == ""
    assert result.records[0].display_address == "臺北市中正區館前路49號"


def test_invalid_overlay_coordinate_is_quarantined_without_blocking_backbone(
    tmp_path: Path,
) -> None:
    valid_content = MODA_FIXTURE.read_text(encoding="utf-8")
    invalid_row = valid_content.splitlines()[1].replace(
        "25.046100",
        "22.685.103",
    )
    downloaded = f"{valid_content.rstrip()}\n{invalid_row}\n".encode("cp950")

    result = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path,
    )

    assert len(result.records) == 3
    assert result.quarantined_rows == (
        SourceRowQuarantine(row_number=5, reason="invalid_record"),
    )


def test_unambiguous_swapped_official_coordinates_are_normalized(
    tmp_path: Path,
) -> None:
    downloaded = (
        MODA_FIXTURE.read_text(encoding="utf-8")
        .replace("121.514100,25.046100", "25.046100,121.514100", 1)
        .encode("cp950")
    )
    result = ModaAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    ).fetch(
        source_date=date(2025, 11, 3),
        raw_archive_directory=tmp_path,
    )

    record = next(record for record in result.records if record.source_record_id == "1")
    assert (record.latitude, record.longitude) == (
        25.0461,
        121.5141,
    )
    assert record.coordinate_was_swapped is True


def _read_snapshot(path: Path) -> list[dict[str, Any]]:
    with gzip.open(path, mode="rt", encoding="utf-8") as snapshot:
        return [json.loads(line) for line in snapshot if line.strip()]


class _StaticDownloader:
    def __init__(self, resource: DownloadedResource) -> None:
        self._resource = resource

    def download(self, url: str) -> DownloadedResource:
        return self._resource


class _Headers:
    @staticmethod
    def get_content_type() -> str:
        return "text/csv"


class _UrlResponse:
    def __init__(self, content: bytes) -> None:
        self._content = content
        self.headers = _Headers()

    def __enter__(self) -> _UrlResponse:
        return self

    def __exit__(self, *args: object) -> None:
        return None

    def read(self) -> bytes:
        return self._content

    def __iter__(self) -> Iterator[bytes]:
        return iter(())
