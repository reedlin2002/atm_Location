import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_artifact_importer.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Python 發布的 full snapshot 可由 App 匯入並查詢 ATM 據點',
    () async {
      final workspaceDirectory = Directory.current.parent;
      final pipelineDirectory = Directory(
        '${workspaceDirectory.path}${Platform.pathSeparator}pipeline',
      );
      final providedReleaseDirectory =
          Platform.environment['CATALOG_RELEASE_DIRECTORY'];
      final outputDirectory = providedReleaseDirectory == null
          ? await Directory.systemTemp.createTemp('atmfinder-contract-')
          : Directory(providedReleaseDirectory);
      final ownsOutputDirectory = providedReleaseDirectory == null;
      final database = AtmDatabase(NativeDatabase.memory());

      try {
        if (ownsOutputDirectory) {
          final environment = Map<String, String>.from(Platform.environment);
          environment['PYTHONPATH'] =
              '${pipelineDirectory.path}${Platform.pathSeparator}src';
          final pythonExecutable =
              environment['PYTHON_EXECUTABLE'] ??
              environment['CONDA_PYTHON_EXE'] ??
              'python';
          final build = await Process.run(
            pythonExecutable,
            [
              '-m',
              'atm_catalog_builder',
              '--source',
              'tests/fixtures/official_atms.csv',
              '--source-name',
              'fixture-official-source',
              '--source-date',
              '2026-07-24',
              '--output',
              outputDirectory.path,
              '--dataset-version',
              '2026.07.25.1',
              '--published-at',
              '2026-07-25T08:00:00Z',
              '--artifact-base-url',
              'https://catalog.example.test/releases/2026.07.25.1',
              '--dry-run',
            ],
            workingDirectory: pipelineDirectory.path,
            environment: environment,
          );
          expect(build.exitCode, 0, reason: '${build.stdout}\n${build.stderr}');
        }

        final manifestJson = await File(
          '${outputDirectory.path}${Platform.pathSeparator}manifest.json',
        ).readAsString();
        final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
        final fullSnapshot = manifest['fullSnapshot'] as Map<String, dynamic>;
        final fullSnapshotName = Uri.parse(
          fullSnapshot['url'] as String,
        ).pathSegments.last;
        final importResult = await CatalogArtifactImporter(database)
            .installFullSnapshot(
              manifestJson: manifestJson,
              compressedSnapshot: await File(
                '${outputDirectory.path}${Platform.pathSeparator}$fullSnapshotName',
              ).readAsBytes(),
            );
        expect(importResult, isA<CatalogArtifactInstalled>());

        final catalog = DriftAtmCatalog(
          database,
          const _UnexpectedCatalogAssetSource(),
        );
        final sites = await catalog.findNearby(
          const GeoPoint(latitude: 25.0478, longitude: 121.5170),
          radiusMeters: 10000,
        );

        expect(sites, hasLength(4));
        expect(sites.map((site) => site.site.institutionCode).toSet(), {
          '004',
          '700',
          '812',
          '822',
        });
      } finally {
        await database.close();
        if (ownsOutputDirectory) {
          await outputDirectory.delete(recursive: true);
        }
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test('發布會阻擋低座標覆蓋率，App 仍可搜尋未發布的無座標草稿', () async {
    final workspaceDirectory = Directory.current.parent;
    final pipelineDirectory = Directory(
      '${workspaceDirectory.path}${Platform.pathSeparator}pipeline',
    );
    final outputDirectory = await Directory.systemTemp.createTemp(
      'atmfinder-fisc-contract-',
    );
    final database = AtmDatabase(NativeDatabase.memory());

    try {
      final environment = Map<String, String>.from(Platform.environment);
      environment['PYTHONPATH'] =
          '${pipelineDirectory.path}${Platform.pathSeparator}src';
      final pythonExecutable =
          environment['PYTHON_EXECUTABLE'] ??
          environment['CONDA_PYTHON_EXE'] ??
          'python';
      final build = await Process.run(
        pythonExecutable,
        [
          '-m',
          'atm_catalog_builder',
          '--source',
          'tests/fixtures/fisc_a2_location.csv',
          '--source-format',
          'fisc',
          '--source-name',
          'fisc-national-atm',
          '--source-date',
          '2026-07-24',
          '--output',
          outputDirectory.path,
          '--dataset-version',
          '2026.07.25.fisc',
          '--published-at',
          '2026-07-25T08:00:00Z',
          '--artifact-base-url',
          'https://catalog.example.test/fisc',
          '--dry-run',
        ],
        workingDirectory: pipelineDirectory.path,
        environment: environment,
      );
      expect(build.exitCode, 2, reason: '${build.stdout}\n${build.stderr}');
      expect(
        build.stdout,
        contains('coordinate_coverage_below_98_percent'),
      );

      final importResult = await CatalogArtifactImporter(database)
          .installFullSnapshot(
            manifestJson: await File(
              '${outputDirectory.path}${Platform.pathSeparator}manifest.json',
            ).readAsString(),
            compressedSnapshot: await File(
              '${outputDirectory.path}${Platform.pathSeparator}'
              'catalog-2026.07.25.fisc.ndjson.gz',
            ).readAsBytes(),
          );
      expect(importResult, isA<CatalogArtifactInstalled>());

      final catalog = DriftAtmCatalog(
        database,
        const _UnexpectedCatalogAssetSource(),
      );
      final expectedInstitutionByQuery = {
        '中國信託': '822',
        '7-ELEVEN': '822',
        '臺南市': '812',
        '西門路一段658號': '812',
      };
      for (final entry in expectedInstitutionByQuery.entries) {
        final results = await catalog.searchOffline(entry.key);
        expect(
          results.map((site) => site.institutionCode),
          contains(entry.value),
          reason: '查詢「${entry.key}」應找到 ${entry.value}',
        );
        expect(results.every((site) => site.position == null), isTrue);
      }
    } finally {
      await database.close();
      await outputDirectory.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('App 匯入正式產物後保留座標與場所的公開證據', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final snapshot = gzip.encode(
        utf8.encode(
          '${jsonEncode({
            'id': 'atm-moda-provenance',
            'institutionCode': '004',
            'institutionName': '臺灣銀行',
            'placeName': '館前分行',
            'placeCategory': 'bank',
            'county': '臺北市',
            'displayAddress': '臺北市中正區館前路49號',
            'latitude': 25.0461,
            'longitude': 121.5141,
            'coordinateEvidence': {'source': 'licensed-address-geocoder', 'date': '2026-07-25', 'confidence': 'licensed_exact'},
            'placeCategoryEvidence': {'source': 'moda-cash-atm', 'date': '2025-11-03', 'confidence': 'official_exact'},
            'capabilities': {
              'deposit': {
                'status': 'confirmed',
                'evidence': {'source': 'chunghwa-post-atm', 'date': '2026-07-25', 'confidence': 'official_positive'},
              },
            },
            'locationType': 'on_site',
            'locationTypeEvidence': {'source': 'chunghwa-post-atm', 'date': '2026-07-25', 'confidence': 'official_exact'},
          })}\n',
        ),
      );
      final result = await CatalogArtifactImporter(database)
          .installFullSnapshot(
            manifestJson: jsonEncode({
              'schemaVersion': 1,
              'datasetVersion': 'moda-provenance-contract',
              'recordCount': 1,
              'fullSnapshot': {'sha256': sha256.convert(snapshot).toString()},
            }),
            compressedSnapshot: snapshot,
          );
      expect(result, isA<CatalogArtifactInstalled>());

      final catalog = DriftAtmCatalog(
        database,
        const _UnexpectedCatalogAssetSource(),
      );
      final site = (await catalog.searchOffline('館前分行')).single;
      expect(
        site.coordinateEvidence?.publisher,
        EvidencePublisher.licensedGeocoder,
      );
      expect(
        site.coordinateEvidence?.confidence,
        EvidenceConfidence.licensedExact,
      );
      expect(site.coordinateEvidence?.sourceDate, DateTime.utc(2026, 7, 25));
      expect(
        site.placeCategoryEvidence?.publisher,
        EvidencePublisher.ministryOfDigitalAffairs,
      );
      expect(
        site.capabilityStatus(AtmCapability.deposit),
        CapabilityStatus.confirmed,
      );
      expect(
        site.capabilities.single.evidence?.publisher,
        EvidencePublisher.chunghwaPost,
      );
      expect(site.locationType, AtmLocationType.onSite);
      expect(
        site.locationTypeEvidence?.publisher,
        EvidencePublisher.chunghwaPost,
      );
    } finally {
      await database.close();
    }
  });

  test('SQLite 寫入失敗時保留先前已驗證 catalog', () async {
    final database = AtmDatabase(NativeDatabase.memory());
    try {
      final initial = _singleSiteArtifact(
        datasetVersion: 'verified-before-storage-failure',
        siteId: 'verified-atm',
        placeName: '原有 ATM',
      );
      expect(
        await CatalogArtifactImporter(database).installFullSnapshot(
          manifestJson: initial.manifestJson,
          compressedSnapshot: initial.compressedSnapshot,
        ),
        isA<CatalogArtifactInstalled>(),
      );

      await database.customStatement('''
        CREATE TRIGGER simulate_disk_full
        BEFORE INSERT ON atm_sites
        BEGIN
          SELECT RAISE(FAIL, 'database or disk is full');
        END
      ''');
      final replacement = _singleSiteArtifact(
        datasetVersion: 'replacement-that-cannot-be-written',
        siteId: 'replacement-atm',
        placeName: '替代 ATM',
      );

      expect(
        await CatalogArtifactImporter(database).installFullSnapshot(
          manifestJson: replacement.manifestJson,
          compressedSnapshot: replacement.compressedSnapshot,
        ),
        isA<CatalogArtifactRejected>(),
      );

      final catalog = DriftAtmCatalog(
        database,
        const _UnexpectedCatalogAssetSource(),
      );
      expect(
        (await catalog.searchOffline('原有 ATM')).map((site) => site.id),
        contains('verified-atm'),
      );
      expect(await catalog.searchOffline('替代 ATM'), isEmpty);
    } finally {
      await database.close();
    }
  });
}

({
  String manifestJson,
  List<int> compressedSnapshot,
}) _singleSiteArtifact({
  required String datasetVersion,
  required String siteId,
  required String placeName,
}) {
  final compressedSnapshot = gzip.encode(
    utf8.encode(
      '${jsonEncode({
        'id': siteId,
        'institutionCode': '004',
        'institutionName': '臺灣銀行',
        'placeName': placeName,
        'placeCategory': 'bank',
        'county': '臺北市',
        'displayAddress': '臺北市中正區館前路49號',
        'latitude': 25.0461,
        'longitude': 121.5141,
        'capabilities': <String, Object?>{},
      })}\n',
    ),
  );
  return (
    manifestJson: jsonEncode({
      'schemaVersion': 1,
      'datasetVersion': datasetVersion,
      'recordCount': 1,
      'fullSnapshot': {
        'sha256': sha256.convert(compressedSnapshot).toString(),
      },
    }),
    compressedSnapshot: compressedSnapshot,
  );
}

class _UnexpectedCatalogAssetSource implements CatalogAssetSource {
  const _UnexpectedCatalogAssetSource();

  @override
  Future<String> loadBundledCatalog() {
    throw StateError('Contract import must not load the bundled JSON fixture');
  }
}
