from __future__ import annotations

import csv
import hashlib
import unicodedata
from dataclasses import dataclass, replace
from datetime import date
from pathlib import Path
from typing import Protocol
from urllib.request import Request, urlopen

from atm_catalog_builder.evidence import AtmEvidence, EvidenceAttribution
from atm_catalog_builder.fisc import DownloadedResource, RawSnapshot


@dataclass(frozen=True)
class ModaAtmRecord:
    source_record_id: str
    institution_code: str
    place_name: str
    county: str
    district: str
    display_address: str
    raw_place_category: str
    latitude: float
    longitude: float
    coordinate_was_swapped: bool
    service_type: str
    wheelchair_use: str
    audio_guidance: str
    wheelchair_environment: str
    audio_environment: str


@dataclass(frozen=True)
class AdaptedModaSource:
    source_name: str
    source_date: date
    raw_snapshot: RawSnapshot
    records: tuple[ModaAtmRecord, ...]
    quarantined_rows: tuple[SourceRowQuarantine, ...]


@dataclass(frozen=True)
class SourceRowQuarantine:
    row_number: int
    reason: str


@dataclass(frozen=True)
class OverlayDecision:
    source_record_id: str
    outcome: str
    canonical_source_record_id: str | None


@dataclass(frozen=True)
class ModaOverlayResult:
    source_name: str
    source_date: date
    overlay_source_name: str
    overlay_source_date: date
    normalized_coordinate_count: int
    records: tuple[AtmEvidence, ...]
    decisions: tuple[OverlayDecision, ...]


class BinaryDownloader(Protocol):
    def download(self, url: str) -> DownloadedResource:
        ...


class ModaSourceContractError(ValueError):
    pass


