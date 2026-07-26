import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_artifact_importer.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

class CatalogDeltaArtifact {
  const CatalogDeltaArtifact({
    required this.schemaVersion,
    required this.fromVersion,
    required this.toVersion,
    required this.sha256,
    required this.compressedDelta,
  });

  final int schemaVersion;
  final String fromVersion;
  final String toVersion;
  final String sha256;
  final List<int> compressedDelta;
}

sealed class CatalogDeltaImportResult {
  const CatalogDeltaImportResult();
}

class CatalogDeltaInstalled extends CatalogDeltaImportResult {
  const CatalogDeltaInstalled(this.datasetVersion);

  final String datasetVersion;
}

class CatalogDeltaRejected extends CatalogDeltaImportResult {
  const CatalogDeltaRejected();
}

class CatalogDeltaFullSnapshotRequired extends CatalogDeltaImportResult {
  const CatalogDeltaFullSnapshotRequired();
}

class CatalogDeltaImporter {
  const CatalogDeltaImporter(this.database);

  static const _supportedSchemaVersion = 1;
  static const defaultMaxChainLength = 7;

  final AtmDatabase database;

  Future<CatalogDeltaImportResult> applyChain(
    List<CatalogDeltaArtifact> artifacts, {
    int maxChainLength = defaultMaxChainLength,
  }) async {
    if (artifacts.isEmpty || maxChainLength <= 0) {
      return const CatalogDeltaRejected();
    }
    if (artifacts.length > maxChainLength) {
      return const CatalogDeltaFullSnapshotRequired();
    }
    try {
      final metadata = await (database.select(
        database.catalogMetadataEntries,
      )..limit(1)).getSingleOrNull();
      if (metadata == null) {
        return const CatalogDeltaFullSnapshotRequired();
      }
      var expectedFromVersion = metadata.datasetVersion;
      final parsedArtifacts = <_ParsedDelta>[];
      for (final artifact in artifacts) {
        if (artifact.schemaVersion != _supportedSchemaVersion ||
            artifact.fromVersion != expectedFromVersion ||
            _compareVersions(artifact.toVersion, artifact.fromVersion) <= 0 ||
            sha256.convert(artifact.compressedDelta).toString() !=
                artifact.sha256) {
          return const CatalogDeltaRejected();
        }
        parsedArtifacts.add(_parse(artifact));
        expectedFromVersion = artifact.toVersion;
      }

      await database.transaction(() async {
        for (final parsed in parsedArtifacts) {
          for (final operation in parsed.operations) {
            switch (operation) {
              case _UpsertOperation():
                await database
                    .into(database.atmSites)
                    .insertOnConflictUpdate(operation.site);
              case _RetireOperation():
                final updated =
                    await (database.update(
                      database.atmSites,
                    )..where((site) => site.id.equals(operation.id))).write(
                      AtmSitesCompanion(
                        active: const Value(false),
                        lastSeenDate: Value(operation.lastSeenDate),
                      ),
                    );
                if (updated != 1) {
                  throw const FormatException(
                    'Delta retirement target does not exist',
                  );
                }
            }
          }
        }
        await (database.update(database.catalogMetadataEntries)).write(
          CatalogMetadataEntriesCompanion(
            datasetVersion: Value(expectedFromVersion),
            installedAt: Value(DateTime.now().toUtc()),
          ),
        );
      });
      return CatalogDeltaInstalled(expectedFromVersion);
    } on Object {
      return const CatalogDeltaRejected();
    }
  }

  static _ParsedDelta _parse(CatalogDeltaArtifact artifact) {
    final decoded = utf8.decode(gzip.decode(artifact.compressedDelta));
    final rawOperations = const LineSplitter()
        .convert(decoded)
        .where((line) => line.trim().isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, Object?>)
        .toList(growable: false);
    if (rawOperations.isEmpty) {
      throw const FormatException('Delta has no operations');
    }
    final ids = <String>{};
    final operations = <_DeltaOperation>[];
    for (final raw in rawOperations) {
      switch (raw['operation']) {
        case 'upsert':
          final site = raw['site']! as Map<String, Object?>;
          final id = site['id'] as String;
          if (!ids.add(id)) {
            throw const FormatException('Duplicate delta operation');
          }
          operations.add(
            _UpsertOperation(
              CatalogArtifactImporter.siteCompanion(site, <String>{}),
            ),
          );
        case 'retire':
          final id = raw['id'] as String;
          final lastSeenDate = raw['lastSeenDate'] as String;
          if (!ids.add(id) || !_isIsoDate(lastSeenDate)) {
            throw const FormatException('Invalid delta retirement');
          }
          operations.add(_RetireOperation(id: id, lastSeenDate: lastSeenDate));
        default:
          throw const FormatException('Unsupported delta operation');
      }
    }
    return _ParsedDelta(operations);
  }

  static bool _isIsoDate(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed != null &&
        value ==
            '${parsed.year.toString().padLeft(4, '0')}-'
                '${parsed.month.toString().padLeft(2, '0')}-'
                '${parsed.day.toString().padLeft(2, '0')}';
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

class _ParsedDelta {
  const _ParsedDelta(this.operations);

  final List<_DeltaOperation> operations;
}

sealed class _DeltaOperation {
  const _DeltaOperation();
}

class _UpsertOperation extends _DeltaOperation {
  const _UpsertOperation(this.site);

  final AtmSitesCompanion site;
}

class _RetireOperation extends _DeltaOperation {
  const _RetireOperation({required this.id, required this.lastSeenDate});

  final String id;
  final String lastSeenDate;
}
