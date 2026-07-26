# 32：準備 Google Play 發行候選版

Status: ready-for-human

Type: AFK

User stories covered: 45, 57, 66, 75, 76, 77, 78, 79, 80, 88, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

產生可交給專案擁有者完成 Play Console 上架的 Android release candidate 與完整發行資料；自動化可完成的內容要可重建，帳號、付款、簽署秘密與 console 宣告留給 HITL 議題 33。

此切片包含：

- Android min SDK 24、目前 Play 要求的 target SDK、release shrink／obfuscation 與可重現 AAB build。
- release signing 只讀取未入版控的注入設定；專案不含私鑰或密碼。
- CI 產出版本化 AAB、mapping、checksums、測試與資料品質報告。
- 台灣繁體中文商店標題、短／長說明、版本說明與截圖需求清單。
- 可公開存取的繁體中文隱私權政策內容，說明定位、離線資料、最近搜尋、收藏、無遠端診斷、無帳號、無廣告及資料回報。
- 資料來源、授權、更新頻率、免責與客服／資料更正聯絡資訊範本。
- Play Data safety 與 Financial features declaration 的答案工作表，依實際實作逐項附證據。
- release checklist 涵蓋金鑰、Firebase consent、Google API 限制、版本、TalkBack、離線及正式資料。

## Acceptance criteria

- [x] RED：先加入會因 release 組態、政策文件、宣告工作表或必要 artifacts 缺失而失敗的 release-readiness test。
- [ ] GREEN：提供簽署設定的安全 CI／本機環境可一個命令產生 release AAB，且 debug key 不會被誤用。
- [x] AAB 的 min／target SDK、application ID、version code／name 與 shrink 設定可由自動檢查驗證。
- [x] CI artifact 同時包含 AAB、mapping、checksum、測試摘要、資料品質與效能報告。
- [x] 隱私權政策與 Data safety 工作表和程式行為一致：無帳號、無廣告、無背景定位，且不含 Firebase／Crashlytics／Analytics；另如實列出 Maps SDK 自動與依使用方式處理的資料。
- [ ] Financial features declaration 明確說明 App 只提供 ATM 位置資訊，不執行交易、不提供金融帳戶或貸款服務，最後答案由 Play Console 擁有者確認。
- [x] 商店素材規格與文字可直接由 HITL 補上帳號／客服等擁有者資料，不需重新做產品決策。
- [x] release build 通過自動測試、lint、靜態分析與議題 31 gates。
- [x] REFACTOR：發行 metadata、版本與政策事實由單一可驗證來源產生，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [31：執行效能與正式資料品質門檻](./31-enforce-performance-and-production-data-gates.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)

[Release toolchain check](../../../release/release-toolchain-check.md)