class ModaAtmAdapter:
    source_url = "https://www-api.moda.gov.tw/OpenData/Files/17380"
    _expected_fields = (
        "編號",
        "銀行代號",
        "分行代號",
        "所屬銀行簡稱",
        "裝設型態",
        "裝設地點類別",
        "裝設地點",
        "所屬縣市",
        "鄉鎮縣市別",
        "地址",
        "英文地址",
        "區碼",
        "聯絡電話",
        "服務型態",
        "符合輪椅使用",
        "視障語音",
        "符合輪椅使用且環境亦符合",
        "視障語音且環境亦符合",
        "備註",
        "座標經度",
        "座標緯度",
    )

    def __init__(self, downloader: BinaryDownloader | None = None) -> None:
        self._downloader = downloader or _UrlDownloader()

    def fetch(
        self,
        *,
        source_date: date,
        raw_archive_directory: Path,
    ) -> AdaptedModaSource:
        resource = self._downloader.download(self.source_url)
        checksum = hashlib.sha256(resource.content).hexdigest()
        snapshot_path = (
            raw_archive_directory
            / "moda-cash-atm"
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
            raise ModaSourceContractError(
                f"Unexpected MODA Content-Type: {resource.content_type}"
            )
        raw_lines = resource.content.splitlines()
        if not raw_lines:
            raise ModaSourceContractError("MODA source is empty")
        try:
            header = raw_lines[0].decode("cp950")
        except UnicodeDecodeError as error:
            raise ModaSourceContractError("MODA header is not valid CP950") from error
        try:
            fields = tuple(next(csv.reader([header])))
        except (csv.Error, StopIteration) as error:
            raise ModaSourceContractError("MODA header is not valid CSV") from error
        if fields != self._expected_fields:
            raise ModaSourceContractError("MODA 官方欄位與已審核 schema 不符")

        records: list[ModaAtmRecord] = []
        quarantined_rows: list[SourceRowQuarantine] = []
        for row_number, raw_line in enumerate(raw_lines[1:], start=2):
            if not raw_line.strip():
                continue
            try:
                decoded_line = raw_line.decode("cp950")
            except UnicodeDecodeError:
                quarantined_rows.append(
                    SourceRowQuarantine(
                        row_number=row_number,
                        reason="invalid_cp950",
                    )
                )
                continue
            try:
                values = next(csv.reader([decoded_line]))
            except (csv.Error, StopIteration):
                quarantined_rows.append(
                    SourceRowQuarantine(
                        row_number=row_number,
                        reason="invalid_csv",
                    )
                )
                continue
            if len(values) != len(fields):
                quarantined_rows.append(
                    SourceRowQuarantine(
                        row_number=row_number,
                        reason="invalid_csv",
                    )
                )
                continue
            try:
                record = _to_record(dict(zip(fields, values, strict=True)))
            except ModaSourceContractError:
                quarantined_rows.append(
                    SourceRowQuarantine(
                        row_number=row_number,
                        reason="invalid_record",
                    )
                )
                continue
            records.append(record)

        return AdaptedModaSource(
            source_name="moda-cash-atm",
            source_date=source_date,
            raw_snapshot=RawSnapshot(path=snapshot_path, sha256=checksum),
            records=tuple(records),
            quarantined_rows=tuple(quarantined_rows),
        )


class ModaAtmOverlay:
    def apply(
        self,
        *,
        backbone: object,
        overlay: AdaptedModaSource,
    ) -> ModaOverlayResult:
        backbone_records = tuple(getattr(backbone, "records"))
        address_index: dict[tuple[str, str], list[int]] = {}
        for index, record in enumerate(backbone_records):
            key = (
                record.institution_code,
                _normalize_identity_text(record.display_address),
            )
            address_index.setdefault(key, []).append(index)

        enriched_records = list(backbone_records)
        decisions = [
            OverlayDecision(
                source_record_id=f"row-{row.row_number}",
                outcome=f"quarantined_source_{row.reason}",
                canonical_source_record_id=None,
            )
            for row in overlay.quarantined_rows
        ]
        attribution = EvidenceAttribution(
            source_name=overlay.source_name,
            source_date=overlay.source_date,
            confidence="official_exact",
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
            if (
                candidate.latitude is not None
                and candidate.longitude is not None
                and (
                    candidate.latitude != overlay_record.latitude
                    or candidate.longitude != overlay_record.longitude
                )
            ):
                decisions.append(
                    OverlayDecision(
                        source_record_id=overlay_record.source_record_id,
                        outcome="quarantined",
                        canonical_source_record_id=candidate.source_record_id,
                    )
                )
                continue

            mapped_category = _place_category(overlay_record.raw_place_category)
            enriched_records[candidate_index] = replace(
                candidate,
                latitude=overlay_record.latitude,
                longitude=overlay_record.longitude,
                coordinate_evidence=attribution,
                place_category=(
                    mapped_category
                    if mapped_category != "unknown"
                    else candidate.place_category
                ),
                place_category_evidence=(
                    attribution
                    if mapped_category != "unknown"
                    else candidate.place_category_evidence
                ),
            )
            decisions.append(
                OverlayDecision(
                    source_record_id=overlay_record.source_record_id,
                    outcome=(
                        "enriched"
                        if mapped_category != "unknown"
                        else "enriched_unknown_place_category"
                    ),
                    canonical_source_record_id=candidate.source_record_id,
                )
            )

        return ModaOverlayResult(
            source_name=getattr(backbone, "source_name"),
            source_date=getattr(backbone, "source_date"),
            overlay_source_name=overlay.source_name,
            overlay_source_date=overlay.source_date,
            normalized_coordinate_count=sum(
                record.coordinate_was_swapped for record in overlay.records
            ),
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


def _to_record(row: dict[str, str | None]) -> ModaAtmRecord:
    county = _required(row, "所屬縣市")
    district = (row.get("鄉鎮縣市別") or "").strip()
    address = _required(row, "地址")
    display_address = address
    if not _normalize_identity_text(address).startswith(
        _normalize_identity_text(county)
    ):
        display_address = f"{county}{district}{address}"
    latitude, longitude, coordinate_was_swapped = _coordinates(row)
    return ModaAtmRecord(
        source_record_id=_required(row, "編號"),
        institution_code=_required(row, "銀行代號"),
        place_name=_required(row, "裝設地點"),
        county=county,
        district=district,
        display_address=display_address,
        raw_place_category=(row.get("裝設地點類別") or "").strip(),
        latitude=latitude,
        longitude=longitude,
        coordinate_was_swapped=coordinate_was_swapped,
        service_type=(row.get("服務型態") or "").strip(),
        wheelchair_use=(row.get("符合輪椅使用") or "").strip(),
        audio_guidance=(row.get("視障語音") or "").strip(),
        wheelchair_environment=(row.get("符合輪椅使用且環境亦符合") or "").strip(),
        audio_environment=(row.get("視障語音且環境亦符合") or "").strip(),
    )


def _coordinate_value(row: dict[str, str | None], field: str) -> float:
    value = _required(row, field).removeprefix("'")
    try:
        return float(value)
    except ValueError as error:
        raise ModaSourceContractError(f"MODA 座標格式錯誤: {field}") from error


def _coordinates(
    row: dict[str, str | None],
) -> tuple[float, float, bool]:
    source_longitude = _coordinate_value(row, "座標經度")
    source_latitude = _coordinate_value(row, "座標緯度")
    if -180 <= source_longitude <= 180 and -90 <= source_latitude <= 90:
        return source_latitude, source_longitude, False
    if -90 <= source_longitude <= 90 and -180 <= source_latitude <= 180:
        return source_longitude, source_latitude, True
    raise ModaSourceContractError("MODA 座標超出範圍")


def _required(row: dict[str, str | None], field: str) -> str:
    value = row.get(field)
    if value is None or not value.strip():
        raise ModaSourceContractError(f"MODA 必要值缺失: {field}")
    return value.strip()


def _place_category(value: str) -> str:
    normalized = _normalize_identity_text(value)
    return {
        "銀行": "bank",
        "金融機構": "bank",
        "分行": "bank",
        "便利商店": "convenience_store",
        "超商": "convenience_store",
        "郵局": "post_office",
    }.get(normalized, "unknown")


def _normalize_identity_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).replace("台", "臺")
    return "".join(normalized.split()).casefold()


__all__ = [
    "AdaptedModaSource",
    "ModaAtmAdapter",
    "ModaAtmOverlay",
    "ModaAtmRecord",
    "ModaOverlayResult",
    "ModaSourceContractError",
    "OverlayDecision",
    "SourceRowQuarantine",
]
