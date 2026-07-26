# PRD：台灣 ATM Finder

Status: ready-for-agent

Last updated: 2026-07-25

Working product name: 台灣 ATM Finder

Initial release platform: Android

## Problem Statement

台灣使用者需要提款或使用 ATM 特殊功能時，目前常得分別打開銀行網站、銀行 App、地圖服務或超商資訊，才能猜測附近是否有合適的 ATM。這些來源通常只涵蓋單一銀行，或只知道地點而不知道銀行、設置場所、存款、無障礙、外幣及可進入時間等條件。設在超商、郵局、捷運站、商場及其他非銀行場所的 ATM 尤其容易散落在不同資料來源。

這是一個有時間壓力的任務。使用者需要的不是金融商品或交易功能，而是快速回答：「我現在可以去哪一個 ATM？」如果結果位置錯誤、把未知功能當成不支援、錯誤宣稱免手續費，或把無法進入的 ATM 排在最前面，產品就會失去信任。

產品還必須處理幾個現實限制：

- 台灣目前沒有單一官方資料集同時提供全台覆蓋、座標、營業時間及全部特殊功能。
- 全國 ATM 主資料雖每日更新，卻不包含座標和完整能力欄位。
- 不同銀行與政府資料的格式、更新頻率和 ATM 粒度不同。
- 使用者可能拒絕定位、沒有網路，或尚未完成第一次資料同步。
- 專案由 Android 起步，但不能把領域邏輯與資料架構寫死在 Android，否則未來 iOS 需要重做。
- 專案不建立帳號系統、不做廣告，並以零固定月費為 MVP 預算前提。

## Solution

建立一個面向台灣使用者、Android 優先的跨平台 ATM 據點搜尋 App。App 以 Flutter／Dart 實作，從第一天保留 iOS 專案結構；MVP 先在台灣 Google Play 發布。

使用者可以用目前位置、地址、捷運站、地標、行政區或拖曳地圖尋找 ATM。首頁同時提供 Google Maps 地圖與可拉動的附近清單。結果預設先符合篩選條件，再依「確認可進入、開放狀態未知、確認不可進入」及直線距離排序；同銀行優先是使用者可選的排序模式，不暗中改變預設距離排序。

App 會整合財金公司、數位發展部、中華郵政、金管會銀行局及其他具合法授權的機構資料。資料由 Python 排程管線下載、驗證、正規化、去重、補充能力證據並產生版本化資料；App 不依賴常駐後端，而是下載靜態完整快照或差異更新，保存在本機 SQLite。安裝包內附一份建置時的全台基準資料，因此第一次啟動沒有網路也能以清單搜尋。

資料缺漏採保守表達。只有可靠來源明確證實時，才標示 24 小時、營業中、存款、外幣、輪椅可用或視障語音等能力；未知必須顯示為「未知」，不能推測為不支援。App 不承諾 ATM 即時正常、未缺鈔，也不保證實際手續費。

開發全程採 TDD。每個功能以一個使用者可觀察行為完成 Red → Green → Refactor，再進入下一個垂直切片；測試通過公開介面，自己的模組不互相 mock，只在定位、時間、網路、地圖、外部導航、郵件、分享、當機回報及 geocoder 等系統邊界使用 fake。

## User Stories

