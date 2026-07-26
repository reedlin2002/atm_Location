# 28：控制自願加入的當機診斷

Status: ready-for-human

Type: AFK

User stories covered: 56, 57, 58, 77, 78, 79, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

在供應商中立的診斷介面後實作「預設關閉、使用者主動同意才啟用」的當機診斷控制，並限制可傳出的資料。

此切片包含：

- onboarding 或設定頁可查看說明並開啟／關閉當機診斷。
- 初次安裝、升級及重設資料後皆預設關閉。
- consent gate 位於任何診斷 SDK 呼叫之前；沒有 provider 時 App 仍正常運作。
- 僅允許非致命／致命錯誤必要資訊與明確 allowlist 的低敏感度 metadata。
- 永不傳送精確／約略位置、搜尋字串、最近地點、收藏、ATM 選取紀錄、廣告 ID 或行為事件。
- 使用者關閉後停止後續收集，並清除尚未送出的本機診斷資料（若 provider 支援）。

## Acceptance criteria

- [x] RED：先寫失敗測試，證明 provider 在未同意時仍可能收到呼叫。
- [x] GREEN：預設、拒絕及撤回同意狀態下，fake provider 收到零筆診斷事件。
- [x] 主動同意後只有 allowlist 欄位可通過；任何禁止欄位會被丟棄並由測試證明。
- [x] 同意狀態會在重啟後保存；執行「重設所有本機資料」後恢復關閉。
- [x] provider 缺失、初始化失敗或離線時不影響核心搜尋、詳細資料與導航流程。
- [x] 診斷介面不得包含通用 analytics event API，專案亦不新增行為分析。
- [x] 單元與 widget 測試完整覆蓋預設、同意、拒絕、撤回、重設及 provider 失敗。
- [x] REFACTOR：將 consent gate 與資料清洗集中於單一 boundary，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [27：管理本機設定與重設資料](./27-manage-local-settings-and-reset.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
