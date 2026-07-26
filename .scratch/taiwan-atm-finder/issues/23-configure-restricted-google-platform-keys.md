# 23：設定受限制的 Google Maps／Places 金鑰

Status: ready-for-human

Type: HITL

User stories covered: 9, 10, 11, 13, 16, 60

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

在擁有者的 Google Cloud 帳號中建立 MVP 專用 project 與 Android Google Maps／Places 配置，使用 package name、簽署憑證、API allowlist、每日 quota 與 billing alerts 限制風險。將 CI／本機需要的配置以安全方式注入，不把可濫用 credential commit 到 repository。

## Acceptance criteria

- [ ] Google Cloud project 與 ATM Finder 專案用途一一對應。
- [ ] Maps SDK 與實際使用的 Places/Geocoding API 分開啟用，只開必要 API。
- [ ] Android key 受 package name 與 debug/release signing certificate 限制；未來 iOS 使用獨立 bundle restriction。
- [ ] Places/Geocoding 設有低於免費月額的每日 quota、budget alert 與可快速停用方式。
- [x] Secrets/configuration 不出現在 Git history、logs、issue body 或可下載 catalog。
- [ ] 實機或 emulator smoke 證明 map load 與一個台灣 place query 成功。
- [x] 無 key／quota exceeded 的 App fallback 仍依前一張 AFK issue 正常。

## Blocked by

- [01：建立專屬專案 Repository](./01-create-dedicated-project-repository.md)
- [02：離線顯示內建資料中的附近 ATM](./02-show-nearby-atms-from-bundled-data-offline.md)
- [22：在線解析地址、車站與地標](./22-resolve-online-addresses-and-landmarks.md)
