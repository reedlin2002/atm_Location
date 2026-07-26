# 30：讓核心流程無障礙、響應式並支援主題

Status: ready-for-human

Type: AFK

User stories covered: 15, 61, 70, 71, 72, 73, 74, 75, 76, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓繁體中文核心旅程在手機、平板、直向、橫向、亮色與深色模式下都可使用，且不依賴地圖即可由螢幕閱讀器完成「搜尋 → 選擇 ATM → 看詳情 → 啟動導航」。

此切片包含：

- ATM 清單、地圖控制、摘要面板、詳細資料、篩選、設定與外部動作的語意標籤及可預期焦點順序。
- 狀態與能力不得只靠顏色表達。
- 支援系統字級放大，不截斷關鍵名稱、距離、狀態與動作。
- 可點擊區域、對比、錯誤文字與載入狀態符合 Android 無障礙實務。
- 手機／平板、直向／橫向的響應式配置；不得把互動鎖死在單一像素尺寸。
- 跟隨系統亮色／深色主題，地圖控制與 overlay 在兩種模式皆清楚。
- 所有使用者可見字串集中並以台灣繁體中文為預設。

## Acceptance criteria

- [x] RED：先建立失敗的 semantics／golden 測試，指出核心流程中缺少標籤、焦點或大字級溢位。
- [x] GREEN：TalkBack 使用者可完全跳過地圖，以清單完成搜尋、詳細資料及導航啟動。
- [x] 清單項目、標記、叢集、篩選 chip、狀態徽章與外部動作都有具意義且不重複的語意。
- [x] 200% 系統字級下，核心資訊與主要動作不被裁切、重疊或無法觸達。
- [x] 至少以小型手機、一般手機、平板及橫向尺寸執行 widget／golden 測試。
- [x] 亮色與深色模式的文字、控制、地圖 overlay、錯誤及未知狀態不只靠顏色區分。
- [x] 自動測試之外，有可重複的真實 Android TalkBack 核心旅程 checklist。
- [x] REFACTOR：共用語意、間距、字體與響應式 breakpoints，避免逐頁硬編碼，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [25：處理密集標記與離線地圖狀態](./25-handle-dense-and-offline-maps.md)
- [26：啟動導航、分享與回報](./26-launch-navigation-share-and-feedback.md)
- [27：管理本機設定與重設資料](./27-manage-local-settings-and-reset.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
