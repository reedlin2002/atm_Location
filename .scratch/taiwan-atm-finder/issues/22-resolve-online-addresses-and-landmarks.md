# 22：在線解析地址、車站與地標

Status: ready-for-human

Type: AFK

User stories covered: 5, 9, 10, 54, 55, 60, 89, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

在離線搜尋之外加入 provider-neutral Place Resolver：有網路且 provider 已配置時，使用者可解析台灣地址、捷運／車站與地標，選定結果後以座標執行附近搜尋並加入最近地點。未配置、超額、無結果或網路錯誤時回到離線 catalog 搜尋，不暴露第三方 exception。

## Acceptance criteria

- [x] 先以 RED widget test 證明 fake resolver 回傳多個地標候選，使用者選定後看到該座標附近 ATM。
- [x] Resolver public contract 表達 success candidates、no results、offline、quota/configuration 與 provider failure。
- [x] 搜尋限制在台灣或明確提示非台灣結果不支援。
- [x] 選定 result 才保存 recent manual place；未完成的 autocomplete keystrokes 不保存。
- [x] 未配置 API 時 App 仍可完整使用離線 search，不 crash 或顯示 raw error。
- [x] Provider calls 有 debounce/session/quota-aware behavior，但 tests 驗證 observable results 而非內部 call count，除非額度本身是需求。
- [x] Google-specific types 不進入 Search Coordinator、recent searches 或 catalog。
- [x] Red-Green-Refactor 使用 fake provider boundary，真實 provider smoke 留給配置票。

## Blocked by

- [16：搜尋離線 Catalog 並重用最近地點](./16-search-the-offline-catalog-and-reuse-recent-places.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
