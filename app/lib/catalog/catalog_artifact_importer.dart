import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/search_index.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;

sealed class CatalogArtifactImportResult {
  const CatalogArtifactImportResult();
}

class CatalogArtifactInstalled extends CatalogArtifactImportResult {
  const CatalogArtifactInstalled(this.datasetVersion);

  final String datasetVersion;
}

class CatalogArtifactRejected extends CatalogArtifactImportResult {
  const CatalogArtifactRejected();
}

class CatalogArtifactImporter {
  const CatalogArtifactImporter(this._database);

  static const _supportedSchemaVersion = 1;

  final AtmDatabase _database;

  Future<CatalogArtifactImportResult> installFullSnapshot({
    required String manifestJson,
    required List<int> compressedSnapshot,
    DateTime? lastUpdateCheckAt,
  }) async {
    try {
      final manifest = jsonDecode(manifestJson) as Map<String, Object?>;
      final schemaVersion = manifest['schemaVersion'] as int;
      final datasetVersion = manifest['datasetVersion'] as String;
      final recordCount = manifest['recordCount'] as int;
      final fullSnapshot = manifest['fullSnapshot']! as Map<String, Object?>;
      final expectedChecksum = fullSnapshot['sha256'] as String;
      final actualChecksum = sha256.convert(compressedSnapshot).toString();
      if (schemaVersion != _supportedSchemaVersion ||
          datasetVersion.trim().isEmpty ||
          recordCount <= 0 ||
          expectedChecksum != actualChecksum) {
        return const CatalogArtifactRejected();
      }

      final decodedSnapshot = utf8.decode(gzip.decode(compressedSnapshot));
      final rawSites = const LineSplitter()
          .convert(decodedSnapshot)
          .where((line) => line.trim().isNotEmpty)
          .map((line) => jsonDecode(line) as Map<String, Object?>)
          .toList(growable: false);
      if (rawSites.length != recordCount) {
        return const CatalogArtifactRejected();
      }

      final ids = <String>{};
      final sites = [
        for (final rawSite in rawSites) siteCompanion(rawSite, ids),
      ];
      await _database.batch((batch) {
        batch.deleteAll(_database.catalogMetadataEntries);
        batch.deleteAll(_database.atmSites);
        batch.insertAll(_database.atmSites, sites);
        batch.insert(
          _database.catalogMetadataEntries,
          CatalogMetadataEntriesCompanion.insert(
            schemaVersion: schemaVersion,
            datasetVersion: datasetVersion,
            installedAt: DateTime.now().toUtc(),
            lastUpdateCheckAt: Value(lastUpdateCheckAt?.toUtc()),
          ),
        );
      });

      return CatalogArtifactInstalled(datasetVersion);
    } on Object {
      return const CatalogArtifactRejected();
    }
  }

  static AtmSitesCompanion siteCompanion(
    Map<String, Object?> raw,
    Set<String> ids,
  ) {
    final id = raw['id'] as String;
    final institutionCode = raw['institutionCode'] as String;
    final institutionName = raw['institutionName'] as String;
    final placeName = raw['placeName'] as String;
    final placeCategory = raw['placeCategory'] as String;
    final county = (raw['county'] as String?) ?? '';
    final displayAddress = raw['displayAddress'] as String;
    final rawLatitude = raw['latitude'];
    final rawLongitude = raw['longitude'];
    final latitude = rawLatitude == null
        ? null
        : (rawLatitude as num).toDouble();
    final longitude = rawLongitude == null
        ? null
        : (rawLongitude as num).toDouble();
    final coordinateEvidence = _storedAttribution(raw['coordinateEvidence']);
    final placeCategoryEvidence = _storedAttribution(
      raw['placeCategoryEvidence'],
    );
    final capabilitiesJson = _validatedCapabilitiesJson(raw['capabilities']);
    final locationType = (raw['locationType'] as String?) ?? 'unknown';
    if (!{'on_site', 'off_site', 'unknown'}.contains(locationType)) {
      throw const FormatException('Invalid ATM location type');
    }
    final locationTypeEvidence = _storedAttribution(
      raw['locationTypeEvidence'],
    );
    final accessScheduleJson = _validatedAccessScheduleJson(
      raw['accessSchedule'],
    );
    final accessEvidence = _storedAttribution(raw['accessEvidence']);
    if (!ids.add(id) ||
        id.trim().isEmpty ||
        institutionCode.trim().isEmpty ||
        institutionName.trim().isEmpty ||
        placeName.trim().isEmpty ||
        displayAddress.trim().isEmpty ||
        (latitude == null) != (longitude == null) ||
        (latitude != null && (latitude < -90 || latitude > 90)) ||
        (longitude != null && (longitude < -180 || longitude > 180))) {
      throw const FormatException('Invalid ATM site in full snapshot');
    }
    return AtmSitesCompanion.insert(
      id: id,
      institutionCode: institutionCode,
      institutionName: institutionName,
      placeName: placeName,
      placeCategory: placeCategory,
      county: Value(county),
      displayAddress: displayAddress,
      normalizedAddress: Value(normalizeSearchText(displayAddress)),
      district: Value(extractDistrict(displayAddress, county: county)),
      latitude: Value(latitude),
      longitude: Value(longitude),
      coordinateEvidenceSource: Value(coordinateEvidence?.source),
      coordinateEvidenceDate: Value(coordinateEvidence?.date),
      coordinateEvidenceConfidence: Value(coordinateEvidence?.confidence),
      placeCategoryEvidenceSource: Value(placeCategoryEvidence?.source),
      placeCategoryEvidenceDate: Value(placeCategoryEvidence?.date),
      placeCategoryEvidenceConfidence: Value(placeCategoryEvidence?.confidence),
      capabilitiesJson: Value(capabilitiesJson),
      locationType: Value(locationType),
      locationTypeEvidenceSource: Value(locationTypeEvidence?.source),
      locationTypeEvidenceDate: Value(locationTypeEvidence?.date),
      locationTypeEvidenceConfidence: Value(locationTypeEvidence?.confidence),
      accessScheduleJson: Value(accessScheduleJson),
      accessEvidenceSource: Value(accessEvidence?.source),
      accessEvidenceDate: Value(accessEvidence?.date),
      accessEvidenceConfidence: Value(accessEvidence?.confidence),
      lastSeenDate: const Value(null),
      active: const Value(true),
    );
  }

