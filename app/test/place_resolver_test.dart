import 'dart:async';

import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/search/offline_search_page.dart';
import 'package:atmfinder/search/place_resolver.dart';
import 'package:atmfinder/search/recent_places.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalogJson = '''
{
  "schemaVersion": 1,
  "datasetVersion": "places-v1",
  "sites": [
    {
      "id": "near-station",
      "institutionCode": "004",
      "institutionName": "臺灣銀行",
      "placeName": "台北車站據點",
      "placeCategory": "bank",
      "county": "臺北市",
      "displayAddress": "臺北市中正區忠孝西路一段 49 號",
      "latitude": 25.0478,
      "longitude": 121.5170
    }
  ]
}
''';

void main() {
  late AtmDatabase database;
  late DriftAtmCatalog catalog;
  late DriftRecentPlacesRepository recentPlaces;

  setUp(() async {
    database = AtmDatabase(NativeDatabase.memory());
    catalog = DriftAtmCatalog(
      database,
      const _StringCatalogAssetSource(_catalogJson),
    );
    recentPlaces = DriftRecentPlacesRepository(database);
    await catalog.ensureBundledCatalogInstalled();
  });

  tearDown(() => database.close());

  test('選定 resolver 候選後才保存最近地點並搜尋附近 ATM', () async {
    final coordinator = PlaceSearchCoordinator(
      catalog: catalog,
      recentPlaces: recentPlaces,
      resolver: const _FakePlaceResolver(),
    );

    final result = await coordinator.resolve('台北車站');
    expect(result, isA<PlaceCandidates>());
    final candidates = (result as PlaceCandidates).values;
    expect(candidates.map((candidate) => candidate.label), ['台北車站', '台北捷運站']);
    expect(await recentPlaces.list(), isEmpty);

    final nearby = await coordinator.select(candidates.first);

    expect(nearby.single.site.id, 'near-station');
    expect((await recentPlaces.list()).single.label, '台北車站');
  });

  testWidgets('畫面讓使用者從多個地標候選選定後查看附近 ATM', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          atmCatalogProvider.overrideWithValue(catalog),
          recentPlacesRepositoryProvider.overrideWithValue(recentPlaces),
          placeResolverProvider.overrideWithValue(const _FakePlaceResolver()),
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

    await tester.enterText(
      find.byKey(const ValueKey('offline-search-field')),
      '交通樞紐',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('台北車站'), findsOneWidget);
    expect(find.text('台北捷運站'), findsOneWidget);
    expect(await recentPlaces.list(), isEmpty);

    await tester.tap(find.text('台北車站'));
    await tester.pumpAndSettle();
    expect(find.text('臺灣銀行'), findsOneWidget);
    expect((await recentPlaces.list()).single.label, '台北車站');
  });

  test(
    'debounce drops superseded work and keeps a provider-neutral session',
    () async {
      final gate = Completer<void>();
      var sessionSequence = 0;
      final gateway = _RecordingPlaceResolverGateway(
        (request) async => PlaceCandidates([
          PlaceCandidate(
            label: request.query,
            position: const GeoPoint(latitude: 25.0478, longitude: 121.5170),
            countryCode: 'TW',
          ),
        ]),
      );
      final resolver = SessionQuotaAwarePlaceResolver(
        gateway: gateway,
        debounce: const Duration(milliseconds: 300),
        delay: (_) => gate.future,
        sessionTokenFactory: () => 'session-${++sessionSequence}',
      );

      final superseded = resolver.resolve('台');
      final latest = resolver.resolve('台北車站');
      gate.complete();

      expect(await superseded, isA<PlaceNoResults>());
      final latestResult = await latest;
      expect((latestResult as PlaceCandidates).values.single.label, '台北車站');
      expect(gateway.requests.single.sessionToken, 'session-1');

      resolver.endSession();
      await resolver.resolve('高雄車站');
      expect(gateway.requests.last.sessionToken, 'session-2');
    },
  );

  test(
    'quota result opens a local cooldown before provider calls resume',
    () async {
      var now = DateTime.utc(2026, 7, 26);
      var attempts = 0;
      final gateway = _RecordingPlaceResolverGateway((request) async {
        attempts += 1;
        if (attempts == 1) {
          return const PlaceResolverQuotaExceeded();
        }
        return const PlaceNoResults();
      });
      final resolver = SessionQuotaAwarePlaceResolver(
        gateway: gateway,
        debounce: Duration.zero,
        quotaCooldown: const Duration(minutes: 1),
        delay: (_) async {},
        now: () => now,
        sessionTokenFactory: () => 'quota-session',
      );

      expect(await resolver.resolve('台北'), isA<PlaceResolverQuotaExceeded>());
      expect(await resolver.resolve('高雄'), isA<PlaceResolverQuotaExceeded>());
      expect(attempts, 1);

      now = now.add(const Duration(minutes: 1, seconds: 1));
      expect(await resolver.resolve('高雄'), isA<PlaceNoResults>());
      expect(attempts, 2);
    },
  );
}

class _FakePlaceResolver implements PlaceResolver {
  const _FakePlaceResolver();

  @override
  Future<PlaceResolution> resolve(String query) async {
    return const PlaceCandidates([
      PlaceCandidate(
        label: '台北車站',
        position: GeoPoint(latitude: 25.0478, longitude: 121.5170),
        countryCode: 'TW',
      ),
      PlaceCandidate(
        label: '台北捷運站',
        position: GeoPoint(latitude: 25.0465, longitude: 121.5174),
        countryCode: 'TW',
      ),
    ]);
  }
}

class _StringCatalogAssetSource implements CatalogAssetSource {
  const _StringCatalogAssetSource(this.value);

  final String value;

  @override
  Future<String> loadBundledCatalog() async => value;
}

class _RecordingPlaceResolverGateway implements PlaceResolverGateway {
  _RecordingPlaceResolverGateway(this.handler);

  final Future<PlaceResolution> Function(PlaceResolverRequest request) handler;
  final List<PlaceResolverRequest> requests = [];

  @override
  Future<PlaceResolution> resolve(PlaceResolverRequest request) {
    requests.add(request);
    return handler(request);
  }
}
