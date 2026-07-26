from __future__ import annotations

import gzip
import json
from dataclasses import replace
from datetime import date, datetime, timezone
from pathlib import Path

from atm_catalog_builder import CatalogBuilder
from atm_catalog_builder.accessibility import (
    FiscPositiveCapabilityAdapter,
    FiscPositiveCapabilityOverlay,
)
from atm_catalog_builder.evidence import CapabilityEvidence, EvidenceAttribution
from atm_catalog_builder.fisc import DownloadedResource, FiscNationalAtmAdapter
from atm_catalog_builder.post import ChunghwaPostAtmAdapter, ChunghwaPostAtmOverlay

FIXTURES = Path(__file__).parent / "fixtures"


def test_postal_atm_positive_capabilities_overlay_without_adding_duplicate(
    tmp_path: Path,
) -> None:
    backbone = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "fisc_postal_backbone.csv").read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "fisc",
    )
    postal = ChunghwaPostAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "post_atms.csv").read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "post",
    )

    result = ChunghwaPostAtmOverlay().apply(backbone=backbone, overlay=postal)

    assert len(result.records) == len(backbone.records)
    post_office = next(
        record for record in result.records if record.institution_code == "700"
    )
    attribution = EvidenceAttribution(
        source_name="chunghwa-post-atm",
        source_date=date(2026, 7, 25),
        confidence="official_positive",
    )
    assert set(post_office.capabilities) == {
        CapabilityEvidence(
            capability="deposit",
            status="confirmed",
            attribution=attribution,
        ),
        CapabilityEvidence(
            capability="audio_guidance",
            status="confirmed",
            attribution=attribution,
        ),
    }
    general_atm = next(
        record for record in result.records if record.institution_code == "004"
    )
    assert general_atm.capabilities == ()


def test_postal_overlay_preserves_coordinates_and_on_site_evidence(
    tmp_path: Path,
) -> None:
    backbone = _postal_backbone(tmp_path)
    postal = _postal_source(tmp_path)

    result = ChunghwaPostAtmOverlay().apply(backbone=backbone, overlay=postal)

    post_office = next(
        record for record in result.records if record.institution_code == "700"
    )
    assert (post_office.latitude, post_office.longitude) == (
        25.0478,
        121.5104,
    )
    assert post_office.location_type == "on_site"
    assert post_office.location_type_evidence == EvidenceAttribution(
        source_name="chunghwa-post-atm",
        source_date=date(2026, 7, 25),
        confidence="official_exact",
    )


def test_postal_offsite_atm_without_branch_number_gets_stable_source_identity(
    tmp_path: Path,
) -> None:
    postal = _postal_source(tmp_path)

    offsite = next(record for record in postal.records if record.is_offsite)

    assert offsite.source_record_id
    assert offsite.place_name == "臺北車站局外ATM"
    assert offsite.display_address == "臺北市中正區北平西路3號"


def test_accessibility_lists_add_only_positive_evidence_and_leave_absence_unknown(
    tmp_path: Path,
) -> None:
    backbone = _postal_backbone(tmp_path)
    visual = FiscPositiveCapabilityAdapter(
        source_name="fisc-visual-accessibility-atm",
        source_url="https://www.fisc.com.tw/TC/OPENDATA/A103_Location.csv",
        capability="visual_accessibility",
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "fisc_visual_accessibility.csv").read_bytes(),
                content_type="application/octet-stream",
            )
        ),
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "visual",
    )
    wheelchair = FiscPositiveCapabilityAdapter(
        source_name="fisc-wheelchair-accessibility-atm",
        source_url="https://www.fisc.com.tw/TC/OPENDATA/A102_Location.csv",
        capability="wheelchair_accessibility",
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "fisc_wheelchair_accessibility.csv").read_bytes(),
                content_type="application/octet-stream",
            )
        ),
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "wheelchair",
    )

    with_visual = FiscPositiveCapabilityOverlay().apply(
        backbone=backbone,
        overlay=visual,
    )
    result = FiscPositiveCapabilityOverlay().apply(
        backbone=with_visual,
        overlay=wheelchair,
    )

    general_atm = next(
        record for record in result.records if record.institution_code == "004"
    )
    post_office = next(
        record for record in result.records if record.institution_code == "700"
    )
    assert {fact.capability for fact in general_atm.capabilities} == {
        "visual_accessibility"
    }
    assert {fact.capability for fact in post_office.capabilities} == {
        "wheelchair_accessibility"
    }
    assert all(fact.status == "confirmed" for fact in result.records[0].capabilities)
    assert "wheelchair_accessibility" not in {
        fact.capability for fact in general_atm.capabilities
    }
    assert "visual_accessibility" not in {
        fact.capability for fact in post_office.capabilities
    }


