from __future__ import annotations

import json
from dataclasses import replace
from datetime import date, datetime, timezone
from pathlib import Path

from atm_catalog_builder import CatalogBuilder
from atm_catalog_builder.evidence import EvidenceAttribution
from atm_catalog_builder.fisc import DownloadedResource, FiscNationalAtmAdapter
from atm_catalog_builder.geocoding import (
    GeocodeCandidate,
    IncrementalGeocoder,
    ManualCoordinateOverrideSet,
)

FIXTURE = Path(__file__).parent / "fixtures" / "fisc_a2_location.csv"


def test_only_licensed_exact_in_bounds_geocode_is_adopted(
    tmp_path: Path,
) -> None:
    backbone = _backbone(tmp_path)
    provider = _FakeGeocoder(
        {
            "臺北市中正區館前路49號": (
                GeocodeCandidate(
                    returned_address="臺北市中正區館前路49號",
                    latitude=25.0461,
                    longitude=121.5141,
                    match_type="exact",
                ),
            ),
            "臺北市中正區忠孝西路一段49號": (
                GeocodeCandidate(
                    returned_address="臺北市中正區忠孝西路一段",
                    latitude=25.0478,
                    longitude=121.5170,
                    match_type="fuzzy",
                ),
            ),
            "臺南市中西區西門路一段658號": (
                GeocodeCandidate(
                    returned_address="臺南市中西區西門路一段658號",
                    latitude=35.0,
                    longitude=140.0,
                    match_type="exact",
                ),
            ),
        }
    )

    result = IncrementalGeocoder().apply(
        backbone=backbone,
        provider=provider,
        source_date=date(2026, 7, 25),
    )

    bank = next(record for record in result.records if record.institution_code == "004")
    assert (bank.latitude, bank.longitude) == (25.0461, 121.5141)
    assert bank.coordinate_evidence == EvidenceAttribution(
        source_name="licensed-address-geocoder",
        source_date=date(2026, 7, 25),
        confidence="licensed_exact",
    )
    assert {
        decision.source_record_id: decision.outcome for decision in result.decisions
    } == {
        backbone.records[0].source_record_id: "geocoded_exact",
        backbone.records[1].source_record_id: "quarantined_fuzzy",
        backbone.records[2].source_record_id: "quarantined_out_of_bounds",
    }
    assert all(
        record.latitude is None
        for record in result.records
        if record.institution_code != "004"
    )


def test_geocoder_queries_only_missing_or_changed_addresses(
    tmp_path: Path,
) -> None:
    backbone = _backbone(tmp_path)
    records = (
        replace(
            backbone.records[0],
            latitude=25.0461,
            longitude=121.5141,
        ),
        replace(
            backbone.records[1],
            latitude=25.0478,
            longitude=121.5170,
            display_address="臺北市中正區忠孝西路一段51號",
        ),
        backbone.records[2],
    )
    provider = _FakeGeocoder({})

    IncrementalGeocoder().apply(
        backbone=replace(backbone, records=records),
        provider=provider,
        source_date=date(2026, 7, 25),
        prior_addresses_by_source_record_id={
            records[0].source_record_id: records[0].display_address,
            records[1].source_record_id: "臺北市中正區忠孝西路一段49號",
        },
    )

    assert provider.queries == [
        "臺北市中正區忠孝西路一段51號",
        "臺南市中西區西門路一段658號",
    ]


def test_conflicting_geocode_candidates_are_quarantined(
    tmp_path: Path,
) -> None:
    backbone = _backbone(tmp_path)
    address = backbone.records[0].display_address
    provider = _FakeGeocoder(
        {
            address: (
                GeocodeCandidate(
                    returned_address=address,
                    latitude=25.0461,
                    longitude=121.5141,
                    match_type="exact",
                ),
                GeocodeCandidate(
                    returned_address=address,
                    latitude=25.0462,
                    longitude=121.5142,
                    match_type="exact",
                ),
            )
        }
    )

    result = IncrementalGeocoder().apply(
        backbone=replace(backbone, records=(backbone.records[0],)),
        provider=provider,
        source_date=date(2026, 7, 25),
    )

    assert result.records[0].latitude is None
    assert result.decisions[0].outcome == "quarantined_conflicting"


