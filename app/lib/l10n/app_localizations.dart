import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'台灣 ATM Finder'**
  String get appTitle;

  /// No description provided for @nearbyAtmsTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'附近 ATM'**
  String get nearbyAtmsTitle;

  /// No description provided for @loadingAtms.
  ///
  /// In zh_TW, this message translates to:
  /// **'正在載入附近 ATM'**
  String get loadingAtms;

  /// No description provided for @loadAtmsError.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前無法載入 ATM 資料'**
  String get loadAtmsError;

  /// No description provided for @retry.
  ///
  /// In zh_TW, this message translates to:
  /// **'重新嘗試'**
  String get retry;

  /// No description provided for @noNearbyAtms.
  ///
  /// In zh_TW, this message translates to:
  /// **'附近沒有找到 ATM'**
  String get noNearbyAtms;

  /// No description provided for @mapUnavailable.
  ///
  /// In zh_TW, this message translates to:
  /// **'地圖暫時無法使用'**
  String get mapUnavailable;

  /// No description provided for @viewDetails.
  ///
  /// In zh_TW, this message translates to:
  /// **'詳細資料'**
  String get viewDetails;

  /// No description provided for @placeCategoryLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'場所類型：{category}'**
  String placeCategoryLabel(String category);

  /// No description provided for @placeCategoryEvidenceSourceLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'場所來源：{source}'**
  String placeCategoryEvidenceSourceLabel(String source);

  /// No description provided for @coordinateEvidenceSourceLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'座標來源：{source}'**
  String coordinateEvidenceSourceLabel(String source);

  /// No description provided for @evidenceDateLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料日期：{date}'**
  String evidenceDateLabel(String date);

  /// No description provided for @evidenceConfidenceLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'信心：{confidence}'**
  String evidenceConfidenceLabel(String confidence);

  /// No description provided for @placeCategoryBank.
  ///
  /// In zh_TW, this message translates to:
  /// **'銀行'**
  String get placeCategoryBank;

  /// No description provided for @placeCategoryConvenienceStore.
  ///
  /// In zh_TW, this message translates to:
  /// **'便利商店'**
  String get placeCategoryConvenienceStore;

  /// No description provided for @placeCategoryPostOffice.
  ///
  /// In zh_TW, this message translates to:
  /// **'郵局'**
  String get placeCategoryPostOffice;

  /// No description provided for @placeCategoryOther.
  ///
  /// In zh_TW, this message translates to:
  /// **'其他場所'**
  String get placeCategoryOther;

  /// No description provided for @placeCategoryUnknown.
  ///
  /// In zh_TW, this message translates to:
  /// **'未知'**
  String get placeCategoryUnknown;

  /// No description provided for @evidencePublisherFisc.
  ///
  /// In zh_TW, this message translates to:
  /// **'財金公司公開資料'**
  String get evidencePublisherFisc;

  /// No description provided for @evidencePublisherMinistryOfDigitalAffairs.
  ///
  /// In zh_TW, this message translates to:
  /// **'數位發展部公開資料'**
  String get evidencePublisherMinistryOfDigitalAffairs;

  /// No description provided for @evidencePublisherChunghwaPost.
  ///
  /// In zh_TW, this message translates to:
  /// **'中華郵政公開資料'**
  String get evidencePublisherChunghwaPost;

  /// No description provided for @evidencePublisherLicensedGeocoder.
  ///
  /// In zh_TW, this message translates to:
  /// **'已核准地址定位服務'**
  String get evidencePublisherLicensedGeocoder;

  /// No description provided for @evidencePublisherManualReview.
  ///
  /// In zh_TW, this message translates to:
  /// **'人工審核修正'**
  String get evidencePublisherManualReview;

  /// No description provided for @evidencePublisherUnknown.
  ///
  /// In zh_TW, this message translates to:
  /// **'其他官方資料'**
  String get evidencePublisherUnknown;

  /// No description provided for @evidenceConfidenceOfficialExact.
  ///
  /// In zh_TW, this message translates to:
  /// **'官方精確匹配'**
  String get evidenceConfidenceOfficialExact;

  /// No description provided for @evidenceConfidenceOfficialPositive.
  ///
  /// In zh_TW, this message translates to:
  /// **'官方正面證據'**
  String get evidenceConfidenceOfficialPositive;

  /// No description provided for @evidenceConfidenceLicensedExact.
  ///
  /// In zh_TW, this message translates to:
  /// **'授權來源精確匹配'**
  String get evidenceConfidenceLicensedExact;

  /// No description provided for @evidenceConfidenceLicensedFuzzy.
  ///
  /// In zh_TW, this message translates to:
  /// **'授權來源模糊匹配'**
  String get evidenceConfidenceLicensedFuzzy;

  /// No description provided for @evidenceConfidenceManualReviewed.
  ///
  /// In zh_TW, this message translates to:
  /// **'人工審核確認'**
  String get evidenceConfidenceManualReviewed;

  /// No description provided for @evidenceConfidenceUnknown.
  ///
  /// In zh_TW, this message translates to:
  /// **'未知'**
  String get evidenceConfidenceUnknown;

  /// No description provided for @capabilityLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'{capability}：{status}'**
  String capabilityLabel(String capability, String status);

  /// No description provided for @capabilityDeposit.
  ///
  /// In zh_TW, this message translates to:
  /// **'存款功能'**
  String get capabilityDeposit;

  /// No description provided for @capabilityAudioGuidance.
  ///
  /// In zh_TW, this message translates to:
  /// **'語音引導'**
  String get capabilityAudioGuidance;

  /// No description provided for @capabilityVisualAccessibility.
  ///
  /// In zh_TW, this message translates to:
  /// **'視障無障礙'**
  String get capabilityVisualAccessibility;

  /// No description provided for @capabilityWheelchairAccessibility.
  ///
  /// In zh_TW, this message translates to:
  /// **'輪椅無障礙'**
  String get capabilityWheelchairAccessibility;

  /// No description provided for @capabilityForeignCurrencyWithdrawal.
  ///
  /// In zh_TW, this message translates to:
  /// **'外幣提款'**
  String get capabilityForeignCurrencyWithdrawal;

  /// No description provided for @capabilityStatusConfirmed.
  ///
  /// In zh_TW, this message translates to:
  /// **'已確認'**
  String get capabilityStatusConfirmed;

  /// No description provided for @capabilityStatusUnknown.
  ///
  /// In zh_TW, this message translates to:
  /// **'未知'**
  String get capabilityStatusUnknown;

  /// No description provided for @capabilityStatusUnsupported.
  ///
  /// In zh_TW, this message translates to:
  /// **'不支援'**
  String get capabilityStatusUnsupported;

  /// No description provided for @distanceMeters.
  ///
  /// In zh_TW, this message translates to:
  /// **'{distance} 公尺'**
  String distanceMeters(int distance);

  /// No description provided for @distanceKilometers.
  ///
  /// In zh_TW, this message translates to:
  /// **'{distance} 公里'**
  String distanceKilometers(String distance);

  /// No description provided for @onboardingHelpTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'使用說明'**
  String get onboardingHelpTitle;

  /// No description provided for @onboardingWelcome.
  ///
  /// In zh_TW, this message translates to:
  /// **'歡迎使用台灣 ATM Finder'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSummary.
  ///
  /// In zh_TW, this message translates to:
  /// **'不用登入也能搜尋已下載的 ATM 公開資料。'**
  String get onboardingSummary;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'定位用途'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In zh_TW, this message translates to:
  /// **'只有你主動點選「找我附近」時，才會要求前景定位；也可以略過並手動搜尋。'**
  String get onboardingLocationBody;

  /// No description provided for @onboardingSourcesTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料來源'**
  String get onboardingSourcesTitle;

  /// No description provided for @onboardingSourcesBody.
  ///
  /// In zh_TW, this message translates to:
  /// **'ATM 主資料來自財金公司與其他具公開授權的政府或機構資料。'**
  String get onboardingSourcesBody;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'隱私說明'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyBody.
  ///
  /// In zh_TW, this message translates to:
  /// **'離線搜尋不需要接受資料蒐集。當次位置只用來排序附近結果，不保存位置歷史。'**
  String get onboardingPrivacyBody;

  /// No description provided for @skip.
  ///
  /// In zh_TW, this message translates to:
  /// **'略過'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In zh_TW, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @findNearby.
  ///
  /// In zh_TW, this message translates to:
  /// **'找我附近'**
  String get findNearby;

  /// No description provided for @locationDeniedMessage.
  ///
  /// In zh_TW, this message translates to:
  /// **'未授權定位，仍可使用手動搜尋'**
  String get locationDeniedMessage;

  /// No description provided for @manualSearch.
  ///
  /// In zh_TW, this message translates to:
  /// **'手動搜尋'**
  String get manualSearch;

  /// No description provided for @locationDeniedForeverMessage.
  ///
  /// In zh_TW, this message translates to:
  /// **'定位權限已永久拒絕，請到系統設定開啟'**
  String get locationDeniedForeverMessage;

  /// No description provided for @openSystemSettings.
  ///
  /// In zh_TW, this message translates to:
  /// **'前往系統設定'**
  String get openSystemSettings;

  /// No description provided for @locationServicesDisabledMessage.
  ///
  /// In zh_TW, this message translates to:
  /// **'裝置的定位服務已關閉'**
  String get locationServicesDisabledMessage;

  /// No description provided for @openLocationSettings.
  ///
  /// In zh_TW, this message translates to:
  /// **'開啟定位設定'**
  String get openLocationSettings;

  /// No description provided for @locationProviderFailureMessage.
  ///
  /// In zh_TW, this message translates to:
  /// **'暫時無法取得位置，請稍後再試'**
  String get locationProviderFailureMessage;

  /// No description provided for @offlineSearchHint.
  ///
  /// In zh_TW, this message translates to:
  /// **'銀行、場所、地址、縣市或行政區'**
  String get offlineSearchHint;

  /// No description provided for @search.
  ///
  /// In zh_TW, this message translates to:
  /// **'搜尋'**
  String get search;

  /// No description provided for @offlineSearchPrompt.
  ///
  /// In zh_TW, this message translates to:
  /// **'輸入本機 catalog 中的 ATM 資訊'**
  String get offlineSearchPrompt;

  /// No description provided for @offlinePlaceNeedsConnection.
  ///
  /// In zh_TW, this message translates to:
  /// **'本機 catalog 找不到這個地點；解析 catalog 外的新地標需要網路連線。'**
  String get offlinePlaceNeedsConnection;

  /// No description provided for @placeResolverUnavailable.
  ///
  /// In zh_TW, this message translates to:
  /// **'線上地點解析目前未設定或暫時無法使用；仍可搜尋本機 ATM 資料。'**
  String get placeResolverUnavailable;

  /// No description provided for @placeOutsideTaiwanUnsupported.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前只支援台灣境內的地址、車站與地標。'**
  String get placeOutsideTaiwanUnsupported;

  /// No description provided for @choosePlace.
  ///
  /// In zh_TW, this message translates to:
  /// **'選擇地點'**
  String get choosePlace;

  /// No description provided for @searchRadiusStraightLine.
  ///
  /// In zh_TW, this message translates to:
  /// **'搜尋半徑：{radius} 公里（直線距離）'**
  String searchRadiusStraightLine(int radius);

  /// No description provided for @noAtmsWithinTenKm.
  ///
  /// In zh_TW, this message translates to:
  /// **'10 公里內沒有符合條件的 ATM'**
  String get noAtmsWithinTenKm;

  /// No description provided for @clearFilters.
  ///
  /// In zh_TW, this message translates to:
  /// **'清除篩選'**
  String get clearFilters;

  /// No description provided for @filtersTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'篩選條件'**
  String get filtersTitle;

  /// No description provided for @capabilitiesTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'ATM 能力'**
  String get capabilitiesTitle;

  /// No description provided for @placeCategoriesTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'場所類型'**
  String get placeCategoriesTitle;

  /// No description provided for @institutionFilterTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'銀行篩選'**
  String get institutionFilterTitle;

  /// No description provided for @preferredBanksTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'常用銀行'**
  String get preferredBanksTitle;

  /// No description provided for @primaryBank.
  ///
  /// In zh_TW, this message translates to:
  /// **'主要銀行'**
  String get primaryBank;

  /// No description provided for @preferSameBank.
  ///
  /// In zh_TW, this message translates to:
  /// **'同銀行優先'**
  String get preferSameBank;

  /// No description provided for @bankFeeDisclaimer.
  ///
  /// In zh_TW, this message translates to:
  /// **'是否同銀行僅供辨識；實際手續費與優惠請向銀行確認。'**
  String get bankFeeDisclaimer;

  /// No description provided for @openNow.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前營業'**
  String get openNow;

  /// No description provided for @twentyFourHours.
  ///
  /// In zh_TW, this message translates to:
  /// **'24 小時'**
  String get twentyFourHours;

  /// No description provided for @expandRadius.
  ///
  /// In zh_TW, this message translates to:
  /// **'擴大搜尋範圍'**
  String get expandRadius;

  /// No description provided for @searchMapArea.
  ///
  /// In zh_TW, this message translates to:
  /// **'搜尋地圖區域'**
  String get searchMapArea;

  /// No description provided for @mapClusterLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'{count} 個 ATM'**
  String mapClusterLabel(int count);

  /// No description provided for @recentPlaces.
  ///
  /// In zh_TW, this message translates to:
  /// **'最近地點'**
  String get recentPlaces;

  /// No description provided for @clearAll.
  ///
  /// In zh_TW, this message translates to:
  /// **'全部清除'**
  String get clearAll;

  /// No description provided for @deleteRecentPlace.
  ///
  /// In zh_TW, this message translates to:
  /// **'刪除最近地點'**
  String get deleteRecentPlace;

  /// No description provided for @recentPlaceSaved.
  ///
  /// In zh_TW, this message translates to:
  /// **'已加入最近地點'**
  String get recentPlaceSaved;

  /// No description provided for @favoritesTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'收藏'**
  String get favoritesTitle;

  /// No description provided for @addFavorite.
  ///
  /// In zh_TW, this message translates to:
  /// **'加入收藏'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In zh_TW, this message translates to:
  /// **'取消收藏'**
  String get removeFavorite;

  /// No description provided for @retiredFavoriteWarning.
  ///
  /// In zh_TW, this message translates to:
  /// **'此 ATM 已從最新資料來源撤除，以下為最後已知資料。'**
  String get retiredFavoriteWarning;

  /// No description provided for @catalogVersionLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料集版本：{version}'**
  String catalogVersionLabel(String version);

  /// No description provided for @catalogRefreshedAtLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'最近更新：{date}'**
  String catalogRefreshedAtLabel(String date);

  /// No description provided for @staleDataWarning.
  ///
  /// In zh_TW, this message translates to:
  /// **'ATM 資料超過 30 天未更新，可能有遺漏的最新變化'**
  String get staleDataWarning;

  /// No description provided for @detailDistanceLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'距離：{distance}'**
  String detailDistanceLabel(String distance);

  /// No description provided for @navigateToAtm.
  ///
  /// In zh_TW, this message translates to:
  /// **'導航至 ATM'**
  String get navigateToAtm;

  /// No description provided for @shareAtm.
  ///
  /// In zh_TW, this message translates to:
  /// **'分享 ATM'**
  String get shareAtm;

  /// No description provided for @reportAtmData.
  ///
  /// In zh_TW, this message translates to:
  /// **'回報 ATM 資料'**
  String get reportAtmData;

  /// No description provided for @externalActionUnavailable.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前沒有可處理此操作的 App，請稍後再試'**
  String get externalActionUnavailable;

  /// No description provided for @supportEmailCopied.
  ///
  /// In zh_TW, this message translates to:
  /// **'無法開啟郵件 App，客服信箱已複製'**
  String get supportEmailCopied;

  /// No description provided for @settingsTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @localDataOnlyTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'資料只存在這台裝置'**
  String get localDataOnlyTitle;

  /// No description provided for @localDataOnlyBody.
  ///
  /// In zh_TW, this message translates to:
  /// **'不需登入，也不會跨裝置同步；偏好、最近搜尋與收藏只保存在本機。'**
  String get localDataOnlyBody;

  /// No description provided for @searchPreferences.
  ///
  /// In zh_TW, this message translates to:
  /// **'搜尋偏好'**
  String get searchPreferences;

  /// No description provided for @manageFilters.
  ///
  /// In zh_TW, this message translates to:
  /// **'管理銀行、能力、場所與營業時間篩選'**
  String get manageFilters;

  /// No description provided for @filtersCleared.
  ///
  /// In zh_TW, this message translates to:
  /// **'已恢復篩選與排序預設值'**
  String get filtersCleared;

  /// No description provided for @favoriteCount.
  ///
  /// In zh_TW, this message translates to:
  /// **'{count} 個收藏'**
  String favoriteCount(int count);

  /// No description provided for @noRecentPlaces.
  ///
  /// In zh_TW, this message translates to:
  /// **'尚無最近搜尋'**
  String get noRecentPlaces;

  /// No description provided for @reviewOnboarding.
  ///
  /// In zh_TW, this message translates to:
  /// **'重新查看使用與權限說明'**
  String get reviewOnboarding;

  /// No description provided for @settingsFeedback.
  ///
  /// In zh_TW, this message translates to:
  /// **'提供意見回饋'**
  String get settingsFeedback;

  /// No description provided for @resetAllLocalData.
  ///
  /// In zh_TW, this message translates to:
  /// **'重設所有本機資料'**
  String get resetAllLocalData;

  /// No description provided for @resetAllDescription.
  ///
  /// In zh_TW, this message translates to:
  /// **'這會清除偏好、最近搜尋、收藏、同意狀態與已安裝 ATM 資料。'**
  String get resetAllDescription;

  /// No description provided for @resetDialogTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'確定要重設所有資料？'**
  String get resetDialogTitle;

  /// No description provided for @resetDialogBody.
  ///
  /// In zh_TW, this message translates to:
  /// **'此操作無法復原。下次將重新安裝隨附資料並顯示首次使用說明。'**
  String get resetDialogBody;

  /// No description provided for @cancel.
  ///
  /// In zh_TW, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirmReset.
  ///
  /// In zh_TW, this message translates to:
  /// **'確認重設'**
  String get confirmReset;

  /// No description provided for @resetComplete.
  ///
  /// In zh_TW, this message translates to:
  /// **'本機資料已重設'**
  String get resetComplete;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'自願提供當機診斷'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsBody.
  ///
  /// In zh_TW, this message translates to:
  /// **'預設關閉。開啟後只傳送錯誤類型、堆疊與低敏感度版本資訊；不傳位置、搜尋、最近地點、收藏、ATM 選取或廣告識別碼。'**
  String get diagnosticsBody;

  /// No description provided for @atmResultSemantics.
  ///
  /// In zh_TW, this message translates to:
  /// **'ATM 結果，{institution}，{place}，{address}，距離 {distance}'**
  String atmResultSemantics(
    String institution,
    String place,
    String address,
    String distance,
  );

  /// No description provided for @moreOptions.
  ///
  /// In zh_TW, this message translates to:
  /// **'更多選項'**
  String get moreOptions;

  /// No description provided for @atmSummarySemantics.
  ///
  /// In zh_TW, this message translates to:
  /// **'已選取 {place}，ATM 摘要'**
  String atmSummarySemantics(String place);

  /// No description provided for @accessStatusLabel.
  ///
  /// In zh_TW, this message translates to:
  /// **'進入狀態：{status}'**
  String accessStatusLabel(String status);

  /// No description provided for @accessStatusSemantics.
  ///
  /// In zh_TW, this message translates to:
  /// **'進入狀態{status}'**
  String accessStatusSemantics(String status);

  /// No description provided for @accessStatusOpen.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前營業'**
  String get accessStatusOpen;

  /// No description provided for @accessStatusUnknown.
  ///
  /// In zh_TW, this message translates to:
  /// **'未知（無可靠時段資料）'**
  String get accessStatusUnknown;

  /// No description provided for @accessStatusClosed.
  ///
  /// In zh_TW, this message translates to:
  /// **'目前關閉'**
  String get accessStatusClosed;

  /// No description provided for @accessStatusTwentyFourHours.
  ///
  /// In zh_TW, this message translates to:
  /// **'24 小時'**
  String get accessStatusTwentyFourHours;

  /// No description provided for @bankRelationshipSame.
  ///
  /// In zh_TW, this message translates to:
  /// **'本行 ATM'**
  String get bankRelationshipSame;

  /// No description provided for @bankRelationshipCross.
  ///
  /// In zh_TW, this message translates to:
  /// **'跨行 ATM'**
  String get bankRelationshipCross;

  /// No description provided for @removeFilter.
  ///
  /// In zh_TW, this message translates to:
  /// **'移除此篩選'**
  String get removeFilter;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
