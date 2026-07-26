import 'dart:io';

import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/map/nearby_map_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _bankMarkerId = 'atm-bank-001';
const _storeMarkerId = 'atm-store-001';

void main() {
  late AtmDatabase appDatabase;
  late String bundledJson;

  setUp(() async {
    // In-memory DB + an in-memory asset string keep each widget test isolated
    // and avoid real per-test I/O during pumpAndSettle (mirrors
    // home_offline_test, which is the pattern that settles reliably here).
    appDatabase = AtmDatabase(NativeDatabase.memory());
    bundledJson = File(
      'assets/catalog/baseline_fixture.json',
    ).readAsStringSync();
  });

  tearDown(() async {
    await appDatabase.close();
  });

  testWidgets('清單與地圖標記共享同一選取狀態', (tester) async {
    await _pumpNearbyMap(tester, appDatabase, bundledJson: bundledJson);

    // Nothing selected on first load.
    expect(_markerState(tester, _bankMarkerId), 'unselected');
    expect(_markerState(tester, _storeMarkerId), 'unselected');

    // Selecting from the list focuses the matching marker and opens a summary.
    await tester.tap(find.text('臺灣銀行'));
    await tester.pumpAndSettle();
    expect(_markerState(tester, _bankMarkerId), 'selected');
    expect(
      find.byKey(const ValueKey('atm-summary-$_bankMarkerId')),
      findsOneWidget,
    );

    // Tapping a different marker moves the shared selection to that ATM.
    await tester.tap(find.byKey(const ValueKey('map-marker-$_storeMarkerId')));
    await tester.pumpAndSettle();
    expect(_markerState(tester, _storeMarkerId), 'selected');
    expect(_markerState(tester, _bankMarkerId), 'unselected');
    expect(
      find.byKey(const ValueKey('atm-summary-$_storeMarkerId')),
      findsOneWidget,
    );
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('從清單或地圖摘要進入的詳細資料相同且使用穩定 ID', (tester) async {
    await _pumpNearbyMap(tester, appDatabase, bundledJson: bundledJson);

    Future<void> openDetailFor(
      String markerId, {
      required bool viaMarker,
    }) async {
      if (viaMarker) {
        await tester.tap(find.byKey(ValueKey('map-marker-$markerId')));
      } else {
        await tester.tap(find.text('臺灣銀行'));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('atm-summary-detail-$markerId')));
      await tester.pumpAndSettle();
    }

    // From the list.
    await openDetailFor(_bankMarkerId, viaMarker: false);
    expect(
      find.byKey(const ValueKey('atm-detail-$_bankMarkerId')),
      findsOneWidget,
    );
    expect(find.text('臺北市中正區館前路 49 號'), findsOneWidget);
    Navigator.of(
      tester.element(find.byKey(const ValueKey('atm-detail-$_bankMarkerId'))),
    ).pop();
    await tester.pumpAndSettle();

    // From the map summary — identical detail for the same stable id.
    await openDetailFor(_bankMarkerId, viaMarker: true);
    expect(
      find.byKey(const ValueKey('atm-detail-$_bankMarkerId')),
      findsOneWidget,
    );
    expect(find.text('臺北市中正區館前路 49 號'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('拖曳摘要面板不會重新查詢附近結果', (tester) async {
    final spyCatalog = _CountingAtmCatalog(
      DriftAtmCatalog(appDatabase, _StringCatalogAssetSource(bundledJson)),
    );
    await _pumpNearbyMap(
      tester,
      appDatabase,
      bundledJson: bundledJson,
      catalog: spyCatalog,
    );

    await tester.tap(find.text('臺灣銀行'));
    await tester.pumpAndSettle();
    final queriesAfterSelect = spyCatalog.findNearbyCalls;

    // Drag the summary sheet up and down; results must not be refetched.
    await tester.drag(
      find.byKey(const ValueKey('atm-summary-$_bankMarkerId')),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('atm-summary-$_bankMarkerId')),
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(spyCatalog.findNearbyCalls, queriesAfterSelect);
    expect(find.byType(AtmResultTile), findsNWidgets(3));
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('地圖初始化失敗時仍可使用清單與詳細資料', (tester) async {
    await _pumpNearbyMap(tester, appDatabase, bundledJson: bundledJson);

    await tester.tap(find.byKey(const ValueKey('map-trigger-error')));
    await tester.pumpAndSettle();

    // Clear status is shown, but the list is still usable.
    expect(find.text('地圖暫時無法使用'), findsOneWidget);
    expect(find.byType(AtmResultTile), findsNWidgets(3));

    // Detail flow still works with the map gone.
    await tester.tap(find.text('臺灣銀行'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('atm-summary-detail-$_bankMarkerId')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('atm-detail-$_bankMarkerId')),
      findsOneWidget,
    );
  }, timeout: const Timeout(Duration(seconds: 30)));
}

Future<void> _pumpNearbyMap(
  WidgetTester tester,
  AtmDatabase database, {
  required String bundledJson,
  AtmCatalog? catalog,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        atmDatabaseProvider.overrideWithValue(database),
        catalogAssetSourceProvider.overrideWithValue(
          _StringCatalogAssetSource(bundledJson),
        ),
        if (catalog != null) atmCatalogProvider.overrideWithValue(catalog),
        locationGatewayProvider.overrideWithValue(
          const _FixedLocationGateway(
            GeoPoint(latitude: 25.0478, longitude: 121.5180),
          ),
        ),
        mapAdapterProvider.overrideWithValue(const _FakeMapAdapter()),
        selectedSiteProvider.overrideWith(SelectedSiteController.new),
        mapAvailableProvider.overrideWith(MapAvailabilityController.new),
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
  await tester.tap(find.text('找我附近'));
  await tester.pumpAndSettle();
}

String _markerState(WidgetTester tester, String siteId) {
  return tester
      .widget<Text>(find.byKey(ValueKey('map-marker-state-$siteId')))
      .data!;
}

/// A minimal fake map that renders markers as tappable buttons so widget tests
/// can drive selection without any real map SDK.
class _FakeMapAdapter implements MapAdapter {
  const _FakeMapAdapter();

  @override
  Widget buildMap(MapPresentation presentation) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final marker in presentation.markers)
          TextButton(
            key: ValueKey('map-marker-${marker.siteId}'),
            onPressed: () => presentation.onMarkerSelected(marker.siteId),
            child: Text(
              marker.selected ? 'selected' : 'unselected',
              key: ValueKey('map-marker-state-${marker.siteId}'),
            ),
          ),
        TextButton(
          key: const ValueKey('map-trigger-error'),
          onPressed: presentation.onMapError,
          child: const Text('trigger map error'),
        ),
      ],
    );
  }
}

class _CountingAtmCatalog implements AtmCatalog {
  _CountingAtmCatalog(this._delegate);

  final AtmCatalog _delegate;
  int findNearbyCalls = 0;

  @override
  Future<CatalogInstallResult> ensureBundledCatalogInstalled() =>
      _delegate.ensureBundledCatalogInstalled();

  @override
  Future<List<NearbyAtmSite>> findNearby(
    GeoPoint origin, {
    required double radiusMeters,
    int limit = 50,
  }) {
    findNearbyCalls += 1;
    return _delegate.findNearby(
      origin,
      radiusMeters: radiusMeters,
      limit: limit,
    );
  }

  @override
  Future<List<AtmSite>> searchOffline(String query, {int limit = 50}) =>
      _delegate.searchOffline(query, limit: limit);
}

class _FixedLocationGateway implements LocationGateway {
  const _FixedLocationGateway(this.position);

  final GeoPoint position;

  @override
  Future<LocationOutcome> currentPosition() async =>
      LocationAvailable(position);
}

class _StringCatalogAssetSource implements CatalogAssetSource {
  const _StringCatalogAssetSource(this.json);

  final String json;

  @override
  Future<String> loadBundledCatalog() async => json;
}