1. As a 在外需要現金的使用者, I want to 看見附近 ATM, so that 我能快速決定往哪裡走。
2. As a 不知道附近銀行位置的使用者, I want to 同時看見銀行內與非銀行場所的 ATM, so that 我不會漏掉更近的選擇。
3. As a 常使用超商 ATM 的使用者, I want to 看見設在便利商店內的 ATM, so that 我能在熟悉且容易抵達的場所提款。
4. As a 郵局帳戶使用者, I want to 搜尋郵政 ATM, so that 我能找到同機構據點。
5. As a 不願提供定位權限的使用者, I want to 用地址、行政區或地標搜尋, so that 我仍能完整使用核心功能。
6. As a 願意提供定位權限的使用者, I want to 只在點擊「找我附近」時被要求授權, so that App 不會一開啟就索取敏感權限。
7. As a 只授予約略位置的使用者, I want to 仍取得附近結果, so that 我不用分享不必要的精確位置。
8. As a 拒絕定位的使用者, I want to 在之後需要時再次主動啟用定位, so that 拒絕不會造成永久死路。
9. As a 使用手動位置搜尋的使用者, I want to 搜尋台灣地址, so that 我能查看目的地附近的 ATM。
10. As a 通勤者, I want to 搜尋捷運站、車站或地標, so that 我能在抵達前先規劃。
11. As a 地圖使用者, I want to 拖曳地圖並按「搜尋此區域」, so that 結果會跟著我正在看的區域更新。
12. As a 偏鄉使用者, I want to 在結果太少時自動擴大搜尋半徑, so that 我不會只看到空白頁。
13. As a 都市使用者, I want to 地圖標記自動群組, so that 密集 ATM 不會遮住整張地圖。
14. As a 偏好清單的使用者, I want to 把附近清單拉到全畫面, so that 我能快速比較結果。
15. As a 不方便閱讀地圖的使用者, I want to 只靠清單完成搜尋、查看詳情與導航, so that 地圖不是完成任務的必要條件。
16. As a 使用地圖標記的使用者, I want to 點擊標記後看見相同的 ATM 詳情, so that 地圖與清單不會呈現矛盾資料。
17. As a 使用清單的使用者, I want to 看見 ATM 名稱、銀行、場所、距離和開放狀態, so that 我能在進入詳情前比較。
18. As a 使用者, I want to 看見直線距離而不是不明演算法分數, so that 排序方式透明。
19. As a 使用者, I want to 在搜尋半徑擴大時看見目前範圍, so that 我知道結果可能離我多遠。
20. As a 使用者, I want to 最多先看最近 50 個結果, so that 清單與地圖保持流暢。
21. As a 持有特定銀行金融卡的使用者, I want to 設定多間常用銀行, so that App 能標示哪些 ATM 屬於我的銀行。
22. As a 有主要往來銀行的使用者, I want to 指定一間主要銀行, so that 我能快速套用該銀行篩選。
23. As a 在意跨行費用的使用者, I want to 看見「同銀行」或「跨行」提示, so that 我能自行判斷可能的費用。
24. As a 在意跨行費用的使用者, I want to 不被保證錯誤的精確手續費, so that 帳戶優惠變動不會誤導我。
25. As a 急著提款的使用者, I want to 預設看見符合條件且最近的 ATM, so that 較遠的同銀行 ATM 不會偷偷被排到最近者前面。
26. As a 願意多走一點以找同銀行 ATM 的使用者, I want to 選擇「同銀行優先」排序, so that 結果符合我的當次偏好。
27. As a 需要存款的使用者, I want to 篩選已確認支援現金存款的 ATM, so that 我不會白跑一趟。
28. As a 需要無障礙設備的使用者, I want to 篩選已確認可供輪椅操作的 ATM, so that 我能選擇適用據點。
29. As a 視障使用者, I want to 篩選已確認提供語音輔助的 ATM, so that 我能找到可操作的設備。
30. As a 需要外幣的使用者, I want to 篩選已確認提供外幣提款的 ATM, so that 我能找到特殊設備。
31. As a 夜間使用者, I want to 篩選已確認 24 小時可進入的 ATM, so that 我能降低抵達後無法進入的風險。
32. As a 立即要前往 ATM 的使用者, I want to 篩選目前確認可進入的據點, so that 已知關閉或未知者不會混入。
33. As a 使用者, I want to 依銀行篩選, so that 我能只看指定金融機構。
34. As a 使用者, I want to 依場所類型篩選, so that 我能只看銀行、超商、郵局、交通場站或其他場域。
35. As a 使用者, I want to 清楚看見所有生效中的篩選標籤, so that 我不會忘記為什麼結果變少。
36. As a 找不到結果的使用者, I want to 一鍵清除篩選, so that 我能快速恢復完整結果。
37. As a 有固定需求的使用者, I want to 讓銀行、能力篩選與排序偏好在重開 App 後保留, so that 我不用每次重設。
38. As a 使用者, I want to 讓當次搜尋文字、地圖範圍與動態半徑不被永久保留, so that 下次開啟不會出現難以理解的舊狀態。
39. As a 使用者, I want to 看見「營業中」、「已關閉」或「開放時間未知」, so that App 不會把未知偽裝成確定資訊。
40. As a 使用者, I want to 只有官方或可靠來源明確提供時才看見 24 小時標示, so that 場所類型不會被錯誤推論成營業時間。
41. As a 使用者, I want to 看見 ATM 據點而不是每一台重複機器, so that 地圖與清單不會出現重疊結果。
42. As a 使用者, I want to 同一場所的不同銀行仍分開顯示, so that 同銀行判斷與能力不會混在一起。
43. As a 使用者, I want to 在 ATM 詳情看見地址、銀行、場所、能力、開放資訊與資料日期, so that 我能在出發前判斷可信度。
44. As a 使用者, I want to 看見每項未知能力的明確文字, so that 我不會把空白誤認成不支援。
45. As a 使用者, I want to 看見資料來源與最後更新日期, so that 我能判斷資料新鮮度。
46. As a 使用者, I want to 在資料超過 30 天未更新時收到畫面提醒, so that 我知道結果可能過期。
47. As a 使用者, I want to 將 ATM 座標交給手機上的導航 App, so that 我能使用熟悉的即時路線與交通資訊。
48. As a 安裝多個導航 App 的使用者, I want to 由系統選擇可開啟的導航工具, so that App 不強迫我使用單一導航品牌。
49. As a 使用者, I want to 分享 ATM 的銀行、場所、地址與公開地圖連結, so that 收件者不安裝本 App 也能前往。
50. As a 使用者, I want to 收藏常用 ATM, so that 我能快速回到固定據點。
51. As a 沒有網路的使用者, I want to 離線查看收藏的 ATM, so that 網路中斷時仍能使用。
52. As a 收藏舊據點的使用者, I want to 在資料來源移除 ATM 後看見「來源中已不存在」, so that 收藏不會無聲消失。
53. As a 使用者, I want to 收藏在資料更新或地址微調後仍保留, so that 上游格式改變不會破壞我的資料。
54. As a 重複搜尋地點的使用者, I want to 看見最多 10 筆本機最近搜尋, so that 我能快速重做常見搜尋。
55. As a 重視隱私的使用者, I want to 單筆刪除或清除最近搜尋, so that 我能控制本機資料。
56. As a 重視隱私的使用者, I want to 不保存移動軌跡和每次定位結果, so that App 不會成為位置歷史資料庫。
57. As a 使用者, I want to 不註冊就使用全部核心功能, so that 找 ATM 不需要建立帳號。
58. As a 使用者, I want to 讓收藏、銀行偏好、篩選與最近搜尋只存在手機, so that 服務端不持有個人偏好。
59. As a 第一次安裝且沒有網路的使用者, I want to 使用安裝包內建的 ATM 基準資料, so that 首次啟動不會完全無法使用。
60. As a 暫時離線的使用者, I want to 使用最後成功更新的 ATM 資料, so that 網路錯誤不會阻止搜尋。
61. As a 離線使用地圖失敗的使用者, I want to 自動切換到可操作的清單狀態, so that 空白地圖不會卡住任務。
62. As a 使用者, I want to 更新失敗時保留舊資料, so that 不完整下載不會破壞 App。
63. As a 使用者, I want to 在更新完成後才一次切換到新版本, so that 查詢期間不會看到半套資料。
64. As a 使用者, I want to 每天最多檢查一次資料版本, so that App 保持新鮮又不浪費網路與電量。
65. As a 使用者, I want to 不收到 ATM 更新推播, so that 一般資料異動不會打擾我。
66. As a 使用者, I want to 不被要求通知或背景定位權限, so that App 只索取核心功能真正需要的權限。
67. As a 使用者, I want to 從 ATM 詳情開啟預填內容的回報郵件, so that 我能指出撤除、位置或功能錯誤。
68. As a 使用者, I want to 回報郵件只自動帶入 ATM 識別資料和 App 資料版本, so that 我的目前位置不會被附加。
69. As a 使用者, I want to 透過設定頁寄送一般意見, so that 我不必在商店評論公開細節。
70. As a TalkBack 使用者, I want to 聽見 ATM 名稱、銀行、距離、狀態及按鈕用途, so that 我能獨立完成任務。
71. As a 使用大字體的使用者, I want to 畫面不截斷核心資訊或按鈕, so that 我能正常搜尋和導航。
72. As a 色覺差異使用者, I want to 狀態不只用顏色表示, so that 我能理解營業與能力資訊。
73. As a 夜間使用者, I want to App 與地圖跟隨系統深色模式, so that 畫面不會過亮。
74. As a 平板或橫向手機使用者, I want to 使用不溢位的響應式版面, so that 核心功能在非標準尺寸仍正常。
75. As a 台灣使用者, I want to 使用台灣繁體中文介面, so that 用語符合本地情境。
76. As a 未來英文使用者, I want to 產品文字與官方英文資料已預留在地化結構, so that 新增語言不必重寫核心架構。
77. As a 重視隱私的使用者, I want to 不被廣告或行為分析 SDK 追蹤, so that 找 ATM 不會產生廣告輪廓。
78. As a 願意協助改善穩定性的使用者, I want to 選擇性開啟最小化當機診斷, so that 開發者能修正錯誤。
79. As a 不願傳送診斷資料的使用者, I want to 預設不傳送並可在設定中控制, so that 資料蒐集基於明確選擇。
80. As a 使用者, I want to 免費且無付費排序地使用 App, so that 搜尋可信度不受商業置入影響。
81. As a 資料維護者, I want to 每日自動下載官方來源並保存原始校驗碼, so that 每次發布可追溯。
82. As a 資料維護者, I want to 在來源 schema 改變時停止發布, so that 壞資料不會自動進入使用者裝置。
83. As a 資料維護者, I want to 看見記錄數、座標覆蓋率、重複、隔離及來源差異報告, so that 我能評估新版本品質。
84. As a 資料維護者, I want to 以版本控制的人工修正檔處理客服回報, so that 修正有原因、證據、日期與審核紀錄。
85. As a 資料維護者, I want to 讓人工修正可設定到期日, so that 暫時修正不會永久覆蓋後續官方更新。
86. As a 資料維護者, I want to 讓地址變更後的同一 ATM 保留穩定 ID, so that 使用者收藏不會失效。
87. As a 資料維護者, I want to 將不確定的合併候選隔離供檢查, so that 模糊比對不會把不同 ATM 誤合併。
88. As a 開發者, I want to 讓 Android 與未來 iOS 共用領域、資料與大部分 UI, so that iOS 擴充不必重做產品。
89. As a 開發者, I want to 讓平台服務隱藏在小型介面後, so that 定位、地圖、導航和診斷可以獨立測試或替換。
90. As a 開發者, I want to 以一個行為一個 Red-Green-Refactor 循環交付, so that 測試反映實際行為而不是想像中的結構。

