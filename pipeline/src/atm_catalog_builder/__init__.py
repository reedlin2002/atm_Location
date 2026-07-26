from __future__ import annotations

import csv
import gzip
import hashlib
import json
import unicodedata
from collections import Counter
from dataclasses import dataclass
from datetime import date, datetime, timezone
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any, Iterable

from atm_catalog_builder.accessibility import PositiveCapabilityOverlayResult
from atm_catalog_builder.evidence import (
    AtmEvidence,
    CapabilityEvidence,
    EvidenceAttribution,
    EvidenceSource,
)
from atm_catalog_builder.geocoding import GeocodingResult, ManualOverrideResult
from atm_catalog_builder.moda import ModaOverlayResult
from atm_catalog_builder.post import PostOverlayResult


@dataclass(frozen=True)
class SourceSnapshot:
    name: str
    source_date: date
    path: Path


@dataclass(frozen=True)
class CatalogRelease:
    manifest_path: Path
    full_snapshot_path: Path
    quality_report_path: Path
    delta_paths: tuple[Path, ...] = ()


class CatalogBuilder:
    def publish(
        self,
        *,
        sources: Iterable[SourceSnapshot | EvidenceSource],
        prior_catalog_path: Path | None = None,
        output_directory: Path,
        dataset_version: str,
        published_at: datetime,
        artifact_base_url: str,
    ) -> CatalogRelease:
        source_list = list(sources)
        output_directory.mkdir(parents=True, exist_ok=True)

        canonical_sites: dict[str, dict[str, Any]] = {}
        decisions: list[dict[str, str]] = []
        evidence_overlays: dict[str, dict[str, Any]] = {}
        raw_count = 0
        merged_count = 0
        quarantined_count = 0
        prior_sites = _read_prior_catalog(prior_catalog_path)
        prior_source_keys = {
            (str(key["source"]), str(key["recordId"])): str(site["id"])
            for site in prior_sites
            for key in site.get("sourceKeys", [])
        }
        prior_identities = {
            _site_document_identity(site): str(site["id"]) for site in prior_sites
        }
        assigned_ids: dict[str, str] = {}
        review_candidates: list[dict[str, str]] = []

        for source in source_list:
            if isinstance(
                source,
                (
                    ModaOverlayResult,
                    PostOverlayResult,
                    PositiveCapabilityOverlayResult,
                    GeocodingResult,
                    ManualOverrideResult,
                ),
            ):
                evidence_overlays[
                    source.overlay_source_name
                ] = _overlay_quality_document(source)
            records = _source_records(source)
            raw_count += len(records)
            source_name = _source_name(source)
            for record in records:
                identity = _site_identity(record)
                source_key = (source_name, record.source_record_id)
                continuity = "deterministic"
                canonical_id = prior_source_keys.get(source_key)
                if canonical_id is not None:
                    continuity = "source_key"
                else:
                    canonical_id = prior_identities.get(identity)
                    if canonical_id is not None:
                        continuity = "exact_identity"
                if canonical_id is None:
                    candidate_id = _fuzzy_continuity_candidate(
                        record,
                        prior_sites,
                    )
                    if candidate_id is not None:
                        continuity = "fuzzy_candidate_review"
                        review_candidates.append(
                            {
                                "sourceRecordId": record.source_record_id,
                                "candidateCanonicalId": candidate_id,
                                "reason": "fuzzy_text_continuity",
                            }
                        )
                if canonical_id is None:
                    canonical_id = _canonical_id(identity)
                if (
                    canonical_id in assigned_ids
                    and assigned_ids[canonical_id] != identity
                ):
                    canonical_id = _canonical_id(identity)
                    continuity = "continuity_conflict_review"
                if identity in canonical_sites:
                    existing_site = canonical_sites[identity]
                    _add_source_key(
                        existing_site,
                        source_name=source_name,
                        source_record_id=record.source_record_id,
                    )
                    if _coordinates_conflict(existing_site, record):
                        quarantined_count += 1
                        existing_site["latitude"] = None
                        existing_site["longitude"] = None
                        existing_site["coordinateEvidence"] = None
                        outcome = "quarantined_coordinate_conflict"
                        review_candidates.append(
                            {
                                "sourceRecordId": record.source_record_id,
                                "candidateCanonicalId": canonical_id,
                                "reason": "coordinate_conflict",
                            }
                        )
                    else:
                        merged_count += 1
                        outcome = "merged"
                else:
                    canonical_sites[identity] = _canonical_site(
                        record,
                        canonical_id,
                        source_name,
                    )
                    assigned_ids[canonical_id] = identity
                    outcome = "published"
                decisions.append(
                    _primary_decision_document(
                        outcome=outcome,
                        source=source_name,
                        source_record_id=record.source_record_id,
                        canonical_id=canonical_id,
                        id_continuity=continuity,
                    )
                )

        sites = sorted(canonical_sites.values(), key=lambda site: str(site["id"]))
        snapshot_name = f"catalog-{dataset_version}.ndjson.gz"
        snapshot_path = output_directory / snapshot_name
        snapshot_path.write_bytes(gzip.compress(_ndjson_bytes(sites), mtime=0))
        delta_paths: tuple[Path, ...] = ()
        delta_documents: list[dict[str, Any]] = []
        if prior_catalog_path is not None:
            from_version = _prior_version_from_path(prior_catalog_path)
            delta_name = f"delta-{from_version}-to-{dataset_version}.ndjson.gz"
            delta_path = output_directory / delta_name
            operations = _delta_operations(
                prior_sites=prior_sites,
                current_sites=sites,
                last_seen_date=_version_date(from_version),
            )
            delta_path.write_bytes(gzip.compress(_ndjson_bytes(operations), mtime=0))
            delta_paths = (delta_path,)
            delta_documents.append(
                {
                    "schemaVersion": 1,
                    "fromVersion": from_version,
                    "toVersion": dataset_version,
                    "operationCount": len(operations),
                    "url": (f"{artifact_base_url.rstrip('/')}/{delta_name}"),
                    "sha256": hashlib.sha256(delta_path.read_bytes()).hexdigest(),
                }
            )

        manifest_path = output_directory / "manifest.json"
        manifest = {
            "schemaVersion": 1,
            "datasetVersion": dataset_version,
            "publishedAt": _utc_wire_value(published_at),
            "recordCount": len(sites),
            "sources": [
                {
                    "name": _source_name(source),
                    "date": source.source_date.isoformat(),
                }
                for source in source_list
            ],
            "fullSnapshot": {
                "url": f"{artifact_base_url.rstrip('/')}/{snapshot_name}",
                "sha256": hashlib.sha256(snapshot_path.read_bytes()).hexdigest(),
            },
            "deltas": delta_documents,
        }
        _write_json(manifest_path, manifest)

        quality_report_path = (
            output_directory / f"quality-report-{dataset_version}.json"
        )
        quality_report: dict[str, Any] = {
            "datasetVersion": dataset_version,
            "counts": {
                "raw": raw_count,
                "parsed": raw_count,
                "published": len(sites),
                "merged": merged_count,
                "quarantined": quarantined_count,
            },
            "decisions": decisions,
            "retirements": [
                {
                    "canonicalId": str(site["id"]),
                    "outcome": "retired",
                }
                for site in prior_sites
                if str(site["id"])
                not in {
                    str(current_site["id"]) for current_site in canonical_sites.values()
                }
            ],
            "reviewCandidates": review_candidates,
            "coordinateQuality": _coordinate_quality_document(
                sites,
                source_list,
            ),
            "sourceFreshness": _source_freshness_document(
                source_list,
                published_at,
            ),
            "capabilityUnknownRates": _capability_unknown_rates(sites),
            "overrideExpiry": _override_expiry_document(
                source_list,
                published_at.astimezone(timezone.utc).date(),
            ),
        }
        if evidence_overlays:
            quality_report["evidenceOverlays"] = evidence_overlays
        _write_json(quality_report_path, quality_report)

        return CatalogRelease(
            manifest_path=manifest_path,
            full_snapshot_path=snapshot_path,
            quality_report_path=quality_report_path,
            delta_paths=delta_paths,
        )


