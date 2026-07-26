import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_artifact_importer.dart';
import 'package:atmfinder/catalog/catalog_delta_importer.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

abstract interface class CatalogHttpClient {
  Future<CatalogHttpResponse> get(Uri uri);
}

class CatalogHttpResponse {
  const CatalogHttpResponse({
    required this.statusCode,
    required this.contentType,
    required this.bodyBytes,
  });

  const CatalogHttpResponse.okJson(List<int> bodyBytes)
    : this(
        statusCode: 200,
        contentType: 'application/json',
        bodyBytes: bodyBytes,
      );

  const CatalogHttpResponse.okBinary(List<int> bodyBytes)
    : this(
        statusCode: 200,
        contentType: 'application/octet-stream',
        bodyBytes: bodyBytes,
      );

  final int statusCode;
  final String contentType;
  final List<int> bodyBytes;
}

abstract interface class UpdateClock {
  DateTime nowUtc();
}

sealed class CatalogUpdateResult {
  const CatalogUpdateResult();
}

class CatalogUpToDate extends CatalogUpdateResult {
  const CatalogUpToDate();
}

class CatalogUpdated extends CatalogUpdateResult {
  const CatalogUpdated(this.datasetVersion);

  final String datasetVersion;
}

class CatalogUsingOldData extends CatalogUpdateResult {
  const CatalogUsingOldData();
}

class CatalogIncompatible extends CatalogUpdateResult {
  const CatalogIncompatible();
}

class CatalogRolledBack extends CatalogUpdateResult {
  const CatalogRolledBack(this.datasetVersion);

  final String datasetVersion;
}

class CatalogUpdateCoordinator {
  CatalogUpdateCoordinator({
    required this.database,
    required this.importer,
    required this.http,
    required this.clock,
    required this.manifestUri,
    CatalogDeltaImporter? deltaImporter,
    this.maxDeltaChainLength = CatalogDeltaImporter.defaultMaxChainLength,
  }) : deltaImporter = deltaImporter ?? CatalogDeltaImporter(database);

  static const _supportedArtifactSchemaVersion = 1;

  final AtmDatabase database;
  final CatalogArtifactImporter importer;
  final CatalogHttpClient http;
  final UpdateClock clock;
  final Uri manifestUri;
  final CatalogDeltaImporter deltaImporter;
  final int maxDeltaChainLength;

