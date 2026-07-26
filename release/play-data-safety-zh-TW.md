# Play Data safety 答案工作表

最終答案與 Console 勾選須由帳號擁有者確認。客服：lin1022business@gmail.com。

| Play 問題 | 建議答案 | 程式證據／條件 |
|---|---|---|
| App 是否蒐集或分享使用者資料 | 是（Maps SDK 會蒐集）；「分享」須依送審當下 Play 對服務供應商的定義確認 | App 沒有自有後端，但 Maps SDK for Android 仍屬第三方 SDK |
| Maps SDK 自動蒐集項目 | 裝置／請求中繼資料、SDK stack trace 與 crash metrics、IP 位址、Maps SDK 假名識別碼 | Google 官方 Maps SDK Data disclosure |
| 依使用方式蒐集項目 | 地圖平移、縮放等互動；本 App 會把目前或選定區域作為 map camera 目標，位置分類須按 release 實測與 Console 當下題目保守申報 | 不得因沒有 Places／Crashlytics 就填成零蒐集 |
| 是否蒐集位置 | App 不保存位置歷史、不使用背景位置，也不送到自有後端；Maps SDK 相關位置／viewport 分類仍需在 Console 確認 | 前景位置用於距離排序，地圖開啟時會以搜尋原點設定 camera |
| 是否需要帳號 | 否 | 沒有登入、註冊、帳號識別碼或雲端同步 |
| 是否含廣告或廣告 ID | 否 | 沒有廣告 SDK，也不讀取 advertising ID |
| 是否蒐集搜尋或 App 活動 | 搜尋、最近地點、收藏與 ATM 選取只存本機；Maps SDK 的地圖互動須申報 | App 不傳送搜尋字詞或收藏 |
| 資料是否加密傳輸 | App 沒有自有後端；Maps SDK 網路傳輸依 Google Maps Platform 安全契約 | 郵件、地圖、分享與導航另受外部 App／服務政策約束 |
| 使用者能否要求刪除 | 本機資料可在設定中完整重設 | `LocalSettingsManager.resetAll` |
| 資料是否為必要 | 離線清單與文字搜尋不需 Maps；地圖功能需要 Maps SDK | 最終依 Console 對 optional／required 的當下定義回答 |

不得把 ATM 公開資料誤列為使用者資料。上架前仍需以 release build 與依賴清單
逐項重核，確認沒有新增其他資料蒐集 SDK，並依
https://developers.google.com/maps/documentation/android-sdk/play-data-disclosure
完成 Maps SDK 對應，再把隱私權政策公開網址填入 Play Console。若 Console
的問題文字或分類在送審前改版，帳號擁有者應以當下版本為準，保留日期與
螢幕截圖，不能直接複製過期答案。
