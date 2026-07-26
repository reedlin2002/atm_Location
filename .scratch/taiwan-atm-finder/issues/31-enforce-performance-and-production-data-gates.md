# 31：執行效能與正式資料品質門檻

Status: ready-for-human

Type: AFK

User stories covered: 45, 46, 59, 60, 62, 63, 81, 82, 83, 88, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

以正式規模資料與最低支援裝置等級驗證資料品質、啟動、更新及查詢效能，並將不可接受的回歸變成 CI 的可見失敗。

此切片包含：

- 使用 production-like 全台資料執行 builder 與 App 匯入 dry run。
- 驗證 PRD 目標：已解析座標覆蓋率至少 98%、壓縮更新包原則上不超過 10 MB、首次匯入小於 5 秒、warm start 小於 2 秒、附近查詢 p95 小於 300 ms。
- 效能量測環境、資料版本、裝置等級、樣本數與統計方法可重現。
- 建立冷啟動、warm start、全量匯入、delta、回滾、附近查詢、文字搜尋與密集地圖基準。
- CI 產出人可讀及機器可讀報告；超過硬性門檻即失敗，不默默放寬。
- 對來源缺檔、checksum 錯誤、schema 變更、低座標覆蓋、重複暴增、網路中斷與磁碟空間不足執行故障矩陣。

## Acceptance criteria

- [x] RED：先加入會因缺少正式規模基準或品質報告而失敗的 gate test。
- [x] GREEN：固定資料版本與指定最低裝置等級可重跑並產生包含 p50／p95、樣本數及環境資訊的報告。
- [x] 座標覆蓋率低於 98% 時 builder／release gate 失敗並列出未解析分布；不得以隱藏資料列通過。
- [x] 壓縮包大於 10 MB 時 gate 失敗並列出體積來源；若日後要變更目標，須另作明確產品決策。
- [x] 首次匯入、warm start 與附近查詢超過 PRD 門檻時 gate 失敗，報告保留可比較基準。
- [x] 故障矩陣證明現有已驗證資料不因下載、驗證、匯入或 delta 失敗而損壞。
- [x] CI 可在沒有 Google／Firebase 真實網路呼叫的環境執行；平台 smoke test 另有明確 job。
- [x] REFACTOR：將基準 fixture、計時與報告格式共用化，避免測試自行定義互相矛盾的門檻，所有測試保持綠燈。
- [x] 實作過程留下可辨識的 Red-Green-Refactor 提交或工作紀錄。

## Blocked by

- [12：只發布通過品質門檻的 ATM 目錄](./12-publish-only-quality-gated-catalogs.md)
- [29：設定 Firebase 當機回報](./29-configure-firebase-crash-reporting.md)
- [30：讓核心流程無障礙、響應式並支援主題](./30-make-core-flow-accessible-responsive-themed.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
