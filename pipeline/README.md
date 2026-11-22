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

## 官方來源與內建資料

財金公司全國清單沒有座標。加上 `--official-overlays`（需搭配
`--source-format fisc`）時，builder 會再下載下列來源，依「金融機構代號＋正規化地址」
完全比對後疊加：

- 數位發展部「114年發放現金ATM裝設地點明細」：座標、場所類型
- 中華郵政「全國郵局ATM分佈」：郵局 ATM 座標與服務
- 財金公司視障、輪椅無障礙 ATM 清單：只加正面證據，沒列到的維持未知

App 內建資料 `app/assets/catalog/baseline_catalog.json` 由
`scripts/update-baseline-catalog.ps1` 重新產生：它跑完整建置，再用
`python -m atm_catalog_builder.baseline` 去掉 `sourceKeys` 轉成 App 格式。
更新後依腳本印出的筆數修改 `app/test/bundled_catalog_test.dart`。
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
