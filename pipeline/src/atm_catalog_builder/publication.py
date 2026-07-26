from __future__ import annotations

import gzip
import hashlib
import json
from collections.abc import Callable
from dataclasses import dataclass
from datetime import date, datetime
from pathlib import Path
from typing import Literal, Protocol

from atm_catalog_builder import CatalogRelease

PublicationStatus = Literal[
    "blocked",
    "requires_human_approval",
    "dry_run",
    "published",
]

MIN_COORDINATE_COVERAGE = 0.98
MAX_FULL_SNAPSHOT_BYTES = 10 * 1024 * 1024


class ArtifactPublisher(Protocol):
    def upload_immutable(self, name: str, content: bytes) -> None:
        ...

    def read_immutable(self, name: str) -> bytes:
        ...

    def replace_manifest(self, content: bytes) -> None:
        ...


@dataclass(frozen=True)
class PublicationResult:
    status: PublicationStatus
    issues: tuple[str, ...] = ()
    uploaded_assets: tuple[str, ...] = ()


class CatalogPublicationWorkflow:
    def __init__(self, *, publisher: ArtifactPublisher | None = None) -> None:
        self._publisher = publisher

    def run(
        self,
        *,
        build_release: Callable[[], CatalogRelease],
        dry_run: bool = False,
        prior_catalog_path: Path | None = None,
        human_approved: bool = False,
    ) -> PublicationResult:
        try:
            release = build_release()
        except Exception as error:
            return PublicationResult(
                status="blocked",
                issues=(f"build_failed:{type(error).__name__}",),
            )

        issues = _release_contract_issues(release)
        if issues:
            return PublicationResult(status="blocked", issues=issues)

        approval_issues = _change_approval_issues(
            release.full_snapshot_path,
            prior_catalog_path,
        )
        if any(issue.startswith("prior_catalog_") for issue in approval_issues):
            return PublicationResult(status="blocked", issues=approval_issues)
        if approval_issues and not human_approved:
            return PublicationResult(
                status="requires_human_approval",
                issues=approval_issues,
            )

        if dry_run:
            return PublicationResult(status="dry_run")
        if self._publisher is None:
            return PublicationResult(
                status="blocked",
                issues=("publisher_required",),
            )

        uploaded: list[str] = []
        try:
            for path in (
                release.full_snapshot_path,
                *release.delta_paths,
                release.quality_report_path,
            ):
                content = path.read_bytes()
                self._publisher.upload_immutable(path.name, content)
                uploaded_content = self._publisher.read_immutable(path.name)
                if not _same_content(content, uploaded_content):
                    raise OSError("Uploaded artifact verification failed")
                uploaded.append(path.name)
            self._publisher.replace_manifest(release.manifest_path.read_bytes())
        except Exception as error:
            return PublicationResult(
                status="blocked",
                issues=(f"upload_failed:{type(error).__name__}",),
                uploaded_assets=tuple(uploaded),
            )

        return PublicationResult(
            status="published",
            uploaded_assets=tuple(uploaded),
        )


class FilesystemArtifactPublisher:
    def __init__(self, directory: Path) -> None:
        self._directory = directory

    def upload_immutable(self, name: str, content: bytes) -> None:
        path = self._asset_path(name)
        self._directory.mkdir(parents=True, exist_ok=True)
        if path.exists():
            if not _same_content(path.read_bytes(), content):
                raise FileExistsError(f"Immutable asset already exists: {name}")
            return
        path.write_bytes(content)

    def read_immutable(self, name: str) -> bytes:
        return self._asset_path(name).read_bytes()

    def replace_manifest(self, content: bytes) -> None:
        self._directory.mkdir(parents=True, exist_ok=True)
        manifest_path = self._directory / "manifest.json"
        temporary_path = self._directory / ".manifest.json.tmp"
        temporary_path.write_bytes(content)
        temporary_path.replace(manifest_path)

    def _asset_path(self, name: str) -> Path:
        if not name or Path(name).name != name:
            raise ValueError("Artifact name must be a filename")
        return self._directory / name


