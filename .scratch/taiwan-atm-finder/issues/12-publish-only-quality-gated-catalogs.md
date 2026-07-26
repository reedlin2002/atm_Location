# 12：只發布通過品質閘門的 Catalog

Status: ready-for-human

Type: AFK

User stories covered: 45, 46, 81, 82, 83, 84, 85, 87, 90

## Parent

[臺灣 ATM Finder PRD](../PRD.md)

## What to build

在專案 repository 建立可排程的 dry-run 與正式發布 workflow。只有來源、
schema、品質與 App contract 全部通過的 full/delta artifacts 才能成為不可變
release assets；固定 manifest 只能在所有資產上傳並回讀驗證成功後，切換到新
的公開版本。

## Acceptance criteria

- [x] 先寫 RED publication test，證明 source/schema/quality/upload 失敗時固定 manifest 不變。
- [x] Required institution/address、unique IDs、Taiwan coordinate bounds、artifact checksum 與 contract tests 都是 blocking gates。
- [x] 每一筆 primary row 都有 accounting：published、merged，或帶有 reason 的 quarantined。
- [x] Active site 數量變化超過 2%、material county drop 或 institution anomaly 必須取得明確 human approval。
- [x] 報告包含 source freshness、counts、merges、retirements、coordinate coverage/confidence、capability unknown rates 與 override expiry。
- [x] Full snapshot、deltas 與品質報告是 immutable release assets；fixed manifest 只指向已完整上傳並驗證的版本。
- [x] App contract test 直接使用目前 workflow 產生的 artifacts。
- [x] Scheduled dry-run 不需要發布權限；錯誤輸出不包含 exception message 或 secrets。
- [x] 以最小 gate 走完 Red-Green-Refactor，並讓完整自動化測試恢復 green。

## Verification

- `pipeline/tests/test_publication_gate.py`：7 個 publication gate tests。
- Python：40 tests passed。
- Python quality：Black、isort、mypy（production source 與新增 publication tests）通過。
- Flutter：26 tests passed；`flutter analyze` 無問題。
- CI artifact handoff：以 `CATALOG_RELEASE_DIRECTORY` 直接匯入 dry-run staged release，3 tests passed。
- Workflow YAML 已解析；dry-run CLI 回傳 `status: dry_run`。

## Human follow-up

- 在 dedicated GitHub repository 建立 `catalog-production` environment 並設定 required reviewers。
- 啟用 Actions/Release 權限後，先執行 `Catalog dry run`，再以一個測試版本執行 `Publish catalog`。
- 若 workflow 回報 `requires_human_approval`，審閱品質報告後，以 `approve_anomalies=true` 明確重跑。

## Blocked by

- [01：建立專用專案 Repository](./01-create-dedicated-project-repository.md)
- [04：匯入每日全國 ATM 主資料](./04-import-the-daily-national-atm-source.md)
- [05：疊加 MODA 座標與場所證據](./05-overlay-moda-coordinates-and-place-evidence.md)
- [06：疊加郵局與無障礙證據](./06-overlay-postal-and-accessibility-evidence.md)
- [09：地理編碼並審查未解析據點](./09-geocode-and-review-unresolved-sites.md)
- [11：套用 delta 並退役移除據點](./11-apply-deltas-and-retire-removed-sites.md)
