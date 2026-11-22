# 35：更換 App 圖示、桌面名稱與商店素材

Status: ready-for-human

Type: AFK

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

依擁有者選定的圖示方案，更換 Android／iOS 啟動器圖示與 Play 商店素材，並把桌面顯示名稱縮短為「ATM Finder」。商店標題維持「台灣 ATM Finder」。

設計稿：https://claude.ai/artifact/Pvxf1MkSX6fQLsJ1CTad4V（方案 A 定位鈔票、B 出鈔口、C 元字定位、D ATM 字標）。

等待中：擁有者選定方案。

## Acceptance criteria

- [ ] 選定方案以向量繪製（不依賴字型），輸出 1024 母版到 `app/assets/branding/`。
- [ ] Android adaptive icon：前景／背景分層，主體落在 66dp 安全區內；另有 legacy mipmap 各密度與 monochrome（Android 13 主題圖示）。
- [ ] iOS AppIcon 各尺寸更新。
- [ ] Play 商店 512×512 圖示與 1024×500 主打圖片輸出到 `release/`。
- [ ] Android `android:label` 與 iOS `CFBundleDisplayName` 改為「ATM Finder」；`appTitle`、商店標題、隱私權政策仍為「台灣 ATM Finder」。
- [ ] 若選 A、C、D：`AppTheme.seedColor` 改成與圖示一致的主色，並確認錯誤色與主色可區分。
- [ ] `flutter analyze`、`flutter test`、release-readiness 測試保持綠燈。

## Blocked by

None - can start immediately once the concept is chosen

## Comments
