# 17：顯示 ATM 詳情、證據與資料新鮮度

Status: ready-for-human

Type: AFK

User stories covered: 17, 39, 40, 43, 44, 45, 46, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓使用者從附近或搜尋清單開啟 ATM 詳情，查看銀行、場所、地址、距離、場所類型、座標信心、能力的 confirmed／unknown 狀態、來源日期與 catalog version。資料超過 30 天未成功更新時，首頁與詳情以可理解方式警示但仍允許使用 last-good catalog。

## Acceptance criteria

- [x] 先以 RED widget test 證明點擊清單項目後可看見 ATM facts 與至少一個明確 unknown capability。
- [x] 詳情顯示 institution、place、address、distance（有 origin 時）、place category、catalog version 與 source dates。
- [x] 能力以「已確認支援／已確認不支援／未知」呈現，不以空白或圖示 absence 表示。
- [x] Coordinate source/confidence 可供使用者判斷但不暴露 adapter 內部欄位名稱。
- [x] 可替換 clock 證明 last successful catalog 超過 30 天會顯示 stale warning。
- [x] Stale warning 不阻止離線查看、搜尋或後續 retry。
- [x] Detail route 對 active 與 retired lookup 使用 stable site ID。
- [x] Widget/integration tests 依 Red-Green-Refactor 完成，未直接查 database 驗證畫面行為。

## Blocked by

- [05：疊加數發部座標與場所證據](./05-overlay-moda-coordinates-and-place-evidence.md)
- [06：疊加郵局與無障礙能力證據](./06-overlay-postal-and-accessibility-evidence.md)
- [10：安裝經驗證的完整 Catalog 更新](./10-install-a-verified-full-catalog-update.md)
