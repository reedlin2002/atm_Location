# 01：建立專屬專案 Repository

Status: ready-for-human

Type: HITL

User stories covered: 88, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

為 ATM Finder 建立獨立、公開的 GitHub repository，讓原始碼、CI、排程資料管線及靜態 catalog artifacts 不會誤用目前父層個人網站的 remote。保留現有本機 PRD 與 issues，之後的 agent 才能安全設定 GitHub Actions 與 release assets。

## Acceptance criteria

- [ ] ATM Finder 有自己的 GitHub repository 與明確擁有者。
- [x] 目前專案目錄的 Git 操作不會 push 到父層個人網站 repository。
- [ ] Repository 可使用 GitHub Actions、Releases 及公開 HTTPS artifacts。
- [ ] 預設分支與最基本的合併保護方式已決定。
- [ ] 未建立或公開任何 Google、Firebase、TGOS 或簽署私密金鑰。
- [ ] 若 issue tracker 之後改用 GitHub Issues，先更新 `docs/agents/issue-tracker.md`，不在本票內自行遷移或關閉本機 issues。

## Blocked by

None - can start immediately
