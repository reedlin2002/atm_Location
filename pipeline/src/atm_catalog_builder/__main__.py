from __future__ import annotations

import argparse
import json
from datetime import date, datetime
from pathlib import Path

from atm_catalog_builder import CatalogBuilder, CatalogRelease, SourceSnapshot
from atm_catalog_builder.evidence import EvidenceSource
from atm_catalog_builder.fisc import DownloadedResource, FiscNationalAtmAdapter
from atm_catalog_builder.publication import (
    CatalogPublicationWorkflow,
    FilesystemArtifactPublisher,
)


def main() -> None:
    parser = argparse.ArgumentParser(description="Build an ATM catalog release")
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument(
        "--source-format",
        choices=("generic", "fisc"),
        default="generic",
    )
    parser.add_argument("--source-name", required=True)
    parser.add_argument("--source-date", type=date.fromisoformat, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--dataset-version", required=True)
    parser.add_argument("--published-at", type=_parse_datetime, required=True)
    parser.add_argument("--artifact-base-url", required=True)
    parser.add_argument("--prior-catalog", type=Path)
    publication_mode = parser.add_mutually_exclusive_group()
    publication_mode.add_argument("--dry-run", action="store_true")
    publication_mode.add_argument("--publish-directory", type=Path)
    parser.add_argument("--human-approved", action="store_true")
    arguments = parser.parse_args()

    def build_release() -> CatalogRelease:
        source: SourceSnapshot | EvidenceSource = (
            FiscNationalAtmAdapter(downloader=_FileDownloader(arguments.source)).fetch(
                source_date=arguments.source_date,
                raw_archive_directory=arguments.output.parent / "raw",
            )
            if arguments.source_format == "fisc"
            else SourceSnapshot(
                name=arguments.source_name,
                source_date=arguments.source_date,
                path=arguments.source,
            )
        )
        return CatalogBuilder().publish(
            sources=[source],
            prior_catalog_path=arguments.prior_catalog,
            output_directory=arguments.output,
            dataset_version=arguments.dataset_version,
            published_at=arguments.published_at,
            artifact_base_url=arguments.artifact_base_url,
        )

    if not arguments.dry_run and arguments.publish_directory is None:
        build_release()
        return

    publisher = (
        FilesystemArtifactPublisher(arguments.publish_directory)
        if arguments.publish_directory is not None
        else None
    )
    result = CatalogPublicationWorkflow(publisher=publisher).run(
        build_release=build_release,
        dry_run=arguments.dry_run,
        prior_catalog_path=arguments.prior_catalog,
        human_approved=arguments.human_approved,
    )
    print(
        json.dumps(
            {
                "status": result.status,
                "issues": result.issues,
                "uploadedAssets": result.uploaded_assets,
            },
            sort_keys=True,
        )
    )
    if result.status not in {"dry_run", "published"}:
        raise SystemExit(2)


def _parse_datetime(value: str) -> datetime:
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


class _FileDownloader:
    def __init__(self, path: Path) -> None:
        self._path = path

    def download(self, url: str) -> DownloadedResource:
        return DownloadedResource(
            content=self._path.read_bytes(),
            content_type="text/csv; charset=utf-8",
        )


if __name__ == "__main__":
    main()
