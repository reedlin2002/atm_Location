# 15：自動擴大附近搜尋直到結果足夠

Status: ready-for-human

Type: AFK

User stories covered: 12, 18, 19, 20, 25, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓附近搜尋從 1 公里開始，在 eligible results 太少時依序擴到 3、5、10 公里，
找到至少 20 筆即停止並最多顯示最近 50 筆。首頁顯示實際使用的半徑；10 公里
仍無結果時提供使用者主動擴大或搜尋地圖區域的 recovery。

## Acceptance criteria

- [x] 先以 RED 測試一個都市 fixture 停在 1 km、一個偏鄉 fixture 擴到 10 km。
- [x] 每個半徑先用 indexed bounding box 選候選，再以 Haversine 計算與排序。
- [x] 找到至少 20 個 eligible results 後不再擴大，畫面最多呈現最近 50 個。
- [x] 畫面顯示實際半徑與直線距離，不將其描述為步行或行車距離。
- [x] 10 km 無結果顯示清除篩選／擴大／改用地圖搜尋的可操作狀態。
- [x] 當次 radius 不在重開 App 後作為隱藏 active filter。
- [x] 測試透過 Search Coordinator／首頁公開行為完成 Red-Green-Refactor。

## Verification

- `app/test/home_radius_test.dart`：4 tests，涵蓋都市、偏鄉、UI 半徑、restart reset 與 recovery。
- `app/test/atm_catalog_test.dart`：驗證 geo index 存在，bounding-box 候選仍由 Haversine 排除圓外據點。
- `DriftAtmCatalog.findNearby` 每次查詢 limit 50，依距離與穩定 ID 排序。
- Flutter：38 tests passed；`flutter analyze` 無問題。

## Blocked by

- [14：只在使用者操作後要求前景定位](./14-request-only-foreground-location.md)