def _primary_decision_document(
    *,
    outcome: str,
    source: str,
    source_record_id: str,
    canonical_id: str,
    id_continuity: str,
) -> dict[str, str]:
    document = {
        "source": source,
        "sourceRecordId": source_record_id,
        "outcome": outcome,
        "canonicalId": canonical_id,
        "idContinuity": id_continuity,
    }
    if outcome.startswith("quarantined_"):
        document["reason"] = outcome.removeprefix("quarantined_")
    return document


def _source_freshness_document(
    sources: list[SourceSnapshot | EvidenceSource],
    published_at: datetime,
) -> list[dict[str, Any]]:
    publication_date = published_at.astimezone(timezone.utc).date()
    return [
        {
            "name": _source_name(source),
            "sourceDate": source.source_date.isoformat(),
            "ageDaysAtPublication": (publication_date - source.source_date).days,
        }
        for source in sources
    ]


def _capability_unknown_rates(
    sites: list[dict[str, Any]],
) -> dict[str, dict[str, int | float]]:
    capability_names = (
        "audioGuidance",
        "deposit",
        "visualAccessibility",
        "wheelchairAccessibility",
    )
    total = len(sites)
    result: dict[str, dict[str, int | float]] = {}
    for capability in capability_names:
        unknown = sum(
            not isinstance(site.get("capabilities"), dict)
            or not isinstance(site["capabilities"].get(capability), dict)
            or site["capabilities"][capability].get("status") == "unknown"
            for site in sites
        )
        result[capability] = {
            "unknown": unknown,
            "total": total,
            "rate": unknown / total if total else 0.0,
        }
    return result


