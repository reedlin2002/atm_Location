// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '台灣 ATM Finder';

  @override
  String get nearbyAtmsTitle => '附近 ATM';

  @override
  String get loadingAtms => '正在載入附近 ATM';

  @override
  String get loadAtmsError => '目前無法載入 ATM 資料';

  @override
  String get retry => '重新嘗試';

  @override
  String get noNearbyAtms => '附近沒有找到 ATM';

  @override
  String get mapUnavailable => '地圖暫時無法使用';

  @override
  String get viewDetails => '詳細資料';

  @override
  String placeCategoryLabel(String category) {
    return '場所類型：$category';
  }

  @override
  String placeCategoryEvidenceSourceLabel(String source) {
    return '場所來源：$source';
  }

  @override
  String coordinateEvidenceSourceLabel(String source) {
    return '座標來源：$source';
  }

  @override
  String evidenceDateLabel(String date) {
    return '資料日期：$date';
  }

  @override
  String evidenceConfidenceLabel(String confidence) {
    return '信心：$confidence';
  }

  @override
  String get placeCategoryBank => '銀行';

  @override
  String get placeCategoryConvenienceStore => '便利商店';

  @override
  String get placeCategoryPostOffice => '郵局';

  @override
  String get placeCategoryOther => '其他場所';

  @override
  String get placeCategoryUnknown => '未知';

  @override
  String get evidencePublisherFisc => '財金公司公開資料';

  @override
  String get evidencePublisherMinistryOfDigitalAffairs => '數位發展部公開資料';

  @override
  String get evidencePublisherChunghwaPost => '中華郵政公開資料';

  @override
  String get evidencePublisherLicensedGeocoder => '已核准地址定位服務';

  @override
  String get evidencePublisherManualReview => '人工審核修正';

  @override
  String get evidencePublisherUnknown => '其他官方資料';

  @override
  String get evidenceConfidenceOfficialExact => '官方精確匹配';

  @override
  String get evidenceConfidenceOfficialPositive => '官方正面證據';

  @override
  String get evidenceConfidenceLicensedExact => '授權來源精確匹配';

  @override
  String get evidenceConfidenceLicensedFuzzy => '授權來源模糊匹配';

  @override
  String get evidenceConfidenceManualReviewed => '人工審核確認';

  @override
  String get evidenceConfidenceUnknown => '未知';

  @override
  String capabilityLabel(String capability, String status) {
    return '$capability：$status';
  }

  @override
  String get capabilityDeposit => '存款功能';

  @override
  String get capabilityAudioGuidance => '語音引導';

  @override
  String get capabilityVisualAccessibility => '視障無障礙';

  @override
  String get capabilityWheelchairAccessibility => '輪椅無障礙';

  @override
  String get capabilityForeignCurrencyWithdrawal => '外幣提款';

  @override
  String get capabilityStatusConfirmed => '已確認';

  @override
  String get capabilityStatusUnknown => '未知';

  @override
  String get capabilityStatusUnsupported => '不支援';

  @override
  String distanceMeters(int distance) {
    return '$distance 公尺';
  }

  @override
  String distanceKilometers(String distance) {
    return '$distance 公里';
  }

  @override
  String get onboardingHelpTitle => '使用說明';

  @override
  String get onboardingWelcome => '歡迎使用台灣 ATM Finder';

  @override
  String get onboardingSummary => '不用登入也能搜尋已下載的 ATM 公開資料。';

  @override
  String get onboardingLocationTitle => '定位用途';

  @override
  String get onboardingLocationBody => '只有你主動點選「找我附近」時，才會要求前景定位；也可以略過並手動搜尋。';

  @override
  String get onboardingSourcesTitle => '資料來源';

  @override
  String get onboardingSourcesBody => 'ATM 主資料來自財金公司與其他具公開授權的政府或機構資料。';

  @override
  String get onboardingPrivacyTitle => '隱私說明';

  @override
  String get onboardingPrivacyBody => '離線搜尋不需要接受資料蒐集。當次位置只用來排序附近結果，不保存位置歷史。';

  @override
  String get skip => '略過';

  @override
  String get back => '返回';

  @override
  String get findNearby => '找我附近';

  @override
  String get locationDeniedMessage => '未授權定位，仍可使用手動搜尋';

  @override
  String get manualSearch => '手動搜尋';

  @override
  String get locationDeniedForeverMessage => '定位權限已永久拒絕，請到系統設定開啟';

  @override
  String get openSystemSettings => '前往系統設定';

  @override
  String get locationServicesDisabledMessage => '裝置的定位服務已關閉';

  @override
  String get openLocationSettings => '開啟定位設定';

  @override
  String get locationProviderFailureMessage => '暫時無法取得位置，請稍後再試';

  @override
  String get offlineSearchHint => '銀行、場所、地址、縣市或行政區';

  @override
  String get search => '搜尋';

  @override
  String get offlineSearchPrompt => '輸入本機 catalog 中的 ATM 資訊';

  @override
  String get offlinePlaceNeedsConnection =>
      '本機 catalog 找不到這個地點；解析 catalog 外的新地標需要網路連線。';

  @override
  String get placeResolverUnavailable => '線上地點解析目前未設定或暫時無法使用；仍可搜尋本機 ATM 資料。';

  @override
  String get placeOutsideTaiwanUnsupported => '目前只支援台灣境內的地址、車站與地標。';

  @override
  String get choosePlace => '選擇地點';

  @override
  String searchRadiusStraightLine(int radius) {
    return '搜尋半徑：$radius 公里（直線距離）';
  }

  @override
  String get noAtmsWithinTenKm => '10 公里內沒有符合條件的 ATM';

  @override
  String get clearFilters => '清除篩選';

  @override
  String get filtersTitle => '篩選條件';

  @override
  String get capabilitiesTitle => 'ATM 能力';

  @override
  String get placeCategoriesTitle => '場所類型';

  @override
  String get institutionFilterTitle => '銀行篩選';

  @override
  String get preferredBanksTitle => '常用銀行';

  @override
  String get primaryBank => '主要銀行';

  @override
  String get preferSameBank => '同銀行優先';

  @override
  String get bankFeeDisclaimer => '是否同銀行僅供辨識；實際手續費與優惠請向銀行確認。';

  @override
  String get openNow => '目前營業';

  @override
  String get twentyFourHours => '24 小時';

  @override
  String get expandRadius => '擴大搜尋範圍';

  @override
  String get searchMapArea => '搜尋地圖區域';

  @override
  String mapClusterLabel(int count) {
    return '$count 個 ATM';
  }

  @override
  String get recentPlaces => '最近地點';

  @override
  String get clearAll => '全部清除';

  @override
  String get deleteRecentPlace => '刪除最近地點';

  @override
  String get recentPlaceSaved => '已加入最近地點';

  @override
  String get favoritesTitle => '收藏';

  @override
  String get addFavorite => '加入收藏';

  @override
  String get removeFavorite => '取消收藏';

  @override
  String get retiredFavoriteWarning => '此 ATM 已從最新資料來源撤除，以下為最後已知資料。';

  @override
  String catalogVersionLabel(String version) {
    return '資料集版本：$version';
  }

  @override
  String catalogRefreshedAtLabel(String date) {
    return '最近更新：$date';
  }

  @override
  String get staleDataWarning => 'ATM 資料超過 30 天未更新，可能有遺漏的最新變化';

  @override
  String detailDistanceLabel(String distance) {
    return '距離：$distance';
  }

  @override
  String get navigateToAtm => '導航至 ATM';

  @override
  String get shareAtm => '分享 ATM';

  @override
  String get reportAtmData => '回報 ATM 資料';

  @override
  String get externalActionUnavailable => '目前沒有可處理此操作的 App，請稍後再試';

  @override
  String get supportEmailCopied => '無法開啟郵件 App，客服信箱已複製';

  @override
  String get settingsTitle => '設定';

  @override
  String get localDataOnlyTitle => '資料只存在這台裝置';

  @override
  String get localDataOnlyBody => '不需登入，也不會跨裝置同步；偏好、最近搜尋與收藏只保存在本機。';

  @override
  String get searchPreferences => '搜尋偏好';

  @override
  String get manageFilters => '管理銀行、能力、場所與營業時間篩選';

  @override
  String get filtersCleared => '已恢復篩選與排序預設值';

  @override
  String favoriteCount(int count) {
    return '$count 個收藏';
  }

  @override
  String get noRecentPlaces => '尚無最近搜尋';

  @override
  String get reviewOnboarding => '重新查看使用與權限說明';

  @override
  String get settingsFeedback => '提供意見回饋';

  @override
  String get resetAllLocalData => '重設所有本機資料';

  @override
  String get resetAllDescription => '這會清除偏好、最近搜尋、收藏、同意狀態與已安裝 ATM 資料。';

  @override
  String get resetDialogTitle => '確定要重設所有資料？';

  @override
  String get resetDialogBody => '此操作無法復原。下次將重新安裝隨附資料並顯示首次使用說明。';

  @override
  String get cancel => '取消';

  @override
  String get confirmReset => '確認重設';

  @override
  String get resetComplete => '本機資料已重設';

  @override
  String get diagnosticsTitle => '自願提供當機診斷';

  @override
  String get diagnosticsBody =>
      '預設關閉。開啟後只傳送錯誤類型、堆疊與低敏感度版本資訊；不傳位置、搜尋、最近地點、收藏、ATM 選取或廣告識別碼。';

  @override
  String atmResultSemantics(
    String institution,
    String place,
    String address,
    String distance,
  ) {
    return 'ATM 結果，$institution，$place，$address，距離 $distance';
  }

  @override
  String get moreOptions => '更多選項';

  @override
  String atmSummarySemantics(String place) {
    return '已選取 $place，ATM 摘要';
  }

  @override
  String accessStatusLabel(String status) {
    return '進入狀態：$status';
  }

  @override
  String accessStatusSemantics(String status) {
    return '進入狀態$status';
  }

  @override
  String get accessStatusOpen => '目前營業';

  @override
  String get accessStatusUnknown => '未知（無可靠時段資料）';

  @override
  String get accessStatusClosed => '目前關閉';

  @override
  String get accessStatusTwentyFourHours => '24 小時';

  @override
  String get bankRelationshipSame => '本行 ATM';

  @override
  String get bankRelationshipCross => '跨行 ATM';

  @override
  String get removeFilter => '移除此篩選';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '台灣 ATM Finder';

  @override
  String get nearbyAtmsTitle => '附近 ATM';

  @override
  String get loadingAtms => '正在載入附近 ATM';

  @override
  String get loadAtmsError => '目前無法載入 ATM 資料';

  @override
  String get retry => '重新嘗試';

  @override
  String get noNearbyAtms => '附近沒有找到 ATM';

  @override
  String get mapUnavailable => '地圖暫時無法使用';

  @override
  String get viewDetails => '詳細資料';

  @override
  String placeCategoryLabel(String category) {
    return '場所類型：$category';
  }

  @override
  String placeCategoryEvidenceSourceLabel(String source) {
    return '場所來源：$source';
  }

  @override
  String coordinateEvidenceSourceLabel(String source) {
    return '座標來源：$source';
  }

  @override
  String evidenceDateLabel(String date) {
    return '資料日期：$date';
  }

  @override
  String evidenceConfidenceLabel(String confidence) {
    return '信心：$confidence';
  }

  @override
  String get placeCategoryBank => '銀行';

  @override
  String get placeCategoryConvenienceStore => '便利商店';

  @override
  String get placeCategoryPostOffice => '郵局';

  @override
  String get placeCategoryOther => '其他場所';

  @override
  String get placeCategoryUnknown => '未知';

  @override
  String get evidencePublisherFisc => '財金公司公開資料';

  @override
  String get evidencePublisherMinistryOfDigitalAffairs => '數位發展部公開資料';

  @override
  String get evidencePublisherChunghwaPost => '中華郵政公開資料';

  @override
  String get evidencePublisherLicensedGeocoder => '已核准地址定位服務';

  @override
  String get evidencePublisherManualReview => '人工審核修正';

  @override
  String get evidencePublisherUnknown => '其他官方資料';

  @override
  String get evidenceConfidenceOfficialExact => '官方精確匹配';

  @override
  String get evidenceConfidenceOfficialPositive => '官方正面證據';

  @override
  String get evidenceConfidenceLicensedExact => '授權來源精確匹配';

  @override
  String get evidenceConfidenceLicensedFuzzy => '授權來源模糊匹配';

  @override
  String get evidenceConfidenceManualReviewed => '人工審核確認';

  @override
  String get evidenceConfidenceUnknown => '未知';

  @override
  String capabilityLabel(String capability, String status) {
    return '$capability：$status';
  }

  @override
  String get capabilityDeposit => '存款功能';

  @override
  String get capabilityAudioGuidance => '語音引導';

  @override
  String get capabilityVisualAccessibility => '視障無障礙';

  @override
  String get capabilityWheelchairAccessibility => '輪椅無障礙';

  @override
  String get capabilityForeignCurrencyWithdrawal => '外幣提款';

  @override
  String get capabilityStatusConfirmed => '已確認';

  @override
  String get capabilityStatusUnknown => '未知';

  @override
  String get capabilityStatusUnsupported => '不支援';

  @override
  String distanceMeters(int distance) {
    return '$distance 公尺';
  }

  @override
  String distanceKilometers(String distance) {
    return '$distance 公里';
  }

  @override
  String get onboardingHelpTitle => '使用說明';

  @override
  String get onboardingWelcome => '歡迎使用台灣 ATM Finder';

  @override
  String get onboardingSummary => '不用登入也能搜尋已下載的 ATM 公開資料。';

  @override
  String get onboardingLocationTitle => '定位用途';

  @override
  String get onboardingLocationBody => '只有你主動點選「找我附近」時，才會要求前景定位；也可以略過並手動搜尋。';

  @override
  String get onboardingSourcesTitle => '資料來源';

  @override
  String get onboardingSourcesBody => 'ATM 主資料來自財金公司與其他具公開授權的政府或機構資料。';

  @override
  String get onboardingPrivacyTitle => '隱私說明';

  @override
  String get onboardingPrivacyBody => '離線搜尋不需要接受資料蒐集。當次位置只用來排序附近結果，不保存位置歷史。';

  @override
  String get skip => '略過';

  @override
  String get back => '返回';

  @override
  String get findNearby => '找我附近';

  @override
  String get locationDeniedMessage => '未授權定位，仍可使用手動搜尋';

  @override
  String get manualSearch => '手動搜尋';

  @override
  String get locationDeniedForeverMessage => '定位權限已永久拒絕，請到系統設定開啟';

  @override
  String get openSystemSettings => '前往系統設定';

  @override
  String get locationServicesDisabledMessage => '裝置的定位服務已關閉';

  @override
  String get openLocationSettings => '開啟定位設定';

  @override
  String get locationProviderFailureMessage => '暫時無法取得位置，請稍後再試';

  @override
  String get offlineSearchHint => '銀行、場所、地址、縣市或行政區';

  @override
  String get search => '搜尋';

  @override
  String get offlineSearchPrompt => '輸入本機 catalog 中的 ATM 資訊';

  @override
  String get offlinePlaceNeedsConnection =>
      '本機 catalog 找不到這個地點；解析 catalog 外的新地標需要網路連線。';

  @override
  String get placeResolverUnavailable => '線上地點解析目前未設定或暫時無法使用；仍可搜尋本機 ATM 資料。';

  @override
  String get placeOutsideTaiwanUnsupported => '目前只支援台灣境內的地址、車站與地標。';

  @override
  String get choosePlace => '選擇地點';

  @override
  String searchRadiusStraightLine(int radius) {
    return '搜尋半徑：$radius 公里（直線距離）';
  }

  @override
  String get noAtmsWithinTenKm => '10 公里內沒有符合條件的 ATM';

  @override
  String get clearFilters => '清除篩選';

  @override
  String get filtersTitle => '篩選條件';

  @override
  String get capabilitiesTitle => 'ATM 能力';

  @override
  String get placeCategoriesTitle => '場所類型';

  @override
  String get institutionFilterTitle => '銀行篩選';

  @override
  String get preferredBanksTitle => '常用銀行';

  @override
  String get primaryBank => '主要銀行';

  @override
  String get preferSameBank => '同銀行優先';

  @override
  String get bankFeeDisclaimer => '是否同銀行僅供辨識；實際手續費與優惠請向銀行確認。';

  @override
  String get openNow => '目前營業';

  @override
  String get twentyFourHours => '24 小時';

  @override
  String get expandRadius => '擴大搜尋範圍';

  @override
  String get searchMapArea => '搜尋地圖區域';

  @override
  String mapClusterLabel(int count) {
    return '$count 個 ATM';
  }

  @override
  String get recentPlaces => '最近地點';

  @override
  String get clearAll => '全部清除';

  @override
  String get deleteRecentPlace => '刪除最近地點';

  @override
  String get recentPlaceSaved => '已加入最近地點';

  @override
  String get favoritesTitle => '收藏';

  @override
  String get addFavorite => '加入收藏';

  @override
  String get removeFavorite => '取消收藏';

  @override
  String get retiredFavoriteWarning => '此 ATM 已從最新資料來源撤除，以下為最後已知資料。';

  @override
  String catalogVersionLabel(String version) {
    return '資料集版本：$version';
  }

  @override
  String catalogRefreshedAtLabel(String date) {
    return '最近更新：$date';
  }

  @override
  String get staleDataWarning => 'ATM 資料超過 30 天未更新，可能有遺漏的最新變化';

  @override
  String detailDistanceLabel(String distance) {
    return '距離：$distance';
  }

  @override
  String get navigateToAtm => '導航至 ATM';

  @override
  String get shareAtm => '分享 ATM';

  @override
  String get reportAtmData => '回報 ATM 資料';

  @override
  String get externalActionUnavailable => '目前沒有可處理此操作的 App，請稍後再試';

  @override
  String get supportEmailCopied => '無法開啟郵件 App，客服信箱已複製';

  @override
  String get settingsTitle => '設定';

  @override
  String get localDataOnlyTitle => '資料只存在這台裝置';

  @override
  String get localDataOnlyBody => '不需登入，也不會跨裝置同步；偏好、最近搜尋與收藏只保存在本機。';

  @override
  String get searchPreferences => '搜尋偏好';

  @override
  String get manageFilters => '管理銀行、能力、場所與營業時間篩選';

  @override
  String get filtersCleared => '已恢復篩選與排序預設值';

  @override
  String favoriteCount(int count) {
    return '$count 個收藏';
  }

  @override
  String get noRecentPlaces => '尚無最近搜尋';

  @override
  String get reviewOnboarding => '重新查看使用與權限說明';

  @override
  String get settingsFeedback => '提供意見回饋';

  @override
  String get resetAllLocalData => '重設所有本機資料';

  @override
  String get resetAllDescription => '這會清除偏好、最近搜尋、收藏、同意狀態與已安裝 ATM 資料。';

  @override
  String get resetDialogTitle => '確定要重設所有資料？';

  @override
  String get resetDialogBody => '此操作無法復原。下次將重新安裝隨附資料並顯示首次使用說明。';

  @override
  String get cancel => '取消';

  @override
  String get confirmReset => '確認重設';

  @override
  String get resetComplete => '本機資料已重設';

  @override
  String get diagnosticsTitle => '自願提供當機診斷';

  @override
  String get diagnosticsBody =>
      '預設關閉。開啟後只傳送錯誤類型、堆疊與低敏感度版本資訊；不傳位置、搜尋、最近地點、收藏、ATM 選取或廣告識別碼。';

  @override
  String atmResultSemantics(
    String institution,
    String place,
    String address,
    String distance,
  ) {
    return 'ATM 結果，$institution，$place，$address，距離 $distance';
  }

  @override
  String get moreOptions => '更多選項';

  @override
  String atmSummarySemantics(String place) {
    return '已選取 $place，ATM 摘要';
  }

  @override
  String accessStatusLabel(String status) {
    return '進入狀態：$status';
  }

  @override
  String accessStatusSemantics(String status) {
    return '進入狀態$status';
  }

  @override
  String get accessStatusOpen => '目前營業';

  @override
  String get accessStatusUnknown => '未知（無可靠時段資料）';

  @override
  String get accessStatusClosed => '目前關閉';

  @override
  String get accessStatusTwentyFourHours => '24 小時';

  @override
  String get bankRelationshipSame => '本行 ATM';

  @override
  String get bankRelationshipCross => '跨行 ATM';

  @override
  String get removeFilter => '移除此篩選';
}
