# 18：只用已確認能力篩選 ATM

Status: ready-for-human

Type: AFK

User stories covered: 27, 28, 29, 30, 33, 34, 35, 36, 37, 44, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓使用者依銀行、場所類型、存款、輪椅操作、語音輔助與外幣提款篩選附近／搜尋結果。正面能力篩選只納入 confirmed supported；unknown 不混入也不被改寫成 unsupported。首頁顯示 active chips、empty recovery 與一鍵清除，明確設定會本機保存。

## Acceptance criteria

- [x] 先以 RED 測試「存款」篩選包含 confirmed deposit 並排除 unknown/unsupported。
- [x] Institution 與 place-category filters 使用 canonical values，不比對 UI 顯示字串。
- [x] 每個 active filter 以文字 chip 顯示並可個別移除。
- [x] 一鍵清除恢復完整 eligible results，不清除 preferred banks、favorites 或 recent searches。
- [x] 篩選造成空結果時顯示 active conditions 與 clear action。
- [x] 明確選取的 filters 重開 App 後保留；當次 query/radius 不被一併保存。
- [x] Filter combinations 套用於 map/list 共用結果來源，沒有兩套不一致邏輯。
- [x] 使用真實 catalog 的 behavior/widget tests 逐項 Red-Green-Refactor。

## Blocked by

- [15：自動擴大附近搜尋直到結果足夠](./15-expand-the-nearby-radius-until-results-are-useful.md)
- [17：顯示 ATM 詳情、證據與資料新鮮度](./17-show-atm-details-provenance-and-staleness.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
