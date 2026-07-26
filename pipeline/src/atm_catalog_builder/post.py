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
class PostAtmRecord:
    source_record_id: str
    place_name: str
    county: str
    district: str
    display_address: str
    latitude: float
    longitude: float
    is_offsite: bool
    has_deposit: bool
    has_audio_guidance: bool


@dataclass(frozen=True)
class AdaptedPostAtmSource:
    source_name: str
    source_date: date
    raw_snapshot: RawSnapshot
    records: tuple[PostAtmRecord, ...]


@dataclass(frozen=True)
class PostOverlayResult:
    source_name: str
    source_date: date
    overlay_source_name: str
    overlay_source_date: date
    records: tuple[AtmEvidence, ...]
    decisions: tuple[OverlayDecision, ...]


class BinaryDownloader(Protocol):
    def download(self, url: str) -> DownloadedResource:
        ...


class PostSourceContractError(ValueError):
    pass


class ChunghwaPostAtmAdapter:
    source_url = (
        "https://www.post.gov.tw/post/internet/Templates/"
        "getOpenDataFile.jsp?vkey=85422E4D-6133-4404-851E-08EC2077A162"
    )
    _expected_fields = (
        "縣市",
        "鄉鎮市區",
        "儲匯局號",
        "局名",
        "聯絡電話",
        "郵局地址",
        "經度",
        "緯度",
        "ATM",
        "具存款",
        "具補摺",
        "自動補摺機",
        "提領200元",
        "具視障語音",
        "是否為局外ATM",
        "縣市排序代號",
    )

    def __init__(self, downloader: BinaryDownloader | None = None) -> None:
        self._downloader = downloader or _UrlDownloader()

    def fetch(
        self,
        *,
        source_date: date,
        raw_archive_directory: Path,
    ) -> AdaptedPostAtmSource:
        resource = self._downloader.download(self.source_url)
        checksum = hashlib.sha256(resource.content).hexdigest()
        snapshot_path = (
            raw_archive_directory
            / "chunghwa-post-atm"
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
            raise PostSourceContractError(
                f"Unexpected Chunghwa Post Content-Type: {resource.content_type}"
            )
        try:
            decoded = resource.content.decode("utf-8-sig")
        except UnicodeDecodeError as error:
            raise PostSourceContractError(
                "Chunghwa Post source is not valid UTF-8"
            ) from error
        reader = csv.DictReader(io.StringIO(decoded, newline=""))
        if tuple(reader.fieldnames or ()) != self._expected_fields:
            raise PostSourceContractError("中華郵政官方欄位與已審核 schema 不符")
        records = tuple(
            _to_record(row)
            for row in reader
            if (row.get("ATM") or "").strip().upper() == "O"
        )
        return AdaptedPostAtmSource(
            source_name="chunghwa-post-atm",
            source_date=source_date,
            raw_snapshot=RawSnapshot(path=snapshot_path, sha256=checksum),
            records=records,
        )


class ChunghwaPostAtmOverlay:
    def apply(
        self,
        *,
        backbone: object,
        overlay: AdaptedPostAtmSource,
    ) -> PostOverlayResult:
        backbone_records = tuple(getattr(backbone, "records"))
        address_index: dict[str, list[int]] = {}
        for index, record in enumerate(backbone_records):
            if record.institution_code != "700":
                continue
            address_index.setdefault(
                _normalize_identity_text(record.display_address),
                [],
            ).append(index)

        enriched_records = list(backbone_records)
        decisions: list[OverlayDecision] = []
        attribution = EvidenceAttribution(
            source_name=overlay.source_name,
            source_date=overlay.source_date,
            confidence="official_positive",
        )
        for overlay_record in overlay.records:
            candidates = address_index.get(
                _normalize_identity_text(overlay_record.display_address),
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
            positive_capabilities = candidate.capabilities
            capability_outcomes: list[str] = []
            for capability, is_confirmed in (
                ("deposit", overlay_record.has_deposit),
                ("audio_guidance", overlay_record.has_audio_guidance),
            ):
                if not is_confirmed:
                    continue
                positive_capabilities, capability_outcome = merge_capability_evidence(
                    positive_capabilities,
                    CapabilityEvidence(
                        capability=capability,
                        status="confirmed",
                        attribution=attribution,
                    ),
                )
                capability_outcomes.append(capability_outcome)
            enriched_records[candidate_index] = replace(
                candidate,
                latitude=overlay_record.latitude,
                longitude=overlay_record.longitude,
                coordinate_evidence=EvidenceAttribution(
                    source_name=overlay.source_name,
                    source_date=overlay.source_date,
                    confidence="official_exact",
                ),
                capabilities=positive_capabilities,
                location_type=("off_site" if overlay_record.is_offsite else "on_site"),
                location_type_evidence=EvidenceAttribution(
                    source_name=overlay.source_name,
                    source_date=overlay.source_date,
                    confidence="official_exact",
                ),
            )
            decisions.append(
                OverlayDecision(
                    source_record_id=overlay_record.source_record_id,
                    outcome=(
                        "conflict_replaced"
                        if "conflict_replaced" in capability_outcomes
                        else "enriched"
                    ),
                    canonical_source_record_id=candidate.source_record_id,
                )
            )

        return PostOverlayResult(
            source_name=getattr(backbone, "source_name"),
            source_date=getattr(backbone, "source_date"),
            overlay_source_name=overlay.source_name,
            overlay_source_date=overlay.source_date,
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


def _to_record(row: dict[str, str | None]) -> PostAtmRecord:
    county = _required(row, "縣市")
    district = _required(row, "鄉鎮市區")
    address = _required(row, "郵局地址")
    display_address = address
    if not _normalize_identity_text(address).startswith(
        _normalize_identity_text(county)
    ):
        display_address = f"{county}{district}{address}"
    branch_number = (row.get("儲匯局號") or "").strip()
    source_record_id = (
        branch_number
        or hashlib.sha256(
            f"{_required(row, '局名')}|{display_address}".encode("utf-8")
        ).hexdigest()
    )
    try:
        longitude = float(_required(row, "經度"))
        latitude = float(_required(row, "緯度"))
    except ValueError as error:
        raise PostSourceContractError("中華郵政座標不是有效數字") from error
    if not -90 <= latitude <= 90 or not -180 <= longitude <= 180:
        raise PostSourceContractError("中華郵政座標超出合法範圍")
    return PostAtmRecord(
        source_record_id=source_record_id,
        place_name=_required(row, "局名"),
        county=county,
        district=district,
        display_address=display_address,
        latitude=latitude,
        longitude=longitude,
        is_offsite=(row.get("是否為局外ATM") or "").strip() == "局外",
        has_deposit=(row.get("具存款") or "").strip().upper() == "O",
        has_audio_guidance=(row.get("具視障語音") or "").strip().upper() == "O",
    )


def _required(row: dict[str, str | None], field: str) -> str:
    value = row.get(field)
    if value is None or not value.strip():
        raise PostSourceContractError(f"中華郵政必要值缺失: {field}")
    return value.strip()


def _normalize_identity_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).replace("台", "臺")
    return "".join(normalized.split()).casefold()


__all__ = [
    "AdaptedPostAtmSource",
    "ChunghwaPostAtmAdapter",
    "ChunghwaPostAtmOverlay",
    "PostAtmRecord",
    "PostOverlayResult",
    "PostSourceContractError",
]
