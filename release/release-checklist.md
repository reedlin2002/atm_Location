# Release candidate checklist

- [ ] 專案已移入專屬 GitHub repository，main 保護與 CI 必要檢查已啟用。
- [ ] `release-facts.json` 的 application ID、版本、min SDK 24、target SDK 36
      與 AAB manifest 完全一致。
- [ ] 以未入版控的 upload keystore、alias、store password、key password 簽署；
      `apksigner`／Play App signing 證據確認不是 debug certificate。
- [ ] 舊的硬編碼 Maps key 已由擁有者輪替；Android key 只允許正式 package 與
      debug/release SHA，API 只允許 Maps SDK；Places／Geocoding 維持停用。
- [ ] `ATM_SUPPORT_EMAIL` 是 `lin1022business@gmail.com`，且隱私政策已有
      公開 HTTPS URL。
- [ ] Release 依賴、Android manifest、iOS plist 與 App UI 均不含 Firebase、
      Crashlytics、Analytics、廣告 SDK 或診斷同意入口。
- [ ] Data safety 與隱私政策已依目前 Maps SDK 官方 disclosure 申報裝置／請求
      中繼資料、SDK 當機指標、IP、SDK 識別碼及地圖互動，未誤填為零蒐集。
- [ ] Python、Flutter tests、analyze、release-readiness、25k performance gate、
      正式資料品質報告全部通過。
- [ ] 25k CI proxy 之外，Android 10／2 GB 最低裝置報告通過 5s／2s／300ms
      門檻；磁碟不足故障注入沒有破壞已驗證 catalog。
- [ ] TalkBack 核心旅程在亮／暗、100%／200%、直向／橫向、手機／平板完成。
- [ ] 飛航模式首次啟動、離線搜尋、地圖失敗降級、權限拒絕與永久拒絕皆可恢復。
- [ ] AAB、R8 mapping、symbols、SHA-256、測試摘要、品質報告、效能報告與
      source revision 打包成不可變 release artifact。
- [ ] Store listing、截圖、Data safety、Financial features、資料來源／授權、
      更新頻率、免責與客服答案由 Play Console 擁有者逐項確認。

Google Play 官方文件顯示自 2026-08-31 起，新 App 與更新需 target Android 16
(API 36) 或更高；送審當日仍須再查官方政策與任何 extension／例外。
