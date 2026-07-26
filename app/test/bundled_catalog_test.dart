import 'dart:io';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    '全台內建 catalog 可匯入、搜尋且只讓合法座標進入附近結果',
    () async {
      final database = AtmDatabase(NativeDatabase.memory());
      final catalog = DriftAtmCatalog(
        database,
        _FileCatalogAssetSource(File('assets/catalog/baseline_catalog.json')),
      );

      try {
        expect(
          await catalog.ensureBundledCatalogInstalled(),
          isA<CatalogInstalled>(),
        );
        final counts = await database.customSelect('''
          SELECT
            COUNT(*) AS total,
            SUM(
              CASE
                WHEN latitude IS NOT NULL AND longitude IS NOT NULL THEN 1
                ELSE 0
              END
            ) AS with_coordinates,
            SUM(
              CASE
                WHEN latitude IS NOT NULL
                  AND (
                    latitude < 20.5 OR latitude > 26.5
                    OR longitude < 118.0 OR longitude > 123.0
                  )
                THEN 1
                ELSE 0
              END
            ) AS out_of_bounds
          FROM atm_sites
        ''').getSingle();

        expect(counts.read<int>('total'), 27289);
        expect(counts.read<int>('with_coordinates'), 19541);
        expect(counts.read<int>('out_of_bounds'), 0);
        expect(await catalog.searchOffline('臺灣銀行'), isNotEmpty);
        expect(
          await catalog.findNearby(
            const GeoPoint(latitude: 25.0478, longitude: 121.5170),
            radiusMeters: 10000,
          ),
          isNotEmpty,
        );
      } finally {
        await database.close();
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}

class _FileCatalogAssetSource implements CatalogAssetSource {
  const _FileCatalogAssetSource(this.file);

  final File file;

  @override
  Future<String> loadBundledCatalog() => file.readAsString();
}