## Implementation Decisions

### Product scope and terminology

- Product working name is **台灣 ATM Finder**. Final store name, icon and brand assets are a release task, not an architecture dependency.
- The primary domain entity is an **ATM 據點**, not an individual physical machine.
- Records from the same institution, normalized address and installation place are merged into one ATM 據點. Different institutions at the same address remain separate.
- **能力** means a feature supported by an ATM 據點, such as cash deposit, wheelchair operation, audio assistance or foreign-currency withdrawal.
- Every capability and access fact is tri-state: `confirmed supported/open`, `confirmed unsupported/closed`, or `unknown`. Absence from a positive-list source does not automatically mean unsupported.
- **目前可進入** describes access to the ATM location, not whether the machine is healthy or contains cash.
- The App must never describe ATM status as real time unless a future source explicitly supports it.

### Mobile technology and supported platforms

- Use Flutter and Dart in a single mobile codebase.
- Preserve Android and iOS targets from project creation, but only Android is in the MVP release scope.
- Minimum Android version is Android 7.0, API 24.
- Set Android target SDK to the latest Google Play requirement at release time.
- The future iOS target uses the minimum version supported by the selected current Flutter and Google Maps packages; the planning baseline is iOS 14.
- Phone portrait is the primary design target. Landscape phones and tablets must remain functionally complete and free of layout overflow, without requiring a bespoke tablet information architecture.
- Use Flutter's localization generation. MVP ships only Taiwan Traditional Chinese, while all interface strings remain externalized and source records may retain official English names and addresses.