def _override_expiry_document(
    sources: list[SourceSnapshot | EvidenceSource],
    publication_date: date,
) -> dict[str, int | str | None]:
    decisions = [
        decision
        for source in sources
        if isinstance(source, ManualOverrideResult)
        for decision in source.decisions
    ]
    active = sum(
        decision.outcome == "manual_override_applied" for decision in decisions
    )
    expired = sum(
        decision.outcome == "manual_override_expired" for decision in decisions
    )
    future_expiries = sorted(
        decision.expiry
        for decision in decisions
        if decision.expiry is not None and decision.expiry >= publication_date
    )
    return {
        "active": active,
        "expired": expired,
        "nearestExpiry": (future_expiries[0].isoformat() if future_expiries else None),
    }


def _source_name(source: SourceSnapshot | EvidenceSource) -> str:
    if isinstance(source, SourceSnapshot):
        return source.name
    return source.source_name


def _source_records(
    source: SourceSnapshot | EvidenceSource,
) -> tuple[AtmEvidence, ...]:
    if not isinstance(source, SourceSnapshot):
        return source.records
    with source.path.open(newline="", encoding="utf-8-sig") as source_file:
        return tuple(_fixture_evidence(row) for row in csv.DictReader(source_file))


def _fixture_evidence(row: dict[str, str | None]) -> AtmEvidence:
    return AtmEvidence(
        source_record_id=_required(row, "source_record_id"),
        institution_code=_required(row, "institution_code").strip(),
        institution_name=_required(row, "institution_name").strip(),
        place_name=_required(row, "place_name").strip(),
        county=(row.get("county") or "").strip(),
        display_address=_required(row, "address").strip(),
        place_category=_required(row, "place_category").strip(),
        latitude=float(_required(row, "latitude")),
        longitude=float(_required(row, "longitude")),
    )


def _site_identity(record: AtmEvidence) -> str:
    return "|".join(
        (
            record.institution_code,
            _normalize_identity_text(record.display_address),
            _normalize_identity_text(record.place_name),
        )
    )


def _canonical_id(identity: str) -> str:
    digest = hashlib.sha256(identity.encode("utf-8")).hexdigest()
    return f"atm-{digest[:20]}"


def _canonical_site(
    record: AtmEvidence,
    canonical_id: str,
    source_name: str,
) -> dict[str, Any]:
    return {
        "id": canonical_id,
        "institutionCode": record.institution_code,
        "institutionName": record.institution_name,
        "placeName": record.place_name,
        "placeCategory": record.place_category,
        "county": record.county,
        "displayAddress": record.display_address,
        "latitude": record.latitude,
        "longitude": record.longitude,
        "coordinateEvidence": _attribution_document(record.coordinate_evidence),
        "placeCategoryEvidence": _attribution_document(record.place_category_evidence),
        "capabilities": _capabilities_document(record.capabilities),
        "locationType": record.location_type,
        "locationTypeEvidence": _attribution_document(record.location_type_evidence),
        "sourceKeys": [
            {
                "source": source_name,
                "recordId": record.source_record_id,
            }
        ],
    }


def _add_source_key(
    site: dict[str, Any],
    *,
    source_name: str,
    source_record_id: str,
) -> None:
    source_keys = site["sourceKeys"]
    assert isinstance(source_keys, list)
    key = {
        "source": source_name,
        "recordId": source_record_id,
    }
    if key not in source_keys:
        source_keys.append(key)
        source_keys.sort(key=lambda item: (str(item["source"]), str(item["recordId"])))


def _coordinates_conflict(
    site: dict[str, Any],
    record: AtmEvidence,
) -> bool:
    existing_latitude = site["latitude"]
    existing_longitude = site["longitude"]
    return (
        existing_latitude is not None
        and existing_longitude is not None
        and record.latitude is not None
        and record.longitude is not None
        and (
            float(existing_latitude) != record.latitude
            or float(existing_longitude) != record.longitude
        )
    )


