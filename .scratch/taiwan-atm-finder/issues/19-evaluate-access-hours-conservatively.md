# 19：保守判斷 ATM 場所可進入狀態

Status: ready-for-human

Type: AFK

User stories covered: 25, 31, 32, 39, 40, 44, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

根據明確的 24 小時證據或可靠 schedule，以 Asia/Taipei clock 計算 confirmed open／closed；資料不足則保持 unknown。預設排序為 open、unknown、closed，再依距離；「目前營業」與「24 小時」篩選只納入 confirmed evidence，不從超商名稱推論營業。

## Acceptance criteria

- [x] 先以 RED 測試同距離的 open、unknown、closed 據點依指定順序呈現。
- [x] `open now` 只由 reliable schedule/24-hour evidence 與 replaceable Asia/Taipei clock 推導。
- [x] Convenience-store place category 本身不產生 24-hour evidence。
- [x] 「目前營業」只包含 confirmed open；「24 小時」只包含 confirmed 24-hour。
- [x] Unknown 在未套正面篩選時仍可見且清楚標示。
- [x] 跨午夜與星期邊界有行為測試；無 schedule 不丟例外。
- [x] 預設排序在 access group 內依直線距離，不含隱藏推薦分數。
- [x] Red-Green-Refactor 測試使用 public search result，不測 clock helper private implementation。

## Blocked by

- [17：顯示 ATM 詳情、證據與資料新鮮度](./17-show-atm-details-provenance-and-staleness.md)
- [18：只用已確認能力篩選 ATM](./18-filter-only-confirmed-capabilities.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
