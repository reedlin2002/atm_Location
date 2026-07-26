# 26：啟動導航、分享與回報

Status: ready-for-human

Type: AFK

User stories covered: 47, 48, 49, 67, 68, 69, 89, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓使用者從 ATM 詳細資料啟動已安裝的地圖導航、分享可公開開啟的位置連結，並用電子郵件回報資料問題或一般意見。

此切片包含：

- 透過標準 geo／地圖 intent 或平台 chooser 傳遞 ATM 名稱、地址與座標。
- App 本身不計算、不儲存也不呈現導航路線。
- 分享內容包含 ATM 名稱、地址及不需安裝本 App 即可開啟的公開地圖 URL。
- ATM 資料回報郵件預填 ATM 穩定 ID、名稱、地址、資料版本及問題欄位。
- 設定頁提供一般意見回饋郵件入口。
- intent、分享與郵件 composer 均置於平台 boundary 後，測試使用 fake。

不得把使用者目前位置、最近搜尋、裝置識別碼或其他不必要資訊帶入郵件與分享內容。

## Acceptance criteria

- [x] RED：先寫失敗測試，證明詳細資料頁尚未能建立導航、分享與回報 payload。
- [x] GREEN：具備可處理 geo intent 的裝置會開啟系統 chooser 或預設地圖 App，且 payload 含 ATM 名稱、地址與座標。
- [x] 沒有可處理導航 intent 的裝置會顯示可恢復的訊息，不造成 crash。
- [x] 分享 URL 可在未安裝本 App 的環境開啟 ATM 座標；分享文字不含使用者位置。
- [x] ATM 回報郵件會預填穩定 ID、ATM 資料及版本，但不會自動寄送；一般回饋入口不強迫附帶特定 ATM。
- [x] 沒有郵件 App 時會提供複製客服信箱或其他清楚的復原方式。
- [x] 單元／widget 測試使用 fake platform launcher 驗證 payload 與錯誤分支，不啟動真實外部 App。
- [x] REFACTOR：共用安全的外部動作與 payload builder，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [17：顯示 ATM 詳情、來源與資料新鮮度](./17-show-atm-details-provenance-and-staleness.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
