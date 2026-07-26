# 33：執行封閉測試並送審

Status: ready-for-human

Type: HITL

User stories covered: 57, 75, 76, 77, 78, 79, 80, 88, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

由專案擁有者在真實 Android 裝置與 Google Play Console 完成最終驗收、封閉測試、宣告與首版送審。

此工作需要個人開發者帳號、一次性註冊費、身分／裝置驗證、測試者管理、簽署秘密及法律宣告，因此必須由人類執行。依目前個人帳號規則規劃至少 12 位測試者連續 14 天的封閉測試；實際送審前仍須以 Play Console 當下顯示的要求為準。

## Acceptance criteria

- [ ] Google Play 個人開發者帳號、付款、身分與必要裝置驗證皆完成。
- [ ] 建立應用程式、Play App Signing／upload key、客服 email 及公開隱私權政策 URL；秘密不進 Git。
- [ ] 將議題 32 的候選 AAB 上傳內部測試，通過 Play pre-launch report 或逐項處理可行問題。
- [ ] 專案擁有者親自以真實裝置驗證：首次啟動、拒絕／允許定位、離線搜尋、清單、地圖、密集標記、詳細資料、篩選、收藏、導航、分享、email 回報、重設、TalkBack、深色模式及當機診斷同意。
- [ ] Data safety、內容分級、目標對象、廣告、App access 及 Financial features declaration 依候選版實際行為填寫並保存證據。
- [ ] 台灣繁體中文商店文字、圖示、feature graphic、手機／平板截圖、聯絡資訊與資料來源揭露完成。
- [ ] 若帳號適用封閉測試門檻，至少 12 位測試者連續 14 天保持加入，回饋與阻斷問題有紀錄；不另招募未經專案擁有者同意的測試者。
- [ ] 取得 production access 後，以台灣為首發範圍送出第一版；首版不假設可使用 staged rollout。
- [ ] 上架核准後驗證商店頁、下載、啟動、正式 API key 限制、catalog 更新與客服 email。
- [ ] 後續版本才採 staged rollout，並記錄停止／擴大 rollout 的判準。

## Blocked by

- [32：準備 Google Play 發行候選版](./32-prepare-play-release-candidate.md)
