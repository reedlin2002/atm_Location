# Release candidate checklist

- [ ] 專案已移入專屬 GitHub repository，main 保護與 CI 必要檢查已啟用。
- [ ] `release-facts.json` 的 application ID、版本、min SDK 24、target SDK 36
      與 AAB manifest 完全一致。
- [ ] 以未入版控的 upload keystore、alias、store password、key password 簽署；
      `apksigner`／Play App signing 證據確認不是 debug certificate。
- [ ] 舊的硬編碼 Maps key 已由擁有者輪替；Android key 只允許正式 package 與
      debug/release SHA，API 只允許 Maps SDK；Places server key 分離並限制配額。
- [ ] `ATM_SUPPORT_EMAIL` 是由擁有者控制的真實信箱，隱私政策中的
      `{{SUPPORT_EMAIL}}` 已替換，且政策已有公開 HTTPS URL。
- [ ] Firebase 僅啟用 Crashlytics；Analytics／廣告停用；未同意零事件、同意後
      只有 allowlist、撤回清除 pending 的真機證據已附上。
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