  static String _validatedCapabilitiesJson(Object? raw) {
    if (raw == null) {
      return '{}';
    }
    final document = raw as Map<String, Object?>;
    const supportedCapabilities = {
      'deposit',
      'audioGuidance',
      'visualAccessibility',
      'wheelchairAccessibility',
      'foreignCurrencyWithdrawal',
    };
    for (final entry in document.entries) {
      if (!supportedCapabilities.contains(entry.key)) {
        throw const FormatException('Invalid ATM capability');
      }
      final fact = entry.value! as Map<String, Object?>;
      final status = fact['status'] as String;
      if (!{'confirmed', 'unknown', 'unsupported'}.contains(status)) {
        throw const FormatException('Invalid capability status');
      }
      final evidence = _storedAttribution(fact['evidence']);
      if (status == 'confirmed' && evidence == null) {
        throw const FormatException('Confirmed capability requires evidence');
      }
    }
    return jsonEncode(document);
  }

  static _StoredAttribution? _storedAttribution(Object? raw) {
    if (raw == null) {
      return null;
    }
    final document = raw as Map<String, Object?>;
    final source = document['source'] as String;
    final date = document['date'] as String;
    final confidence = document['confidence'] as String;
    final parsedDate = DateTime.parse(date);
    if (source.trim().isEmpty ||
        confidence.trim().isEmpty ||
        date !=
            '${parsedDate.year.toString().padLeft(4, '0')}-'
                '${parsedDate.month.toString().padLeft(2, '0')}-'
                '${parsedDate.day.toString().padLeft(2, '0')}') {
      throw const FormatException('Invalid evidence attribution');
    }
    return _StoredAttribution(
      source: source,
      date: date,
      confidence: confidence,
    );
  }

  static String? _validatedAccessScheduleJson(Object? raw) {
    if (raw == null) {
      return null;
    }
    final document = raw as Map<String, Object?>;
    final confirmedTwentyFourHours =
        document['confirmedTwentyFourHours'] as bool? ?? false;
    final rawPeriods = document['periods'] as List<Object?>? ?? const [];
    final periods = <Map<String, int>>[];
    for (final rawPeriod in rawPeriods) {
      final period = rawPeriod! as Map<String, Object?>;
      final weekday = period['weekday'] as int;
      final startMinute = period['startMinute'] as int;
      final endMinute = period['endMinute'] as int;
      if (weekday < DateTime.monday ||
          weekday > DateTime.sunday ||
          startMinute < 0 ||
          startMinute >= 1440 ||
          endMinute <= 0 ||
          endMinute > 1440) {
        throw const FormatException('Invalid ATM access schedule');
      }
      periods.add({
        'weekday': weekday,
        'startMinute': startMinute,
        'endMinute': endMinute,
      });
    }
    return jsonEncode({
      'confirmedTwentyFourHours': confirmedTwentyFourHours,
      'periods': periods,
    });
  }
}

class _StoredAttribution {
  const _StoredAttribution({
    required this.source,
    required this.date,
    required this.confidence,
  });

  final String source;
  final String date;
  final String confidence;
}
