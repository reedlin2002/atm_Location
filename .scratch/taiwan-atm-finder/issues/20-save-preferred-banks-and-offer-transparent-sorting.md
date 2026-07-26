# 20：保存常用銀行並提供透明排序

Status: ready-for-human

Type: AFK

User stories covered: 21, 22, 23, 24, 25, 26, 37, 58, 80, 90

## Parent

[台灣 ATM Finder PRD](../PRD.md)

## What to build

讓使用者本機選擇多間常用銀行與零或一間主要銀行；清單／詳情標示同銀行或跨行，但預設仍按 access 與距離排序。使用者明確切換「同銀行優先」時，任何常用銀行才被提升，距離作為次排序；App 不顯示保證手續費或「免費」。

## Acceptance criteria

- [x] 先以 RED 測試預設排序不把較遠同銀行排到較近跨行之前。
- [x] 使用者可保存多間 preferred banks，且最多一間 primary bank。
- [x] 設定主要銀行時會自動包含於 preferred banks；移除時行為明確且可測。
- [x] 「同銀行優先」只在使用者明確選取後作用，並於群組內依既有 access/distance 規則排序。
- [x] List/detail 使用 canonical institution code 顯示同銀行／跨行 context。
- [x] UI 不顯示精確 fee、免費保證或帳戶優惠推測，並提供簡短 disclaimer。
- [x] Preferred banks、primary bank 與 sort mode 本機保存且可修改。
- [x] Behavior/widget tests 以 Red-Green-Refactor 完成，不 assert internal provider call order。

## Blocked by

- [18：只用已確認能力篩選 ATM](./18-filter-only-confirmed-capabilities.md)

## Work log

[Issues 16–32 Red–Green–Refactor 工作紀錄](../../../docs/testing/issues-16-32-work-log.md)
