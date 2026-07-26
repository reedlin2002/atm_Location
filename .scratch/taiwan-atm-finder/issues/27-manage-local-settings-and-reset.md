# 27：管理本機設定與重設資料

Status: ready-for-human

Type: AFK

User stories covered: 35, 37, 38, 54, 55, 57, 58, 65, 66, 75, 79, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

提供不需帳號的本機設定中心，讓使用者管理搜尋偏好、最近搜尋、收藏與 onboarding，並能清楚區分「清除篩選」和「重設所有本機資料」。

此切片包含：

- 顯示及修改已支援的偏好銀行、排序模式、篩選條件與必要的小型 UI 偏好。
- 列出並刪除個別或全部最近搜尋。
- 顯示收藏數量並提供前往收藏清單入口。
- 重新開啟 onboarding／權限說明。
- 「清除篩選」只恢復篩選與排序預設值，不刪除收藏或最近搜尋。
- 「重設所有本機資料」經明確確認後刪除偏好、最近搜尋、收藏、同意狀態與已安裝資料庫，回到首次啟動狀態。
- 關鍵集合使用 Drift／SQLite；少量旗標可使用 SharedPreferences。

不得加入帳號、雲端同步、通知或背景定位。

## Acceptance criteria

- [x] RED：先寫失敗測試，證明設定於 App 重啟後尚未保存，且清除篩選與重設資料尚未區分。
- [x] GREEN：所有已支援偏好會在重啟後恢復，並立即影響清單與地圖的共用查詢狀態。
- [x] 使用者可刪除單筆或全部最近搜尋；動作不會影響收藏。
- [x] 清除篩選保留偏好銀行、收藏與最近搜尋；重設所有資料前必須二次確認。
- [x] 取消重設不改變任何資料；確認後資料庫與少量設定皆清除，onboarding 重新出現。
- [x] 設定頁明確說明資料僅存本機，沒有登入或跨裝置同步。
- [x] repository 與 widget 測試使用真實暫存 SQLite 驗證交易、重啟與重設；只在平台儲存 boundary 使用 fake。
- [x] REFACTOR：集中設定預設值與重設交易，避免各畫面各自清理，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [13：提供不強迫權限的首次使用引導](./13-guide-first-run-without-forcing-permissions.md)
- [16：離線搜尋 ATM 並重用最近地點](./16-search-the-offline-catalog-and-reuse-recent-places.md)
- [18：只以已確認能力篩選 ATM](./18-filter-only-confirmed-capabilities.md)
- [20：保存偏好銀行並提供透明排序](./20-save-preferred-banks-and-offer-transparent-sorting.md)
- [21：收藏 ATM 並保留已下架收藏](./21-favorite-sites-and-retain-retired-favorites.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
