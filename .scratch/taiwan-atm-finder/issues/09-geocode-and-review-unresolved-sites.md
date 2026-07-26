# 09：補座標並審核未解析據點

Status: ready-for-human

Type: AFK

User stories covered: 1, 9, 18, 43, 45, 83, 84, 85, 87, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

用已核准 geocoder 對缺少座標的新／變更地址做增量定位，驗證地址 components 與台灣 bounds，並讓不精確或衝突結果進入人工 review。客服確認的修正以具理由、證據、審核日期與到期日的版本控制 override 重新發布，App 顯示座標信心與來源。

## Acceptance criteria

- [x] 先以 RED 測試 exact result 被採用、fuzzy/conflicting/out-of-bounds result 被隔離。
- [x] 只處理缺少或已變更地址，不在每次 build 重查所有地址。
- [x] Provider credential 僅從安全 runtime/CI secret 注入，不出現在 logs 或 artifacts。
- [x] 官方 exact、licensed exact、licensed fuzzy、manual reviewed 與 unknown confidence 被明確區分。
- [x] 沒有合法可散布座標的據點仍可文字搜尋，但不進入 distance sort 或 map markers。
- [x] Override 包含 target、fact、reason、evidence、reviewer、review date 與 optional expiry；到期後自動停止套用並回報。
- [x] 品質報告呈現 coordinate coverage、confidence 及 unresolved reasons。
- [x] Pipeline 和 App detail behavior tests 依 Red-Green-Refactor 完成。

## Blocked by

- [07：核准可離線散布的地址定位來源](./07-approve-an-offline-geocoding-source.md)
- [08：保留 ATM 據點身分並保守去重](./08-preserve-site-identity-and-deduplicate-conservatively.md)

## Implementation notes

- `IncrementalGeocoder` 只查缺座標或 prior address 已變更的 record；既有未變更座標不重查。
- 只有唯一、地址一致、Taiwan bounds 內的 `exact` 結果會以 `licensed_exact` 採用；fuzzy、多候選與越界均隔離。
- 依 ADR 0001，正式環境目前沒有核准 provider，故不注入或呼叫任何 credential；介面只允許 server-side provider 實作，repository 與 artifact 無 secret。
- 版本控制的 override schema 包含 target/fact/coordinates/reason/evidence/reviewer/reviewDate/expiry；過期自動停止並寫品質報告。
- 品質報告提供 coverage、confidence 分布與 unresolved reason；App 公開 enum／中文 UI 區分 official、licensed exact/fuzzy、manual reviewed、unknown。
- null 座標既有行為維持：可離線文字搜尋，但附近距離 SQL 與 map marker 會排除。
- 驗證：black/isort/mypy 通過，Python 32/32；Flutter format/analyze 通過，15/15 tests。