### Mobile architecture

- Build a modular monolith, not microservices and not a large collection of shallow pass-through layers.
- Use feature-oriented modules with domain behavior behind small public interfaces.
- Use Riverpod for dependency composition and UI state. Tests assert visible behavior and public state transitions, not provider implementation details.
- Use Drift on SQLite for the installed ATM catalog, indexes, migrations, favorites and local preferences that need relational integrity.
- Use SharedPreferences only for small, non-critical flags such as onboarding completion and diagnostic opt-in; do not split core user data across several key-value stores.
- Use immutable domain values and explicit result/error types for catalog import, update, search and platform actions.
- Google Maps types must remain inside the map adapter and presentation layer. Domain and persistence models use provider-neutral WGS84 latitude and longitude values.
- All displayed time and schedule calculations use the `Asia/Taipei` timezone and a replaceable clock boundary.

### Deep modules and public responsibilities

- **ATM Catalog**: owns installed catalog import, version, site lookup, bounding-box candidate selection, exact distance calculation, filtering, sorting, full-text offline search and retired-site lookup. Its public surface exposes user-level queries rather than raw database tables.
- **Dataset Synchronizer**: owns daily manifest checks, delta-chain selection, full-snapshot fallback, download verification, schema compatibility, transactional apply, monotonic-version protection and rollback. Callers receive a small result describing `up-to-date`, `updated`, `using-old-data`, or `incompatible`.
- **Search Coordinator**: combines user location or resolved manual location with saved criteria, adaptive radius rules and catalog queries. It does not know SQLite or Google Maps details.
- **Location and Place Resolver**: exposes foreground current-position requests and manual place resolution. It translates permission states and provider failures into user-facing outcomes without leaking platform exception types.
- **Preferences and Collections**: owns preferred institutions, primary institution, persisted filters, sort mode, favorites and up to 10 recent manual searches.
- **Platform Actions**: owns navigation intents, system share sheet and prefilled email feedback. It never sends mail or shares data without an explicit user gesture.
- **Diagnostics**: exposes opt-in crash reporting with a strict allowlist of technical fields and no product analytics.
- **Catalog Builder**: Python deep module that turns immutable raw source snapshots, the prior canonical catalog and reviewed overrides into a full snapshot, deltas, manifest and quality report.
- **Source Adapters**: one Python adapter per official source. Each adapter owns transport, encoding, source schema and mapping into a common evidence model.
- **Identity Reconciler**: preserves stable ATM site IDs across source reorderings and minor corrections, merges only high-confidence same-institution sites, and emits uncertain candidates for review.
- **Artifact Publisher**: publishes only a catalog that passed every quality gate and retains the previous good release for rollback.

### Map, list and navigation experience

- Use Google Maps through the official Flutter plugin for Android and future iOS.
- Home uses a map with clustered ATM markers and a draggable nearby-results sheet. The sheet can expand to a full-screen list.
- Panning the map does not immediately query on every camera frame. After movement settles, show an explicit「搜尋此區域」action.
- When map tiles are unavailable, keep the list, detail and actions usable and explain that the map requires a connection.
- Navigation leaves the App through a standard platform intent or URL, passing site name, address and coordinate. Do not calculate routes or travel time inside MVP.
- Share through the system share sheet using bank, place name, address and a public map URL. Do not implement App deep links in MVP.

### Search behavior

- Foreground current location is requested only after the user taps「找我附近」or an equivalent explicit action.
- Do not request background location. Do not request notification permission.
- Without location permission, the user can search by online place resolution, recent manual searches, administrative area, ATM place name/address, or map movement.
- Offline manual search covers content already present in the ATM catalog, including institution, place name, address, county and district. Arbitrary new landmark-to-coordinate resolution may require a network connection.
- Online manual place resolution is isolated behind a provider interface. The default provider is Google Places/Geocoding with Android/iOS key restrictions and daily quotas set below the monthly free-use allowance.
- Recent searches store only user-entered label, resolved coordinate and timestamp, up to 10 entries, locally. They never store passive current-location samples.
- Nearby search begins at 1 km, then automatically tries 3 km, 5 km and 10 km until it has at least 20 eligible results.
- Show at most the nearest 50 results initially. If none are found at 10 km, offer an explicit wider search or map-area search rather than silently expanding without limit.
- Use an indexed latitude/longitude bounding box to select candidates, followed by exact Haversine straight-line distance.
- Do not call a route matrix to sort results.

### Filtering and sorting

- MVP filters include institution, installation-place category, confirmed cash deposit, confirmed wheelchair operation, confirmed audio assistance, confirmed foreign-currency withdrawal, confirmed 24-hour access and confirmed currently accessible.
- Unknown capability values are excluded from a positive capability filter but remain in unfiltered results.
- Default ordering is: matching the explicit filters, then confirmed currently accessible, then access unknown, then confirmed inaccessible, then straight-line distance ascending.
- The default ordering does not promote the user's bank ahead of a closer result.
- An explicit「同銀行優先」sort promotes any saved preferred institution, with distance as the secondary sort.
- Preferred institutions may contain several institutions and exactly zero or one primary institution.
- The UI shows `你的銀行`, `同銀行`, or `跨行` context but does not promise a fee amount or use the word `免費` without a separately governed reliable rule source.
- Persist preferred institutions, primary institution, explicit feature filters and sort mode. Do not persist the prior map viewport, adaptive radius or current query as hidden active state.
- Always display active filter chips and provide a single reset action.

### ATM detail and user actions