def _same_content(expected: bytes, actual: bytes) -> bool:
    return hashlib.sha256(expected).digest() == hashlib.sha256(actual).digest()


def _release_contract_issues(release: CatalogRelease) -> tuple[str, ...]:
    issues: list[str] = []
    try:
        if release.full_snapshot_path.stat().st_size > MAX_FULL_SNAPSHOT_BYTES:
            issues.append("full_snapshot_over_10_mb")
    except OSError:
        issues.append("full_snapshot_unreadable")
    manifest = _read_json_object(
        release.manifest_path,
        document_name="manifest",
        issues=issues,
    )
    quality = _read_json_object(
        release.quality_report_path,
        document_name="quality_report",
        issues=issues,
    )
    sites = _read_gzip_documents(
        release.full_snapshot_path,
        document_name="full_snapshot",
        issues=issues,
    )
    if manifest is None or quality is None or sites is None:
        return tuple(dict.fromkeys(issues))

    _validate_manifest(manifest, release, sites, issues)
    _validate_sites(sites, issues)
    resolved_count = sum(
        _number(site.get("latitude")) is not None
        and _number(site.get("longitude")) is not None
        for site in sites
    )
    coverage = resolved_count / len(sites) if sites else 0.0
    if coverage < MIN_COORDINATE_COVERAGE:
        issues.append("coordinate_coverage_below_98_percent")
    _validate_quality_report(quality, manifest, sites, issues)
    _validate_deltas(manifest, release.delta_paths, issues)
    return tuple(dict.fromkeys(issues))


def _change_approval_issues(
    current_catalog_path: Path,
    prior_catalog_path: Path | None,
) -> tuple[str, ...]:
    if prior_catalog_path is None:
        return ()
    read_issues: list[str] = []
    prior_sites = _read_gzip_documents(
        prior_catalog_path,
        document_name="prior_catalog",
        issues=read_issues,
    )
    current_sites = _read_gzip_documents(
        current_catalog_path,
        document_name="full_snapshot",
        issues=read_issues,
    )
    if prior_sites is None or current_sites is None:
        return tuple(read_issues)
    if not prior_sites:
        return ()

    approval_issues: list[str] = []
    relative_change = abs(len(current_sites) - len(prior_sites)) / len(prior_sites)
    if relative_change > 0.02:
        approval_issues.append("active_site_change_over_2_percent")

    prior_counties = _counts_by(prior_sites, "county")
    current_counties = _counts_by(current_sites, "county")
    if any(
        current_counties.get(county, 0) < count * 0.9
        for county, count in prior_counties.items()
        if county
    ):
        approval_issues.append("material_county_drop")

    prior_institutions = _counts_by(prior_sites, "institutionCode")
    current_institutions = _counts_by(current_sites, "institutionCode")
    if any(
        current_institutions.get(institution, 0) == 0
        or current_institutions.get(institution, 0) < count * 0.8
        for institution, count in prior_institutions.items()
        if institution
    ):
        approval_issues.append("institution_anomaly")
    return tuple(approval_issues)


def _counts_by(
    sites: list[dict[str, object]],
    field: str,
) -> dict[str, int]:
    counts: dict[str, int] = {}
    for site in sites:
        value = site.get(field)
        if isinstance(value, str):
            counts[value] = counts.get(value, 0) + 1
    return counts


def _read_json_object(
    path: Path,
    *,
    document_name: str,
    issues: list[str],
) -> dict[str, object] | None:
    try:
        document: object = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError):
        issues.append(f"{document_name}_unreadable")
        return None
    if not isinstance(document, dict):
        issues.append(f"{document_name}_schema_invalid")
        return None
    return document


