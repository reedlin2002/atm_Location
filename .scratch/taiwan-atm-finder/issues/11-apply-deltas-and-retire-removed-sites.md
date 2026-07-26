# 11：套用差異更新並保留撤除據點

Status: ready-for-human

Type: AFK

User stories covered: 52, 53, 60, 62, 63, 64, 86, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓 pipeline 產生具有確切 from/to version 的 upsert／retire delta，App 從目前版本選擇有效 delta chain 並以 transaction 套用。撤除 ATM 不再出現在一般搜尋，但 last-known record 可供收藏查看；delta 缺失、過長或失效時自動回退 full snapshot。

## Acceptance criteria

- [x] 先以 RED 測試一個 upsert 與一個 retirement 套用後，搜尋與 retired lookup 呈現正確行為。
- [x] Delta 宣告 exact source/target versions、operation type、SHA-256 與 schema version。
- [x] App 拒絕有 gap、錯序、downgrade、duplicate operation 或 checksum 錯誤的 chain。
- [x] Chain 不可用或超過安全長度時改用 full snapshot。
- [x] Delta 在單一 transaction/staging 套用；中途失敗維持完整舊版本。
- [x] Retirement 保留 stable ID、last-known facts 與 last-seen date。
- [x] Pipeline delta round-trip 與 App importer contract tests 通過。
- [x] 實作逐步 Red-Green-Refactor，未以直接查 database row 作為唯一行為驗證。

## Blocked by

- [08：保留 ATM 據點身分並保守去重](./08-preserve-site-identity-and-deduplicate-conservatively.md)
- [10：安裝經驗證的完整 Catalog 更新](./10-install-a-verified-full-catalog-update.md)

## Implementation notes

- Pipeline 比對 prior/current stable IDs，產出 deterministic gzip NDJSON `upsert`／`retire` operations，manifest 宣告 schema/from/to/count/URL/SHA-256。
- App `CatalogDeltaImporter` 先完整驗證 chain，再以單一 Drift transaction 套用；任何中途錯誤 rollback。
- Gap、downgrade、checksum、duplicate operation、未知 operation、無效 retirement 與缺少 target 都會拒絕。
- Schema 6 的 retired row 保留 stable ID、完整 last-known facts、`active=false` 與 ISO `lastSeenDate`；一般搜尋排除，`findById(..., includeRetired:true)` 可查。
- Coordinator 從目前版本選唯一連續 chain；缺失、失效或超過上限時不下載 delta，改走已驗證 full snapshot。
- 測試以公開搜尋／retired lookup 驗證行為，另驗證 transaction rollback 與 metadata target version。
- 驗證：Python format/type gates 與 33/33 tests；Dart format、Flutter analyze 與 26/26 tests。