  Future<CatalogUpdateResult> checkForUpdate() async {
    final metadata = await (database.select(
      database.catalogMetadataEntries,
    )..limit(1)).getSingleOrNull();
    if (metadata == null) {
      return const CatalogUsingOldData();
    }
    final now = clock.nowUtc().toUtc();
    if (_isSameUtcDay(metadata.lastUpdateCheckAt, now)) {
      return const CatalogUpToDate();
    }
    await (database.update(database.catalogMetadataEntries)
          ..where((row) => row.singletonKey.equals(metadata.singletonKey)))
        .write(CatalogMetadataEntriesCompanion(lastUpdateCheckAt: Value(now)));

    try {
      if (manifestUri.scheme != 'https') {
        return const CatalogIncompatible();
      }
      final manifestResponse = await http.get(manifestUri);
      if (!_isSuccessful(
        manifestResponse,
        expectedMediaTypes: const {'application/json'},
      )) {
        return const CatalogUsingOldData();
      }
      final manifestJson = utf8.decode(manifestResponse.bodyBytes);
      final manifest = jsonDecode(manifestJson) as Map<String, Object?>;
      final schemaVersion = manifest['schemaVersion'] as int;
      final datasetVersion = manifest['datasetVersion'] as String;
      if (schemaVersion != _supportedArtifactSchemaVersion) {
        return const CatalogIncompatible();
      }
      final versionOrder = _compareVersions(
        datasetVersion,
        metadata.datasetVersion,
      );
      if (versionOrder == 0) {
        return const CatalogUpToDate();
      }
      if (versionOrder < 0) {
        return const CatalogIncompatible();
      }

      final previous = await _captureCurrentCatalog();
      final deltaChain = _selectDeltaChain(
        manifest['deltas'],
        fromVersion: metadata.datasetVersion,
        toVersion: datasetVersion,
        maxLength: maxDeltaChainLength,
      );
      if (deltaChain != null) {
        try {
          final artifacts = <CatalogDeltaArtifact>[];
          for (final descriptor in deltaChain) {
            final uri = Uri.parse(descriptor['url'] as String);
            if (uri.scheme != 'https') {
              throw const FormatException('Delta URL must use HTTPS');
            }
            final response = await http.get(uri);
            if (!_isSuccessful(
              response,
              expectedMediaTypes: const {
                'application/octet-stream',
                'application/gzip',
              },
            )) {
              throw const HttpException('Delta download failed');
            }
            artifacts.add(
              CatalogDeltaArtifact(
                schemaVersion: descriptor['schemaVersion'] as int,
                fromVersion: descriptor['fromVersion'] as String,
                toVersion: descriptor['toVersion'] as String,
                sha256: descriptor['sha256'] as String,
                compressedDelta: response.bodyBytes,
              ),
            );
          }
          final deltaResult = await deltaImporter.applyChain(
            artifacts,
            maxChainLength: maxDeltaChainLength,
          );
          if (deltaResult is CatalogDeltaInstalled) {
            if (previous != null) {
              await _saveBackup(previous, now);
            }
            return CatalogUpdated(deltaResult.datasetVersion);
          }
        } on Object {
          // A missing or invalid chain deliberately falls back to full.
        }
      }

      final fullSnapshot = manifest['fullSnapshot']! as Map<String, Object?>;
      final snapshotUri = Uri.parse(fullSnapshot['url'] as String);
      if (snapshotUri.scheme != 'https') {
        return const CatalogIncompatible();
      }
      final snapshotResponse = await http.get(snapshotUri);
      if (!_isSuccessful(
        snapshotResponse,
        expectedMediaTypes: const {
          'application/octet-stream',
          'application/gzip',
        },
      )) {
        return const CatalogUsingOldData();
      }

      final installResult = await importer.installFullSnapshot(
        manifestJson: manifestJson,
        compressedSnapshot: snapshotResponse.bodyBytes,
        lastUpdateCheckAt: now,
      );
      if (installResult is! CatalogArtifactInstalled) {
        return const CatalogUsingOldData();
      }
      final installedMetadata = await (database.select(
        database.catalogMetadataEntries,
      )..limit(1)).getSingleOrNull();
      final installedSite = await (database.select(
        database.atmSites,
      )..limit(1)).getSingleOrNull();
      if (installedMetadata?.datasetVersion != datasetVersion ||
          installedSite == null) {
        if (previous != null) {
          await _restore(previous, lastUpdateCheckAt: now);
        }
        return const CatalogUsingOldData();
      }
      if (previous != null) {
        await _saveBackup(previous, now);
      }
      return CatalogUpdated(datasetVersion);
    } on Object {
      return const CatalogUsingOldData();
    }
  }

  Future<CatalogUpdateResult> rollbackToPreviousGood() async {
    final backup = await (database.select(
      database.catalogBackupEntries,
    )..limit(1)).getSingleOrNull();
    if (backup == null) {
      return const CatalogUsingOldData();
    }
    final result = await importer.installFullSnapshot(
      manifestJson: backup.manifestJson,
      compressedSnapshot: backup.compressedSnapshot,
      lastUpdateCheckAt: clock.nowUtc(),
    );
    return result is CatalogArtifactInstalled
        ? CatalogRolledBack(backup.datasetVersion)
        : const CatalogUsingOldData();
  }

  Future<_CatalogArtifact?> _captureCurrentCatalog() async {
    final metadata = await (database.select(
      database.catalogMetadataEntries,
    )..limit(1)).getSingleOrNull();
    final rows = await database.select(database.atmSites).get();
    if (metadata == null || rows.isEmpty) {
      return null;
    }
    final snapshotBytes = gzip.encode(
      utf8.encode(
        rows
            .map((row) => jsonEncode(_siteDocument(row)))
            .map((line) => '$line\n')
            .join(),
      ),
    );
    final manifest = {
      'schemaVersion': metadata.schemaVersion,
      'datasetVersion': metadata.datasetVersion,
      'recordCount': rows.length,
      'fullSnapshot': {'sha256': sha256.convert(snapshotBytes).toString()},
    };
    return _CatalogArtifact(
      datasetVersion: metadata.datasetVersion,
      manifestJson: jsonEncode(manifest),
      compressedSnapshot: Uint8List.fromList(snapshotBytes),
    );
  }

  Future<bool> _restore(
    _CatalogArtifact artifact, {
    required DateTime lastUpdateCheckAt,
  }) async {
    final result = await importer.installFullSnapshot(
      manifestJson: artifact.manifestJson,
      compressedSnapshot: artifact.compressedSnapshot,
      lastUpdateCheckAt: lastUpdateCheckAt,
    );
    return result is CatalogArtifactInstalled;
  }

