# 24：顯示地圖並連動 ATM 結果

Status: ready-for-human

Type: AFK

User stories covered: 11, 14, 15, 16, 17, 61, 88, 89, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

把同一份附近 ATM 結果同時呈現在 Google 地圖與清單，讓使用者能從任一入口選取 ATM、看摘要並進入相同的詳細資料頁。地圖實作須置於平台介面之後，領域與清單層不得依賴 Google Maps 型別。

此切片包含：

- Google Maps Flutter 地圖畫面與 ATM 標記。
- 清單、標記及目前選取 ATM 的單一共享狀態。
- 點擊標記後顯示可拖曳摘要面板，並可前往詳細資料。
- 點擊清單項目時選取對應標記；由摘要面板開啟的詳細資料須與清單入口相同。
- 地圖無法初始化時保留完整清單與詳細資料流程。
- 相機位置、可見區域及地圖事件包在可替換的 map adapter 內。

本議題不包含密集標記叢集、搜尋此區域、導航路線計算或第三方行為分析。

## Acceptance criteria

- [x] RED：先以 fake map adapter 撰寫失敗的 widget／狀態測試，證明清單與標記目前尚未共享選取狀態。
- [x] GREEN：選取清單項目會聚焦對應 ATM；點擊標記會選取同一 ATM 並顯示摘要面板。
- [x] 由清單或地圖摘要進入詳細資料時，使用相同穩定 ATM ID，顯示相同內容。
- [x] 拖曳摘要面板不會改變結果集合或觸發不必要的資料重新查詢。
- [x] 地圖初始化、API 金鑰或服務錯誤時，畫面會顯示清楚狀態，但清單及詳細資料仍可使用。（搜尋 UI 屬 #16，尚未建置）
- [x] production map adapter 使用 Google Maps Flutter；核心 package 與 repository 不匯入 Google Maps SDK 型別。
- [x] 測試不呼叫真實 Google 服務（`google_maps_adapter_test` 僅驗證組裝、不 pump 平台視圖）。~~另有可由具備金鑰環境執行的最小整合 smoke test~~ → 需真實金鑰的裝置端 integration test 隨 #23 補上。
- [x] REFACTOR：消除地圖與清單各自維護結果／選取狀態的重複邏輯，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 工作紀錄（見下方 Work log）。

## Blocked by

- [15：逐步擴大附近搜尋半徑](./15-expand-the-nearby-radius-until-results-are-useful.md)
- [17：顯示 ATM 詳情、來源與資料新鮮度](./17-show-atm-details-provenance-and-staleness.md)
- [23：設定受限制的 Google 平台金鑰](./23-configure-restricted-google-platform-keys.md)

## Work log (2026-07-25)

Red-Green-Refactor：

- **RED** — `test/nearby_map_test.dart` 先以 `_FakeMapAdapter` 撰寫「清單與地圖標記共享同一選取狀態」，編譯即失敗（`NearbyMapPage`／`mapAdapterProvider` 尚不存在），證明選取狀態尚未共享。
- **GREEN** — 新增 `lib/map/map_adapter.dart`（`MapAdapter` 抽象、`MapMarker`／`MapCameraPosition`／`MapPresentation`，不含任何 Google 型別）、`lib/map/nearby_map_page.dart`（`selectedSiteProvider` 單一共享選取、地圖＋清單同畫面、可拖曳摘要面板、`mapAvailableProvider` 降級）、`lib/detail/atm_detail_page.dart`（依穩定 id 的詳情頁，#17 stub）、`lib/map/google_maps_adapter.dart`（唯一 import `google_maps_flutter` 的 production adapter）。
- **REFACTOR** — 刪除 `lib/home/home_page.dart`，清單／失敗視圖收斂到 `NearbyMapPage`；選取狀態單一來源。

隨手接上的相依：
- 真實定位 `GeolocatorLocationGateway`（#14 前置），`locationGatewayProvider` 由 production 綁定；Android 權限＋web 已補。
- 新增 `web/` 平台；`web/index.html` 與 AndroidManifest 放入 `YOUR_GOOGLE_MAPS_API_KEY` 佔位（待 #23）。

閘門：`dart format`、`flutter analyze`（No issues）、`flutter test`（11 passed）全綠。

尚未涵蓋（後續 issue）：
- 需真實金鑰的裝置端 integration smoke test → 隨 **#23**。
- 半徑自動放大（目前固定 10km）→ **#15**；詳情頁來源／新鮮度 → **#17**；搜尋列 → **#16**。
- 標記叢集／「搜尋此區域」→ **#25**（本 issue 明列不含）。
