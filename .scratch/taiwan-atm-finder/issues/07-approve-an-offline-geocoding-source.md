# 07：核准可離線散布的地址定位來源

Status: ready-for-human

Type: HITL

User stories covered: 1, 9, 18, 43, 45, 59, 83

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

確認 TGOS／全國門牌地址定位或替代供應者是否允許將地址定位結果長期保存、重新發布並隨 App 離線 catalog 散布。只有具備可稽核授權依據的來源才可成為 pipeline geocoder；若無合適來源，正式決策是保留 unresolved coordinate，而不是偷偷改用具限制的結果。

## Acceptance criteria

- [x] 保存所選服務目前的申請資格、使用條款、儲存與再散布條款證據。
- [x] 明確記錄允許的用途、速率／額度、署名要求及 credential 管理方式。
- [x] 若核准 TGOS，取得僅供 server-side pipeline 使用的 App ID／key，且未寫入 repository。
- [x] 若 TGOS 不允許所需用途，記錄被拒原因並核准另一個具明確授權的 provider，或正式選擇 unresolved fallback。
- [x] 決策指出座標系統、fuzzy 結果處理及資料更新／到期義務。
- [x] 不用 Google Maps 畫面資料或未授權網站爬蟲補足離線資料。

## Blocked by

- [03：產生 App 可匯入的 Catalog Artifact](./03-build-an-importable-catalog-artifact.md)

## Decision

- 已接受 [ADR 0001](../../../docs/adr/0001-geocoding-and-coordinate-distribution.md)：正式採用 unresolved fallback。
- TGOS 公開文件未明確授權把定位結果長期保存、放入公開 catalog artifact 並隨 App 離線再散布，因此目前禁止 pipeline 呼叫。
- TGOS credential 條件不適用；repository 新增 secret ignore 規則，未保存任何 App ID／key。
- 官方 exact 座標可繼續發布；無合法座標者保留 null、可文字搜尋但不進距離排序／map marker。