- Detail shows stable site ID in diagnostic/feedback context, institution, installation place, address, distance when a search origin exists, place category, access status, known capabilities, unknown capabilities, source date and catalog version.
- Detail offers favorite, navigation, share and email-report actions.
- A removed site remains retrievable if it is favorited, shows its last-known facts and is clearly marked as absent from the current source.
- Feedback opens the user's email client with site ID, institution, place, address, current catalog version and App version. It does not attach current user location.
- A general feedback email action is available in Settings.
- Google Play reviews are an additional public feedback channel, not the preferred place for detailed addresses or screenshots.

### Local user data

- There is no registration, login, cloud profile or cross-device synchronization.
- Favorites, preferred institutions, primary institution, filters, sort mode and recent searches are local only.
- Favorites reference stable ATM site IDs and remain intact through catalog updates.
- Recent searches are capped at 10 and support individual deletion and clear-all.
- Provide a single local-data reset action with an explicit confirmation. Resetting data is separate from clearing filters.

### First run and onboarding

- First run presents a short, skippable introduction, optional preferred-institution selection, a concise location-use explanation and links to privacy/data-source information.
- Do not trigger the Android location permission dialog during onboarding.
- Diagnostic collection is default-off. The onboarding may explain it but cannot preselect opt-in.
- Import the bundled baseline catalog before presenting an empty home state.
- If import fails, show a recoverable error and retry action; never crash-loop.

### Local catalog contract

- The distributable contract consists of a small JSON manifest plus gzip-compressed newline-delimited JSON artifacts.
- The full snapshot contains one canonical ATM site record per line.
- Delta artifacts contain explicit `upsert` and `retire` operations and declare their exact source and target dataset versions.
- The manifest contains schema version, monotonic dataset version, publication time, source names and source dates, record count, full-snapshot URL and SHA-256, and all available delta URLs and SHA-256 values.
- The App accepts only supported schema versions and strictly newer dataset versions.
- The App prefers a valid delta chain from its installed version and falls back to the full snapshot when the chain is unavailable, invalid or longer than the configured safe limit.
- Import and delta application occur in a transaction against a staging database or staging tables. The active catalog changes only after validation succeeds.
- Keep one previous good local catalog until the new catalog has opened successfully.
- The bundled baseline artifact uses the same schema and import path as a network full snapshot.

### Canonical ATM site data

- Each site stores a stable opaque ID, institution code/name, installation-place name, place category, normalized and display addresses, county/district, WGS84 coordinate, coordinate evidence/confidence, active/retired status and last-seen date.
- Capabilities store tri-state value plus evidence source and evidence date. A more recent authoritative negative may supersede an older positive; source priority and conflict rules are deterministic and reported.
- Access data stores explicit 24-hour evidence and any reliable schedule. `open now` is derived only from reliable schedule data and the replaceable Asia/Taipei clock.
- Source record keys and provenance are retained for audits but are not treated as stable public IDs.
- Place categories are a controlled vocabulary: bank, convenience store, post office, transit, retail, hospital, government, education, other and unknown.
- Coordinate confidence is a controlled vocabulary: official exact, licensed address exact, licensed address fuzzy, manual reviewed and unknown.
- Records without a distributable coordinate remain available to offline textual/administrative search but are excluded from distance ranking and map markers until resolved.

### Identity and deduplication

- The initial deterministic identity seed uses institution code, normalized address and normalized installation-place name.
- Future builds consume the prior canonical catalog so minor source corrections can retain an existing stable ID.
- Exact source-key continuity wins when a trustworthy source key exists.
- Same-institution records with equivalent normalized addresses and place names merge automatically.
- Same-institution records with a coordinate movement within a conservative threshold may be proposed as continuity, but fuzzy candidates with conflicting evidence are quarantined for review.
- Different institution codes never merge into one ATM site.
- Capabilities from merged machine-level records are combined only when the source proves they belong to the same site.
- Every automatic merge and stable-ID reassignment is reproducible and represented in the quality report.

### Official source strategy

- Use the daily Financial Information Service Co. national ATM location list as the coverage and active-status backbone.
- Overlay coordinates and capability evidence from the current Ministry of Digital Affairs cash-distribution dataset only where institution/address identity matches. Its event-specific service field does not define permanent ATM behavior.
- Use Chunghwa Post's daily national ATM distribution as the detailed authoritative source for postal sites and supported postal capabilities.
- Use Financial Supervisory Commission accessibility positive lists for wheelchair and visual-assistance evidence.
- Add individual institution open-data adapters only when the source has explicit machine-readable access and a compatible redistribution license.
- Do not scrape Google Maps, bank web pages or convenience-store pages whose terms do not authorize this use.
- Store raw downloaded files immutably by source/date/checksum to make a release reproducible.
- Attribute each source and the Open Government Data License as required in the App's data-source screen and published artifacts.

### Address normalization and geocoding

- Normalize Taiwan character variants, whitespace, full-width characters, county/city and district representation for matching, while preserving the original display address.
- Prefer coordinates already supplied by an official, redistributable source.
- For remaining addresses, use a server-side geocoder adapter in the Python pipeline, never an unrestricted secret embedded in the App.
- TGOS／National Address Location Service is the preferred Taiwan-specific candidate because it supplies WGS84/TWD97 results and is free to apply for, but production may redistribute stored results only after its current terms are reviewed and recorded.
- If the preferred geocoder's terms do not permit offline redistribution, use another explicitly licensed provider or leave the coordinate unresolved. Do not silently substitute Google Geocoding results into a permanently distributed offline dataset without confirming its storage terms.
- Fuzzy geocoding results are not equal to official exact coordinates. They receive lower confidence and require bounds and address-component checks.
- Never publish coordinates outside Taiwan's accepted bounding region or coordinates at generic county/city centroids as if they were an ATM location.

