# 13：引導首次使用但不強迫授權

Status: ready-for-human

Type: AFK

User stories covered: 57, 59, 66, 75, 79, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓第一次開啟 App 的使用者看到可略過的繁體中文簡介、定位用途說明及隱私／
資料來源入口，然後進入已匯入內建 catalog 的首頁。引導只說明選項，不觸發
定位、通知或診斷授權；完成或略過後不會每次重現，設定中仍可重新查看說明。

## Acceptance criteria

- [x] 第一個 widget test 先以 RED 證明首次開啟顯示可略過引導，略過後到達可用首頁。
- [x] 引導不觸發 Android location、notification 或其他 runtime permission dialog。
- [x] 內建 catalog 匯入完成或進入明確可重試狀態後才顯示首頁，不先顯示誤導性的空結果。
- [x] 使用者可閱讀定位用途、資料來源與隱私入口，不必接受任何資料蒐集才能繼續。
- [x] Onboarding completion 是本機小型 flag，重裝或 reset 後行為可預期。
- [x] 設定入口能重新開啟說明，但不改變已保存的其他偏好。
- [x] Widget tests 使用公開畫面行為，完成 Red-Green-Refactor 並保持離線可測。

## Verification

- `app/test/onboarding_test.dart`：首次略過、零定位呼叫、重啟、重新查看說明、偏好隔離與 reset。
- App startup 先執行 catalog install；失敗顯示可重試狀態。
- Drift schema 7 的 `app_preferences` 只保存 `onboarding.completed.v1`。
- Onboarding 文案已納入 `zh`／`zh_TW` l10n。
- Flutter：28 tests passed；`flutter analyze` 無問題。

## Blocked by

- [02：離線顯示內建資料中的附近 ATM](./02-show-nearby-atms-from-bundled-data-offline.md)
