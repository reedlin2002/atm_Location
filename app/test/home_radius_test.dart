import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/home/home_search.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/map/nearby_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _origin = GeoPoint(latitude: 25.0478, longitude: 121.5170);

void main() {
  test('都市 fixture 在 1 km 達 20 筆後停止擴大', () async {
    final catalog = _RadiusFixtureCatalog({1000: _results(25)});
    final result = await SearchCoordinator(
      catalog,
      const _Location(_origin),
    ).loadNearby();

    expect(catalog.requestedRadii, [1000]);
    expect(catalog.requestedLimits, [50]);
    expect(result, isA<HomeSearchSuccess>());
    final success = result as HomeSearchSuccess;
    expect(success.radiusMeters, 1000);
    expect(success.sites, hasLength(25));
  });

  test('偏鄉 fixture 依序擴到 10 km 並回報實際直線半徑', () async {
    final catalog = _RadiusFixtureCatalog({
      1000: _results(2),
      3000: _results(4),
      5000: _results(6),
      10000: _results(8),
    });
    final result = await SearchCoordinator(
      catalog,
      const _Location(_origin),
    ).loadNearby();

    expect(catalog.requestedRadii, [1000, 3000, 5000, 10000]);
    final success = result as HomeSearchSuccess;
    expect(success.radiusMeters, 10000);
    expect(success.sites, hasLength(8));
  });

  testWidgets('首頁顯示實際直線半徑', (tester) async {
    final catalog = _RadiusFixtureCatalog({1000: _results(25)});
    await _pumpHome(tester, catalog);

    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();

    expect(find.text('搜尋半徑：1 公里（直線距離）'), findsOneWidget);

    await _pumpHome(tester, catalog);
    expect(find.text('找我附近'), findsOneWidget);
    expect(find.text('搜尋半徑：1 公里（直線距離）'), findsNothing);
  });

  testWidgets('10 km 無結果提供清除、擴大與地圖區域 recovery', (tester) async {
    final catalog = _RadiusFixtureCatalog({});
    await _pumpHome(tester, catalog);

    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();

    expect(find.text('10 公里內沒有符合條件的 ATM'), findsOneWidget);
    expect(find.text('清除篩選'), findsOneWidget);
    expect(find.text('擴大搜尋範圍'), findsOneWidget);
    expect(find.text('搜尋地圖區域'), findsOneWidget);

    await tester.tap(find.text('擴大搜尋範圍'));
    await tester.pumpAndSettle();
    expect(catalog.requestedRadii, contains(25000));

    await tester.tap(find.text('搜尋地圖區域'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offline-search-field')), findsOneWidget);
  });
}

Future<void> _pumpHome(WidgetTester tester, AtmCatalog catalog) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        atmCatalogProvider.overrideWithValue(catalog),
        locationGatewayProvider.overrideWithValue(const _Location(_origin)),
        mapAdapterProvider.overrideWithValue(const _MapStub()),
      ],
      child: const MaterialApp(
        locale: Locale('zh', 'TW'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NearbyMapPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<NearbyAtmSite> _results(int count) {
  return List.generate(
    count,
    (index) => NearbyAtmSite(
      site: AtmSite(
        id: 'atm-$index',
        institutionCode: '004',
        institutionName: '測試銀行',
        placeName: '測試場所 $index',
        placeCategory: PlaceCategory.bank,
        displayAddress: '臺北市測試路 $index 號',
        position: const GeoPoint(latitude: 25.0478, longitude: 121.5170),
      ),
      distanceMeters: index * 10,
    ),
  );
}

class _RadiusFixtureCatalog implements AtmCatalog {
  _RadiusFixtureCatalog(this.resultsByRadius);

  final Map<int, List<NearbyAtmSite>> resultsByRadius;
  final List<int> requestedRadii = [];
  final List<int> requestedLimits = [];

  @override
  Future<CatalogInstallResult> ensureBundledCatalogInstalled() async {
    return const CatalogAlreadyInstalled();
  }

  @override
  Future<List<NearbyAtmSite>> findNearby(
    GeoPoint origin, {
    required double radiusMeters,
    int limit = 50,
  }) async {
    requestedRadii.add(radiusMeters.toInt());
    requestedLimits.add(limit);
    return resultsByRadius[radiusMeters.toInt()] ?? const [];
  }

  @override
  Future<List<AtmSite>> searchOffline(String query, {int limit = 50}) async {
    return const [];
  }
}

class _Location implements LocationGateway {
  const _Location(this.origin);

  final GeoPoint origin;

  @override
  Future<LocationOutcome> currentPosition() async {
    return LocationAvailable(origin);
  }
}

class _MapStub implements MapAdapter {
  const _MapStub();

  @override
  Widget buildMap(MapPresentation presentation) => const SizedBox.shrink();
}
