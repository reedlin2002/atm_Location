from __future__ import annotations

import json
import unicodedata
from dataclasses import dataclass, replace
from datetime import date
from pathlib import Path
from typing import Mapping, Protocol

from atm_catalog_builder.evidence import AtmEvidence, EvidenceAttribution


@dataclass(frozen=True)
class GeocodeCandidate:
    returned_address: str
    latitude: float
    longitude: float
    match_type: str


@dataclass(frozen=True)
class GeocodeDecision:
    source_record_id: str
    outcome: str


@dataclass(frozen=True)
class GeocodingResult:
    source_name: str
    source_date: date
    overlay_source_name: str
    overlay_source_date: date
    records: tuple[AtmEvidence, ...]
    decisions: tuple[GeocodeDecision, ...]


@dataclass(frozen=True)
class ManualCoordinateOverride:
    target: str
    fact: str
    latitude: float
    longitude: float
    reason: str
    evidence: str
    reviewer: str
    review_date: date
    expiry: date | None


@dataclass(frozen=True)
class ManualOverrideDecision:
    source_record_id: str
    outcome: str
    reason: str
    evidence: str
    reviewer: str
    review_date: date
    expiry: date | None


@dataclass(frozen=True)
class ManualOverrideResult:
    source_name: str
    source_date: date
    overlay_source_name: str
    overlay_source_date: date
    records: tuple[AtmEvidence, ...]
    decisions: tuple[ManualOverrideDecision, ...]


@dataclass(frozen=True)
class ManualCoordinateOverrideSet:
    overrides: tuple[ManualCoordinateOverride, ...]

    @classmethod
    def from_json_file(cls, path: Path) -> ManualCoordinateOverrideSet:
        document = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(document, list):
            raise ValueError("Manual coordinate overrides must be a list")
        overrides = tuple(_manual_override(item) for item in document)
        targets = [override.target for override in overrides]
        if len(targets) != len(set(targets)):
            raise ValueError("Duplicate manual coordinate override target")
        return cls(overrides=overrides)

    def apply(
        self,
        *,
        backbone: object,
        as_of: date,
    ) -> ManualOverrideResult:
        overrides_by_target = {override.target: override for override in self.overrides}
        records: list[AtmEvidence] = []
        decisions: list[ManualOverrideDecision] = []
        for record in tuple(getattr(backbone, "records")):
            override = overrides_by_target.get(record.source_record_id)
            if override is None:
                records.append(record)
                continue
            if override.expiry is not None and override.expiry < as_of:
                records.append(record)
                decisions.append(_manual_decision(override, "manual_override_expired"))
                continue
            records.append(
                replace(
                    record,
                    latitude=override.latitude,
                    longitude=override.longitude,
                    coordinate_evidence=EvidenceAttribution(
                        source_name="manual-reviewed-override",
                        source_date=override.review_date,
                        confidence="manual_reviewed",
                    ),
                )
            )
            decisions.append(_manual_decision(override, "manual_override_applied"))

        source_date = max(
            (override.review_date for override in self.overrides),
            default=as_of,
        )
        return ManualOverrideResult(
            source_name=getattr(backbone, "source_name"),
            source_date=getattr(backbone, "source_date"),
            overlay_source_name="manual-reviewed-override",
            overlay_source_date=source_date,
            records=tuple(records),
            decisions=tuple(decisions),
        )


class AddressGeocoder(Protocol):
    @property
    def source_name(self) -> str:
        ...

    def geocode(self, address: str) -> tuple[GeocodeCandidate, ...]:
        ...