def _read_prior_catalog(path: Path | None) -> list[dict[str, Any]]:
    if path is None:
        return []
    with gzip.open(path, mode="rt", encoding="utf-8") as snapshot:
        return [json.loads(line) for line in snapshot if line.strip()]


def _prior_version_from_path(path: Path) -> str:
    name = path.name
    prefix = "catalog-"
    suffix = ".ndjson.gz"
    if not name.startswith(prefix) or not name.endswith(suffix):
        raise ValueError("Prior catalog filename must be catalog-<version>.ndjson.gz")
    version = name[len(prefix) : -len(suffix)]
    if not version:
        raise ValueError("Prior catalog filename has no version")
    return version


def _version_date(version: str) -> str:
    candidate = version[:10].replace(".", "-")
    try:
        date.fromisoformat(candidate)
    except ValueError as error:
        raise ValueError("Delta source version must begin with an ISO date") from error
    return candidate


def _delta_operations(
    *,
    prior_sites: list[dict[str, Any]],
    current_sites: list[dict[str, Any]],
    last_seen_date: str,
) -> list[dict[str, Any]]:
    prior_by_id = {str(site["id"]): site for site in prior_sites}
    current_by_id = {str(site["id"]): site for site in current_sites}
    operations = [
        {
            "operation": "upsert",
            "site": site,
        }
        for canonical_id, site in current_by_id.items()
        if prior_by_id.get(canonical_id) != site
    ]
    operations.extend(
        {
            "operation": "retire",
            "id": canonical_id,
            "lastSeenDate": last_seen_date,
        }
        for canonical_id in prior_by_id.keys() - current_by_id.keys()
    )
    return sorted(
        operations,
        key=lambda operation: (
            0 if operation["operation"] == "upsert" else 1,
            str(operation.get("id") or operation["site"]["id"]),
        ),
    )


def _site_document_identity(site: dict[str, Any]) -> str:
    return "|".join(
        (
            str(site["institutionCode"]),
            _normalize_identity_text(str(site["displayAddress"])),
            _normalize_identity_text(str(site["placeName"])),
        )
    )


def _fuzzy_continuity_candidate(
    record: AtmEvidence,
    prior_sites: list[dict[str, Any]],
) -> str | None:
    address = _normalize_identity_text(record.display_address)
    place = _normalize_identity_text(record.place_name)
    candidates = [
        (
            SequenceMatcher(
                None,
                address,
                _normalize_identity_text(str(site["displayAddress"])),
            ).ratio(),
            str(site["id"]),
        )
        for site in prior_sites
        if str(site["institutionCode"]) == record.institution_code
        and _normalize_identity_text(str(site["placeName"])) == place
    ]
    eligible = sorted(
        (candidate for candidate in candidates if candidate[0] >= 0.85),
        reverse=True,
    )
    if not eligible:
        return None
    if len(eligible) > 1 and eligible[0][0] == eligible[1][0]:
        return None
    return eligible[0][1]


def _attribution_document(
    attribution: EvidenceAttribution | None,
) -> dict[str, str] | None:
    if attribution is None:
        return None
    return {
        "source": attribution.source_name,
        "date": attribution.source_date.isoformat(),
        "confidence": attribution.confidence,
    }


def _capabilities_document(
    capabilities: tuple[CapabilityEvidence, ...],
) -> dict[str, dict[str, Any]]:
    names = {
        "audio_guidance": "audioGuidance",
        "deposit": "deposit",
        "visual_accessibility": "visualAccessibility",
        "wheelchair_accessibility": "wheelchairAccessibility",
    }
    return {
        names.get(fact.capability, fact.capability): {
            "status": fact.status,
            "evidence": _attribution_document(fact.attribution),
        }
        for fact in sorted(
            capabilities,
            key=lambda item: item.capability,
        )
    }


