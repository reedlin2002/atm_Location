import 'dart:convert';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AtmDatabase database;

  setUp(() {
    database = AtmDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close().timeout(const Duration(seconds: 5));
  });

  test('附近結果最多回傳 50 筆且同距離時維持穩定順序', () async {
    final sites = List.generate(55, (index) {
      final reversedIndex = 54 - index;
      return {
        'id': 'atm-${reversedIndex.toString().padLeft(3, '0')}',
        'institutionCode': '004',
        'institutionName': '測試銀行',
        'placeName': '測試場所 $reversedIndex',
        'placeCategory': 'bank',
        'displayAddress': '臺北市測試路 $reversedIndex 號',
        'latitude': 25.0478,
        'longitude': 121.5170,
      };
    });
    final catalog = DriftAtmCatalog(
      database,
      _StringCatalogAssetSource(
        jsonEncode({
          'schemaVersion': 1,
          'datasetVersion': 'test-55-sites',
          'sites': sites,
        }),
      ),
    );

    final installResult = await catalog.ensureBundledCatalogInstalled().timeout(
      const Duration(seconds: 5),
    );
    expect(installResult, isA<CatalogInstalled>());
    final nearby = await catalog
        .findNearby(
          const GeoPoint(latitude: 25.0478, longitude: 121.5170),
          radiusMeters: 10000,
        )
        .timeout(const Duration(seconds: 5));

    expect(nearby, hasLength(50));
    expect(
      nearby.map((result) => result.site.id),
      List.generate(50, (index) => 'atm-${index.toString().padLeft(3, '0')}'),
    );
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('indexed bounding box 候選仍以 Haversine 排除圓形半徑外據點', () async {
    final catalog = DriftAtmCatalog(
      database,
      _StringCatalogAssetSource(
        jsonEncode({
          'schemaVersion': 1,
          'datasetVersion': 'bounding-box-haversine',
          'sites': [
            {
              'id': 'inside-circle',
              'institutionCode': '004',
              'institutionName': '測試銀行',
              'placeName': '圓形內',
              'placeCategory': 'bank',
              'displayAddress': '臺北市測試路 1 號',
              'latitude': 25.0550,
              'longitude': 121.5170,
            },
            {
              'id': 'inside-box-outside-circle',
              'institutionCode': '004',
              'institutionName': '測試銀行',
              'placeName': '方框內但圓形外',
              'placeCategory': 'bank',
              'displayAddress': '臺北市測試路 2 號',
              'latitude': 25.0550,
              'longitude': 121.5242,
            },
          ],
        }),
      ),
    );
    expect(
      await catalog.ensureBundledCatalogInstalled(),
      isA<CatalogInstalled>(),
    );

    final nearby = await catalog.findNearby(
      const GeoPoint(latitude: 25.0478, longitude: 121.5170),
      radiusMeters: 1000,
    );
    final indexes = await database
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'index' AND name = 'atm_sites_geo_active'",
        )
        .get();

    expect(nearby.map((result) => result.site.id), ['inside-circle']);
    expect(indexes, hasLength(1));
  });

  test('沒有座標的正式 ATM 仍可離線搜尋但不進入附近結果', () async {
    final catalog = DriftAtmCatalog(
      database,
      _StringCatalogAssetSource(
        jsonEncode({
          'schemaVersion': 1,
          'datasetVersion': 'unresolved-coordinate',
          'sites': [
            {
              'id': 'unresolved-atm',
              'institutionCode': '004',
              'institutionName': '測試銀行',
              'placeName': '待補座標據點',
              'placeCategory': 'unknown',
              'county': '臺北市',
              'displayAddress': '臺北市測試路 9 號',
              'latitude': null,
              'longitude': null,
            },
          ],
        }),
      ),
    );

    expect(
      await catalog.ensureBundledCatalogInstalled(),
      isA<CatalogInstalled>(),
    );
    expect((await catalog.searchOffline('待補座標')).single.position, isNull);
    expect(
      await catalog.findNearby(
        const GeoPoint(latitude: 25.0478, longitude: 121.5170),
        radiusMeters: 10000,
      ),
      isEmpty,
    );
  });

  test(
    'catalog install round-trips confirmed access schedule and evidence',
    () async {
      final catalog = DriftAtmCatalog(
        database,
        _StringCatalogAssetSource(
          jsonEncode({
            'schemaVersion': 1,
            'datasetVersion': 'access-schedule',
            'sites': [
              {
                'id': 'scheduled-atm',
                'institutionCode': '004',
                'institutionName': '測試銀行',
                'placeName': '有營業時段據點',
                'placeCategory': 'bank',
                'displayAddress': '臺北市測試路 3 號',
                'latitude': 25.0478,
                'longitude': 121.5170,
                'accessSchedule': {
                  'confirmedTwentyFourHours': false,
                  'periods': [
                    {
                      'weekday': DateTime.monday,
                      'startMinute': 540,
                      'endMinute': 1020,
                    },
                  ],
                },
                'accessEvidence': {
                  'source': 'manual-reviewed-override',
                  'date': '2026-07-26',
                  'confidence': 'manual_reviewed',
                },
              },
            ],
          }),
        ),
      );

      expect(
        await catalog.ensureBundledCatalogInstalled(),
        isA<CatalogInstalled>(),
      );
      final site = (await catalog.findNearby(
        const GeoPoint(latitude: 25.0478, longitude: 121.5170),
        radiusMeters: 1000,
      )).single.site;

      expect(site.accessSchedule, isNotNull);
      expect(site.accessSchedule!.confirmedTwentyFourHours, isFalse);
      expect(site.accessSchedule!.periods, hasLength(1));
      expect(site.accessSchedule!.periods.single.weekday, DateTime.monday);
      expect(site.accessSchedule!.periods.single.startMinute, 540);
      expect(site.accessEvidence?.publisher, EvidencePublisher.manualReview);
      expect(
        site.accessEvidence?.confidence,
        EvidenceConfidence.manualReviewed,
      );
    },
  );
}

class _StringCatalogAssetSource implements CatalogAssetSource {
  const _StringCatalogAssetSource(this.json);

  final String json;

  @override
  Future<String> loadBundledCatalog() async => json;
}
