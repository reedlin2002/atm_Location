import 'dart:io';
import 'dart:typed_data';

import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/favorites/favorites.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/onboarding/onboarding_preferences.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/search/recent_places.dart';
import 'package:atmfinder/settings/local_settings_manager.dart';
import 'package:atmfinder/settings/settings_page.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDirectory;
  late AtmDatabase database;
  late DriftUserSettingsRepository settings;
  late DriftRecentPlacesRepository recentPlaces;
  late DriftOnboardingPreferences onboarding;
  late LocalSettingsManager manager;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('atm-settings-');
    database = AtmDatabase(
      NativeDatabase(File('${tempDirectory.path}/settings.sqlite')),
    );
    settings = DriftUserSettingsRepository(database);
    recentPlaces = DriftRecentPlacesRepository(database);
    onboarding = DriftOnboardingPreferences(database);
    manager = LocalSettingsManager(database, settings);
    await _seedAll(database, settings, recentPlaces, onboarding);
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  Future<void> pumpSettingsPage(
    WidgetTester tester, {
    Future<void> Function()? onReset,
  }) async {
    final favorites = DriftFavoritesRepository(
      database,
      const _SingleSiteLookup(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          atmDatabaseProvider.overrideWithValue(database),
          userSettingsRepositoryProvider.overrideWithValue(settings),
          localSettingsManagerProvider.overrideWithValue(manager),
          recentPlacesRepositoryProvider.overrideWithValue(recentPlaces),
          onboardingPreferencesProvider.overrideWithValue(onboarding),
          favoritesRepositoryProvider.overrideWithValue(favorites),
        ],
        child: MaterialApp(
          locale: const Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(onReset: onReset),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('清除篩選保留偏好銀行、最近搜尋、收藏與 catalog', () async {
    final updated = await manager.clearFilters();

    expect(updated.filters.isEmpty, isTrue);
    expect(updated.bankPreferences.preferredInstitutionCodes, {'004'});
    expect(updated.bankPreferences.primaryInstitutionCode, '004');
    expect(updated.bankPreferences.preferSameBank, isFalse);
    expect(await recentPlaces.list(), hasLength(1));
    expect(await database.select(database.favoriteSites).get(), hasLength(1));
    expect(await database.select(database.atmSites).get(), hasLength(1));
  });

  test('重設交易清除所有本機資料並讓 onboarding 回到未完成', () async {
    await manager.resetAll();

    expect(await database.select(database.atmSites).get(), isEmpty);
    expect(
      await database.select(database.catalogMetadataEntries).get(),
      isEmpty,
    );
    expect(await database.select(database.catalogBackupEntries).get(), isEmpty);
    expect(await database.select(database.appPreferences).get(), isEmpty);
    expect(await recentPlaces.list(), isEmpty);
    expect(await database.select(database.favoriteSites).get(), isEmpty);
    expect((await settings.load()).filters.isEmpty, isTrue);
    expect(
      (await settings.load()).bankPreferences.preferredInstitutionCodes,
      isEmpty,
    );
    expect(await onboarding.isComplete(), isFalse);
  });

  testWidgets('設定頁可刪除單筆與全部最近搜尋且不影響收藏', (tester) async {
    await recentPlaces.save(
      RecentPlace(
        label: '高雄車站',
        position: const GeoPoint(latitude: 22.639, longitude: 120.302),
        searchedAt: DateTime.utc(2026, 7, 27),
      ),
    );
    await pumpSettingsPage(tester);

    final delete = find.byKey(const ValueKey('delete-recent-台北車站'));
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(await recentPlaces.list(), hasLength(1));

    await tester.tap(find.byKey(const ValueKey('clear-recent-places')));
    await tester.pumpAndSettle();
    expect(await recentPlaces.list(), isEmpty);
    expect(await database.select(database.favoriteSites).get(), hasLength(1));
  });

  testWidgets('取消重設不改資料，二次確認後才執行集中重設交易', (tester) async {
    var resetCallbackCount = 0;
    await pumpSettingsPage(tester, onReset: () async => resetCallbackCount++);

    final reset = find.byKey(const ValueKey('reset-all-local-data'));
    await tester.scrollUntilVisible(
      reset,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cancel-reset')));
    await tester.pumpAndSettle();
    expect(await recentPlaces.list(), hasLength(1));
    expect(await database.select(database.favoriteSites).get(), hasLength(1));
    expect(resetCallbackCount, 0);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-reset')));
    await tester.pumpAndSettle();
    expect(await database.select(database.appPreferences).get(), isEmpty);
    expect(await recentPlaces.list(), isEmpty);
    expect(await database.select(database.favoriteSites).get(), isEmpty);
    expect(resetCallbackCount, 1);
  });
}

class _SingleSiteLookup implements AtmSiteLookup {
  const _SingleSiteLookup();

  static const site = AtmSite(
    id: 'site-1',
    institutionCode: '004',
    institutionName: '臺灣銀行',
    placeName: '台北車站',
    placeCategory: PlaceCategory.bank,
    displayAddress: '臺北市中正區',
    position: null,
  );

  @override
  Future<AtmSite?> findById(String id, {bool includeRetired = false}) async {
    return id == site.id ? site : null;
  }
}

Future<void> _seedAll(
  AtmDatabase database,
  DriftUserSettingsRepository settings,
  DriftRecentPlacesRepository recentPlaces,
  DriftOnboardingPreferences onboarding,
) async {
  await settings.save(
    const UserSettings(
      filters: AtmFilters(requiredCapabilities: {AtmCapability.deposit}),
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: {'004'},
        primaryInstitutionCode: '004',
        preferSameBank: true,
      ),
    ),
  );
  await recentPlaces.save(
    RecentPlace(
      label: '台北車站',
      position: const GeoPoint(latitude: 25.0478, longitude: 121.517),
      searchedAt: DateTime.utc(2026, 7, 26),
    ),
  );
  await onboarding.markComplete();
  await database
      .into(database.favoriteSites)
      .insert(
        FavoriteSitesCompanion.insert(
          siteId: 'site-1',
          favoritedAt: DateTime.utc(2026, 7, 26),
        ),
      );
  await database
      .into(database.atmSites)
      .insert(
        AtmSitesCompanion.insert(
          id: 'site-1',
          institutionCode: '004',
          institutionName: '臺灣銀行',
          placeName: '台北車站',
          placeCategory: 'bank',
          displayAddress: '臺北市中正區',
        ),
      );
  await database
      .into(database.catalogMetadataEntries)
      .insert(
        CatalogMetadataEntriesCompanion.insert(
          schemaVersion: 1,
          datasetVersion: '2026.07.26',
          installedAt: DateTime.utc(2026, 7, 26),
        ),
      );
  await database
      .into(database.catalogBackupEntries)
      .insert(
        CatalogBackupEntriesCompanion.insert(
          datasetVersion: '2026.07.25',
          manifestJson: '{}',
          compressedSnapshot: Uint8List(0),
          createdAt: DateTime.utc(2026, 7, 26),
        ),
      );
}
