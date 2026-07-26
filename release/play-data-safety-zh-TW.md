# Play Data safety 答案工作表

最終答案與 Console 勾選須由帳號擁有者確認。客服：{{SUPPORT_EMAIL}}。

| Play 問題 | 建議答案 | 程式證據／條件 |
|---|---|---|
| App 是否蒐集或分享使用者資料 | 若 Issue 29 未啟用：否；若啟用 Crashlytics：是，僅在明確同意後蒐集「App 資訊與效能／當機記錄」 | `CrashDiagnosticsBoundary` 在 SDK 前檢查 consent |
| 是否蒐集位置 | 否 | 前景位置只在記憶體用於距離排序；診斷白名單排除位置 |
| 是否需要帳號 | 否 | 沒有登入、註冊、帳號識別碼或雲端同步 |
| 是否含廣告或廣告 ID | 否 | 沒有廣告 SDK；診斷禁止 advertising ID |
| 是否蒐集搜尋或 App 活動 | 否 | 搜尋、最近地點、收藏與 ATM 選取只存本機且禁止送出 |
| 資料是否加密傳輸 | 若啟用 Crashlytics：是，依 Firebase HTTPS；郵件與外部導航由使用者選擇的 App 處理 | Issue 29 Console／供應商文件需留證 |
| 使用者能否要求刪除 | 本機資料可在設定中完整重設；已送出的診斷依供應商保留與刪除能力說明 | `LocalSettingsManager.resetAll` 與 Issue 29 保留設定 |
| 資料是否為必要 | 當機診斷不是必要且預設關閉 | 核心搜尋、詳情與導航在 provider 缺失時仍可用 |

不得把 ATM 公開資料誤列為使用者資料；也不得因加入 Firebase 設定檔就宣稱
Analytics 已啟用。上架前需以 release build、真實裝置與 Firebase Console 證據
逐項重核，並把實際保留期限、處理地區、刪除途徑與隱私權政策公開網址填入
Play Console。若 Console 的問題文字或分類在送審前改版，帳號擁有者應以當下
版本為準，保留日期與螢幕截圖，不能直接複製過期答案。