### Data pipeline and quality gates

- Implement the pipeline in Python with pytest.
- Run the scheduled pipeline once per day. A source may be checked daily even when it publishes less frequently.
- Download failures, unexpected content types, schema drift, decoding failures or incomplete sources fail closed: retain the previous published catalog.
- A release accounts for every primary-source row as canonicalized, merged or quarantined with a reason.
- Required institution and address fields must parse for 100% of published active sites.
- Canonical site IDs must be unique and referentially valid.
- Every published coordinate must be finite and inside the configured Taiwan bounds.
- Production launch target: at least 98% of active canonical sites have an official-exact or licensed-address coordinate; unresolved records remain auditable.
- A change of more than 2% in total active site count, a material county-level drop, or an unusual institution-level drop requires manual approval before publication.
- Unknown capability rates are reported but do not block publication.
- The quality report includes raw counts, parsed counts, quarantine counts/reasons, canonical counts, merges, retirements, coordinate confidence, capability coverage, source freshness and diffs from the prior release.
- Manual overrides live in version control and include target stable ID/source key, changed fact, reason, evidence reference, reviewer, review date and optional expiry.
- An expired override stops applying automatically and appears in the report.

### Static distribution and cost controls

- There is no traditional always-on application backend.
- Default MVP distribution uses a dedicated public GitHub repository: scheduled GitHub Actions build artifacts; immutable full snapshots and deltas are release assets; a small stable manifest is published at a fixed HTTPS location.
- The current parent workspace remote is unrelated and must not be used. Create a dedicated project repository before CI or public artifact publishing.
- Encapsulate artifact URLs so static hosting can move later without changing domain or catalog logic.
- Set quotas and budget alerts for any map/place APIs. Do not rely on an uncapped pay-as-you-go configuration.
- Do not introduce a recurring paid service without a new explicit product decision.
- Expected unavoidable MVP distribution cost is the one-time Google Play developer registration fee. Future iOS distribution requires the Apple Developer Program annual fee.

### Privacy, diagnostics and security

- Collect no account, server-side favorites, passive location history, behavioral analytics or advertising identifier.
- Foreground location is used to perform the current search and is not uploaded to the project's own service.
- Diagnostic reporting is opt-in and default-off.
- Diagnostic payloads may include stack trace, App version, operating-system version and device model. They must not add precise/approximate location, query text, preferred institutions, filters, recent searches, favorites, ATM viewed, email content or advertising ID.
- Use Firebase Crashlytics only behind the diagnostic boundary and only after consent; do not enable Firebase Analytics.
- Restrict Google Maps/Places keys by Android package and signing certificate, by iOS bundle ID when added, and by API allowlist and quota.
- Pipeline geocoder credentials and release secrets live in CI secret storage and never in repository artifacts.
- Use HTTPS for all data downloads. Verify artifact SHA-256 and monotonic version before import.
- Provide a Traditional Chinese privacy policy and accurate Google Play Data safety declaration before closed testing.
- The App locates ATMs and performs no banking, payment, transfer, account access or personalized financial advice. Complete Google Play's mandatory Financial features declaration accurately; the planning interpretation is「no financial features」, subject to Play review.

### Accessibility and visual behavior

- Follow system light/dark mode; MVP does not need an independent theme selector.
- Map styling follows the system theme when supported.
- Every actionable element has a semantic label and meaningful focus order.
- ATM list items expose institution, place, distance and access state to TalkBack.
- Color is never the only indicator of capability, selection, warning or access state.
- Support Android font scaling without clipping critical content or hiding navigation/report actions.
- Maintain practical touch target sizes and sufficient contrast.
- The list path must provide a complete non-map alternative.
- Test narrow phones, large fonts, landscape and tablet constraints.

### Release strategy

- Development and routine manual testing may be done by the owner.
- Begin with local/emulator builds, then Google Play Internal testing.
- Because the owner does not have a pre-2023 Play developer account, public release requires a Closed test with at least 12 opted-in testers for 14 continuous days under current Google Play policy.
- Recruit more than 12 invitees at release time to protect against dropouts and seek varied Taiwan regions, device vendors, Android versions and accessibility settings.
- The first production release targets Taiwan only.
- Google Play does not support a percentage staged rollout for the first production release. Use staged rollout for later updates and monitor Play vitals, opt-in crash reports and feedback.
- The App is free, contains no ads, subscriptions, in-app purchases or paid placement.

### Performance and launch quality targets

- A warm launch should become interactive within 2 seconds on the defined minimum-class test device, excluding first baseline import.
- First baseline import should complete within 5 seconds on the minimum-class test device or present deterministic progress and remain responsive.
- A local nearby query over the production-size catalog should complete within 300 ms at the 95th percentile on the minimum-class test device.
- The initial compressed bundled catalog target is 10 MB or less; crossing it requires an explicit size review, not silent removal of offline coverage.
- The App must remain usable when the update host, geocoder, map tiles, navigation App, mail App or diagnostic service is unavailable.
- No release-blocking crash, data corruption, permission dead end, inaccessible core action or unhandled schema incompatibility may remain at production candidate.

## Testing Decisions

### TDD philosophy

