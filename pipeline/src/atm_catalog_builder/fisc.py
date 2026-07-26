from __future__ import annotations

import csv
import hashlib
import io
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Protocol
from urllib.request import urlopen

from atm_catalog_builder.evidence import AtmEvidence


@dataclass(frozen=True)
class DownloadedResource:
    content: bytes
    content_type: str


@dataclass(frozen=True)
class RawSnapshot:
    path: Path
    sha256: str


@dataclass(frozen=True)
class AdaptedAtmSource:
    source_name: str
    source_date: date
    raw_snapshot: RawSnapshot
    records: tuple[AtmEvidence, ...]


class BinaryDownloader(Protocol):
    def download(self, url: str) -> DownloadedResource:
        ...


class SourceContractError(ValueError):
    pass


class FiscNationalAtmAdapter:
    source_url = "https://www.fisc.com.tw/TC/OPENDATA/A2_Location.csv"
    _expected_fields = (
        "裝設金融機構代號/總機構代碼",
        "裝設金融機構名稱",
        "裝設地點",
        "裝設縣市",
        "裝設地址",
    )

    def __init__(self, downloader: BinaryDownloader | None = None) -> None:
        self._downloader = downloader or _UrlDownloader()

    def fetch(
        self,
        *,
        source_date: date,
        raw_archive_directory: Path,
    ) -> AdaptedAtmSource:
        resource = self._downloader.download(self.source_url)
        checksum = hashlib.sha256(resource.content).hexdigest()
        snapshot_path = (
            raw_archive_directory
            / "fisc-national-atm"
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
            raise SourceContractError(
                f"Unexpected FISC Content-Type: {resource.content_type}"
            )
        try:
            decoded = resource.content.decode("utf-8-sig")
        except UnicodeDecodeError as error:
            raise SourceContractError("FISC source is not valid UTF-8") from error
        reader = csv.DictReader(io.StringIO(decoded, newline=""))
        if tuple(reader.fieldnames or ()) != self._expected_fields:
            raise SourceContractError("FISC 官方欄位與已審核 schema 不符")
        records = tuple(_to_evidence(row) for row in reader)
        return AdaptedAtmSource(
            source_name="fisc-national-atm",
            source_date=source_date,
            raw_snapshot=RawSnapshot(path=snapshot_path, sha256=checksum),
            records=records,
        )


class _UrlDownloader:
    def download(self, url: str) -> DownloadedResource:
        with urlopen(url) as response:
            return DownloadedResource(
                content=response.read(),
                content_type=response.headers.get_content_type(),
            )


def _to_evidence(row: dict[str, str | None]) -> AtmEvidence:
    institution_code = _required(row, "裝設金融機構代號/總機構代碼")
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
    return AtmEvidence(
        source_record_id=hashlib.sha256(identity.encode("utf-8")).hexdigest(),
        institution_code=institution_code,
        institution_name=institution_name,
        place_name=place_name,
        county=county,
        display_address=display_address,
        place_category="unknown",
        latitude=None,
        longitude=None,
    )


def _required(row: dict[str, str | None], field: str) -> str:
    value = row.get(field)
    if value is None or not value.strip():
        raise SourceContractError(f"FISC 必要值缺失: {field}")
    return value.strip()


__all__ = [
    "AdaptedAtmSource",
    "AtmEvidence",
    "DownloadedResource",
    "FiscNationalAtmAdapter",
    "RawSnapshot",
    "SourceContractError",
]
