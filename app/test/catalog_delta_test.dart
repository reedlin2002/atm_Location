import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/catalog_delta_importer.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('delta chain 在單一 transaction 套用 upsert 與 retirement', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(
          jsonEncode({
            'schemaVersion': 1,
            'datasetVersion': '2026.07.25',
            'sites': [_site('atm-change', '舊名稱'), _site('atm-retired', '即將撤除')],
          }),
        ),
      );
      await catalog.ensureBundledCatalogInstalled();
      final deltaBytes = gzip.encode(
        utf8.encode(
          '${jsonEncode({'operation': 'upsert', 'site': _site('atm-change', '更新名稱')})}\n'
          '${jsonEncode({'operation': 'retire', 'id': 'atm-retired', 'lastSeenDate': '2026-07-25'})}\n',
        ),
      );
      final artifact = CatalogDeltaArtifact(
        schemaVersion: 1,
        fromVersion: '2026.07.25',
        toVersion: '2026.07.26',
        sha256: sha256.convert(deltaBytes).toString(),
        compressedDelta: deltaBytes,
      );

      final result = await CatalogDeltaImporter(
        database,
      ).applyChain([artifact]);

      expect(result, isA<CatalogDeltaInstalled>());
      expect((await catalog.searchOffline('更新名稱')).single.id, 'atm-change');
      expect(await catalog.searchOffline('舊名稱'), isEmpty);
      expect(await catalog.searchOffline('即將撤除'), isEmpty);
      final retired = await catalog.findById(
        'atm-retired',
        includeRetired: true,
      );
      expect(retired?.placeName, '即將撤除');
      expect(retired?.lastSeenDate, DateTime.utc(2026, 7, 25));

      final metadata = await database
          .select(database.catalogMetadataEntries)
          .getSingle();
      expect(metadata.datasetVersion, '2026.07.26');
    } finally {
      await database.close();
    }
  });

  test('拒絕 gap、downgrade、duplicate operation 與 checksum 錯誤', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(
          jsonEncode({
            'schemaVersion': 1,
            'datasetVersion': '2026.07.25',
            'sites': [_site('atm-old', '舊資料')],
          }),
        ),
      );
      await catalog.ensureBundledCatalogInstalled();
      final importer = CatalogDeltaImporter(database);
      final validBytes = _deltaBytes([
        {'operation': 'upsert', 'site': _site('atm-old', '更新資料')},
      ]);
      final invalidArtifacts = [
        _artifact(bytes: validBytes, from: '2026.07.24', to: '2026.07.26'),
        _artifact(bytes: validBytes, from: '2026.07.25', to: '2026.07.24'),
        CatalogDeltaArtifact(
          schemaVersion: 1,
          fromVersion: '2026.07.25',
          toVersion: '2026.07.26',
          sha256: List.filled(64, '0').join(),
          compressedDelta: validBytes,
        ),
        _artifact(
          bytes: _deltaBytes([
            {'operation': 'upsert', 'site': _site('atm-old', '更新一')},
            {
              'operation': 'retire',
              'id': 'atm-old',
              'lastSeenDate': '2026-07-25',
            },
          ]),
          from: '2026.07.25',
          to: '2026.07.26',
        ),
      ];

      for (final artifact in invalidArtifacts) {
        expect(
          await importer.applyChain([artifact]),
          isA<CatalogDeltaRejected>(),
        );
      }
      expect((await catalog.searchOffline('舊資料')).single.id, 'atm-old');
      final metadata = await database
          .select(database.catalogMetadataEntries)
          .getSingle();
      expect(metadata.datasetVersion, '2026.07.25');
    } finally {
      await database.close();
    }
  });

  test('過長 chain 要求 full snapshot 且不修改 catalog', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(
          jsonEncode({
            'schemaVersion': 1,
            'datasetVersion': '2026.07.25',
            'sites': [_site('atm-old', '舊資料')],
          }),
        ),
      );
      await catalog.ensureBundledCatalogInstalled();
      final first = _artifact(
        bytes: _deltaBytes([
          {'operation': 'upsert', 'site': _site('atm-old', '第一版')},
        ]),
        from: '2026.07.25',
        to: '2026.07.26',
      );
      final second = _artifact(
        bytes: _deltaBytes([
          {'operation': 'upsert', 'site': _site('atm-old', '第二版')},
        ]),
        from: '2026.07.26',
        to: '2026.07.27',
      );

      final result = await CatalogDeltaImporter(
        database,
      ).applyChain([first, second], maxChainLength: 1);

      expect(result, isA<CatalogDeltaFullSnapshotRequired>());
      expect((await catalog.searchOffline('舊資料')).single.id, 'atm-old');
    } finally {
      await database.close();
    }
  });

  test('delta 中途失敗會 rollback 先前 upsert', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final catalog = DriftAtmCatalog(
        database,
        _StringAssetSource(
          jsonEncode({
            'schemaVersion': 1,
            'datasetVersion': '2026.07.25',
            'sites': [_site('atm-old', '舊資料')],
          }),
        ),
      );
      await catalog.ensureBundledCatalogInstalled();
      final artifact = _artifact(
        bytes: _deltaBytes([
          {'operation': 'upsert', 'site': _site('atm-old', '不應留下')},
          {
            'operation': 'retire',
            'id': 'missing-target',
            'lastSeenDate': '2026-07-25',
          },
        ]),
        from: '2026.07.25',
        to: '2026.07.26',
      );

      expect(
        await CatalogDeltaImporter(database).applyChain([artifact]),
        isA<CatalogDeltaRejected>(),
      );
      expect((await catalog.searchOffline('舊資料')).single.id, 'atm-old');
      expect(await catalog.searchOffline('不應留下'), isEmpty);
    } finally {
      await database.close();
    }
  });
}

CatalogDeltaArtifact _artifact({
  required List<int> bytes,
  required String from,
  required String to,
}) {
  return CatalogDeltaArtifact(
    schemaVersion: 1,
    fromVersion: from,
    toVersion: to,
    sha256: sha256.convert(bytes).toString(),
    compressedDelta: bytes,
  );
}

List<int> _deltaBytes(List<Map<String, Object?>> operations) {
  return gzip.encode(
    utf8.encode(operations.map(jsonEncode).map((line) => '$line\n').join()),
  );
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
