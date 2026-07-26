# 02：離線顯示內建資料中的附近 ATM

Status: ready-for-human

Type: AFK

User stories covered: 1, 2, 17, 18, 20, 57, 59, 88, 89, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

完成第一個 App tracer bullet：使用者第一次啟動且沒有網路時，App 匯入安裝包內的小型 catalog fixture；當定位邊界提供測試座標，首頁以繁體中文清單顯示附近 ATM 據點並依直線距離排序。這個切片同時建立 Flutter Android/iOS 專案、真實本機 SQLite 路徑與最小可測 UI，但不提前實作正式地圖、篩選或資料更新。

## Acceptance criteria

- [x] 第一個測試先以 RED 證明「離線啟動後可看到依距離排序的附近 ATM 清單」尚未成立。
- [x] 測試使用真實暫存 SQLite/Drift catalog，只在定位與網路等系統邊界使用 fake。
- [x] 內建 fixture 至少包含銀行、超商及郵局 ATM 據點，首頁顯示銀行、場所、地址與距離。
- [x] 直線距離排序可由畫面觀察，結果最多先顯示 50 筆。
- [x] 首次匯入失敗會顯示可重試錯誤，不會 crash-loop 或留下半套 catalog。
- [x] Android 最低版本為 API 24，iOS target 保留，介面文案走繁體中文 localization resources。
- [x] GREEN 後才進行重構；測試名稱與 assertion 描述使用者行為，不描述 provider、DAO 或 private method。
- [x] Flutter formatting、analysis、tests 與 Android debug build 通過。

## Blocked by

None - can start immediately

## Comments

- 2026-07-25：以 TDD 完成離線首頁 tracer bullet。涵蓋首次匯入、距離排序與繁中顯示、重啟冪等、50 筆上限與穩定排序、匯入失敗原子回滾及畫面重試。
- 2026-07-25：`dart format`、`flutter analyze`、完整 Flutter tests 與 Android debug APK build 均通過，移交人工驗收。
