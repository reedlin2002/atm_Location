from __future__ import annotations

import gzip
import hashlib
import json
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any

from atm_catalog_builder import CatalogBuilder, SourceSnapshot

FIXTURES = Path(__file__).parent / "fixtures"


def test_pipeline_emits_exact_upsert_and_retire_delta_from_prior_catalog(
    tmp_path: Path,
) -> None:
    prior = CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=date(2026, 7, 25),
                path=FIXTURES / "official_atms.csv",
            )
        ],
        output_directory=tmp_path / "prior",
        dataset_version="2026.07.25",
        published_at=datetime(2026, 7, 25, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/2026.07.25",
    )
    current = CatalogBuilder().publish(
        sources=[
            SourceSnapshot(
                name="fixture-official-source",
                source_date=date(2026, 7, 26),
                path=FIXTURES / "official_atms_changed_removed.csv",
            )
        ],
        prior_catalog_path=prior.full_snapshot_path,
        output_directory=tmp_path / "current",
        dataset_version="2026.07.26",
        published_at=datetime(2026, 7, 26, 8, 0, tzinfo=timezone.utc),
        artifact_base_url="https://catalog.example.test/2026.07.26",
    )

    assert len(current.delta_paths) == 1
    (delta_path,) = current.delta_paths
    operations = _read_delta(delta_path)
    assert [operation["operation"] for operation in operations] == [
        "upsert",
        "retire",
    ]
    assert operations[0]["site"]["institutionCode"] == "004"
    assert operations[0]["site"]["displayAddress"].endswith("51 號")
    assert operations[1]["id"]
    assert operations[1]["lastSeenDate"] == "2026-07-25"

    manifest = json.loads(current.manifest_path.read_text(encoding="utf-8"))
    assert manifest["deltas"] == [
        {
            "schemaVersion": 1,
            "fromVersion": "2026.07.25",
            "toVersion": "2026.07.26",
            "operationCount": 2,
            "url": (
                "https://catalog.example.test/2026.07.26/"
                "delta-2026.07.25-to-2026.07.26.ndjson.gz"
            ),
            "sha256": hashlib.sha256(delta_path.read_bytes()).hexdigest(),
        }
    ]


def _read_delta(path: Path) -> list[dict[str, Any]]:
    with gzip.open(path, mode="rt", encoding="utf-8") as delta:
        return [json.loads(line) for line in delta if line.strip()]
