import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/catalog_delta_importer.dart';
import 'package:atmfinder/favorites/favorites.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalogJson = '''
{
  "schemaVersion": 1,
  "datasetVersion": "favorites-v1",
  "sites": [
    {
      "id": "site-1",
      "institutionCode": "004",
      "institutionName": "臺灣銀行",
      "placeName": "館前分行",
      "placeCategory": "bank",
      "county": "臺北市",
      "displayAddress": "臺北市中正區館前路 49 號",
      "latitude": 25.045,
      "longitude": 121.515
    }
  ]
}
''';

void main() {
  late AtmDatabase database;
  late DriftAtmCatalog catalog;

  setUp(() async {
    database = AtmDatabase(NativeDatabase.memory());
    catalog = DriftAtmCatalog(
      database,
      const _StringCatalogAssetSource(_catalogJson),
    );
    expect(
      await catalog.ensureBundledCatalogInstalled(),
      isA<CatalogInstalled>(),
    );
  });

  tearDown(() => database.close());

  test('收藏只引用 stable ID，repository 重建後仍取得 catalog facts', () async {
    await DriftFavoritesRepository(database, catalog).add('site-1');

    final favorites = await DriftFavoritesRepository(database, catalog).list();

    expect(favorites, hasLength(1));
    expect(favorites.single.site.id, 'site-1');
    expect(favorites.single.site.placeName, '館前分行');
    expect(favorites.single.retired, isFalse);
  });

  test('delta 撤除的收藏仍可開啟 last-known facts 並標示已撤除', () async {
    final repository = DriftFavoritesRepository(database, catalog);
    await repository.add('site-1');
    final delta = gzip.encode(
      utf8.encode(
        '${jsonEncode({'operation': 'retire', 'id': 'site-1', 'lastSeenDate': '2026-07-25'})}\n',
      ),
    );

    expect(
      await CatalogDeltaImporter(database).applyChain([
        CatalogDeltaArtifact(
          schemaVersion: 1,
          fromVersion: 'favorites-v1',
          toVersion: 'favorites-v2',
          sha256: sha256.convert(delta).toString(),
          compressedDelta: delta,
        ),
      ]),
      isA<CatalogDeltaInstalled>(),
    );

    final favorite = (await repository.list()).single;
    expect(favorite.retired, isTrue);
    expect(favorite.site.placeName, '館前分行');
    expect(favorite.site.lastSeenDate, DateTime.utc(2026, 7, 25));
    expect(await catalog.searchOffline('館前分行'), isEmpty);
  });
}

class _StringCatalogAssetSource implements CatalogAssetSource {
  const _StringCatalogAssetSource(this.value);

  final String value;

  @override
  Future<String> loadBundledCatalog() async => value;
}
