from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from typing import Protocol


@dataclass(frozen=True)
class EvidenceAttribution:
    source_name: str
    source_date: date
    confidence: str


@dataclass(frozen=True)
class CapabilityEvidence:
    capability: str
    status: str
    attribution: EvidenceAttribution


@dataclass(frozen=True)
class AtmEvidence:
    source_record_id: str
    institution_code: str
    institution_name: str
    place_name: str
    county: str
    display_address: str
    place_category: str
    latitude: float | None
    longitude: float | None
    coordinate_evidence: EvidenceAttribution | None = None
    place_category_evidence: EvidenceAttribution | None = None
    capabilities: tuple[CapabilityEvidence, ...] = ()
    location_type: str = "unknown"
    location_type_evidence: EvidenceAttribution | None = None


class EvidenceSource(Protocol):
    @property
    def source_name(self) -> str:
        ...

    @property
    def source_date(self) -> date:
        ...

    @property
    def records(self) -> tuple[AtmEvidence, ...]:
        ...


def merge_capability_evidence(
    existing: tuple[CapabilityEvidence, ...],
    incoming: CapabilityEvidence,
) -> tuple[tuple[CapabilityEvidence, ...], str]:
    current = next(
        (fact for fact in existing if fact.capability == incoming.capability),
        None,
    )
    if current is None:
        return (*existing, incoming), "enriched"
    if current == incoming:
        return existing, "confirmed_existing"

    current_key = (
        current.attribution.source_date,
        _capability_source_priority(current.attribution.source_name),
        current.attribution.source_name,
    )
    incoming_key = (
        incoming.attribution.source_date,
        _capability_source_priority(incoming.attribution.source_name),
        incoming.attribution.source_name,
    )
    if incoming_key <= current_key:
        return existing, "conflict_kept_existing"
    return (
        *(fact for fact in existing if fact.capability != incoming.capability),
        incoming,
    ), "conflict_replaced"


def _capability_source_priority(source_name: str) -> int:
    return {
        "fisc-wheelchair-accessibility-atm": 30,
        "fisc-visual-accessibility-atm": 30,
        "chunghwa-post-atm": 20,
    }.get(source_name, 0)


__all__ = [
    "AtmEvidence",
    "CapabilityEvidence",
    "EvidenceAttribution",
    "EvidenceSource",
    "merge_capability_evidence",
]
