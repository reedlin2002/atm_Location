# 06：疊加郵局與無障礙能力證據

Status: ready-for-human

Type: AFK

User stories covered: 4, 27, 28, 29, 43, 44, 45, 83, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

整合中華郵政每日 ATM 分布與金管會輪椅／視障正面清單，讓匹配據點在 App 詳情呈現已確認的存款、輪椅操作、語音輔助等能力與來源日期。未出現在正面清單中的能力保持 unknown，不能改成 unsupported。

## Acceptance criteria

- [x] 先以 RED 測試一個郵政 ATM 取得 confirmed deposit／audio evidence，而未列名的一般 ATM 維持 unknown。
- [x] 郵政 adapter 保留官方座標、局內／局外與已公開能力的 evidence source/date。
- [x] 輪椅與視障資料以正面證據 overlay，不將 absence 映射成 false。
- [x] 同一能力的衝突依明文化的來源優先與日期規則決定，並出現在品質報告。
- [x] App 詳情以「已確認」或「未知」顯示能力，不以空白代表任何狀態。
- [x] 郵局主資料與全國 backbone 的同一據點不重複顯示。
- [x] Source fixtures、pipeline contract 及 App behavior tests 均通過。
- [x] 實作以單一能力行為逐步 Red-Green-Refactor，不批次想像所有銀行格式。

## Blocked by

- [04：匯入每日全國 ATM 主資料](./04-import-the-daily-national-atm-source.md)

## Implementation notes

- 中華郵政每日主檔採 UTF-8 BOM、16 欄嚴格契約並封存 checksum；局外 ATM 缺少儲匯局號時，以局名與完整地址產生穩定來源 ID。
- A102 輪椅與 A103 視障清單只產生 `confirmed` 正向證據；清單缺席維持 `unknown`。
- 能力衝突先採較新資料日期，同日再採專門 FISC 無障礙清單高於郵政主檔的來源優先級；每筆結果寫入 overlay 品質報告。
- 2026-07-25 live contract 驗證：郵政 1,964 筆（局外 700、存款 912、語音 250）、輪椅 24,340 筆、視障 6,938 筆。
- Drift schema 4 保存能力、局內／局外與來源；詳情頁固定顯示存款、語音、視障與輪椅狀態。
- 驗證：Python black/isort/mypy 通過、pytest 23/23；Flutter format/analyze 通過、widget/contract tests 14/14。
