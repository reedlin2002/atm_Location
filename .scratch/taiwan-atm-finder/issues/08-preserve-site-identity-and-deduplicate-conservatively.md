# 08：保留 ATM 據點身分並保守去重

Status: ready-for-human

Type: AFK

User stories covered: 41, 42, 52, 53, 86, 87, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓 Catalog Builder 以 prior catalog 保留穩定 ATM 據點 ID，並用同銀行、正規化地址、場所及可信來源 key 做保守去重。小幅地址修正後仍是同一據點；不同銀行、衝突座標或無法唯一判斷的候選不得誤合併，須進入 review report。

## Acceptance criteria

- [x] 先以 RED 測試一個地址格式微調仍保留 stable site ID，而同地址不同銀行仍有不同 ID。
- [x] 初始 ID 產生具決定性；同一輸入不受 row order 影響。
- [x] Trustworthy source key continuity 優先於文字格式差異。
- [x] Fuzzy continuity 只提出候選，衝突或低信心資料進入 quarantine/review。
- [x] 每個 merge、ID continuity 與 retirement decision 可在品質報告追溯。
- [x] Canonical IDs 唯一，合併後能力 evidence 不會跨銀行污染。
- [x] App 從新 snapshot 讀到相同站點時仍使用原 stable ID。
- [x] Property/behavior tests 經 Red-Green-Refactor 通過，未測 private normalization helper。

## Blocked by

- [05：疊加數發部座標與場所證據](./05-overlay-moda-coordinates-and-place-evidence.md)
- [06：疊加郵局與無障礙能力證據](./06-overlay-postal-and-accessibility-evidence.md)

## Implementation notes

- Snapshot 保存排序後的 `sourceKeys`；prior snapshot 的可信來源 key 優先承接 canonical ID，其次才用 exact identity。
- 初始 ID 仍由銀行代碼、正規化地址與場所決定，反轉 row order 後 ID 與 source keys 完全相同。
- Fuzzy 文字只寫入 `reviewCandidates`，不沿用 prior ID；座標衝突清空座標並標記 `quarantined_coordinate_conflict`。
- 品質報告逐筆保存 `idContinuity`，並列出 merge、review candidate 與 prior ID retirement。
- Canonical identity 含 institution code；同址不同銀行保持不同 ID，能力不會跨銀行合併。
- App full snapshot importer 直接保存 canonical ID，跨版本相同 ID 不重新衍生。
- 驗證：black/isort/mypy 通過，pytest 27/27。
