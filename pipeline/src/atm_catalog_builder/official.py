"""Layer every reviewed official overlay onto the FISC national backbone.

The FISC national list has no coordinates. Coordinates come from the MODA cash
ATM list and Chunghwa Post; accessibility comes from the two FISC positive
lists. Each overlay matches exact institution code plus normalized address and
never invents evidence for rows it cannot match.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path

from atm_catalog_builder.accessibility import BinaryDownloader as _CapabilityDownloader
from atm_catalog_builder.accessibility import (
    FiscPositiveCapabilityAdapter,
    FiscPositiveCapabilityOverlay,
    PositiveCapabilityOverlayResult,
)
from atm_catalog_builder.fisc import AdaptedAtmSource
from atm_catalog_builder.moda import BinaryDownloader as _ModaDownloader
from atm_catalog_builder.moda import ModaAtmAdapter, ModaAtmOverlay
from atm_catalog_builder.post import BinaryDownloader as _PostDownloader
from atm_catalog_builder.post import ChunghwaPostAtmAdapter, ChunghwaPostAtmOverlay

FISC_VISUAL_ACCESSIBILITY_URL = "https://www.fisc.com.tw/TC/OPENDATA/A103_Location.csv"
FISC_WHEELCHAIR_ACCESSIBILITY_URL = (
    "https://www.fisc.com.tw/TC/OPENDATA/A102_Location.csv"
)


@dataclass(frozen=True)
class OfficialOverlayDownloaders:
    """Optional downloaders, injected by tests; ``None`` uses the official URL."""

    moda: _ModaDownloader | None = None
    post: _PostDownloader | None = None
    visual_accessibility: _CapabilityDownloader | None = None
    wheelchair_accessibility: _CapabilityDownloader | None = None


def apply_official_overlays(
    *,
    backbone: AdaptedAtmSource,
    source_date: date,
    raw_archive_directory: Path,
    downloaders: OfficialOverlayDownloaders | None = None,
) -> PositiveCapabilityOverlayResult:
    selected = downloaders or OfficialOverlayDownloaders()

    moda = ModaAtmAdapter(downloader=selected.moda).fetch(
        source_date=source_date,
        raw_archive_directory=raw_archive_directory,
    )
    with_moda = ModaAtmOverlay().apply(backbone=backbone, overlay=moda)

    post = ChunghwaPostAtmAdapter(downloader=selected.post).fetch(
        source_date=source_date,
        raw_archive_directory=raw_archive_directory,
    )
    with_post = ChunghwaPostAtmOverlay().apply(backbone=with_moda, overlay=post)

    visual = FiscPositiveCapabilityAdapter(
        source_name="fisc-visual-accessibility-atm",
        source_url=FISC_VISUAL_ACCESSIBILITY_URL,
        capability="visual_accessibility",
        downloader=selected.visual_accessibility,
    ).fetch(source_date=source_date, raw_archive_directory=raw_archive_directory)
    with_visual = FiscPositiveCapabilityOverlay().apply(
        backbone=with_post,
        overlay=visual,
    )

    wheelchair = FiscPositiveCapabilityAdapter(
        source_name="fisc-wheelchair-accessibility-atm",
        source_url=FISC_WHEELCHAIR_ACCESSIBILITY_URL,
        capability="wheelchair_accessibility",
        downloader=selected.wheelchair_accessibility,
    ).fetch(source_date=source_date, raw_archive_directory=raw_archive_directory)
    return FiscPositiveCapabilityOverlay().apply(
        backbone=with_visual,
        overlay=wheelchair,
    )
