# 36：在啟動畫面、歡迎頁與主畫面顯示品牌圖示

Status: ready-for-human

Type: AFK

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

App 內目前沒有任何品牌圖示：啟動時只有一個轉圈圈（`onboarding_page.dart` 的 loading 狀態），歡迎頁是 AppBar 加純文字。依設計稿把選定的圖示放進 App，讓使用者一眼認得這是哪個 App。

設計稿（每張可用 Tweaks 切換方案）：https://claude.ai/artifact/Pvxf1MkSX6fQLsJ1CTad4V

- 啟動畫面：置中圖示、App 名稱、「離線查詢全台 ATM」、線性進度與「正在載入 ATM 資料…」、底部資料來源一行。Android 12+ 系統 splash 使用同一圖示與背景色，銜接不閃白。
- 歡迎頁：上方淺綠主視覺區放圖示、標題與說明；三張說明卡（定位用途、資料來源、隱私說明）有圖示；主按鈕「開始使用」。資料來源文案改為與議題 34 的顯名聲明一致。
- 附近 ATM：AppBar 標題左側放 32px 圖示。
- 資料來源與授權頁：頁首放圖示、App 名稱、版本與資料日期（頁面本體由議題 34 交付）。

等待中：議題 35 選定方案。

## Acceptance criteria

- [ ] 啟動時顯示品牌載入畫面，不再只有轉圈圈；載入失敗畫面維持現有重試行為。
- [ ] Android 12+ 系統 splash 與 Flutter 載入畫面同色、同圖示。
- [ ] 歡迎頁依設計稿呈現，`reviewMode`（從選單重看說明）仍可返回。
- [ ] 附近 ATM 的 AppBar 顯示品牌圖示，圖示標記為裝飾（TalkBack 不重複念 App 名稱）。
- [ ] 亮色／暗色主題、200% 字級與橫向都不破版。
- [ ] widget test 涵蓋品牌載入畫面與歡迎頁；既有測試保持綠燈。

## Blocked by

- [35：更換 App 圖示、桌面名稱與商店素材](./35-replace-app-icon-and-store-graphics.md)
- [34：顯示開放資料顯名聲明與非官方免責](./34-show-open-data-attribution-and-disclaimers.md)（僅資料來源頁頁首）

## Comments
