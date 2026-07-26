# 04：匯入每日全國 ATM 主資料

Status: ready-for-human

Type: AFK

User stories covered: 2, 3, 33, 41, 42, 45, 81, 82, 83, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓資料管線從財金公司的全國 ATM 主資料取得覆蓋與 active backbone，將銀行、超商及其他場所記錄正規化後發布成 App 可查詢的 catalog。來源 adapter 必須封裝下載、編碼與 schema，來源異常時 fail closed，不得推進公開版本。

## Acceptance criteria

- [x] 先以一個 failing source-contract test 固定目前官方欄位、編碼與必要值。
- [x] Adapter 將金融機構代碼／名稱、設置地點、縣市與地址轉成共同 evidence model。
- [x] 原始下載以來源、日期與 checksum 可追溯保存；測試不依賴即時網路。
- [x] 未預期欄位變動、內容類型、解碼或必要值缺失會讓 build 失敗並保留前一版。
- [x] Catalog quality report 呈現 raw、parsed、published、merged 與 quarantine counts。
- [x] App 匯入產物後可用銀行、場所名稱、縣市與地址找到銀行內及非銀行場所 ATM。
- [x] 不從場所名稱推論座標、24 小時或 ATM 特殊能力。
- [x] Red-Green-Refactor 證據與測試皆通過公開 adapter/builder contract。

## Blocked by

- [03：產生 App 可匯入的 Catalog Artifact](./03-build-an-importable-catalog-artifact.md)

## Comments

- 2026-07-25：完成財金公司全國 ATM adapter、共同 evidence model、來源／日期／SHA-256 原始封存、固定 schema／UTF-8／必要值驗證與 fail-closed 測試。
- 2026-07-25：以 RED→GREEN 修正官方即時回應使用 `application/octet-stream` 的來源契約；live smoke test 成功解析 27,289 筆，未從場所名稱推論座標或能力。
- 2026-07-25：CLI contract 證明來源 schema 失敗時既有 manifest、snapshot 與 quality report 不變；Flutter contract 證明產物可依銀行、場所、縣市與地址離線搜尋。
- 2026-07-25：Black、isort、mypy strict、pytest 8/8、Dart format、Flutter analyze、Flutter tests 11/11 與 Android debug APK build 均通過，移交人工驗收。
