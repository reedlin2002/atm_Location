from __future__ import annotations

import gzip
import hashlib
import json
from datetime import date, datetime, timezone
from pathlib import Path

from atm_catalog_builder import CatalogBuilder, CatalogRelease, SourceSnapshot
from atm_catalog_builder.publication import (
    CatalogPublicationWorkflow,
    FilesystemArtifactPublisher,
)

FIXTURES = Path(__file__).parent / "fixtures"


def test_failed_build_or_upload_never_replaces_fixed_manifest(
    tmp_path: Path,
) -> None:
    publisher = _MemoryPublisher(manifest=b'{"datasetVersion":"previous"}\n')
    workflow = CatalogPublicationWorkflow(publisher=publisher)

    def failed_build() -> CatalogRelease:
        raise RuntimeError("source download failed with token=do-not-log")

    build_result = workflow.run(build_release=failed_build)

    assert build_result.status == "blocked"
    assert build_result.issues == ("build_failed:RuntimeError",)
    assert publisher.manifest == b'{"datasetVersion":"previous"}\n'

    release = _build_release(tmp_path)
    publisher.fail_upload = True

    upload_result = workflow.run(build_release=lambda: release)

    assert upload_result.status == "blocked"
    assert upload_result.issues == ("upload_failed:OSError",)
    assert publisher.manifest == b'{"datasetVersion":"previous"}\n'


def test_quality_report_contains_publication_accounting_and_health_metrics(
    tmp_path: Path,
) -> None:
    release = _build_release(tmp_path)

    report = json.loads(release.quality_report_path.read_text(encoding="utf-8"))

    assert report["counts"] == {
        "raw": 5,
        "parsed": 5,
        "published": 4,
        "merged": 1,
        "quarantined": 0,
    }
    assert len(report["decisions"]) == report["counts"]["raw"]
    assert report["sourceFreshness"] == [
        {
            "name": "fixture-official-source",
            "sourceDate": "2026-07-25",
            "ageDaysAtPublication": 0,
        }
    ]
    assert report["capabilityUnknownRates"] == {
        capability: {"unknown": 4, "total": 4, "rate": 1.0}
        for capability in (
            "audioGuidance",
            "deposit",
            "visualAccessibility",
            "wheelchairAccessibility",
        )
    }
    assert report["overrideExpiry"] == {
        "active": 0,
        "expired": 0,
        "nearestExpiry": None,
    }


def test_contract_violations_block_publication_before_any_upload(
    tmp_path: Path,
) -> None:
    release = _build_release(tmp_path)
    sites = _read_snapshot(release.full_snapshot_path)
    invalid = dict(sites[0])
    invalid["institutionName"] = ""
    invalid["displayAddress"] = ""
    invalid["latitude"] = 35.0
    invalid["longitude"] = 140.0
    sites.append(invalid)
    _rewrite_snapshot_and_manifest(release, sites)

    publisher = _MemoryPublisher(manifest=b'{"datasetVersion":"previous"}\n')
    result = CatalogPublicationWorkflow(publisher=publisher).run(
        build_release=lambda: release
    )

    assert result.status == "blocked"
    assert set(result.issues) >= {
        "required_institution_missing",
        "required_address_missing",
        "duplicate_site_id",
        "coordinate_out_of_taiwan_bounds",
    }
    assert publisher.assets == {}
    assert publisher.manifest == b'{"datasetVersion":"previous"}\n'


