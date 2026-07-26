# ATM Catalog Pipeline

Python 3.11 的 ATM Catalog Builder。它把來源快照轉成 App 可驗證及匯入的：

- `manifest.json`
- `catalog-<dataset-version>.ndjson.gz`
- `quality-report-<dataset-version>.json`

## 驗證

```powershell
python -m black --check src tests
python -m isort --check-only src tests
python -m mypy
python -m pytest
```

Flutter 的 `catalog_artifact_contract_test.dart` 會在同一次測試中執行 builder，
再用 production importer 匯入真實 Drift／SQLite catalog。
## Publication safety

`--dry-run` builds and validates a staged release without needing publication
credentials. `--publish-directory <path>` additionally writes immutable full,
delta, and quality-report assets, reads them back, and replaces the fixed
`manifest.json` only after every verification succeeds.

Changes above 2% of active sites, material county drops, and institution
anomalies stop with `requires_human_approval`. A reviewer may rerun with
`--human-approved` after checking the quality report. Build, contract, quality,
or upload failures never replace the prior fixed manifest, and exception text
is not emitted because it may contain credentials.

The scheduled read-only dry run lives in
`.github/workflows/catalog-dry-run.yml`. The manual production workflow creates
a draft GitHub release, uploads and downloads immutable assets for checksum
verification, uploads `manifest.json` last, and only then makes the release the
latest public version. Configure required reviewers on its
`catalog-production` environment before enabling it.