def test_versioned_manual_override_applies_until_optional_expiry(
    tmp_path: Path,
) -> None:
    backbone = _backbone(tmp_path)
    overrides = ManualCoordinateOverrideSet.from_json_file(
        Path(__file__).parent / "fixtures" / "manual_coordinate_overrides.json"
    )

    result = overrides.apply(backbone=backbone, as_of=date(2026, 7, 25))

    reviewed = next(
        record for record in result.records if record.institution_code == "004"
    )
    assert (reviewed.latitude, reviewed.longitude) == (25.0461, 121.5141)
    assert reviewed.coordinate_evidence == EvidenceAttribution(
        source_name="manual-reviewed-override",
        source_date=date(2026, 7, 25),
        confidence="manual_reviewed",
    )
    expired = next(
        record for record in result.records if record.institution_code == "822"
    )
    assert expired.latitude is None
    assert {
        decision.source_record_id: decision.outcome for decision in result.decisions
    } == {
        backbone.records[0].source_record_id: "manual_override_applied",
        backbone.records[1].source_record_id: "manual_override_expired",
    }
    release = CatalogBuilder().publish(
        sources=[result],
        output_directory=tmp_path / "override-release",
        dataset_version="2026.07.25.override",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/override",
    )
    report = _read_json(release.quality_report_path)
    decisions = report["evidenceOverlays"]["manual-reviewed-override"]["decisions"]
    assert decisions[0]["reason"] == "客服以銀行官方據點頁與現場回報確認"
    assert decisions[0]["reviewer"] == "catalog-reviewer"
    assert decisions[0]["reviewDate"] == "2026-07-25"
    assert decisions[0]["expiry"] is None
    assert decisions[1]["expiry"] == "2026-07-24"


def test_geocoding_quality_report_explains_coverage_confidence_and_unresolved(
    tmp_path: Path,
) -> None:
    backbone = _backbone(tmp_path)
    provider = _FakeGeocoder(
        {
            backbone.records[0].display_address: (
                GeocodeCandidate(
                    returned_address=backbone.records[0].display_address,
                    latitude=25.0461,
                    longitude=121.5141,
                    match_type="exact",
                ),
            ),
            backbone.records[1].display_address: (
                GeocodeCandidate(
                    returned_address="臺北市中正區忠孝西路一段",
                    latitude=25.0478,
                    longitude=121.5170,
                    match_type="fuzzy",
                ),
            ),
            backbone.records[2].display_address: (
                GeocodeCandidate(
                    returned_address=backbone.records[2].display_address,
                    latitude=35.0,
                    longitude=140.0,
                    match_type="exact",
                ),
            ),
        }
    )
    geocoded = IncrementalGeocoder().apply(
        backbone=backbone,
        provider=provider,
        source_date=date(2026, 7, 25),
    )

    release = CatalogBuilder().publish(
        sources=[geocoded],
        output_directory=tmp_path / "release",
        dataset_version="2026.07.25.geocoded",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/geocoded",
    )

    report = _read_json(release.quality_report_path)
    assert report["coordinateQuality"] == {
        "total": 3,
        "withCoordinates": 1,
        "coverageRate": 1 / 3,
        "byConfidence": {"licensed_exact": 1, "unknown": 2},
        "unresolvedReasons": {
            "quarantined_fuzzy": 1,
            "quarantined_out_of_bounds": 1,
        },
    }
    overlay = report["evidenceOverlays"]["licensed-address-geocoder"]
    assert overlay["counts"] == {
        "raw": 3,
        "accepted": 1,
        "quarantined": 2,
        "unresolved": 0,
    }


def _backbone(tmp_path: Path) -> object:
    return FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=FIXTURE.read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "raw",
    )


class _FakeGeocoder:
    source_name = "licensed-address-geocoder"

    def __init__(
        self,
        results: dict[str, tuple[GeocodeCandidate, ...]],
    ) -> None:
        self._results = results
        self.queries: list[str] = []

    def geocode(self, address: str) -> tuple[GeocodeCandidate, ...]:
        self.queries.append(address)
        return self._results.get(address, ())


class _StaticDownloader:
    def __init__(self, resource: DownloadedResource) -> None:
        self._resource = resource

    def download(self, url: str) -> DownloadedResource:
        return self._resource


def _read_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))