- Tests specify observable behavior through public interfaces. They do not test private methods, provider internals, database rows behind the public catalog interface, internal call counts or implementation order.
- One vertical behavior is implemented at a time: write one failing test, write the minimum code to pass, then refactor only while green.
- Do not write a horizontal batch of imagined tests followed by a horizontal batch of implementation.
- Prefer real code paths and real temporary SQLite databases. Mock or fake only true system boundaries.
- A refactor that does not change behavior should not require rewriting behavior tests.
- Coverage is a diagnostic tool, not the definition of quality. Critical paths and risky branching behavior receive priority over an arbitrary global percentage.

### First App tracer bullet

- The first failing Flutter behavior test is: **with no network, when the location boundary supplies a test coordinate and the bundled fixture catalog is available, opening Home shows nearby ATM sites ordered by distance**.
- The test crosses bundled import, a real temporary SQLite database, ATM Catalog, Search Coordinator, state composition and the visible Flutter list.
- The location provider and map platform view are replaced at their system boundaries. The repository/catalog implementation is not mocked.
- The minimum implementation does not include filters, favorites, production map markers or speculative abstraction beyond what this behavior reveals.

### First data-pipeline tracer bullet

- The first failing pytest behavior test is: **given a small official-source fixture and no prior release, Catalog Builder publishes a valid canonical full snapshot, manifest and quality report that the Flutter contract reader can import**.
- The fixture includes at least a bank site, a convenience-store site, a postal site and one duplicate machine-level row.
- The output is verified through the published contract, not by testing private normalization helpers.
- The next cycle adds prior-catalog identity continuity and a delta only after the full snapshot tracer is green.

### App test layers

- **Domain/integration tests** cover ATM Catalog queries, adaptive radius, distance, tri-state filters, open/unknown/closed ranking, same-bank sort, stable favorites, retired sites, manifest compatibility, update rollback and recent-search limits through public interfaces.
- **Widget tests** cover onboarding, permission outcomes, map/list coordination through a fake map boundary, active filter chips, empty/error/offline states, detail actions, local-data reset, dark/light themes, large text and semantics.
- **Contract tests** import pipeline-produced fixtures using the production App importer and reject unsupported schema, wrong checksum, invalid delta chain, duplicate IDs and downgrade versions.
- **Integration tests** on Android cover foreground permission, real SQLite persistence across restart, Google Maps smoke behavior, external navigation chooser, share sheet, email intent and update from a local HTTPS test host.
- **Golden tests** are limited to stable, decision-rich states such as Home list/sheet, filters and details in light/dark and phone/tablet sizes. They complement rather than replace semantic assertions.
- **Manual accessibility tests** use TalkBack and maximum practical font scaling on a real Android device before closed testing and production.
- **Manual offline tests** include first launch with network disabled, warm launch with stale data, map tile failure, interrupted update and full storage/retry behavior.

### Pipeline test layers

- Source-adapter contract tests use checked-in raw fixtures representing the exact encodings and headers observed from each source.
- Catalog Builder behavior tests cover source precedence, positive/negative/unknown evidence, deterministic output, address preservation, normalization, deduplication, stable identity, retirement and override expiry.
- Property-based tests are appropriate for address normalization idempotence, coordinate bounds, stable deterministic IDs and delta round trips.
- Snapshot tests may be used for small quality reports and manifests when reviewed as behavior contracts, not for opaque large outputs.
- A full dry-run job downloads current sources but never publishes; it reports schema drift and quality changes.
- Publication tests prove that a failed source, failed quality gate or failed upload cannot advance the public manifest.

### System-boundary fakes

- Fake boundaries are allowed for foreground location, permission state, clock, HTTP transport, online place resolution, map platform view, navigation launcher, system share, email launcher, diagnostics and artifact publishing.
- The fake's contract must mirror outcomes the App uses, not mirror every method of a third-party SDK.
- Do not mock ATM Catalog inside Search Coordinator behavior tests when a real temporary catalog can be used.
- Do not test that an internal service was called a specific number of times unless the observable requirement is itself a rate or quota.

### CI gates

- Flutter formatting, static analysis and all Dart/Flutter tests pass.
- Python formatting/linting, type checks and pytest pass.
- The cross-language catalog contract test passes using the artifact built in the same CI run.
- Android debug build succeeds on every change; release App Bundle build succeeds for release candidates.
- Dependency and secret scanning pass.
- The scheduled source-drift workflow runs separately from code CI and cannot publish unless code, pipeline, contract and quality gates all pass.
- Failed catalog publication leaves the last good manifest and artifacts untouched.

### TDD delivery sequence

1. Establish reproducible Flutter/Python toolchains and the versioned catalog contract.
2. Complete the App offline-nearby tracer bullet.
3. Complete the pipeline full-snapshot tracer bullet and cross-language import.
4. Add stable identity and delta update one Red-Green-Refactor behavior at a time.
5. Add manual location search and foreground permission outcomes.
6. Add adaptive radius, tri-state filters and transparent sorting.
7. Add map/list coordination, clustering and ATM details.
8. Add favorites, preferences, recent searches and retired-site behavior.
9. Add navigation, sharing and email reporting.
10. Add update rollback, stale-data warnings and failure states.
11. Add accessibility, responsive layouts, localization scaffolding and dark mode.
12. Add opt-in diagnostics, privacy/store declarations and release automation.
13. Run production-data quality acceptance, internal testing and the required closed test.

### Definition of done for the MVP

- Every in-scope user story has at least one behavior-level acceptance test or an explicitly documented manual platform/accessibility check.
- All automated gates are green.
- Production catalog quality gates pass and the build contains a current baseline catalog.
- The App works without login, without location permission and without network for the documented offline subset.
- No permission is requested before the related user gesture.
- Unknown capability/access values are visible and never silently interpreted as negative.
- Interrupted and invalid updates preserve the last good catalog and user favorites.
- TalkBack can complete search → detail → navigation without relying on the map.
- Privacy policy, data-source attribution, support email and Google Play declarations are complete.
- At least 12 testers remain opted into the required closed test for 14 continuous days and production access is approved.

