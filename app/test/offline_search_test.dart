import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/search/offline_search_page.dart';
import 'package:atmfinder/search/recent_places.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late AtmDatabase _database;

void main() {
  setUp(() {
    _database = AtmDatabase(NativeDatabase.memory());
  });

  tearDown(() => _database.close());

  testWidgets('行政區與帶空白地址片段可搜尋真實暫存 catalog', (tester) async {
    final catalog = DriftAtmCatalog(
      _database,
      const RootBundleCatalogAssetSource(),
    );
    final recentPlaces = DriftRecentPlacesRepository(_database);
    expect(
      await catalog.ensureBundledCatalogInstalled(),
      isA<CatalogInstalled>(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          atmCatalogProvider.overrideWithValue(catalog),
          recentPlacesRepositoryProvider.overrideWithValue(recentPlaces),
        ],
        child: const MaterialApp(
          locale: Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OfflineSearchPage(),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('offline-search-field')),
      '臺北市 中正區 館前路',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('臺灣銀行'), findsOneWidget);
    expect(find.textContaining('館前路 49 號'), findsOneWidget);
    await tester.tap(find.text('臺灣銀行'));
    await tester.pumpAndSettle();
    expect((await recentPlaces.list()).single.label, '臺北市 中正區 館前路');

    await tester.enterText(
      find.byKey(const ValueKey('offline-search-field')),
      'catalog 外的新地標',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      find.text('線上地點解析目前未設定或暫時無法使用；仍可搜尋本機 ATM 資料。'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  test('最近地點保留最新 10 筆並支援單筆刪除與全部清除', () async {
    final repository = DriftRecentPlacesRepository(_database);

    for (var index = 0; index < 11; index += 1) {
      await repository.save(
        RecentPlace(
          label: '地點 $index',
          position: GeoPoint(
            latitude: 25 + index / 1000,
            longitude: 121 + index / 1000,
          ),
          searchedAt: DateTime.utc(2026, 7, 25, 8, index),
        ),
      );
    }

    final recent = await repository.list();
    expect(recent, hasLength(10));
    expect(recent.map((place) => place.label), [
      for (var index = 10; index >= 1; index -= 1) '地點 $index',
    ]);
    expect(recent.first.position.latitude, closeTo(25.01, 0.000001));

    await repository.delete('地點 5');
    expect(
      (await repository.list()).map((place) => place.label),
      isNot(contains('地點 5')),
    );

    await repository.clear();
    expect(await repository.list(), isEmpty);
  });

  testWidgets('最近地點可重用，重開頁面不會恢復舊 active query', (tester) async {
    final catalog = DriftAtmCatalog(
      _database,
      const RootBundleCatalogAssetSource(),
    );
    final repository = DriftRecentPlacesRepository(_database);
    expect(
      await catalog.ensureBundledCatalogInstalled(),
      isA<CatalogInstalled>(),
    );
    await repository.save(
      RecentPlace(
        label: '館前',
        position: const GeoPoint(latitude: 25.0478, longitude: 121.5170),
        searchedAt: DateTime.utc(2026, 7, 25, 8),
      ),
    );
    await repository.save(
      RecentPlace(
        label: '北門',
        position: const GeoPoint(latitude: 25.0478, longitude: 121.5230),
        searchedAt: DateTime.utc(2026, 7, 25, 9),
      ),
    );

    await _pumpSearch(tester, catalog, repository);
    expect(find.text('最近地點'), findsOneWidget);
    expect(find.text('館前'), findsOneWidget);
    expect(find.text('北門'), findsOneWidget);

    await tester.tap(find.text('館前'));
    await tester.pumpAndSettle();
    expect(find.text('臺灣銀行'), findsOneWidget);

    await _pumpSearch(tester, catalog, repository);
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('offline-search-field')),
    );
    expect(field.controller?.text, isEmpty);
    expect(find.text('館前'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('delete-recent-館前')));
    await tester.pumpAndSettle();
    expect(find.text('館前'), findsNothing);
    expect(find.text('北門'), findsOneWidget);

    await tester.tap(find.text('全部清除'));
    await tester.pumpAndSettle();
    expect(find.text('北門'), findsNothing);
    expect(await repository.list(), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpSearch(
  WidgetTester tester,
  AtmCatalog catalog,
  RecentPlacesRepository recentPlaces,
) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        atmCatalogProvider.overrideWithValue(catalog),
        recentPlacesRepositoryProvider.overrideWithValue(recentPlaces),
      ],
      child: const MaterialApp(
        locale: Locale('zh', 'TW'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OfflineSearchPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