  Future<void> _saveBackup(_CatalogArtifact previous, DateTime now) async {
    await database
        .into(database.catalogBackupEntries)
        .insertOnConflictUpdate(
          CatalogBackupEntriesCompanion.insert(
            datasetVersion: previous.datasetVersion,
            manifestJson: previous.manifestJson,
            compressedSnapshot: previous.compressedSnapshot,
            createdAt: now,
          ),
        );
  }

  static Map<String, Object?> _siteDocument(StoredAtmSite row) {
    return {
      'id': row.id,
      'institutionCode': row.institutionCode,
      'institutionName': row.institutionName,
      'placeName': row.placeName,
      'placeCategory': row.placeCategory,
      'county': row.county,
      'displayAddress': row.displayAddress,
      'latitude': row.latitude,
      'longitude': row.longitude,
      'coordinateEvidence': _attribution(
        row.coordinateEvidenceSource,
        row.coordinateEvidenceDate,
        row.coordinateEvidenceConfidence,
      ),
      'placeCategoryEvidence': _attribution(
        row.placeCategoryEvidenceSource,
        row.placeCategoryEvidenceDate,
        row.placeCategoryEvidenceConfidence,
      ),
      'capabilities': jsonDecode(row.capabilitiesJson),
      'locationType': row.locationType,
      'locationTypeEvidence': _attribution(
        row.locationTypeEvidenceSource,
        row.locationTypeEvidenceDate,
        row.locationTypeEvidenceConfidence,
      ),
      'accessSchedule': row.accessScheduleJson == null
          ? null
          : jsonDecode(row.accessScheduleJson!),
      'accessEvidence': _attribution(
        row.accessEvidenceSource,
        row.accessEvidenceDate,
        row.accessEvidenceConfidence,
      ),
    };
  }

  static Map<String, String>? _attribution(
    String? source,
    String? date,
    String? confidence,
  ) {
    if (source == null && date == null && confidence == null) {
      return null;
    }
    if (source == null || date == null || confidence == null) {
      throw const FormatException('Incomplete stored attribution');
    }
    return {'source': source, 'date': date, 'confidence': confidence};
  }

  static bool _isSuccessful(
    CatalogHttpResponse response, {
    required Set<String> expectedMediaTypes,
  }) {
    final mediaType = response.contentType
        .split(';')
        .first
        .trim()
        .toLowerCase();
    return response.statusCode == 200 &&
        response.bodyBytes.isNotEmpty &&
        expectedMediaTypes.contains(mediaType);
  }

  static bool _isSameUtcDay(DateTime? left, DateTime right) {
    if (left == null) {
      return false;
    }
    final utc = left.toUtc();
    return utc.year == right.year &&
        utc.month == right.month &&
        utc.day == right.day;
  }

  static List<Map<String, Object?>>? _selectDeltaChain(
    Object? raw, {
    required String fromVersion,
    required String toVersion,
    required int maxLength,
  }) {
    if (raw is! List<Object?> || raw.isEmpty || maxLength <= 0) {
      return null;
    }
    final descriptors = raw
        .map((item) => item! as Map<String, Object?>)
        .toList(growable: false);
    final selected = <Map<String, Object?>>[];
    final visited = <String>{};
    var current = fromVersion;
    while (current != toVersion) {
      if (!visited.add(current) || selected.length >= maxLength) {
        return null;
      }
      final candidates = descriptors
          .where((item) => item['fromVersion'] == current)
          .toList(growable: false);
      if (candidates.length != 1) {
        return null;
      }
      final next = candidates.single;
      selected.add(next);
      current = next['toVersion'] as String;
      if (_compareVersions(current, toVersion) > 0) {
        return null;
      }
    }
    return selected;
  }

  static int _compareVersions(String left, String right) {
    final leftParts = left.split('.');
    final rightParts = right.split('.');
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index += 1) {
      final leftPart = index < leftParts.length ? leftParts[index] : '0';
      final rightPart = index < rightParts.length ? rightParts[index] : '0';
      final leftNumber = int.tryParse(leftPart);
      final rightNumber = int.tryParse(rightPart);
      final order = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : leftPart.compareTo(rightPart);
      if (order != 0) {
        return order;
      }
    }
    return 0;
  }
}

class _CatalogArtifact {
  const _CatalogArtifact({
    required this.datasetVersion,
    required this.manifestJson,
    required this.compressedSnapshot,
  });

  final String datasetVersion;
  final String manifestJson;
  final Uint8List compressedSnapshot;
}
