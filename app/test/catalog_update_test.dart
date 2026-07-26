import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_artifact_importer.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/catalog_update.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('有效 full update 原子切換且同一天不重複檢查', () async {
    final temp = await Directory.systemTemp.createTemp('atm-update-test-');
    final database = AtmDatabase(
      NativeDatabase(File('${temp.path}${Platform.pathSeparator}catalog.db')),
    );
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '舊據點')),
      );
      expect(
        await catalog.ensureBundledCatalogInstalled(),
        isA<CatalogInstalled>(),
      );
      final snapshot = _snapshot('atm-new', '新據點');
      final manifestUri = Uri.parse(
        'https://catalog.example.test/manifest.json',
      );
      final snapshotUri = Uri.parse(
        'https://catalog.example.test/catalog-new.ndjson.gz',
      );
      final http = _FakeCatalogHttpClient({
        manifestUri: CatalogHttpResponse.okJson(
          utf8.encode(
            jsonEncode({
              'schemaVersion': 1,
              'datasetVersion': '2026.07.26',
              'recordCount': 1,
              'fullSnapshot': {
                'url': snapshotUri.toString(),
                'sha256': sha256.convert(snapshot).toString(),
              },
            }),
          ),
        ),
        snapshotUri: CatalogHttpResponse.okBinary(snapshot),
      });
      final clock = _FakeUpdateClock(DateTime.utc(2026, 7, 26, 8));
      final updater = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: http,
        clock: clock,
        manifestUri: manifestUri,
      );

      final result = await updater.checkForUpdate();

      expect(result, isA<CatalogUpdated>());
      expect((await catalog.searchOffline('新據點')).single.id, 'atm-new');
      expect(await catalog.searchOffline('舊據點'), isEmpty);
      expect(http.requests, [manifestUri, snapshotUri]);

      final sameDayResult = await updater.checkForUpdate();
      expect(sameDayResult, isA<CatalogUpToDate>());
      expect(http.requests, [manifestUri, snapshotUri]);

      clock.now = DateTime.utc(2026, 7, 27, 8);
      final nextDayResult = await updater.checkForUpdate();
      expect(nextDayResult, isA<CatalogUpToDate>());
      expect(http.requests, [manifestUri, snapshotUri, manifestUri]);

      final rollback = await updater.rollbackToPreviousGood();
      expect(rollback, isA<CatalogRolledBack>());
      expect((await catalog.searchOffline('舊據點')).single.id, 'atm-old');
    } finally {
      await database.close();
      await temp.delete(recursive: true);
    }
  });

  test('checksum 錯誤時繼續使用上一個 good catalog', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '舊據點')),
      );
      await catalog.ensureBundledCatalogInstalled();
      final snapshot = _snapshot('atm-new', '新據點');
      final manifestUri = Uri.parse(
        'https://catalog.example.test/manifest.json',
      );
      final snapshotUri = Uri.parse(
        'https://catalog.example.test/catalog-new.ndjson.gz',
      );
      final http = _FakeCatalogHttpClient({
        manifestUri: CatalogHttpResponse.okJson(
          utf8.encode(
            jsonEncode({
              'schemaVersion': 1,
              'datasetVersion': '2026.07.26',
              'recordCount': 1,
              'fullSnapshot': {
                'url': snapshotUri.toString(),
                'sha256': List.filled(64, '0').join(),
              },
            }),
          ),
        ),
        snapshotUri: CatalogHttpResponse.okBinary(snapshot),
      });
      final updater = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: http,
        clock: _FakeUpdateClock(DateTime.utc(2026, 7, 26, 8)),
        manifestUri: manifestUri,
      );

      final result = await updater.checkForUpdate();

      expect(result, isA<CatalogUsingOldData>());
      expect((await catalog.searchOffline('舊據點')).single.id, 'atm-old');
      expect(await catalog.searchOffline('新據點'), isEmpty);
    } finally {
      await database.close();
    }
  });

  test('manifest 有連續 delta chain 時優先套用而不下載 full snapshot', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '舊據點')),
      );
      await catalog.ensureBundledCatalogInstalled();
      final manifestUri = Uri.parse(
        'https://catalog.example.test/manifest.json',
      );
      final deltaUri = Uri.parse(
        'https://catalog.example.test/delta-25-to-26.ndjson.gz',
      );
      final fullUri = Uri.parse(
        'https://catalog.example.test/catalog-new.ndjson.gz',
      );
      final delta = gzip.encode(
        utf8.encode(
          '${jsonEncode({'operation': 'upsert', 'site': _site('atm-old', 'Delta 新據點')})}\n',
        ),
      );
      final http = _FakeCatalogHttpClient({
        manifestUri: CatalogHttpResponse.okJson(
          utf8.encode(
            jsonEncode({
              'schemaVersion': 1,
              'datasetVersion': '2026.07.26',
              'recordCount': 1,
              'fullSnapshot': {
                'url': fullUri.toString(),
                'sha256': List.filled(64, '0').join(),
              },
              'deltas': [
                {
                  'schemaVersion': 1,
                  'fromVersion': '2026.07.25',
                  'toVersion': '2026.07.26',
                  'url': deltaUri.toString(),
                  'sha256': sha256.convert(delta).toString(),
                },
              ],
            }),
          ),
        ),
        deltaUri: CatalogHttpResponse.okBinary(delta),
      });
      final updater = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: http,
        clock: _FakeUpdateClock(DateTime.utc(2026, 7, 26, 8)),
        manifestUri: manifestUri,
      );

      expect(await updater.checkForUpdate(), isA<CatalogUpdated>());
      expect((await catalog.searchOffline('Delta 新據點')).single.id, 'atm-old');
      expect(http.requests, [manifestUri, deltaUri]);
    } finally {
      await database.close();
    }
  });

  test('delta chain 超過安全長度時自動回退 full snapshot', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '舊據點')),
      );
      await catalog.ensureBundledCatalogInstalled();
      final manifestUri = Uri.parse(
        'https://catalog.example.test/manifest.json',
      );
      final fullUri = Uri.parse(
        'https://catalog.example.test/catalog-27.ndjson.gz',
      );
      final full = _snapshot('atm-new', 'Full fallback 據點');
      final http = _FakeCatalogHttpClient({
        manifestUri: CatalogHttpResponse.okJson(
          utf8.encode(
            jsonEncode({
              'schemaVersion': 1,
              'datasetVersion': '2026.07.27',
              'recordCount': 1,
              'fullSnapshot': {
                'url': fullUri.toString(),
                'sha256': sha256.convert(full).toString(),
              },
              'deltas': [
                {
                  'schemaVersion': 1,
                  'fromVersion': '2026.07.25',
                  'toVersion': '2026.07.26',
                  'url': 'https://catalog.example.test/delta-25-26.gz',
                  'sha256': List.filled(64, '1').join(),
                },
                {
                  'schemaVersion': 1,
                  'fromVersion': '2026.07.26',
                  'toVersion': '2026.07.27',
                  'url': 'https://catalog.example.test/delta-26-27.gz',
                  'sha256': List.filled(64, '2').join(),
                },
              ],
            }),
          ),
        ),
        fullUri: CatalogHttpResponse.okBinary(full),
      });
      final updater = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: http,
        clock: _FakeUpdateClock(DateTime.utc(2026, 7, 27, 8)),
        manifestUri: manifestUri,
        maxDeltaChainLength: 1,
      );

      expect(await updater.checkForUpdate(), isA<CatalogUpdated>());
      expect(
        (await catalog.searchOffline('Full fallback 據點')).single.id,
        'atm-new',
      );
      expect(http.requests, [manifestUri, fullUri]);
    } finally {
      await database.close();
    }
  });

  test('拒絕非 HTTPS、unsupported schema 與 downgrade manifest', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '舊據點')),
      );
      await catalog.ensureBundledCatalogInstalled();
      final clock = _FakeUpdateClock(DateTime.utc(2026, 7, 26, 8));

      final insecure = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: _FakeCatalogHttpClient({}),
        clock: clock,
        manifestUri: Uri.parse('http://catalog.example.test/manifest.json'),
      );
      expect(await insecure.checkForUpdate(), isA<CatalogIncompatible>());

      final manifestUri = Uri.parse(
        'https://catalog.example.test/manifest.json',
      );
      clock.now = DateTime.utc(2026, 7, 27, 8);
      final unsupported = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: _FakeCatalogHttpClient({
          manifestUri: CatalogHttpResponse.okJson(
            utf8.encode(
              jsonEncode({
                'schemaVersion': 999,
                'datasetVersion': '2026.07.27',
              }),
            ),
          ),
        }),
        clock: clock,
        manifestUri: manifestUri,
      );
      expect(await unsupported.checkForUpdate(), isA<CatalogIncompatible>());

      clock.now = DateTime.utc(2026, 7, 28, 8);
      final downgrade = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: _FakeCatalogHttpClient({
          manifestUri: CatalogHttpResponse.okJson(
            utf8.encode(
              jsonEncode({'schemaVersion': 1, 'datasetVersion': '2026.07.24'}),
            ),
          ),
        }),
        clock: clock,
        manifestUri: manifestUri,
      );
      expect(await downgrade.checkForUpdate(), isA<CatalogIncompatible>());
      expect((await catalog.searchOffline('舊據點')).single.id, 'atm-old');
    } finally {
      await database.close();
    }
  });

  test('duplicate IDs 與 record count mismatch 不會切換 active catalog', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '舊據點')),
      );
      await catalog.ensureBundledCatalogInstalled();
      final manifestUri = Uri.parse(
        'https://catalog.example.test/manifest.json',
      );
      final snapshotUri = Uri.parse(
        'https://catalog.example.test/catalog-invalid.ndjson.gz',
      );
      final duplicateSnapshot = gzip.encode(
        utf8.encode(
          '${jsonEncode(_site('atm-duplicate', '重複一'))}\n'
          '${jsonEncode(_site('atm-duplicate', '重複二'))}\n',
        ),
      );
      final http = _FakeCatalogHttpClient({
        manifestUri: CatalogHttpResponse.okJson(
          utf8.encode(
            jsonEncode({
              'schemaVersion': 1,
              'datasetVersion': '2026.07.26',
              'recordCount': 2,
              'fullSnapshot': {
                'url': snapshotUri.toString(),
                'sha256': sha256.convert(duplicateSnapshot).toString(),
              },
            }),
          ),
        ),
        snapshotUri: CatalogHttpResponse.okBinary(duplicateSnapshot),
      });
      final clock = _FakeUpdateClock(DateTime.utc(2026, 7, 26, 8));
      final updater = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: http,
        clock: clock,
        manifestUri: manifestUri,
      );
      expect(await updater.checkForUpdate(), isA<CatalogUsingOldData>());
      expect((await catalog.searchOffline('舊據點')).single.id, 'atm-old');

      clock.now = DateTime.utc(2026, 7, 27, 8);
      http.responses[manifestUri] = CatalogHttpResponse.okJson(
        utf8.encode(
          jsonEncode({
            'schemaVersion': 1,
            'datasetVersion': '2026.07.27',
            'recordCount': 3,
            'fullSnapshot': {
              'url': snapshotUri.toString(),
              'sha256': sha256.convert(duplicateSnapshot).toString(),
            },
          }),
        ),
      );
      expect(await updater.checkForUpdate(), isA<CatalogUsingOldData>());
      expect((await catalog.searchOffline('舊據點')).single.id, 'atm-old');
    } finally {
      await database.close();
    }
  });

  test('網路不可用時仍可使用 bundled catalog 離線搜尋', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(_bundledCatalog('old', '離線據點')),
      );
      await catalog.ensureBundledCatalogInstalled();
      final updater = CatalogUpdateCoordinator(
        database: database,
        importer: CatalogArtifactImporter(database),
        http: const _OfflineCatalogHttpClient(),
        clock: _FakeUpdateClock(DateTime.utc(2026, 7, 26, 8)),
        manifestUri: Uri.parse('https://catalog.example.test/manifest.json'),
      );

      expect(await updater.checkForUpdate(), isA<CatalogUsingOldData>());
      expect((await catalog.searchOffline('離線據點')).single.id, 'atm-old');
    } finally {
      await database.close();
    }
  });
}