def _read_gzip_documents(
    path: Path,
    *,
    document_name: str,
    issues: list[str],
) -> list[dict[str, object]] | None:
    try:
        with gzip.open(path, mode="rt", encoding="utf-8") as stream:
            documents: list[dict[str, object]] = []
            for line in stream:
                if not line.strip():
                    continue
                document: object = json.loads(line)
                if not isinstance(document, dict):
                    issues.append(f"{document_name}_schema_invalid")
                    return None
                documents.append(document)
            return documents
    except (OSError, UnicodeError, json.JSONDecodeError):
        issues.append(f"{document_name}_unreadable")
        return None


def _validate_manifest(
    manifest: dict[str, object],
    release: CatalogRelease,
    sites: list[dict[str, object]],
    issues: list[str],
) -> None:
    if manifest.get("schemaVersion") != 1:
        issues.append("manifest_schema_unsupported")
    dataset_version = manifest.get("datasetVersion")
    if not isinstance(dataset_version, str) or not dataset_version.strip():
        issues.append("dataset_version_missing")
    published_at = _parse_datetime(manifest.get("publishedAt"))
    if published_at is None:
        issues.append("published_at_invalid")
    if manifest.get("recordCount") != len(sites):
        issues.append("snapshot_record_count_mismatch")

    sources = manifest.get("sources")
    if not isinstance(sources, list) or not sources:
        issues.append("source_metadata_missing")
    else:
        for source in sources:
            if not isinstance(source, dict):
                issues.append("source_metadata_invalid")
                continue
            if not _nonempty_string(source.get("name")):
                issues.append("source_name_missing")
            source_date = _parse_date(source.get("date"))
            if source_date is None:
                issues.append("source_date_invalid")
            elif published_at is not None and source_date > published_at.date():
                issues.append("source_date_in_future")

    full_snapshot = manifest.get("fullSnapshot")
    if not isinstance(full_snapshot, dict):
        issues.append("full_snapshot_manifest_missing")
        return
    if not _https_url(full_snapshot.get("url")):
        issues.append("full_snapshot_url_not_https")
    expected_checksum = full_snapshot.get("sha256")
    if not isinstance(expected_checksum, str) or expected_checksum != _sha256(
        release.full_snapshot_path
    ):
        issues.append("full_snapshot_checksum_mismatch")


def _validate_sites(
    sites: list[dict[str, object]],
    issues: list[str],
) -> None:
    if not sites:
        issues.append("empty_catalog")
    identifiers: list[str] = []
    for site in sites:
        identifier = site.get("id")
        if not _nonempty_string(identifier):
            issues.append("site_id_missing")
        else:
            assert isinstance(identifier, str)
            identifiers.append(identifier)
        if not (
            _nonempty_string(site.get("institutionCode"))
            and _nonempty_string(site.get("institutionName"))
        ):
            issues.append("required_institution_missing")
        if not _nonempty_string(site.get("displayAddress")):
            issues.append("required_address_missing")
        latitude = _number(site.get("latitude"))
        longitude = _number(site.get("longitude"))
        if (latitude is None) != (longitude is None):
            issues.append("coordinate_pair_incomplete")
        elif (
            latitude is not None
            and longitude is not None
            and not (20.5 <= latitude <= 26.5 and 118.0 <= longitude <= 123.0)
        ):
            issues.append("coordinate_out_of_taiwan_bounds")
    if len(identifiers) != len(set(identifiers)):
        issues.append("duplicate_site_id")