def test_capability_conflict_uses_newest_date_then_specialized_source_priority(
    tmp_path: Path,
) -> None:
    backbone = _postal_backbone(tmp_path)
    wheelchair_fact = CapabilityEvidence(
        capability="wheelchair_accessibility",
        status="confirmed",
        attribution=EvidenceAttribution(
            source_name="chunghwa-post-atm",
            source_date=date(2026, 7, 25),
            confidence="official_positive",
        ),
    )
    record = next(item for item in backbone.records if item.institution_code == "700")
    same_date_conflict = replace(
        backbone,
        records=(
            replace(record, capabilities=(wheelchair_fact,)),
            *(item for item in backbone.records if item is not record),
        ),
    )
    wheelchair = FiscPositiveCapabilityAdapter(
        source_name="fisc-wheelchair-accessibility-atm",
        source_url="https://www.fisc.com.tw/TC/OPENDATA/A102_Location.csv",
        capability="wheelchair_accessibility",
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "fisc_wheelchair_accessibility.csv").read_bytes(),
                content_type="text/csv",
            )
        ),
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "conflict",
    )

    specialized_wins = FiscPositiveCapabilityOverlay().apply(
        backbone=same_date_conflict,
        overlay=wheelchair,
    )
    selected = next(
        fact
        for fact in specialized_wins.records[0].capabilities
        if fact.capability == "wheelchair_accessibility"
    )
    assert selected.attribution.source_name == "fisc-wheelchair-accessibility-atm"
    assert specialized_wins.decisions[0].outcome == "conflict_replaced"

    newer_fact = replace(
        selected,
        attribution=replace(
            selected.attribution,
            source_date=date(2026, 7, 26),
        ),
    )
    newer_backbone = replace(
        specialized_wins,
        records=(
            replace(specialized_wins.records[0], capabilities=(newer_fact,)),
            *specialized_wins.records[1:],
        ),
    )
    older_result = FiscPositiveCapabilityOverlay().apply(
        backbone=newer_backbone,
        overlay=wheelchair,
    )
    assert older_result.records[0].capabilities == (newer_fact,)
    assert older_result.decisions[0].outcome == "conflict_kept_existing"


def test_capability_and_location_provenance_are_published_with_overlay_report(
    tmp_path: Path,
) -> None:
    postal_result = ChunghwaPostAtmOverlay().apply(
        backbone=_postal_backbone(tmp_path),
        overlay=_postal_source(tmp_path),
    )

    release = CatalogBuilder().publish(
        sources=[postal_result],
        output_directory=tmp_path / "release",
        dataset_version="2026.07.25.capabilities",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/capabilities",
    )

    with gzip.open(
        release.full_snapshot_path,
        mode="rt",
        encoding="utf-8",
    ) as snapshot:
        sites = [json.loads(line) for line in snapshot if line.strip()]
    post_office = next(site for site in sites if site["institutionCode"] == "700")
    assert post_office["capabilities"] == {
        "audioGuidance": {
            "status": "confirmed",
            "evidence": {
                "source": "chunghwa-post-atm",
                "date": "2026-07-25",
                "confidence": "official_positive",
            },
        },
        "deposit": {
            "status": "confirmed",
            "evidence": {
                "source": "chunghwa-post-atm",
                "date": "2026-07-25",
                "confidence": "official_positive",
            },
        },
    }
    assert post_office["locationType"] == "on_site"
    assert post_office["locationTypeEvidence"]["source"] == "chunghwa-post-atm"
    general_atm = next(site for site in sites if site["institutionCode"] == "004")
    assert general_atm["capabilities"] == {}
    assert general_atm["locationType"] == "unknown"

    report = json.loads(release.quality_report_path.read_text(encoding="utf-8"))
    assert report["evidenceOverlays"]["chunghwa-post-atm"]["counts"] == {
        "raw": 2,
        "enriched": 1,
        "quarantined": 1,
        "conflicts": 0,
    }


def _postal_backbone(tmp_path: Path) -> object:
    return FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "fisc_postal_backbone.csv").read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "fisc-shared",
    )


def _postal_source(tmp_path: Path) -> object:
    return ChunghwaPostAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=(FIXTURES / "post_atms.csv").read_bytes(),
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 25),
        raw_archive_directory=tmp_path / "post-shared",
    )


class _StaticDownloader:
    def __init__(self, resource: DownloadedResource) -> None:
        self._resource = resource

    def download(self, url: str) -> DownloadedResource:
        return self._resource
