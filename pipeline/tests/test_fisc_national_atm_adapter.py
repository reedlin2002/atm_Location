from __future__ import annotations

import hashlib
from datetime import date
from pathlib import Path

import pytest

from atm_catalog_builder.fisc import (
    DownloadedResource,
    FiscNationalAtmAdapter,
    SourceContractError,
)

FIXTURE = Path(__file__).parent / "fixtures" / "fisc_a2_location.csv"
EXTRA_COLUMN_FIXTURE = (
    Path(__file__).parent / "fixtures" / "fisc_a2_location_extra_column.csv"
)
MISSING_REQUIRED_FIXTURE = (
    Path(__file__).parent / "fixtures" / "fisc_a2_location_missing_required.csv"
)


def test_daily_fisc_source_is_archived_and_mapped_to_common_evidence(
    tmp_path: Path,
) -> None:
    downloaded = FIXTURE.read_bytes()
    result = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="application/octet-stream",
            )
        )
    ).fetch(
        source_date=date(2026, 7, 24),
        raw_archive_directory=tmp_path,
    )

    checksum = hashlib.sha256(downloaded).hexdigest()
    assert result.raw_snapshot.path == (
        tmp_path / "fisc-national-atm" / "2026-07-24" / f"{checksum}.csv"
    )
    assert result.raw_snapshot.path.read_bytes() == downloaded
    assert result.raw_snapshot.sha256 == checksum
    assert result.source_name == "fisc-national-atm"
    assert result.source_date == date(2026, 7, 24)
    assert [
        (
            record.institution_code,
            record.institution_name,
            record.place_name,
            record.county,
            record.display_address,
            record.place_category,
            record.latitude,
            record.longitude,
        )
        for record in result.records
    ] == [
        (
            "004",
            "臺灣銀行",
            "館前分行",
            "臺北市",
            "臺北市中正區館前路49號",
            "unknown",
            None,
            None,
        ),
        (
            "822",
            "中國信託",
            "7-ELEVEN台北站前門市",
            "臺北市",
            "臺北市中正區忠孝西路一段49號",
            "unknown",
            None,
            None,
        ),
        (
            "812",
            "台新銀行",
            "新光三越台南新天地",
            "臺南市",
            "臺南市中西區西門路一段658號",
            "unknown",
            None,
            None,
        ),
    ]


def test_unreviewed_fisc_schema_change_fails_closed_after_raw_archival(
    tmp_path: Path,
) -> None:
    downloaded = EXTRA_COLUMN_FIXTURE.read_bytes()
    adapter = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv; charset=utf-8",
            )
        )
    )

    with pytest.raises(SourceContractError, match="欄位"):
        adapter.fetch(
            source_date=date(2026, 7, 24),
            raw_archive_directory=tmp_path,
        )

    archived_files = list(tmp_path.rglob("*.csv"))
    assert len(archived_files) == 1
    assert archived_files[0].read_bytes() == downloaded


def test_non_csv_fisc_response_fails_closed(tmp_path: Path) -> None:
    downloaded = b"<html>temporary upstream error</html>"
    adapter = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/html; charset=utf-8",
            )
        )
    )

    with pytest.raises(SourceContractError, match="Content-Type"):
        adapter.fetch(
            source_date=date(2026, 7, 24),
            raw_archive_directory=tmp_path,
        )


def test_non_utf8_fisc_response_fails_closed(tmp_path: Path) -> None:
    downloaded = b"\xff\xfe\x00\x81"
    adapter = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    )

    with pytest.raises(SourceContractError, match="UTF-8"):
        adapter.fetch(
            source_date=date(2026, 7, 24),
            raw_archive_directory=tmp_path,
        )


def test_missing_required_fisc_value_fails_closed(tmp_path: Path) -> None:
    downloaded = MISSING_REQUIRED_FIXTURE.read_bytes()
    adapter = FiscNationalAtmAdapter(
        downloader=_StaticDownloader(
            DownloadedResource(
                content=downloaded,
                content_type="text/csv",
            )
        )
    )

    with pytest.raises(SourceContractError, match="必要值"):
        adapter.fetch(
            source_date=date(2026, 7, 24),
            raw_archive_directory=tmp_path,
        )


class _StaticDownloader:
    def __init__(self, resource: DownloadedResource) -> None:
        self._resource = resource

    def download(self, url: str) -> DownloadedResource:
        return self._resource
