import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_artifact_importer.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/quality/performance_gate.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'production-like App import and query performance gate',
    _runPerformanceGate,
    timeout: const Timeout(Duration(minutes: 3)),
    tags: const ['production-performance'],
  );
}

Future<void> _runPerformanceGate() async {
  const recordCount = int.fromEnvironment(
    'PERFORMANCE_RECORDS',
    defaultValue: 25000,
  );
  const outputPath = String.fromEnvironment(
    'PERFORMANCE_OUTPUT_DIR',
    defaultValue: '../performance/reports',
  );
  const deviceProfile = String.fromEnvironment(
    'PERFORMANCE_DEVICE_PROFILE',
    defaultValue:
        'ci-host-proxy; Android 10 / 2 GB physical-device rerun required',
  );
  final outputDirectory = Directory(outputPath);
  if (recordCount < 1000) {
    throw ArgumentError.value(recordCount, 'PERFORMANCE_RECORDS');
  }

  final fixture = _productionLikeFixture(recordCount);
  final compressedSnapshot = gzip.encode(utf8.encode(fixture.jsonLines));
  final manifestJson = jsonEncode({
    'schemaVersion': 1,
    'datasetVersion': fixture.datasetVersion,
    'recordCount': recordCount,
    'fullSnapshot': {'sha256': sha256.convert(compressedSnapshot).toString()},
  });
  final temporaryDirectory = await Directory.systemTemp.createTemp(
    'atm-performance-',
  );

  AtmDatabase? benchmarkDatabase;
  try {
    final importSamples = <double>[];
    for (var sample = 0; sample < 3; sample++) {
      final database = AtmDatabase(
        NativeDatabase(
          File('${temporaryDirectory.path}/import-$sample.sqlite'),
        ),
      );
      final elapsed = await _measure(() async {
        final result = await CatalogArtifactImporter(database)
            .installFullSnapshot(
              manifestJson: manifestJson,
              compressedSnapshot: compressedSnapshot,
            );
        if (result is! CatalogArtifactInstalled) {
          throw StateError('Production-like App import dry run was rejected');
        }
      });
      importSamples.add(elapsed);
      if (sample == 2) {
        benchmarkDatabase = database;
      } else {
        await database.close();
      }
    }

    final database = benchmarkDatabase!;
    final catalog = DriftAtmCatalog(database, const _NeverAssetSource());
    final warmStartSamples = <double>[];
    for (var sample = 0; sample < 30; sample++) {
      warmStartSamples.add(
        await _measure(() async {
          await catalog.ensureBundledCatalogInstalled();
        }),
      );
    }

    final nearbySamples = <double>[];
    for (var sample = 0; sample < 60; sample++) {
      final origin = GeoPoint(
        latitude: 22.0 + (sample % 45) * 0.1,
        longitude: 120.0 + (sample % 25) * 0.1,
      );
      nearbySamples.add(
        await _measure(
          () async {
            await catalog.findNearby(
              origin,
              radiusMeters: 10000,
              limit: 50,
            );
          },
        ),
      );
    }

    final textSearchSamples = <double>[];
    for (var sample = 0; sample < 30; sample++) {
      textSearchSamples.add(
        await _measure(
          () async {
            await catalog.searchOffline(
              sample.isEven ? '臺北市' : '基準 ATM',
              limit: 50,
            );
          },
        ),
      );
    }

    final report = PerformanceGateReport(
      datasetVersion: fixture.datasetVersion,
      environment: BenchmarkEnvironment(
        operatingSystem:
            '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        runtime: Platform.version,
        deviceProfile: deviceProfile,
      ),
      dataQuality: ProductionDataQuality(
        recordCount: recordCount,
        coordinateCount: fixture.coordinateCount,
        compressedBytes: compressedSnapshot.length,
        unresolvedByCounty: fixture.unresolvedByCounty,
      ),
      timings: {
        'firstImport': TimingSummary.fromSamples(importSamples),
        'warmStart': TimingSummary.fromSamples(warmStartSamples),
        'nearbyQuery': TimingSummary.fromSamples(nearbySamples),
        'textSearch': TimingSummary.fromSamples(textSearchSamples),
      },
    );

    await outputDirectory.create(recursive: true);
    final stem = 'performance-${fixture.datasetVersion}';
    await File('${outputDirectory.path}/$stem.json').writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(report.toJson())}\n',
    );
    await File(
      '${outputDirectory.path}/$stem.md',
    ).writeAsString(report.toMarkdown());
    stdout.write(report.toMarkdown());
    expect(report.violations, isEmpty, reason: report.toMarkdown());
  } finally {
    await benchmarkDatabase?.close();
    await temporaryDirectory.delete(recursive: true);
  }
}

class _ProductionLikeFixture {
  const _ProductionLikeFixture({
    required this.datasetVersion,
    required this.jsonLines,
    required this.coordinateCount,
    required this.unresolvedByCounty,
  });

  final String datasetVersion;
  final String jsonLines;
  final int coordinateCount;
  final Map<String, int> unresolvedByCounty;
}

_ProductionLikeFixture _productionLikeFixture(int recordCount) {
  const datasetVersion = 'production-like-2026.07.26';
  final lines = StringBuffer();
  var coordinateCount = 0;
  var unresolvedCount = 0;
  for (var index = 0; index < recordCount; index++) {
    final unresolved = index % 100 == 0;
    if (unresolved) {
      unresolvedCount++;
    } else {
      coordinateCount++;
    }
    lines.writeln(
      jsonEncode({
        'id': 'benchmark-${index.toString().padLeft(6, '0')}',
        'institutionCode': (index % 40).toString().padLeft(3, '0'),
        'institutionName': '基準銀行 ${index % 40}',
        'placeName': '基準 ATM $index',
        'placeCategory': 'bank',
        'county': unresolved ? '臺東縣' : '臺北市',
        'displayAddress': unresolved
            ? '臺東縣臺東市基準路 $index 號'
            : '臺北市中正區基準路 $index 號',
        'latitude': unresolved ? null : 21.9 + (index % 450) / 100,
        'longitude': unresolved ? null : 120.0 + (index % 280) / 100,
        'capabilities': <String, Object?>{},
      }),
    );
  }
  return _ProductionLikeFixture(
    datasetVersion: datasetVersion,
    jsonLines: lines.toString(),
    coordinateCount: coordinateCount,
    unresolvedByCounty: {'臺東縣': unresolvedCount},
  );
}

Future<double> _measure(Future<void> Function() operation) async {
  final stopwatch = Stopwatch()..start();
  await operation();
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds / 1000;
}

class _NeverAssetSource implements CatalogAssetSource {
  const _NeverAssetSource();

  @override
  Future<String> loadBundledCatalog() {
    throw StateError('Warm start must not load bundled assets');
  }
}
