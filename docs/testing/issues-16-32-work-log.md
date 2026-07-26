# Issues 16–32 Red–Green–Refactor 工作紀錄

日期：2026-07-26

本紀錄彙整 ATM Finder 應用層議題的測試先行證據。測試一律使用本機 fixture、暫存 SQLite、fake platform adapter 或 provider fake；自動化測試不呼叫 Google、Firebase 或其他真實網路服務。

## Red–Green–Refactor

| Issue | RED | GREEN | REFACTOR |
| --- | --- | --- | --- |
| 16 | 行政區／地址搜尋、最近搜尋保存與離線無法解析狀態測試先失敗 | 正規化離線索引、最近搜尋 repository 與誠實 fallback 通過 | 搜尋與最近地點行為收斂至 public catalog interfaces |
| 18 | 已確認／未知 capability 的篩選測試先失敗 | 只納入明確 confirmed 的結果 | 清單與地圖共用 `AtmResultPolicy` |
| 19 | 營業中、未知、已關閉、跨午夜與資料 round-trip 測試先失敗 | 保守時段判斷、證據欄位與 schema 11 持久化通過 | 清單與詳情共用 access status |
| 20 | 預設距離與偏好銀行排序測試先失敗 | 本機偏好、同／跨行脈絡與費用免責說明通過 | 偏好與排序脈絡集中於 canonical policy |
| 21 | 穩定收藏 ID 與 delta 退役情境測試先失敗 | 只保存 ID，退役收藏仍可辨識 | 收藏解析與狀態呈現集中於 repository |
| 22 | fake 地址候選與錯誤分支測試先失敗 | provider-neutral resolver、300 ms debounce、session token 與 quota cooldown 通過 | 供應商型別隔離在 gateway boundary |
| 24 | fake map adapter 證明清單與地圖未共享選取狀態 | 清單、標記、摘要與詳情以穩定 ATM ID 連動 | 共用結果與選取 controller |
| 25 | 密集台北車站 fixture 與 viewport 更新測試先失敗 | 可重現叢集、明確「搜尋此區域」與離線清單 fallback 通過 | 純叢集與 viewport 決策抽離地圖 adapter |
| 26 | 導航、分享與回報 payload 測試先失敗 | platform launcher fake 驗證成功與可恢復錯誤分支 | 共用安全 payload builder 與外部動作 controller |
| 27 | 設定重啟保存、清除篩選與重設資料差異測試先失敗 | 暫存 SQLite 驗證保存、刪除、取消及重設交易 | 預設值與 reset transaction 集中於 manager |
| 28 | 未同意時 provider 仍可能被呼叫的測試先失敗 | 預設關閉、同意 allowlist、撤回、重設及 provider failure 通過 | consent gate 與資料清洗集中於 diagnostics boundary |
| 30 | semantics、200% 字級與多尺寸測試先失敗 | 清單式 TalkBack 核心旅程、響應式版面與明暗主題通過 | 共用 semantics、間距、字體與 breakpoints |
| 31 | 缺少正式規模資料與品質報告時 gate test 先失敗 | 品質、體積、匯入、warm start、查詢與 CI gates 通過 | fixture、計時與報告格式共用 |
| 32 | 缺少 release 組態、政策文件與 artifacts 時 readiness test 先失敗 | 可驗證的 release facts、工作流程、政策與商店素材規格通過 | 版本、metadata 與政策事實集中於 `release/release-facts.json` |

## 驗證結果

- PowerShell：`$env:PYTHONPATH = 'pipeline/src'; python -m pytest -q`：46 passed。
- `flutter test --concurrency=1 --exclude-tags production-performance --reporter compact`：93 passed。
- `flutter analyze`：No issues found。
- Production-like performance gate：通過；資料版本 `production-like-2026.07.26`，座標覆蓋率 99%，壓縮資料 454,914 bytes，首次匯入 p50/p95 為 1872.88/2528.55 ms，warm start 0.49/0.71 ms，附近查詢 2.54/4.38 ms，文字查詢 37.30/42.21 ms。
- Release build 已進入 R8 並產生 unsigned AAB 與 mapping，但本機因 Android command-line tools／licenses 不完整而無法 strip debug symbols；尚未使用正式 upload key 產生可提交的 signed candidate。
- Release-readiness 會掃描 Android、iOS、Web、scripts、release、workflow 與 pipeline 原始碼，拒絕硬編碼的 Google API key；目前掃描為 0 筆。

## 尚需人工或外部環境

- 在指定的 Android 10／2 GB 實機重跑效能 gate。
- 以受限 Google 金鑰執行裝置端 Maps／Places smoke test。
- 配置 Firebase 專案後驗證 consent 開關與非敏感測試 crash。
- 由 Play Console 擁有者提供簽章、客服／政策資訊，完成 closed test 與送審。
