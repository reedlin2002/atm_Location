# 25：處理密集標記與離線地圖狀態

Status: ready-for-human

Type: AFK

User stories covered: 11, 12, 13, 14, 15, 19, 20, 61, 73, 74, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓地圖在都會區大量 ATM、使用者移動視窗及網路不穩時仍保持可理解且可操作。

此切片包含：

- 依縮放層級聚合密集 ATM 標記，點擊叢集可合理放大或展開。
- 使用者停止平移／縮放後顯示「搜尋此區域」，只有明確點擊才重新查詢。
- 查詢結果與地圖顯示數量上限，避免每個相機 frame 重算或請求資料。
- 摘要面板可展開成完整結果清單，也能收合回地圖。
- 地圖圖磚離線、逾時或服務不可用時顯示狀態；本機 ATM 清單與詳細資料不被阻斷。
- 保存地圖與清單間的選取、篩選及排序一致性。

## Acceptance criteria

- [x] RED：以密集台北車站 fixture 撰寫失敗測試，證明未叢集時標記不可用或超出顯示上限。
- [x] GREEN：相同縮放層級與 viewport 會產生可重現的叢集；點擊叢集能看到其涵蓋 ATM。
- [x] 相機連續移動期間不查詢；停止移動後只顯示「搜尋此區域」，點擊後才以新中心／viewport 更新結果。
- [x] 搜尋期間有載入狀態，完成後仍保留既有篩選、排序與選取規則。
- [x] 地圖圖磚或網路不可用時，畫面明確說明地圖狀態，且使用者仍可展開完整清單、看詳細資料及啟動後續操作。
- [x] 叢集演算法、viewport 判斷及節流邏輯可在不載入真實地圖 SDK 的單元測試中驗證。
- [x] widget 測試涵蓋摘要面板展開／收合、密集結果、空結果及離線狀態。
- [x] REFACTOR：將純叢集與 viewport 決策抽離平台 adapter，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [24：顯示地圖並連動 ATM 結果](./24-show-map-and-linked-results.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