def _validate_quality_report(
    quality: dict[str, object],
    manifest: dict[str, object],
    sites: list[dict[str, object]],
    issues: list[str],
) -> None:
    if quality.get("datasetVersion") != manifest.get("datasetVersion"):
        issues.append("quality_dataset_version_mismatch")
    counts = quality.get("counts")
    decisions = quality.get("decisions")
    if not isinstance(counts, dict) or not isinstance(decisions, list):
        issues.append("quality_accounting_missing")
        return
    if (
        counts.get("raw") != len(decisions)
        or counts.get("parsed") != len(decisions)
        or counts.get("published") != len(sites)
    ):
        issues.append("quality_accounting_mismatch")
    merged = 0
    quarantined = 0
    for decision in decisions:
        if not isinstance(decision, dict):
            issues.append("quality_decision_invalid")
            continue
        outcome = decision.get("outcome")
        if outcome == "merged":
            merged += 1
        elif isinstance(outcome, str) and outcome.startswith("quarantined_"):
            quarantined += 1
            if not _nonempty_string(decision.get("reason")):
                issues.append("quarantine_reason_missing")
        elif outcome != "published":
            issues.append("primary_row_unaccounted")
    if counts.get("merged") != merged or counts.get("quarantined") != quarantined:
        issues.append("quality_accounting_mismatch")

    required_sections = (
        "retirements",
        "coordinateQuality",
        "sourceFreshness",
        "capabilityUnknownRates",
        "overrideExpiry",
    )
    if any(section not in quality for section in required_sections):
        issues.append("quality_metrics_missing")
        return

    coordinate_quality = quality.get("coordinateQuality")
    if not isinstance(coordinate_quality, dict):
        issues.append("quality_metrics_missing")
        return
    with_coordinates = sum(
        _number(site.get("latitude")) is not None
        and _number(site.get("longitude")) is not None
        for site in sites
    )
    expected_rate = with_coordinates / len(sites) if sites else 0.0
    if (
        coordinate_quality.get("total") != len(sites)
        or coordinate_quality.get("withCoordinates") != with_coordinates
        or coordinate_quality.get("coverageRate") != expected_rate
    ):
        issues.append("coordinate_quality_mismatch")


def _validate_deltas(
    manifest: dict[str, object],
    delta_paths: tuple[Path, ...],
    issues: list[str],
) -> None:
    deltas = manifest.get("deltas")
    if not isinstance(deltas, list) or len(deltas) != len(delta_paths):
        issues.append("delta_manifest_mismatch")
        return
    paths_by_name = {path.name: path for path in delta_paths}
    for delta in deltas:
        if not isinstance(delta, dict):
            issues.append("delta_schema_invalid")
            continue
        if delta.get("schemaVersion") != 1:
            issues.append("delta_schema_unsupported")
        url = delta.get("url")
        if not _https_url(url):
            issues.append("delta_url_not_https")
            continue
        assert isinstance(url, str)
        name = url.rsplit("/", maxsplit=1)[-1]
        path = paths_by_name.get(name)
        if path is None:
            issues.append("delta_artifact_missing")
            continue
        if delta.get("sha256") != _sha256(path):
            issues.append("delta_checksum_mismatch")
        operations = _read_gzip_documents(
            path,
            document_name="delta",
            issues=issues,
        )
        if operations is None:
            continue
        if delta.get("operationCount") != len(operations):
            issues.append("delta_operation_count_mismatch")
        for operation in operations:
            kind = operation.get("operation")
            if kind == "upsert":
                site = operation.get("site")
                if not isinstance(site, dict):
                    issues.append("delta_operation_invalid")
                else:
                    _validate_sites([site], issues)
            elif kind == "retire" and not (
                _nonempty_string(operation.get("id"))
                and _parse_date(operation.get("lastSeenDate")) is not None
            ):
                issues.append("delta_operation_invalid")
            elif kind not in {"upsert", "retire"}:
                issues.append("delta_operation_invalid")


def _sha256(path: Path) -> str:
    try:
        return hashlib.sha256(path.read_bytes()).hexdigest()
    except OSError:
        return ""


def _nonempty_string(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def _number(value: object) -> float | None:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return None
    return float(value)


def _https_url(value: object) -> bool:
    return isinstance(value, str) and value.startswith("https://")


def _parse_date(value: object) -> date | None:
    if not isinstance(value, str):
        return None
    try:
        return date.fromisoformat(value)
    except ValueError:
        return None


def _parse_datetime(value: object) -> datetime | None:
    if not isinstance(value, str):
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


__all__ = [
    "ArtifactPublisher",
    "CatalogPublicationWorkflow",
    "FilesystemArtifactPublisher",
    "PublicationResult",
    "PublicationStatus",
]