class IncrementalGeocoder:
    def apply(
        self,
        *,
        backbone: object,
        provider: AddressGeocoder,
        source_date: date,
        prior_addresses_by_source_record_id: Mapping[str, str] | None = None,
    ) -> GeocodingResult:
        records: list[AtmEvidence] = []
        decisions: list[GeocodeDecision] = []
        prior_addresses = prior_addresses_by_source_record_id or {}
        for record in tuple(getattr(backbone, "records")):
            prior_address = prior_addresses.get(record.source_record_id)
            address_changed = prior_address is not None and _normalize_address(
                prior_address
            ) != _normalize_address(record.display_address)
            if (
                record.latitude is not None
                and record.longitude is not None
                and not address_changed
            ):
                records.append(record)
                decisions.append(
                    GeocodeDecision(
                        source_record_id=record.source_record_id,
                        outcome="retained_existing_coordinate",
                    )
                )
                continue

            candidates = provider.geocode(record.display_address)
            if not candidates:
                records.append(record)
                decisions.append(
                    GeocodeDecision(
                        source_record_id=record.source_record_id,
                        outcome="unresolved_no_result",
                    )
                )
                continue
            if len(candidates) != 1:
                records.append(record)
                decisions.append(
                    GeocodeDecision(
                        source_record_id=record.source_record_id,
                        outcome="quarantined_conflicting",
                    )
                )
                continue

            candidate = candidates[0]
            if candidate.match_type != "exact" or _normalize_address(
                candidate.returned_address
            ) != _normalize_address(record.display_address):
                records.append(record)
                decisions.append(
                    GeocodeDecision(
                        source_record_id=record.source_record_id,
                        outcome="quarantined_fuzzy",
                    )
                )
                continue
            if not _is_in_taiwan(candidate.latitude, candidate.longitude):
                records.append(record)
                decisions.append(
                    GeocodeDecision(
                        source_record_id=record.source_record_id,
                        outcome="quarantined_out_of_bounds",
                    )
                )
                continue

            records.append(
                replace(
                    record,
                    latitude=candidate.latitude,
                    longitude=candidate.longitude,
                    coordinate_evidence=EvidenceAttribution(
                        source_name=provider.source_name,
                        source_date=source_date,
                        confidence="licensed_exact",
                    ),
                )
            )
            decisions.append(
                GeocodeDecision(
                    source_record_id=record.source_record_id,
                    outcome="geocoded_exact",
                )
            )

        return GeocodingResult(
            source_name=getattr(backbone, "source_name"),
            source_date=getattr(backbone, "source_date"),
            overlay_source_name=provider.source_name,
            overlay_source_date=source_date,
            records=tuple(records),
            decisions=tuple(decisions),
        )


def _normalize_address(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).replace("台", "臺")
    return "".join(normalized.split()).casefold()


def _is_in_taiwan(latitude: float, longitude: float) -> bool:
    return 20.0 <= latitude <= 27.0 and 118.0 <= longitude <= 123.0


def _manual_override(document: object) -> ManualCoordinateOverride:
    if not isinstance(document, dict):
        raise ValueError("Manual coordinate override must be an object")
    required_text = (
        "target",
        "fact",
        "reason",
        "evidence",
        "reviewer",
        "reviewDate",
    )
    values = {field: document.get(field) for field in required_text}
    if any(
        not isinstance(value, str) or not value.strip() for value in values.values()
    ):
        raise ValueError("Manual coordinate override has missing text fields")
    if values["fact"] != "coordinates":
        raise ValueError("Manual override fact must be coordinates")
    try:
        latitude = float(document["latitude"])
        longitude = float(document["longitude"])
        review_date = date.fromisoformat(str(values["reviewDate"]))
        expiry_value = document.get("expiry")
        expiry = (
            date.fromisoformat(expiry_value) if isinstance(expiry_value, str) else None
        )
    except (KeyError, TypeError, ValueError) as error:
        raise ValueError("Manual coordinate override has invalid values") from error
    if not _is_in_taiwan(latitude, longitude):
        raise ValueError("Manual coordinate override is outside Taiwan")
    return ManualCoordinateOverride(
        target=str(values["target"]),
        fact="coordinates",
        latitude=latitude,
        longitude=longitude,
        reason=str(values["reason"]),
        evidence=str(values["evidence"]),
        reviewer=str(values["reviewer"]),
        review_date=review_date,
        expiry=expiry,
    )


def _manual_decision(
    override: ManualCoordinateOverride,
    outcome: str,
) -> ManualOverrideDecision:
    return ManualOverrideDecision(
        source_record_id=override.target,
        outcome=outcome,
        reason=override.reason,
        evidence=override.evidence,
        reviewer=override.reviewer,
        review_date=override.review_date,
        expiry=override.expiry,
    )


__all__ = [
    "AddressGeocoder",
    "GeocodeCandidate",
    "GeocodeDecision",
    "GeocodingResult",
    "IncrementalGeocoder",
    "ManualCoordinateOverride",
    "ManualCoordinateOverrideSet",
    "ManualOverrideDecision",
    "ManualOverrideResult",
]
