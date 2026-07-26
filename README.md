# 台灣 ATM Finder

台灣 ATM Finder 是一個以離線優先、繁體中文與資料可追溯性為核心的 Flutter
App。它從經品質 gate 的全台 ATM catalog 顯示附近據點，支援離線文字搜尋、
保守的營業／能力篩選、收藏、偏好銀行、地圖連動、導航、分享與資料回報。

## Product boundaries

- 不需要帳號，沒有廣告或跨裝置同步。
- 只在使用者主動尋找附近 ATM 時要求前景定位。
- 位置、搜尋、收藏與選取 ATM 不會進入診斷資料。
- 首版不整合 Firebase、Crashlytics、Analytics、廣告或其他遠端診斷服務。
- App 提供 ATM 位置資訊，不執行交易、不存取金融帳戶，也不提供貸款服務。
- 未配置 Maps/Places key 或網路不可用時，離線清單與詳細資料仍可使用。

## Repository layout

- `app/`：Flutter Android/iOS/Web application。
- `pipeline/`：ATM catalog builder、品質 gate 與發布契約。
- `.scratch/taiwan-atm-finder/`：PRD 與本機 Markdown issues。
- `docs/`：ADR、整合與測試證據。
- `release/`：政策、商店文字、發行事實與 owner runbooks。
- `performance/reports/`：host 與 Android minimum-tier reports。

## Verify

```powershell
$env:PYTHONPATH = 'pipeline/src'
python -m pytest -q

Push-Location app
try {
  flutter pub get
  flutter analyze
  flutter test --concurrency=1 --exclude-tags production-performance
  flutter test test/production_performance_gate_test.dart
} finally {
  Pop-Location
}
```

Android 10/API 29、2 GB 裝置 gate：

```powershell
.\scripts\run-android10-performance.ps1 `
  -DeviceId emulator-5554 `
  -FlutterCommand flutter
```

## Release and credentials

Production signing material, Google/Firebase configuration and support contact
are supplied only through ignored local files or protected CI environment
secrets. Never commit credentials. The release command intentionally refuses
missing or placeholder owner values:

```powershell
.\scripts\build-release.ps1
```

See [repository governance](.github/repository-governance.md),
[contribution rules](CONTRIBUTING.md), and the
[closed-test/submission runbook](release/closed-test-and-submission-runbook.md).

## Status

All AFK implementation issues are ready for human review. Google Cloud,
Firebase, upload signing, Play Console declarations and closed testing remain
owner-controlled steps; their unchecked criteria are kept explicit under
`.scratch/taiwan-atm-finder/issues/`.
