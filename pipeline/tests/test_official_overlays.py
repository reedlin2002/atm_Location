from __future__ import annotations

import json
from datetime import date, datetime, timezone
from pathlib import Path

import pytest

from atm_catalog_builder import CatalogBuilder
from atm_catalog_builder.baseline import write_bundled_catalog
from atm_catalog_builder.evidence import EvidenceAttribution
from atm_catalog_builder.fisc import (
    AdaptedAtmSource,
    DownloadedResource,
    FiscNationalAtmAdapter,
)
from atm_catalog_builder.official import (
    OfficialOverlayDownloaders,
    apply_official_overlays,
)

FIXTURES = Path(__file__).parent / "fixtures"
SOURCE_DATE = date(2026, 11, 22)


def test_official_overlays_layer_coordinates_and_capabilities_on_backbone(
    tmp_path: Path,
) -> None:
    backbone = _backbone(tmp_path)

    result = apply_official_overlays(
        backbone=backbone,
        source_date=SOURCE_DATE,
        raw_archive_directory=tmp_path / "raw",
        downloaders=_fixture_downloaders(),
    )

    assert result.source_name == "fisc-national-atm"
    assert result.overlay_source_name == "fisc-wheelchair-accessibility-atm"
    assert len(result.records) == len(backbone.records)
    bank_site = next(
        record for record in result.records if record.institution_code == "004"
    )
    assert (bank_site.latitude, bank_site.longitude) == (25.0461, 121.5141)
    assert bank_site.coordinate_evidence == EvidenceAttribution(
        source_name="moda-cash-atm",
        source_date=SOURCE_DATE,
        confidence="official_exact",
    )


def test_bundled_catalog_matches_snapshot_without_pipeline_only_fields(
    tmp_path: Path,
) -> None:
    overlaid = apply_official_overlays(
        backbone=_backbone(tmp_path),
        source_date=SOURCE_DATE,
        raw_archive_directory=tmp_path / "raw",
        downloaders=_fixture_downloaders(),
    )
    release = CatalogBuilder().publish(
        sources=[overlaid],
        output_directory=tmp_path / "release",
        dataset_version="2026.11.22.1",
        published_at=datetime(2026, 11, 22, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/2026.11.22.1",
    )
    output = tmp_path / "app" / "baseline_catalog.json"

    summary = write_bundled_catalog(
        snapshot_path=release.full_snapshot_path,
        dataset_version="2026.11.22.1",
        output_path=output,
    )

    document = json.loads(output.read_text(encoding="utf-8"))
    assert document["schemaVersion"] == 1
    assert document["datasetVersion"] == "2026.11.22.1"
    sites = document["sites"]
    assert summary.total == len(sites) == len(overlaid.records)
    assert summary.with_coordinates == sum(
        1 for site in sites if site["latitude"] is not None
    )
    assert summary.with_coordinates >= 1
    assert all("sourceKeys" not in site for site in sites)
    assert not list(output.parent.glob(".*.tmp"))


def test_bundled_catalog_rejects_blank_dataset_version(tmp_path: Path) -> None:
    with pytest.raises(ValueError):
        write_bundled_catalog(
            snapshot_path=tmp_path / "missing.ndjson.gz",
            dataset_version=" ",
            output_path=tmp_path / "baseline_catalog.json",
        )


def _backbone(tmp_path: Path) -> AdaptedAtmSource:
    return FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            (FIXTURES / "fisc_a2_location.csv").read_bytes(),
            "application/octet-stream",
        )
    ).fetch(source_date=SOURCE_DATE, raw_archive_directory=tmp_path / "raw")


def _fixture_downloaders() -> OfficialOverlayDownloaders:
    return OfficialOverlayDownloaders(
        moda=_StaticDownloader(
            (FIXTURES / "moda_cash_atms.csv")
            .read_text(encoding="utf-8")
            .encode("cp950"),
            "text/csv",
        ),
        post=_StaticDownloader(
            (FIXTURES / "post_atms.csv").read_bytes(),
            "application/octet-stream",
        ),
        visual_accessibility=_StaticDownloader(
            (FIXTURES / "fisc_visual_accessibility.csv").read_bytes(),
            "application/octet-stream",
        ),
        wheelchair_accessibility=_StaticDownloader(
            (FIXTURES / "fisc_wheelchair_accessibility.csv").read_bytes(),
            "application/octet-stream",
        ),
    )


class _StaticDownloader:
    def __init__(self, content: bytes, content_type: str) -> None:
        self._resource = DownloadedResource(content=content, content_type=content_type)

    def download(self, url: str) -> DownloadedResource:
        return self._resource
