import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/app.dart';
import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/map/nearby_map_page.dart';
import 'package:atmfinder/onboarding/onboarding_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late File databaseFile;
  late AtmDatabase appDatabase;
  late String bundledJson;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'atmfinder-home-',
    );
    databaseFile = File('${temporaryDirectory.path}\\catalog.sqlite');
    appDatabase = AtmDatabase(NativeDatabase(databaseFile));
    bundledJson = File(
      'assets/catalog/baseline_fixture.json',
    ).readAsStringSync();
  });

  tearDown(() async {
    await appDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  testWidgets('離線首次啟動會匯入內建目錄並依距離顯示附近 ATM', (tester) async {
    await _pumpAtmFinder(tester, appDatabase);

    expect(find.text('臺灣銀行'), findsOneWidget);
    expect(find.text('臺灣銀行館前分行'), findsOneWidget);
    expect(find.text('臺北市中正區館前路 49 號'), findsOneWidget);
    expect(find.text('中國信託'), findsOneWidget);
    expect(find.text('7-ELEVEN 台北站前門市'), findsOneWidget);
    expect(find.text('中華郵政'), findsOneWidget);
    expect(find.text('臺北北門郵局'), findsOneWidget);
    expect(find.text('100 公尺'), findsOneWidget);
    expect(find.text('300 公尺'), findsOneWidget);
    expect(find.text('600 公尺'), findsOneWidget);

    final bankTop = tester.getTopLeft(find.text('臺灣銀行')).dy;
    final storeTop = tester.getTopLeft(find.text('中國信託')).dy;
    final postTop = tester.getTopLeft(find.text('中華郵政')).dy;
    expect(bankTop, lessThan(storeTop));
    expect(storeTop, lessThan(postTop));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('再次啟動會沿用已安裝目錄且不產生重複 ATM', () async {
    final firstCatalog = DriftAtmCatalog(
      appDatabase,
      _StringCatalogAssetSource(bundledJson),
    );

    expect(
      await firstCatalog.ensureBundledCatalogInstalled(),
      isA<CatalogInstalled>(),
    );
    await appDatabase.close();
    appDatabase = AtmDatabase(NativeDatabase(databaseFile));

    final restartedCatalog = DriftAtmCatalog(
      appDatabase,
      _StringCatalogAssetSource(bundledJson),
    );
    expect(
      await restartedCatalog.ensureBundledCatalogInstalled(),
      isA<CatalogAlreadyInstalled>(),
    );
    final sites = await restartedCatalog.findNearby(
      const GeoPoint(latitude: 25.0478, longitude: 121.5170),
      radiusMeters: 10000,
    );

    expect(sites, hasLength(3));
    expect(sites.map((result) => result.site.id).toSet(), hasLength(3));
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('內建目錄匯入失敗不會留下半套資料且可以重新嘗試', (tester) async {
    final source = _SequenceCatalogAssetSource([
      jsonEncode({
        'schemaVersion': 1,
        'datasetVersion': 'invalid-partial-catalog',
        'sites': [
          {
            'id': 'partial-site',
            'institutionCode': '004',
            'institutionName': '不應殘留的銀行',
            'placeName': '不應殘留的場所',
            'placeCategory': 'bank',
            'displayAddress': '臺北市測試路 1 號',
            'latitude': 25.0478,
            'longitude': 121.5170,
          },
          {
            'id': 'invalid-site',
            'institutionCode': '004',
            'institutionName': '壞資料銀行',
            'placeName': '壞資料場所',
            'placeCategory': 'bank',
            'displayAddress': '臺北市測試路 2 號',
            'latitude': 200,
            'longitude': 121.5170,
          },
        ],
      }),
      bundledJson,
    ]);

    await _pumpAtmFinder(tester, appDatabase, catalogAssetSource: source);

    expect(find.text('目前無法載入 ATM 資料'), findsOneWidget);
    expect(find.text('重新嘗試'), findsOneWidget);
    expect(find.text('不應殘留的銀行'), findsNothing);

    await tester.tap(find.text('重新嘗試'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();

    expect(find.byType(AtmResultTile), findsNWidgets(3));
    expect(find.text('臺灣銀行'), findsOneWidget);
    expect(find.text('不應殘留的銀行'), findsNothing);
    expect(find.text('目前無法載入 ATM 資料'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 30)));
}

Future<void> _pumpAtmFinder(
  WidgetTester tester,
  AtmDatabase database, {
  CatalogAssetSource? catalogAssetSource,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        atmDatabaseProvider.overrideWithValue(database),
        onboardingPreferencesProvider.overrideWithValue(
          const _CompletedOnboardingPreferences(),
        ),
        if (catalogAssetSource != null)
          catalogAssetSourceProvider.overrideWithValue(catalogAssetSource),
        mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
        locationGatewayProvider.overrideWithValue(
          const _FixedLocationGateway(
            GeoPoint(latitude: 25.0478, longitude: 121.5170),
          ),
        ),
      ],
      child: const AtmFinderApp(),
    ),
  );
  await tester.pumpAndSettle();
  final findNearby = find.text('找我附近');
  if (findNearby.evaluate().isNotEmpty) {
    await tester.tap(findNearby);
    await tester.pumpAndSettle();
  }
}

class _StubMapAdapter implements MapAdapter {
  const _StubMapAdapter();

  @override
  Widget buildMap(MapPresentation presentation) => const SizedBox.shrink();
}

class _FixedLocationGateway implements LocationGateway {
  const _FixedLocationGateway(this.position);

  final GeoPoint position;

  @override
  Future<LocationOutcome> currentPosition() async {
    return LocationAvailable(position);
  }
}

class _CompletedOnboardingPreferences implements OnboardingPreferences {
  const _CompletedOnboardingPreferences();

  @override
  Future<bool> isComplete() async => true;

  @override
  Future<void> markComplete() async {}
}

class _StringCatalogAssetSource implements CatalogAssetSource {
  const _StringCatalogAssetSource(this.json);

  final String json;

  @override
  Future<String> loadBundledCatalog() async => json;
}

class _SequenceCatalogAssetSource implements CatalogAssetSource {
  _SequenceCatalogAssetSource(this._catalogs);

  final List<String> _catalogs;
  int _nextIndex = 0;

  @override
  Future<String> loadBundledCatalog() async {
    final catalog = _catalogs[_nextIndex];
    if (_nextIndex < _catalogs.length - 1) {
      _nextIndex += 1;
    }
    return catalog;
  }
}
