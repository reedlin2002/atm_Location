from __future__ import annotations

import csv
import hashlib
import io
import unicodedata
from dataclasses import dataclass, replace
from datetime import date
from pathlib import Path
from typing import Protocol
from urllib.request import Request, urlopen

from atm_catalog_builder.evidence import (
    AtmEvidence,
    CapabilityEvidence,
    EvidenceAttribution,
    merge_capability_evidence,
)
from atm_catalog_builder.fisc import DownloadedResource, RawSnapshot
from atm_catalog_builder.moda import OverlayDecision


@dataclass(frozen=True)
class PositiveCapabilityRecord:
    source_record_id: str
    institution_code: str
    institution_name: str
    place_name: str
    county: str
    display_address: str


@dataclass(frozen=True)
class AdaptedPositiveCapabilitySource:
    source_name: str
    source_date: date
    capability: str
    raw_snapshot: RawSnapshot
    records: tuple[PositiveCapabilityRecord, ...]


@dataclass(frozen=True)
class PositiveCapabilityOverlayResult:
    source_name: str
    source_date: date
    overlay_source_name: str
    overlay_source_date: date
    capability: str
    records: tuple[AtmEvidence, ...]
    decisions: tuple[OverlayDecision, ...]


class BinaryDownloader(Protocol):
    def download(self, url: str) -> DownloadedResource:
        ...


class AccessibilitySourceContractError(ValueError):
    pass


class FiscPositiveCapabilityAdapter:
    _expected_fields = (
        "裝設金融機構代號",
        "裝設金融機構名稱",
        "裝設地點",
        "裝設縣市",
        "裝設地址",
    )

    def __init__(
        self,
        *,
        source_name: str,
        source_url: str,
        capability: str,
        downloader: BinaryDownloader | None = None,
    ) -> None:
        self.source_name = source_name
        self.source_url = source_url
        self.capability = capability
        self._downloader = downloader or _UrlDownloader()

    def fetch(
        self,
        *,
        source_date: date,
        raw_archive_directory: Path,
    ) -> AdaptedPositiveCapabilitySource:
        resource = self._downloader.download(self.source_url)
        checksum = hashlib.sha256(resource.content).hexdigest()
        snapshot_path = (
            raw_archive_directory
            / self.source_name
            / source_date.isoformat()
            / f"{checksum}.csv"
        )
        snapshot_path.parent.mkdir(parents=True, exist_ok=True)
        snapshot_path.write_bytes(resource.content)

        media_type = resource.content_type.partition(";")[0].strip().lower()
        if media_type not in {
            "text/csv",
            "application/csv",
            "application/octet-stream",
        }:
            raise AccessibilitySourceContractError(
                f"Unexpected FISC accessibility Content-Type: "
                f"{resource.content_type}"
            )
        try:
            decoded = resource.content.decode("utf-8-sig")
        except UnicodeDecodeError as error:
            raise AccessibilitySourceContractError(
                "FISC accessibility source is not valid UTF-8"
            ) from error
        reader = csv.DictReader(io.StringIO(decoded, newline=""))
        if tuple(reader.fieldnames or ()) != self._expected_fields:
            raise AccessibilitySourceContractError("FISC 無障礙官方欄位與已審核 schema 不符")
        records = tuple(_to_record(row) for row in reader)
        return AdaptedPositiveCapabilitySource(
            source_name=self.source_name,
            source_date=source_date,
            capability=self.capability,
            raw_snapshot=RawSnapshot(path=snapshot_path, sha256=checksum),
            records=records,
        )


class FiscPositiveCapabilityOverlay:
    def apply(
        self,
        *,
        backbone: object,
        overlay: AdaptedPositiveCapabilitySource,
    ) -> PositiveCapabilityOverlayResult:
        backbone_records = tuple(getattr(backbone, "records"))
        address_index: dict[tuple[str, str], list[int]] = {}
        for index, record in enumerate(backbone_records):
            key = (
                record.institution_code,
                _normalize_identity_text(record.display_address),
            )
            address_index.setdefault(key, []).append(index)

        enriched_records = list(backbone_records)
        decisions: list[OverlayDecision] = []
        attribution = EvidenceAttribution(
            source_name=overlay.source_name,
            source_date=overlay.source_date,
            confidence="official_positive",
        )
        for overlay_record in overlay.records:
            candidates = address_index.get(
                (
                    overlay_record.institution_code,
                    _normalize_identity_text(overlay_record.display_address),
                ),
                [],
            )
            if len(candidates) != 1:
                decisions.append(
                    OverlayDecision(
                        source_record_id=overlay_record.source_record_id,
                        outcome="quarantined",
                        canonical_source_record_id=None,
                    )
                )
                continue
            candidate_index = candidates[0]
            candidate = enriched_records[candidate_index]
            capability = CapabilityEvidence(
                capability=overlay.capability,
                status="confirmed",
                attribution=attribution,
            )
            merged_capabilities, outcome = merge_capability_evidence(
                candidate.capabilities,
                capability,
            )
            enriched_records[candidate_index] = replace(
                candidate,
                capabilities=merged_capabilities,
            )
            decisions.append(
                OverlayDecision(
                    source_record_id=overlay_record.source_record_id,
                    outcome=outcome,
                    canonical_source_record_id=candidate.source_record_id,
                )
            )

        return PositiveCapabilityOverlayResult(
            source_name=getattr(backbone, "source_name"),
            source_date=getattr(backbone, "source_date"),
            overlay_source_name=overlay.source_name,
            overlay_source_date=overlay.source_date,
            capability=overlay.capability,
            records=tuple(enriched_records),
            decisions=tuple(decisions),
        )


class _UrlDownloader:
    def download(self, url: str) -> DownloadedResource:
        request = Request(
            url,
            headers={"User-Agent": "Taiwan-ATM-Finder-Catalog/1.0"},
        )
        with urlopen(request) as response:
            return DownloadedResource(
                content=response.read(),
                content_type=response.headers.get_content_type(),
            )


def _to_record(row: dict[str, str | None]) -> PositiveCapabilityRecord:
    institution_code = _required(row, "裝設金融機構代號")
    institution_name = _required(row, "裝設金融機構名稱")
    place_name = _required(row, "裝設地點")
    county = _required(row, "裝設縣市")
    display_address = _required(row, "裝設地址")
    identity = "|".join(
        (
            institution_code,
            institution_name,
            place_name,
            county,
            display_address,
        )
    )
    return PositiveCapabilityRecord(
        source_record_id=hashlib.sha256(identity.encode("utf-8")).hexdigest(),
        institution_code=institution_code,
        institution_name=institution_name,
        place_name=place_name,
        county=county,
        display_address=display_address,
    )


def _required(row: dict[str, str | None], field: str) -> str:
    value = row.get(field)
    if value is None or not value.strip():
        raise AccessibilitySourceContractError(f"FISC 無障礙必要值缺失: {field}")
    return value.strip()


def _normalize_identity_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).replace("台", "臺")
    return "".join(normalized.split()).casefold()


__all__ = [
    "AccessibilitySourceContractError",
    "AdaptedPositiveCapabilitySource",
    "FiscPositiveCapabilityAdapter",
    "FiscPositiveCapabilityOverlay",
    "PositiveCapabilityOverlayResult",
    "PositiveCapabilityRecord",
]
