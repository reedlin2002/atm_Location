# 10：安裝經驗證的完整 Catalog 更新

Status: ready-for-human

Type: AFK

User stories covered: 46, 59, 60, 62, 63, 64, 81, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓 App 每天最多檢查一次 manifest，下載完整 catalog snapshot 至 staging，驗證 HTTPS 回應、schema、dataset version、SHA-256 與基本資料完整性後才一次切換。任何下載、驗證、匯入或開啟失敗都繼續使用上一個 good catalog。

## Acceptance criteria

- [x] 先以 RED 測試 valid full snapshot 更新成功，而 checksum 錯誤時畫面仍顯示舊 catalog。
- [x] 同一天重開 App 不重複檢查；可替換 clock 讓行為可測。
- [x] 不接受 unsupported schema、duplicate IDs、非遞增版本或與 manifest 不符的 record count。
- [x] 匯入使用 transaction/staging，active catalog 只在新 catalog 可成功開啟後切換。
- [x] 至少保留一個 previous good catalog 供 rollback。
- [x] 更新結果透過小型公開狀態表示 up-to-date、updated、using-old-data 或 incompatible。
- [x] 網路不可用不阻止 bundled／last-good 離線搜尋。
- [x] Tests 使用真實暫存 database 與 fake HTTP/clock，並完成 Red-Green-Refactor。

## Blocked by

- [02：離線顯示內建資料中的附近 ATM](./02-show-nearby-atms-from-bundled-data-offline.md)
- [03：產生 App 可匯入的 Catalog Artifact](./03-build-an-importable-catalog-artifact.md)

## Implementation notes

- `CatalogUpdateCoordinator` 只接受 HTTPS manifest/snapshot 與允許的 media type，並委派 importer 驗證 schema、version、SHA-256、record count、duplicate ID 與資料完整性。
- `lastUpdateCheckAt` 以可替換 UTC clock 記錄；同日再次呼叫不發網路請求，隔日才重查。
- Importer 在 Drift batch transaction 內切換；驗證／下載／開啟失敗回傳 `CatalogUsingOldData` 並保留 active rows。
- Drift schema 5 保存一份 previous-good manifest + compressed snapshot，可由公開 `rollbackToPreviousGood()` 回復。
- 公開結果型別：`CatalogUpToDate`、`CatalogUpdated`、`CatalogUsingOldData`、`CatalogIncompatible`、`CatalogRolledBack`。
- 真實暫存 SQLite + fake HTTP/clock 測試涵蓋 valid update、checksum、HTTPS、schema、downgrade、duplicate IDs、record count、daily check、offline 與 rollback。
- 驗證：Dart format、Flutter analyze 通過；20/20 Flutter tests。
