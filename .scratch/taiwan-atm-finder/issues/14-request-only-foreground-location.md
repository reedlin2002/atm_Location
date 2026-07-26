# 14：只在使用者操作後要求前景定位

Status: ready-for-human

Type: AFK

User stories covered: 5, 6, 7, 8, 56, 65, 66, 89, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

完成「找我附近」的權限與失敗路徑：只有使用者點擊後才要求 foreground
location；精確或約略位置都能搜尋；拒絕、永久拒絕、定位關閉與 provider error
都顯示可理解的手動搜尋／設定替代方案。App 不宣告背景定位或通知權限，也不
保存被動位置歷史。

## Acceptance criteria

- [x] 先以 RED widget/integration test 證明開啟 App 不要求定位，而點擊「找我附近」才要求。
- [x] Granted precise 與 approximate 結果都能透過 Search Coordinator 顯示附近清單。
- [x] Denied 顯示可用的離線手動搜尋；permanently denied 顯示可開啟系統設定的明確 action。
- [x] Location service disabled 與 provider failure 有不同且可重試的使用者訊息。
- [x] Android manifest 不包含 background location 或 notification permission。
- [x] 使用位置只存在當次 search state，不寫入 recent manual searches 或 server logs。
- [x] Tests fake 平台定位邊界但使用真實暫存 ATM Catalog，並完成 Red-Green-Refactor。

## Verification

- `app/test/location_permission_test.dart`：5 tests，涵蓋零啟動請求、approximate、
  denied、denied forever、services disabled、provider failure 與 manifest 權限。
- `GeolocatorLocationGateway` 僅要求 foreground permission，並提供 app/location settings launcher。
- 搜尋後 `app_preferences` 仍為空，沒有位置歷史持久化。
- Flutter：33 tests passed；`flutter analyze` 無問題。

## Blocked by

- [02：離線顯示內建資料中的附近 ATM](./02-show-nearby-atms-from-bundled-data-offline.md)