def test_schema_quality_and_checksum_failures_leave_manifest_untouched(
    tmp_path: Path,
) -> None:
    previous_manifest = b'{"datasetVersion":"previous"}\n'

    schema_release = _build_release(tmp_path / "schema")
    schema_manifest = json.loads(
        schema_release.manifest_path.read_text(encoding="utf-8")
    )
    schema_manifest["schemaVersion"] = 2
    _write_json(schema_release.manifest_path, schema_manifest)

    quality_release = _build_release(tmp_path / "quality")
    quality = json.loads(
        quality_release.quality_report_path.read_text(encoding="utf-8")
    )
    del quality["coordinateQuality"]
    _write_json(quality_release.quality_report_path, quality)

    checksum_release = _build_release(tmp_path / "checksum")
    checksum_release.full_snapshot_path.write_bytes(b"corrupt")

    for release, expected_issue in (
        (schema_release, "manifest_schema_unsupported"),
        (quality_release, "quality_metrics_missing"),
        (checksum_release, "full_snapshot_unreadable"),
    ):
        publisher = _MemoryPublisher(manifest=previous_manifest)

        def build_release(release: CatalogRelease = release) -> CatalogRelease:
            return release

        result = CatalogPublicationWorkflow(publisher=publisher).run(
            build_release=build_release
        )
        assert result.status == "blocked"
        assert expected_issue in result.issues
        assert publisher.assets == {}
        assert publisher.manifest == previous_manifest


def test_release_gate_rejects_coordinate_coverage_below_98_percent(
    tmp_path: Path,
) -> None:
    release = _build_release(tmp_path)
    sites = _read_snapshot(release.full_snapshot_path)
    sites[0]["latitude"] = None
    sites[0]["longitude"] = None
    _rewrite_snapshot_and_manifest(release, sites)
    publisher = _MemoryPublisher(manifest=b"previous")

    result = CatalogPublicationWorkflow(publisher=publisher).run(
        build_release=lambda: release
    )

    assert result.status == "blocked"
    assert "coordinate_coverage_below_98_percent" in result.issues
    assert publisher.manifest == b"previous"


def test_release_gate_rejects_snapshot_larger_than_10_mb(
    tmp_path: Path,
) -> None:
    release = _build_release(tmp_path)
    release.full_snapshot_path.write_bytes(b"x" * (10 * 1024 * 1024 + 1))
    publisher = _MemoryPublisher(manifest=b"previous")

    result = CatalogPublicationWorkflow(publisher=publisher).run(
        build_release=lambda: release
    )

    assert result.status == "blocked"
    assert "full_snapshot_over_10_mb" in result.issues
    assert publisher.manifest == b"previous"


def test_large_catalog_change_requires_explicit_human_approval(
    tmp_path: Path,
) -> None:
    prior = _build_release(tmp_path / "prior", version="2026.07.24")
    current = _build_release(
        tmp_path / "current",
        fixture="official_atms_changed_removed.csv",
        version="2026.07.25",
        prior_catalog_path=prior.full_snapshot_path,
    )
    publisher = _MemoryPublisher(manifest=prior.manifest_path.read_bytes())
    workflow = CatalogPublicationWorkflow(publisher=publisher)

    held = workflow.run(
        build_release=lambda: current,
        prior_catalog_path=prior.full_snapshot_path,
    )

    assert held.status == "requires_human_approval"
    assert "active_site_change_over_2_percent" in held.issues
    assert publisher.assets == {}
    assert publisher.manifest == prior.manifest_path.read_bytes()

    approved = workflow.run(
        build_release=lambda: current,
        prior_catalog_path=prior.full_snapshot_path,
        human_approved=True,
    )

    assert approved.status == "published"
    assert approved.uploaded_assets == (
        current.full_snapshot_path.name,
        current.delta_paths[0].name,
        current.quality_report_path.name,
    )
    assert publisher.manifest == current.manifest_path.read_bytes()


