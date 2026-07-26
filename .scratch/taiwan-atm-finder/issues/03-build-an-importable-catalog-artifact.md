# 03：產生 App 可匯入的 Catalog Artifact

Status: ready-for-human

Type: AFK

User stories covered: 41, 42, 59, 81, 82, 83, 88, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

完成第一個資料管線 tracer bullet：Python Catalog Builder 讀取小型官方來源 fixture，輸出版本化 manifest、gzip NDJSON full snapshot 與品質報告；App 使用正式 importer 讀取這個 artifact 並顯示其中 ATM。輸出必須以 ATM 據點為粒度，合併明確的同銀行同場所重複機器，但保留同地址的不同銀行。

## Acceptance criteria

- [x] 第一個 pytest 先以 RED 證明 fixture 尚不能產生有效 full snapshot、manifest 與品質報告。
- [x] Fixture 至少包含銀行、超商、郵局、同據點重複機器與同地址不同銀行。
- [x] Manifest 含 schema version、dataset version、published time、record count、來源日期、artifact URL 欄位與 SHA-256。
- [x] Full snapshot 為 gzip NDJSON，App 的 production importer 可匯入並透過公開 catalog 查詢取回資料。
- [x] 品質報告可交代每筆輸入是 published、merged 或 quarantined。
- [x] 同銀行同地址同場所可合併；不同銀行絕不合併。
- [x] Python 測試與 Flutter contract test 在同一次驗證中通過。
- [x] 實作遵守逐一 Red-Green-Refactor，不直接先寫完整 pipeline。

## Blocked by

- [02：離線顯示內建資料中的附近 ATM](./02-show-nearby-atms-from-bundled-data-offline.md)

## Comments

- 2026-07-25：完成 Python Catalog Builder tracer bullet，可發布 manifest、gzip NDJSON full snapshot 與逐筆 quality decisions；5 筆 fixture 產出 4 個 ATM 據點。
- 2026-07-25：Flutter contract test 在同一次執行呼叫 Python builder，再由 production importer 驗證 SHA-256、schema、筆數並原子匯入 Drift。
- 2026-07-25：Black、isort、mypy strict、pytest、Flutter 5/5 tests、Flutter analyze 與 Android debug build 均通過，移交人工驗收。
