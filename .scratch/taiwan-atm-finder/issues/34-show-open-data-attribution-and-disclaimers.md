# 34：顯示開放資料顯名聲明與非官方免責

Status: ready-for-human

Type: AFK

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

App 使用的 ATM 資料全部依「政府資料開放授權條款－第1版」取得。條款第三條第二款規定：
「未盡顯名標示義務者，視為自始未取得開放資料之授權」。目前 App 只有引導頁一句
「ATM 主資料來自財金公司與其他具公開授權的政府或機構資料」，沒有列出提供機關、
資料集名稱與授權條款，不符合附件「顯名聲明」格式，上架前必須補齊。

此切片包含：

- 設定頁新增「資料來源與授權」入口，開啟一頁列出下表五份資料集的顯名聲明。
- 頁面同時顯示非官方聲明與資料免責。
- 詳細頁的來源標籤與顯名聲明使用的提供機關一致。
- 商店長說明補上非官方聲明。

## 顯名聲明內容

2026-11-22 查證 data.gov.tw：五份資料集授權方式皆為「政府資料開放授權條款-第1版」、
計費方式皆為免費，且沒有額外的使用限制欄位。提供機關以平台登記為準（不是實際整理
資料的財金公司）。

| 提供機關（平台登記） | 年份 | 資料集 | 頁面 | Catalog evidence source |
| --- | --- | --- | --- | --- |
| 中央銀行 | 2026 | 金融機構ATM位置查詢一覽表 | https://data.gov.tw/dataset/24333 | `fisc-national-atm` |
| 數位發展部 | 2025 | 114年發放現金ATM裝設地點明細 | https://data.gov.tw/dataset/175482 | `moda-cash-atm` |
| 中華郵政股份有限公司 | 2026 | 全國郵局ATM分佈 | https://data.gov.tw/dataset/6121 | `chunghwa-post-atm` |
| 金融監督管理委員會銀行局 | 2026 | 可供視障民眾使用之ATM設置地點資訊 | https://data.gov.tw/dataset/73189 | `fisc-visual-accessibility-atm` |
| 金融監督管理委員會銀行局 | 2026 | 可供使用輪椅民眾操作之ATM設置地點資訊 | https://data.gov.tw/dataset/73188 | `fisc-wheelchair-accessibility-atm` |

年份指所用資料快照的年份；baseline catalog 更新時要一併更新。

每份資料集之後須附上條款規定的聲明原文：

> 此開放資料依政府資料開放授權條款 (Open Government Data License) 進行公眾釋出，使用者於遵守本條款各項規定之前提下，得利用之。
>
> 政府資料開放授權條款：https://data.gov.tw/license

非官方與免責文字：

> 本 App 非任何銀行、金融機構或政府機關之官方 App。ATM 資料來自政府開放資料，可能有延遲或錯誤；位置、營業時間與服務請以現場及銀行公告為準。

## Acceptance criteria

- [ ] 設定頁有「資料來源與授權」入口，頁面逐筆列出上表五份資料集的提供機關、年份與資料集名稱。
- [ ] 頁面包含上方聲明原文與授權條款網址；網址與各資料集頁面可點擊開啟外部瀏覽器。
- [ ] 頁面顯示非官方與免責文字。
- [ ] 詳細頁的來源標籤（目前 `evidencePublisherFisc` 為「財金公司公開資料」）不再與顯名聲明的提供機關矛盾。
- [ ] 引導頁「資料來源」說明指向新頁面，或改寫成與顯名聲明一致的內容。
- [ ] `release/store-listing-zh-TW.md` 長說明加入非官方聲明。
- [ ] 顯名資料只有一個來源（單一常數或資料檔），widget test 驗證五份資料集與聲明原文都有顯示。
- [ ] 現有 `flutter analyze`、`flutter test` 與 pipeline 測試保持綠燈。

## Blocked by

None - can start immediately

## Comments
