# 台灣 ATM Finder

Flutter App 的第一個離線 tracer bullet。Android 為首發平台，iOS 專案與共用
Dart 領域／資料層一併保留。

## 目前完成

- 安裝包內建銀行、超商與郵局 ATM fixture。
- 首次啟動以 Drift 匯入本機 SQLite；匯入具原子性，可安全重試。
- 以 10 公里為查詢範圍，依直線距離排序並最多回傳 50 筆。
- 首頁使用繁體中文顯示銀行、場所、地址與距離。
- Flutter SDK 固定為 3.44.7；Android 最低 API 24，iOS target 14.0。

目前真實前景定位尚未接上；debug APK 會走「定位不可用」錯誤狀態。離線首頁
行為透過定位系統邊界的測試座標驗證，真實定位與首次使用引導由後續 issue
實作。

## 開發

```powershell
flutter pub get
dart run build_runner build
flutter test
flutter analyze
flutter build apk --debug
```

產出的 debug APK 位於
`build/app/outputs/flutter-apk/app-debug.apk`。