List<int> _snapshot(String id, String placeName) {
  return gzip.encode(utf8.encode('${jsonEncode(_site(id, placeName))}\n'));
}

String _bundledCatalog(String suffix, String placeName) {
  return jsonEncode({
    'schemaVersion': 1,
    'datasetVersion': '2026.07.25',
    'sites': [_site('atm-$suffix', placeName)],
  });
}

Map<String, Object?> _site(String id, String placeName) {
  return {
    'id': id,
    'institutionCode': '004',
    'institutionName': '臺灣銀行',
    'placeName': placeName,
    'placeCategory': 'bank',
    'county': '臺北市',
    'displayAddress': '臺北市中正區館前路49號',
    'latitude': 25.0461,
    'longitude': 121.5141,
  };
}

class _StringAssetSource implements CatalogAssetSource {
  const _StringAssetSource(this.value);

  final String value;

  @override
  Future<String> loadBundledCatalog() async => value;
}

class _FakeCatalogHttpClient implements CatalogHttpClient {
  _FakeCatalogHttpClient(this.responses);

  final Map<Uri, CatalogHttpResponse> responses;
  final List<Uri> requests = [];

  @override
  Future<CatalogHttpResponse> get(Uri uri) async {
    requests.add(uri);
    return responses[uri] ??
        const CatalogHttpResponse(
          statusCode: 404,
          contentType: 'text/plain',
          bodyBytes: [],
        );
  }
}

class _FakeUpdateClock implements UpdateClock {
  _FakeUpdateClock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now.toUtc();
}

class _OfflineCatalogHttpClient implements CatalogHttpClient {
  const _OfflineCatalogHttpClient();

  @override
  Future<CatalogHttpResponse> get(Uri uri) {
    throw const SocketException('offline');
  }
}
