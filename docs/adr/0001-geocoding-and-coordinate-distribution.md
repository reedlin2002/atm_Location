# ADR 0001：地址定位與座標再散布政策

- 狀態：Accepted
- 決策日期：2026-07-25
- 審查期限：2027-01-25，或候選服務條款變更時提前重審

## 決策

正式 catalog 目前不呼叫任何第三方地址定位服務。已有 MODA 或中華郵政官方座標的據點可發布；其他據點保留 `latitude = null`、`longitude = null` 與 `unknown` 座標信心。

TGOS 目前不核准用於本專案的離線 catalog geocoder。公開文件說明如何申請、驗證及取得定位結果，但沒有提供足以確認「長期保存定位結果、把結果放入可下載 artifact、再隨 App 離線散布」的明確授權。未取得書面授權前，不把服務可呼叫誤解為結果可再散布。

各縣市以政府資料開放授權條款第 1 版發布的門牌座標檔可個別評估，但目前沒有一份同契約、同更新義務且覆蓋全國的核准資料集，因此不組合成隱含的全國 provider。

## 可用與禁止用途

- 可用：本 repository 已審核的官方下載檔；來源本身允許保存與再利用時，可在 server-side pipeline 做 exact overlay。
- 禁止：Google Maps 畫面、Places/Geocoding 顯示結果、未授權網站爬蟲、或只有查詢權而沒有再散布權的 API 結果。
- 未解析據點仍可離線文字搜尋；不得產生虛構座標，也不進入距離排序或地圖標記。

## TGOS 審查紀錄

2026-07-25 查閱官方 TGOS MAP API 文件：

- 申請資格：需有 TGOS 帳號並經申請審核；服務以 Domain/IP 識別，IP 異動須重新申請。
- Credential：App ID 與 API key 必須成對使用。若未來取得，只能由 pipeline runtime/CI secret 注入；不得進 App、repository、log 或 artifact。
- 座標：地址定位可要求 EPSG:4326、3825、3826、3827、3828。本專案 catalog 只接受並發布 EPSG:4326（WGS84，longitude/latitude）。
- 模糊比對：TGOS 支援最近門牌、單雙號等 fuzzy 機制。本專案即使未來核准，也只自動採用 provider 明確回報的 full/exact match；fuzzy 僅進人工 review。
- 額度與速率：公開申請頁沒有列出可依賴的固定額度。若未來核准，必須以核准函／帳號頁所載額度為上限並記入新的 ADR；目前額度為「不適用，禁止呼叫」。
- 署名、儲存、再散布、更新與到期：公開申請及開發文件沒有形成足以核准離線再散布的明確授權。必須先取得提供機關書面確認，再以新 ADR 取代本決策。

## 候選開放門牌資料

政府資料開放平臺可找到新北、臺南、桃園、臺中等地方門牌座標資料，個別標示政府資料開放授權條款第 1 版，但更新頻率、欄位、精度及涵蓋範圍不同。這些資料可在後續以「逐資料集審核、逐縣市 adapter、exact-only」方式加入，不能把缺少的縣市用未授權服務補齊。

## Evidence register

| 證據 | 2026-07-25 審查結果 |
| --- | --- |
| https://api.tgos.tw/TGOS_MAP_API/docs/site/web/Application | 申請資格、一般／進階圖資資格、Domain/IP 驗證與 IP 異動流程；未見離線結果再散布授權 |
| https://api.tgos.tw/TGOS_MAP_API/docs/site/ios/AddrLocate | App ID/API key、支援 SRS、fuzzy 參數與地址定位回傳契約 |
| https://data.gov.tw/dataset/168887 | 新北市門牌位置資料；每月、OGL 1.0、EPSG:3826 |
| https://data.gov.tw/dataset/120044 | 臺南市門牌座標；年度、OGL 1.0、TWD97，且標示人工點位僅供參考 |
| https://data.gov.tw/dataset/157689 | 桃園市門牌座標；每月、OGL 1.0，且標示可能有人工套圖誤差 |

## 重審所需證據

要核准新的 geocoder，必須同時保存：提供者與產品名稱、完整條款版本／日期、申請資格、用途、速率／額度、署名、結果儲存、衍生資料與再散布權、座標系統、exact/fuzzy 語義、更新／刪除／到期義務，以及 credential owner 與 rotation 流程。

