# 16：搜尋離線 Catalog 並重用最近地點

Status: ready-for-human

Type: AFK

User stories covered: 5, 9, 10, 54, 55, 56, 58, 60, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓沒有網路或未授權定位的使用者，以 ATM 銀行、場所名稱、地址、縣市或行政區搜尋本機 catalog；可重用最多 10 筆主動輸入的最近地點，並單筆刪除或全部清除。離線搜尋不假裝能解析 catalog 外的任意新地標。

## Acceptance criteria

- [x] 先以 RED 測試輸入行政區／地址片段可從真實暫存 catalog 顯示相關 ATM。
- [x] 搜尋索引涵蓋 institution、place name、display/normalized address、county 與 district。
- [x] 無網路時，無法解析的任意地標顯示需要連線的誠實狀態，不回傳猜測座標。
- [x] 最近搜尋只保存使用者主動輸入的 label、resolved coordinate 與 timestamp，最多 10 筆。
- [x] 新增第 11 筆會依明確規則淘汰最舊一筆；可單筆刪除與 clear all。
- [x] Current-location samples 不進入 recent searches。
- [x] 重開 App 後最近搜尋保留，但舊 query 不自動成為 active search/filter。
- [x] 行為以 public search/collection interfaces 做 Red-Green-Refactor 測試。

## Blocked by

- [02：離線顯示內建資料中的附近 ATM](./02-show-nearby-atms-from-bundled-data-offline.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