def test_dry_run_needs_no_publisher_and_verified_assets_precede_manifest(
    tmp_path: Path,
) -> None:
    release = _build_release(tmp_path)

    dry_run = CatalogPublicationWorkflow().run(
        build_release=lambda: release,
        dry_run=True,
    )

    assert dry_run.status == "dry_run"
    assert dry_run.uploaded_assets == ()

    publisher = _MemoryPublisher(manifest=b"old")
    published = CatalogPublicationWorkflow(publisher=publisher).run(
        build_release=lambda: release
    )

    assert published.status == "published"
    assert publisher.events == [
        f"upload:{release.full_snapshot_path.name}",
        f"read:{release.full_snapshot_path.name}",
        f"upload:{release.quality_report_path.name}",
        f"read:{release.quality_report_path.name}",
        "replace:manifest.json",
    ]

    publisher = _MemoryPublisher(manifest=b"old")
    publisher.corrupt_readback = True
    failed = CatalogPublicationWorkflow(publisher=publisher).run(
        build_release=lambda: release
    )
    assert failed.status == "blocked"
    assert failed.issues == ("upload_failed:OSError",)
    assert publisher.manifest == b"old"


def test_filesystem_publisher_refuses_to_overwrite_immutable_release_asset(
    tmp_path: Path,
) -> None:
    first = _build_release(tmp_path / "first")
    publisher = FilesystemArtifactPublisher(tmp_path / "public")
    workflow = CatalogPublicationWorkflow(publisher=publisher)
    assert workflow.run(build_release=lambda: first).status == "published"
    fixed_manifest = (tmp_path / "public" / "manifest.json").read_bytes()

    conflicting = _build_release(
        tmp_path / "conflicting",
        fixture="official_atms_changed.csv",
    )
    result = workflow.run(build_release=lambda: conflicting)

    assert result.status == "blocked"
    assert result.issues == ("upload_failed:FileExistsError",)
    assert (tmp_path / "public" / "manifest.json").read_bytes() == fixed_manifest


def _read_snapshot(path: Path) -> list[dict[str, object]]:
    with gzip.open(path, mode="rt", encoding="utf-8") as snapshot:
        documents: list[dict[str, object]] = []
        for line in snapshot:
            if not line.strip():
                continue
            document: object = json.loads(line)
            assert isinstance(document, dict)
            documents.append(document)
        return documents


def _rewrite_snapshot_and_manifest(
    release: CatalogRelease,
    sites: list[dict[str, object]],
) -> None:
    content = gzip.compress(
        "".join(
            f"{json.dumps(site, ensure_ascii=False, sort_keys=True)}\n"
            for site in sites
        ).encode("utf-8"),
        mtime=0,
    )
    release.full_snapshot_path.write_bytes(content)
    manifest = json.loads(release.manifest_path.read_text(encoding="utf-8"))
    manifest["recordCount"] = len(sites)
    manifest["fullSnapshot"]["sha256"] = hashlib.sha256(content).hexdigest()
    release.manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def _write_json(path: Path, document: dict[str, object]) -> None:
    path.write_text(
        json.dumps(document, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def _build_release(
    tmp_path: Path,
    *,
    fixture: str = "official_atms.csv",
    version: str = "2026.07.25",
    prior_catalog_path: Path | None = None,
) -> CatalogRelease:
    return CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=date(2026, 7, 25),
                path=FIXTURES / fixture,
            )
        ],
        prior_catalog_path=prior_catalog_path,
        output_directory=tmp_path / version,
        dataset_version=version,
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url=f"https://catalog.example.test/{version}",
    )


class _MemoryPublisher:
    def __init__(self, *, manifest: bytes) -> None:
        self.manifest = manifest
        self.fail_upload = False
        self.corrupt_readback = False
        self.assets: dict[str, bytes] = {}
        self.events: list[str] = []

    def upload_immutable(self, name: str, content: bytes) -> None:
        if self.fail_upload:
            raise OSError("credentials=do-not-log")
        self.events.append(f"upload:{name}")
        self.assets[name] = content

    def read_immutable(self, name: str) -> bytes:
        self.events.append(f"read:{name}")
        content = self.assets[name]
        return content + b"corrupt" if self.corrupt_readback else content

    def replace_manifest(self, content: bytes) -> None:
        self.events.append("replace:manifest.json")
        self.manifest = content
