# 21：收藏據點並保留已撤除收藏

Status: ready-for-human

Type: AFK

User stories covered: 50, 51, 52, 53, 58, 86, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓使用者從清單／詳情收藏或取消收藏 ATM，並在離線收藏頁查看。收藏只引用 stable site ID；catalog 更新保留同一據點，retire operation 後收藏仍能打開 last-known detail 並顯示「來源中已不存在」，但不再進入一般附近結果。

## Acceptance criteria

- [x] 先以 RED 測試收藏 active site、重開 App 後仍存在並可離線打開。
- [x] Favorite storage 只保存 stable site ID 與必要本機 metadata，不複製一份會過期的 ATM facts。
- [x] 地址／場所小幅更新且 stable ID 不變時，收藏顯示新 facts。
- [x] Retired favorite 仍可從收藏頁打開 last-known detail 並有清楚 warning。
- [x] Retired site 不出現在一般 nearby/search results。
- [x] 取消收藏後若 site 已 retired，允許依 catalog retention policy 清理且不影響其他資料。
- [x] Favorites 不上傳、不需要帳號，也不受 clear filters 影響。
- [x] 真實暫存 database 與 delta fixture 的 behavior/widget tests 完成 Red-Green-Refactor。

## Blocked by

- [11：套用差異更新並保留撤除據點](./11-apply-deltas-and-retire-removed-sites.md)
- [17：顯示 ATM 詳情、證據與資料新鮮度](./17-show-atm-details-provenance-and-staleness.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