def _overlay_quality_document(
    source: (
        ModaOverlayResult
        | PostOverlayResult
        | PositiveCapabilityOverlayResult
        | GeocodingResult
        | ManualOverrideResult
    ),
) -> dict[str, Any]:
    outcomes = [decision.outcome for decision in source.decisions]
    if isinstance(source, GeocodingResult):
        return {
            "sourceDate": source.overlay_source_date.isoformat(),
            "counts": {
                "raw": len(outcomes),
                "accepted": outcomes.count("geocoded_exact"),
                "quarantined": sum(
                    outcome.startswith("quarantined") for outcome in outcomes
                ),
                "unresolved": sum(
                    outcome.startswith("unresolved") for outcome in outcomes
                ),
            },
            "decisions": [
                {
                    "sourceRecordId": decision.source_record_id,
                    "outcome": decision.outcome,
                }
                for decision in source.decisions
            ],
        }
    if isinstance(source, ManualOverrideResult):
        return {
            "sourceDate": source.overlay_source_date.isoformat(),
            "counts": {
                "raw": len(outcomes),
                "applied": outcomes.count("manual_override_applied"),
                "expired": outcomes.count("manual_override_expired"),
            },
            "decisions": [
                {
                    "sourceRecordId": decision.source_record_id,
                    "outcome": decision.outcome,
                    "reason": decision.reason,
                    "evidence": decision.evidence,
                    "reviewer": decision.reviewer,
                    "reviewDate": decision.review_date.isoformat(),
                    "expiry": (
                        decision.expiry.isoformat()
                        if decision.expiry is not None
                        else None
                    ),
                }
                for decision in source.decisions
            ],
        }
    if not isinstance(source, ModaOverlayResult):
        return {
            "sourceDate": source.overlay_source_date.isoformat(),
            "counts": {
                "raw": len(source.decisions),
                "enriched": sum(
                    outcome
                    in {
                        "enriched",
                        "confirmed_existing",
                        "conflict_replaced",
                    }
                    for outcome in outcomes
                ),
                "quarantined": sum(
                    outcome.startswith("quarantined") for outcome in outcomes
                ),
                "conflicts": sum(
                    outcome.startswith("conflict") for outcome in outcomes
                ),
            },
            "decisions": [
                {
                    "sourceRecordId": decision.source_record_id,
                    "outcome": decision.outcome,
                    "canonicalSourceRecordId": (decision.canonical_source_record_id),
                }
                for decision in source.decisions
            ],
        }
    return {
        "sourceDate": source.overlay_source_date.isoformat(),
        "counts": {
            "raw": len(source.decisions),
            "enriched": sum(outcome.startswith("enriched") for outcome in outcomes),
            "quarantined": sum(
                outcome.startswith("quarantined") for outcome in outcomes
            ),
            "unknownPlaceCategory": outcomes.count("enriched_unknown_place_category"),
            "normalizedCoordinates": source.normalized_coordinate_count,
        },
        "decisions": [
            {
                "sourceRecordId": decision.source_record_id,
                "outcome": decision.outcome,
                "canonicalSourceRecordId": decision.canonical_source_record_id,
            }
            for decision in source.decisions
        ],
    }


def _coordinate_quality_document(
    sites: list[dict[str, Any]],
    sources: list[SourceSnapshot | EvidenceSource],
) -> dict[str, Any]:
    with_coordinates = [
        site
        for site in sites
        if site["latitude"] is not None and site["longitude"] is not None
    ]
    confidence_counts = Counter(
        (
            str(site["coordinateEvidence"]["confidence"])
            if site["coordinateEvidence"] is not None
            else "unknown"
        )
        for site in sites
    )
    unresolved_counts = Counter(
        decision.outcome
        for source in sources
        if isinstance(source, GeocodingResult)
        for decision in source.decisions
        if decision.outcome.startswith(("quarantined", "unresolved"))
    )
    return {
        "total": len(sites),
        "withCoordinates": len(with_coordinates),
        "coverageRate": (len(with_coordinates) / len(sites) if sites else 0.0),
        "byConfidence": dict(sorted(confidence_counts.items())),
        "unresolvedReasons": dict(sorted(unresolved_counts.items())),
    }


def _normalize_identity_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value)
    return "".join(normalized.split()).casefold()


def _required(row: dict[str, str | None], column: str) -> str:
    value = row.get(column)
    if value is None or not value.strip():
        raise ValueError(f"Missing required column value: {column}")
    return value


def _ndjson_bytes(rows: Iterable[dict[str, Any]]) -> bytes:
    content = "".join(
        f"{json.dumps(row, ensure_ascii=False, sort_keys=True, separators=(',', ':'))}\n"
        for row in rows
    )
    return content.encode("utf-8")


def _utc_wire_value(value: datetime) -> str:
    if value.tzinfo is None:
        raise ValueError("published_at must include a timezone")
    utc_value = value.astimezone(timezone.utc).replace(microsecond=0)
    return utc_value.isoformat().replace("+00:00", "Z")


def _write_json(path: Path, document: dict[str, Any]) -> None:
    path.write_text(
        json.dumps(document, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


__all__ = ["CatalogBuilder", "CatalogRelease", "SourceSnapshot"]
