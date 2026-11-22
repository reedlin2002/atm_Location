"""Convert a full catalog snapshot into the App's bundled baseline asset.

The App ships ``app/assets/catalog/baseline_catalog.json`` so the first launch
works offline. It holds the same site documents as the published
``catalog-<version>.ndjson.gz`` snapshot, minus pipeline-only ``sourceKeys``.
"""

from __future__ import annotations

import argparse
import gzip
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

_PIPELINE_ONLY_FIELDS = ("sourceKeys",)


@dataclass(frozen=True)
class BundledCatalogSummary:
    total: int
    with_coordinates: int


def write_bundled_catalog(
    *,
    snapshot_path: Path,
    dataset_version: str,
    output_path: Path,
) -> BundledCatalogSummary:
    if not dataset_version.strip():
        raise ValueError("dataset_version must not be empty")
    sites = [
        _bundled_site(json.loads(line))
        for line in gzip.decompress(snapshot_path.read_bytes())
        .decode("utf-8")
        .splitlines()
        if line.strip()
    ]
    if not sites:
        raise ValueError("catalog snapshot has no sites")
    document = {
        "schemaVersion": 1,
        "datasetVersion": dataset_version,
        "sites": sites,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = output_path.with_name(f".{output_path.name}.tmp")
    temporary_path.write_text(
        json.dumps(document, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    temporary_path.replace(output_path)
    return BundledCatalogSummary(
        total=len(sites),
        with_coordinates=sum(
            1
            for site in sites
            if site.get("latitude") is not None and site.get("longitude") is not None
        ),
    )


def _bundled_site(site: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value for key, value in site.items() if key not in _PIPELINE_ONLY_FIELDS
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Write the App's bundled baseline catalog from a full snapshot"
    )
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--dataset-version", required=True)
    parser.add_argument("--output", type=Path, required=True)
    arguments = parser.parse_args()
    summary = write_bundled_catalog(
        snapshot_path=arguments.snapshot,
        dataset_version=arguments.dataset_version,
        output_path=arguments.output,
    )
    print(
        json.dumps(
            {"total": summary.total, "withCoordinates": summary.with_coordinates},
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
