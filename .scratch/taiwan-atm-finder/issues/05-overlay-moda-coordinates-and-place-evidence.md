# 05：疊加數發部座標與場所證據

Status: ready-for-human

Type: AFK

User stories covered: 3, 18, 34, 41, 43, 44, 45, 83, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

將數位發展部普發現金 ATM 明細作為證據 overlay，只有在銀行與地址／場所高可信匹配時，才補入座標、場所類型及可重用的無障礙證據。事件限定的「普發現金服務」不得被當作永久 ATM 能力或 active status。

## Acceptance criteria

- [x] 先以 RED 測試一筆高可信匹配會補入座標、另一筆衝突資料不會錯誤覆蓋。
- [x] Overlay 不新增或移除 active 主資料據點；active status 仍由每日全國主資料控制。
- [x] 座標保存 evidence source、evidence date 與 `official exact` confidence。
- [x] 場所類型映射至受控 vocabulary，未知值保留為 unknown 並進入報告。
- [x] 普發現金限定服務欄位不映射成一般提款、存款、營業或即時可用能力。
- [x] 無法唯一匹配的 overlay row 進入 quarantine，不用 fuzzy 猜測。
- [x] App 詳情可顯示座標／場所的來源日期與信心，不暴露來源 adapter 內部格式。
- [x] Pipeline、contract 與 App 行為測試完成 Red-Green-Refactor 並保持 green。

## Blocked by

- [04：匯入每日全國 ATM 主資料](./04-import-the-daily-national-atm-source.md)

## Comments

- 2026-07-25：完成 MODA CP950 source adapter、原始 checksum 封存、銀行＋官方精確地址唯一匹配與保守 quarantine overlay；backbone 據點數及 active 控制不變。
- 2026-07-25：官方 live smoke test 解析 28,024 筆有效 overlay、隔離 13 筆壞列，依經緯度合法範圍可稽核地正規化 14,671 筆官方對調座標；21,988 筆精確 enrich、6,036 筆不唯一或無匹配資料 quarantine。
- 2026-07-25：Catalog snapshot／quality report 保留座標與場所 source/date/`official_exact`；未知場所類型維持 `unknown`，普發限定 service/accessibility 原始欄位不被映射成永久 ATM 能力。
- 2026-07-25：App Drift schema 3 與 production importer 保留公開 provenance，詳情以繁中顯示發布者、日期、信心且不暴露 adapter wire name。
- 2026-07-25：Black、isort、mypy strict、pytest 17/17、Dart format、Flutter analyze 與 Flutter tests 13/13 均通過，移交人工驗收。