### Prior art

- The project directory contained no existing source code or tests when this PRD was written, so there is no repository-local prior test style to copy.
- The first tracer bullets in this document establish the prior art for future App and pipeline work.

## Out of Scope

- User registration, login, profiles or cloud synchronization.
- iOS App Store delivery in the MVP; the shared project structure and code must remain iOS-capable.
- Web, desktop, watch or wearable applications.
- In-App user-generated edits, moderation queues or a web administration panel.
- Automatically ingesting Google Play reviews as structured corrections.
- Real-time ATM machine health, cash inventory, denomination availability or queue length.
- Guaranteeing that an ATM is working merely because its location is accessible.
- Exact transaction fees, account-specific free-withdrawal quotas, promotions or fee guarantees.
- Banking login, balance access, card data, transfers, payments, withdrawals or any financial transaction.
- In-App route planning, live traffic, travel-time matrix or turn-by-turn navigation.
- Complete offline map tiles or offline turn-by-turn navigation.
- Background location, geofencing, nearby-ATM notifications or push notifications.
- Advertising, sponsorship placement, paid ranking, subscriptions, in-app purchases or monetization SDKs.
- Behavioral product analytics, advertising IDs, session replay or passive movement history.
- Advanced machine features without reliable common data, including cash denominations, cardless withdrawal, passbook updates, bill payment and coin deposit.
- User notes, favorite folders, social features, comments or public ratings for an ATM.
- App-specific sharing deep links or referral systems.
- Automatic inference that every convenience store is open 24 hours.
- Scraping sources whose terms do not permit automated collection and redistribution.
- A traditional always-on API/backend for ATM queries.
- A dedicated operator dashboard; reviewed corrections use version-controlled override files.
- Independent in-App light/dark selector in MVP.
- A polished tablet-only navigation model.
- Final brand name, logo and marketing campaign beyond what Google Play submission requires.

## Further Notes

### Confirmed source references

- [金融機構 ATM 位置查詢一覽表](https://data.gov.tw/dataset/24333): national coverage backbone, daily update, institution/place/county/address fields, Open Government Data License.
- [114 年發放現金 ATM 裝設地點明細](https://data.gov.tw/dataset/175482): coordinates, place category, accessibility and service fields for participating institutions; event-specific and irregularly updated, so it is an overlay rather than the permanent active-status authority.
- [全國郵局 ATM 分布](https://data.gov.tw/en/datasets/6121): daily postal locations, coordinates and postal capabilities.
- [可供視障民眾使用之 ATM 設置地點資訊](https://data.gov.tw/dataset/73189): daily accessibility positive list; related wheelchair data should be integrated through its own adapter.
- [TGOS address-location documentation](https://api.tgos.tw/TGOS_MAP_API/docs/site/web/AddrLocate): Taiwan-specific address location candidate; current application and redistribution terms must be archived before production use.
- [Google Maps Platform pricing](https://developers.google.com/maps/billing-and-pricing/pricing): current native Maps SDK usage and Places/Geocoding quotas must be rechecked at implementation and release time.
- [Google Play testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465): current new-personal-account closed-test requirement.
- [Google Play Financial features declaration](https://support.google.com/googleplay/android-developer/answer/13849271): mandatory declaration even when the App declares no financial features.

### Operational assumptions

- The project will receive a dedicated source repository before CI, scheduled data builds or public artifacts are configured.
- The owner can obtain a restricted Google Maps key, a public support email and any approved server-side address-location credential.
- A macOS/Xcode environment is required only when iOS build and signing work begins.
- Source pricing, package support and store policy are time-sensitive and must be rechecked at implementation/release rather than copied permanently from this PRD.
- The zero-fixed-monthly-cost target does not authorize unbounded variable billing. Quotas and alerts are required before enabling a billable API.

### Key risks and mitigations

- **Incomplete coordinates**: prioritize official coordinates, use a licensed geocoder, publish confidence and keep unresolved sites text-searchable.
- **Capability gaps**: use tri-state evidence, report unknown rates and never infer from place names.
- **Source schema drift**: source-specific fixtures and fail-closed daily builds.
- **Wrong deduplication**: conservative same-institution rules, prior-catalog identity continuity and quarantine uncertain matches.
- **Stale event-specific data**: daily national master controls active status; event datasets contribute only matching evidence with dates.
- **Static-host outage**: bundled/last-good catalog keeps App usable.
- **Corrupt or malicious artifact**: HTTPS, SHA-256, supported schema, monotonic version and transactional import. Artifact signing may be added later if threat review justifies it.
- **Google API cost**: native map usage is isolated from place-search calls; quotas, restrictions and provider boundaries prevent accidental runaway usage.
- **Google Play release eligibility**: plan the 12-person/14-day closed test before the production candidate.
- **Financial-app classification ambiguity**: the product does not manage money; complete the declaration accurately and resolve any Play review request before public release.

### Review focus

The product owner should review this PRD once for:

- whether the MVP user stories match the intended product;
- whether the conservative unknown-data behavior is acceptable;
- whether the zero-fixed-cost static distribution is acceptable;
- whether the TDD sequence and launch gates are strict enough;
- whether any item currently listed Out of Scope must move into MVP.

After approval, use the issue-splitting workflow to convert this PRD into independently grabbable tracer-bullet issues. Do not start by creating horizontal issues such as「build all models」or「write all tests」.
