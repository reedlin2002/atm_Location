# 29：設定 Firebase 當機回報

Status: ready-for-human

Type: HITL

User stories covered: 77, 78, 79, 88, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

由專案擁有者建立並設定 Firebase Crashlytics，只把它接到議題 28 的 consent gate；不得啟用 Google Analytics 或其他行為追蹤。

此工作需要人類操作 Firebase Console、接受服務條款、管理專案權限與核對真實裝置資料，因此不能交由無人值守 agent 完成。

## Acceptance criteria

- [ ] 使用專案專屬 Firebase project，Android application ID 與實際 release application ID 一致。
- [ ] 只啟用 Crashlytics 所需服務；Google Analytics、廣告與行為追蹤保持停用。
- [ ] Android 設定檔以 Firebase 建議方式納入專案；任何私密金鑰、服務帳號或可寫入憑證不進 Git。
- [ ] Release build 在未同意時停用 collection；使用者主動同意後才啟用。
- [ ] 真實測試裝置驗證：未同意前的人為測試當機不出現在 console；同意後的人為測試當機可辨識地出現。
- [ ] console 中的 custom keys／logs 僅含議題 28 allowlist，沒有位置、搜尋、收藏、選取 ATM 或其他使用行為。
- [ ] 記錄 Firebase 資料處理、保留設定及 Play Data safety／隱私權政策所需答案。
- [ ] 留下可重做的 console 設定 checklist 與驗證證據，不記錄秘密值。

## Blocked by

- [01：建立獨立專案儲存庫](./01-create-dedicated-project-repository.md)
- [28：控制自願加入的當機診斷](./28-control-opt-in-crash-diagnostics.md)
