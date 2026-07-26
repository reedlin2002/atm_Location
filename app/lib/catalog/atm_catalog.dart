import 'dart:convert';
import 'dart:math' as math;

import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/search_index.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:drift/drift.dart';

enum PlaceCategory { bank, convenienceStore, postOffice, other, unknown }

enum EvidencePublisher {
  fisc,
  ministryOfDigitalAffairs,
  chunghwaPost,
  licensedGeocoder,
  manualReview,
  unknown,
}

enum EvidenceConfidence {
  officialExact,
  officialPositive,
  licensedExact,
  licensedFuzzy,
  manualReviewed,
  unknown,
}

enum AtmCapability {
  deposit,
  audioGuidance,
  visualAccessibility,
  wheelchairAccessibility,
  foreignCurrencyWithdrawal,
}

enum CapabilityStatus { confirmed, unknown, unsupported }

enum AtmLocationType { onSite, offSite, unknown }

enum AtmAccessStatus { open, unknown, closed }

class AccessPeriod {
  const AccessPeriod({
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  }) : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday),
       assert(startMinute >= 0 && startMinute < 1440),
       assert(endMinute > 0 && endMinute <= 1440);

  final int weekday;
  final int startMinute;
  final int endMinute;
}

class AtmAccessSchedule {
  const AtmAccessSchedule({
    this.confirmedTwentyFourHours = false,
    this.periods = const [],
  });

  final bool confirmedTwentyFourHours;
  final List<AccessPeriod> periods;
}

class EvidenceAttribution {
  const EvidenceAttribution({
    required this.publisher,
    required this.sourceDate,
    required this.confidence,
  });

  final EvidencePublisher publisher;
  final DateTime sourceDate;
  final EvidenceConfidence confidence;
}

class CapabilityFact {
  const CapabilityFact({
    required this.capability,
    required this.status,
    this.evidence,
  });

  final AtmCapability capability;
  final CapabilityStatus status;
  final EvidenceAttribution? evidence;
}

class AtmSite {
  const AtmSite({
    required this.id,
    required this.institutionCode,
    required this.institutionName,
    required this.placeName,
    required this.placeCategory,
    this.county = '',
    required this.displayAddress,
    this.normalizedAddress = '',
    this.district = '',
    required this.position,
    this.coordinateEvidence,
    this.placeCategoryEvidence,
    this.capabilities = const [],
    this.locationType = AtmLocationType.unknown,
    this.locationTypeEvidence,
    this.accessSchedule,
    this.accessEvidence,
    this.lastSeenDate,
  });

  final String id;
  final String institutionCode;
  final String institutionName;
  final String placeName;
  final PlaceCategory placeCategory;
  final String county;
  final String displayAddress;
  final String normalizedAddress;
  final String district;
  final GeoPoint? position;
  final EvidenceAttribution? coordinateEvidence;
  final EvidenceAttribution? placeCategoryEvidence;
  final List<CapabilityFact> capabilities;
  final AtmLocationType locationType;
  final EvidenceAttribution? locationTypeEvidence;
  final AtmAccessSchedule? accessSchedule;
  final EvidenceAttribution? accessEvidence;
  final DateTime? lastSeenDate;

  CapabilityStatus capabilityStatus(AtmCapability capability) {
    for (final fact in capabilities) {
      if (fact.capability == capability) {
        return fact.status;
      }
    }
    return CapabilityStatus.unknown;
  }
}

class NearbyAtmSite {
  const NearbyAtmSite({required this.site, required this.distanceMeters});

  final AtmSite site;
  final double distanceMeters;
}

sealed class CatalogInstallResult {
  const CatalogInstallResult();
}

class CatalogInstalled extends CatalogInstallResult {
  const CatalogInstalled();
}

class CatalogAlreadyInstalled extends CatalogInstallResult {
  const CatalogAlreadyInstalled();
}

class CatalogInstallFailed extends CatalogInstallResult {
  const CatalogInstallFailed();
}

abstract interface class AtmCatalog {
  Future<CatalogInstallResult> ensureBundledCatalogInstalled();

  Future<List<NearbyAtmSite>> findNearby(
    GeoPoint origin, {
    required double radiusMeters,
    int limit = 50,
  });

  Future<List<AtmSite>> searchOffline(String query, {int limit = 50});
}

abstract interface class AtmSiteLookup {
  Future<AtmSite?> findById(String id, {bool includeRetired = false});
}

class DriftAtmCatalog implements AtmCatalog, AtmSiteLookup {
  DriftAtmCatalog(this._database, this._assetSource);

  static const _supportedSchemaVersion = 1;
  static const _earthRadiusMeters = 6371008.8;

  final AtmDatabase _database;
  final CatalogAssetSource _assetSource;

  @override
  Future<CatalogInstallResult> ensureBundledCatalogInstalled() async {
    final installedMetadata = await (_database.select(
      _database.catalogMetadataEntries,
    )..limit(1)).getSingleOrNull();
    if (installedMetadata != null) {
      return const CatalogAlreadyInstalled();
    }

    try {
      final document =
          jsonDecode(await _assetSource.loadBundledCatalog())
              as Map<String, Object?>;
      final schemaVersion = document['schemaVersion'] as int;
      final datasetVersion = document['datasetVersion'] as String;
      final rawSites = document['sites'] as List<Object?>;
      if (schemaVersion != _supportedSchemaVersion ||
          datasetVersion.trim().isEmpty ||
          rawSites.isEmpty) {
        return const CatalogInstallFailed();
      }

      final sites = rawSites
          .map((rawSite) => _parseSite(rawSite! as Map<String, Object?>))
          .toList(growable: false);
      await _database.batch((batch) {
        batch.insertAll(_database.atmSites, [
          for (final site in sites)
            AtmSitesCompanion.insert(
              id: site.id,
              institutionCode: site.institutionCode,
              institutionName: site.institutionName,
              placeName: site.placeName,
              placeCategory: _placeCategoryWireValue(site.placeCategory),
              county: Value(site.county),
              displayAddress: site.displayAddress,
              normalizedAddress: Value(site.normalizedAddress),
              district: Value(site.district),
              latitude: Value(site.position?.latitude),
              longitude: Value(site.position?.longitude),
              coordinateEvidenceSource: Value(
                _publisherWireValue(site.coordinateEvidence?.publisher),
              ),
              coordinateEvidenceDate: Value(
                _dateWireValue(site.coordinateEvidence?.sourceDate),
              ),
              coordinateEvidenceConfidence: Value(
                _confidenceWireValue(site.coordinateEvidence?.confidence),
              ),
              placeCategoryEvidenceSource: Value(
                _publisherWireValue(site.placeCategoryEvidence?.publisher),
              ),
              placeCategoryEvidenceDate: Value(
                _dateWireValue(site.placeCategoryEvidence?.sourceDate),
              ),
              placeCategoryEvidenceConfidence: Value(
                _confidenceWireValue(site.placeCategoryEvidence?.confidence),
              ),
              capabilitiesJson: Value(
                jsonEncode(_capabilitiesWireDocument(site.capabilities)),
              ),
              locationType: Value(_locationTypeWireValue(site.locationType)),
              locationTypeEvidenceSource: Value(
                _publisherWireValue(site.locationTypeEvidence?.publisher),
              ),
              locationTypeEvidenceDate: Value(
                _dateWireValue(site.locationTypeEvidence?.sourceDate),
              ),
              locationTypeEvidenceConfidence: Value(
                _confidenceWireValue(site.locationTypeEvidence?.confidence),
              ),
              accessScheduleJson: Value(
                site.accessSchedule == null
                    ? null
                    : jsonEncode(
                        _accessScheduleWireDocument(site.accessSchedule!),
                      ),
              ),
              accessEvidenceSource: Value(
                _publisherWireValue(site.accessEvidence?.publisher),
              ),
              accessEvidenceDate: Value(
                _dateWireValue(site.accessEvidence?.sourceDate),
              ),
              accessEvidenceConfidence: Value(
                _confidenceWireValue(site.accessEvidence?.confidence),
              ),
            ),
        ]);
        batch.insert(
          _database.catalogMetadataEntries,
          CatalogMetadataEntriesCompanion.insert(
            schemaVersion: schemaVersion,
            datasetVersion: datasetVersion,
            installedAt: DateTime.now().toUtc(),
          ),
        );
      });
      return const CatalogInstalled();
    } on Object {
      return const CatalogInstallFailed();
    }
  }

  @override
  Future<List<NearbyAtmSite>> findNearby(
    GeoPoint origin, {
    required double radiusMeters,
    int limit = 50,
  }) async {
    if (radiusMeters <= 0 || limit <= 0) {
      return const [];
    }

    final latitudeDelta = radiusMeters / 111320;
    final longitudeScale = math
        .cos(_toRadians(origin.latitude))
        .abs()
        .clamp(0.01, 1.0);
    final longitudeDelta = radiusMeters / (111320 * longitudeScale);
    final candidates =
        await (_database.select(_database.atmSites)..where(
              (site) =>
                  site.active.equals(true) &
                  site.latitude.isNotNull() &
                  site.longitude.isNotNull() &
                  site.latitude.isBiggerOrEqualValue(
                    origin.latitude - latitudeDelta,
                  ) &
                  site.latitude.isSmallerOrEqualValue(
                    origin.latitude + latitudeDelta,
                  ) &
                  site.longitude.isBiggerOrEqualValue(
                    origin.longitude - longitudeDelta,
                  ) &
                  site.longitude.isSmallerOrEqualValue(
                    origin.longitude + longitudeDelta,
                  ),
            ))
            .get();

    final nearby =
        candidates
            .map((stored) {
              final site = _toDomain(stored);
              return NearbyAtmSite(
                site: site,
                distanceMeters: _haversineDistance(origin, site.position!),
              );
            })
            .where((result) => result.distanceMeters <= radiusMeters)
            .toList()
          ..sort((left, right) {
            final distanceOrder = left.distanceMeters.compareTo(
              right.distanceMeters,
            );
            if (distanceOrder != 0) {
              return distanceOrder;
            }
            return left.site.id.compareTo(right.site.id);
          });

    return List.unmodifiable(nearby.take(limit));
  }

  @override
  Future<List<AtmSite>> searchOffline(String query, {int limit = 50}) async {
    final rawQuery = query.trim();
    final normalizedQuery = normalizeSearchText(rawQuery);
    if (normalizedQuery.isEmpty || limit <= 0) {
      return const [];
    }

    final rows =
        await (_database.select(_database.atmSites)
              ..where(
                (site) =>
                    site.active.equals(true) &
                    (site.institutionCode.contains(rawQuery) |
                        site.institutionName.contains(rawQuery) |
                        site.placeName.contains(rawQuery) |
                        site.county.contains(rawQuery) |
                        site.displayAddress.contains(rawQuery) |
                        site.normalizedAddress.contains(normalizedQuery) |
                        site.district.contains(normalizedQuery)),
              )
              ..orderBy([
                (site) => OrderingTerm.asc(site.institutionCode),
                (site) => OrderingTerm.asc(site.placeName),
                (site) => OrderingTerm.asc(site.id),
              ])
              ..limit(limit))
            .get();
    return List.unmodifiable(rows.map(_toDomain));
  }

  @override
  Future<AtmSite?> findById(String id, {bool includeRetired = false}) async {
    final query = _database.select(_database.atmSites)
      ..where(
        (site) =>
            site.id.equals(id) &
            (includeRetired ? const Constant(true) : site.active.equals(true)),
      )
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  static AtmSite _parseSite(Map<String, Object?> raw) {
    final id = raw['id'] as String;
    final institutionCode = raw['institutionCode'] as String;
    final institutionName = raw['institutionName'] as String;
    final placeName = raw['placeName'] as String;
    final displayAddress = raw['displayAddress'] as String;
    final latitude = (raw['latitude'] as num?)?.toDouble();
    final longitude = (raw['longitude'] as num?)?.toDouble();
    if (id.trim().isEmpty ||
        institutionCode.trim().isEmpty ||
        institutionName.trim().isEmpty ||
        placeName.trim().isEmpty ||
        displayAddress.trim().isEmpty ||
        (latitude == null) != (longitude == null) ||
        (latitude != null &&
            (latitude < -90 ||
                latitude > 90 ||
                longitude! < -180 ||
                longitude > 180))) {
      throw const FormatException('Invalid ATM site');
    }

    return AtmSite(
      id: id,
      institutionCode: institutionCode,
      institutionName: institutionName,
      placeName: placeName,
      placeCategory: _parsePlaceCategory(raw['placeCategory'] as String),
      county: (raw['county'] as String?) ?? '',
      displayAddress: displayAddress,
      normalizedAddress: normalizeSearchText(displayAddress),
      district: extractDistrict(
        displayAddress,
        county: (raw['county'] as String?) ?? '',
      ),
      position: latitude == null
          ? null
          : GeoPoint(latitude: latitude, longitude: longitude!),
      coordinateEvidence: _parseAttribution(raw['coordinateEvidence']),
      placeCategoryEvidence: _parseAttribution(raw['placeCategoryEvidence']),
      capabilities: _parseCapabilities(raw['capabilities']),
      locationType: _parseLocationType(raw['locationType'] as String?),
      locationTypeEvidence: _parseAttribution(raw['locationTypeEvidence']),
      accessSchedule: _parseAccessSchedule(raw['accessSchedule']),
      accessEvidence: _parseAttribution(raw['accessEvidence']),
    );
  }

  static AtmSite _toDomain(StoredAtmSite stored) {
    return AtmSite(
      id: stored.id,
      institutionCode: stored.institutionCode,
      institutionName: stored.institutionName,
      placeName: stored.placeName,
      placeCategory: _parsePlaceCategory(stored.placeCategory),
      county: stored.county,
      displayAddress: stored.displayAddress,
      normalizedAddress: stored.normalizedAddress,
      district: stored.district,
      position: stored.latitude == null || stored.longitude == null
          ? null
          : GeoPoint(latitude: stored.latitude!, longitude: stored.longitude!),
      coordinateEvidence: _storedAttribution(
        source: stored.coordinateEvidenceSource,
        date: stored.coordinateEvidenceDate,
        confidence: stored.coordinateEvidenceConfidence,
      ),
      placeCategoryEvidence: _storedAttribution(
        source: stored.placeCategoryEvidenceSource,
        date: stored.placeCategoryEvidenceDate,
        confidence: stored.placeCategoryEvidenceConfidence,
      ),
      capabilities: _parseCapabilities(jsonDecode(stored.capabilitiesJson)),
      locationType: _parseLocationType(stored.locationType),
      locationTypeEvidence: _storedAttribution(
        source: stored.locationTypeEvidenceSource,
        date: stored.locationTypeEvidenceDate,
        confidence: stored.locationTypeEvidenceConfidence,
      ),
      accessSchedule: stored.accessScheduleJson == null
          ? null
          : _parseAccessSchedule(jsonDecode(stored.accessScheduleJson!)),
      accessEvidence: _storedAttribution(
        source: stored.accessEvidenceSource,
        date: stored.accessEvidenceDate,
        confidence: stored.accessEvidenceConfidence,
      ),
      lastSeenDate: stored.lastSeenDate == null
          ? null
          : DateTime.parse('${stored.lastSeenDate}T00:00:00Z'),
    );
  }

  static List<CapabilityFact> _parseCapabilities(Object? raw) {
    if (raw == null) {
      return const [];
    }
    final document = raw as Map<String, Object?>;
    return List.unmodifiable(
      document.entries.map((entry) {
        final fact = entry.value! as Map<String, Object?>;
        final status = switch (fact['status'] as String) {
          'confirmed' => CapabilityStatus.confirmed,
          'unsupported' => CapabilityStatus.unsupported,
          'unknown' => CapabilityStatus.unknown,
          _ => throw const FormatException('Invalid capability status'),
        };
        final evidence = _parseAttribution(fact['evidence']);
        if (status == CapabilityStatus.confirmed && evidence == null) {
          throw const FormatException('Confirmed capability requires evidence');
        }
        return CapabilityFact(
          capability: switch (entry.key) {
            'deposit' => AtmCapability.deposit,
            'audioGuidance' => AtmCapability.audioGuidance,
            'visualAccessibility' => AtmCapability.visualAccessibility,
            'wheelchairAccessibility' => AtmCapability.wheelchairAccessibility,
            'foreignCurrencyWithdrawal' =>
              AtmCapability.foreignCurrencyWithdrawal,
            _ => throw const FormatException('Invalid ATM capability'),
          },
          status: status,
          evidence: evidence,
        );
      }),
    );
  }

  static EvidenceAttribution? _parseAttribution(Object? raw) {
    if (raw == null) {
      return null;
    }
    final document = raw as Map<String, Object?>;
    return _storedAttribution(
      source: document['source'] as String?,
      date: document['date'] as String?,
      confidence: document['confidence'] as String?,
    );
  }

  static EvidenceAttribution? _storedAttribution({
    required String? source,
    required String? date,
    required String? confidence,
  }) {
    if (source == null && date == null && confidence == null) {
      return null;
    }
    if (source == null || date == null || confidence == null) {
      throw const FormatException('Incomplete evidence attribution');
    }
    final parsedDate = DateTime.parse(date);
    return EvidenceAttribution(
      publisher: switch (source) {
        'fisc-national-atm' => EvidencePublisher.fisc,
        'fisc-visual-accessibility-atm' => EvidencePublisher.fisc,
        'fisc-wheelchair-accessibility-atm' => EvidencePublisher.fisc,
        'moda-cash-atm' => EvidencePublisher.ministryOfDigitalAffairs,
        'chunghwa-post-atm' => EvidencePublisher.chunghwaPost,
        'licensed-address-geocoder' => EvidencePublisher.licensedGeocoder,
        'manual-reviewed-override' => EvidencePublisher.manualReview,
        _ => EvidencePublisher.unknown,
      },
      sourceDate: DateTime.utc(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      ),
      confidence: switch (confidence) {
        'official_exact' => EvidenceConfidence.officialExact,
        'official_positive' => EvidenceConfidence.officialPositive,
        'licensed_exact' => EvidenceConfidence.licensedExact,
        'licensed_fuzzy' => EvidenceConfidence.licensedFuzzy,
        'manual_reviewed' => EvidenceConfidence.manualReviewed,
        _ => EvidenceConfidence.unknown,
      },
    );
  }

  static String? _publisherWireValue(EvidencePublisher? publisher) {
    return switch (publisher) {
      EvidencePublisher.fisc => 'fisc-national-atm',
      EvidencePublisher.ministryOfDigitalAffairs => 'moda-cash-atm',
      EvidencePublisher.chunghwaPost => 'chunghwa-post-atm',
      EvidencePublisher.licensedGeocoder => 'licensed-address-geocoder',
      EvidencePublisher.manualReview => 'manual-reviewed-override',
      EvidencePublisher.unknown => 'unknown',
      null => null,
    };
  }

  static String? _confidenceWireValue(EvidenceConfidence? confidence) {
    return switch (confidence) {
      EvidenceConfidence.officialExact => 'official_exact',
      EvidenceConfidence.officialPositive => 'official_positive',
      EvidenceConfidence.licensedExact => 'licensed_exact',
      EvidenceConfidence.licensedFuzzy => 'licensed_fuzzy',
      EvidenceConfidence.manualReviewed => 'manual_reviewed',
      EvidenceConfidence.unknown => 'unknown',
      null => null,
    };
  }

  static String? _dateWireValue(DateTime? value) {
    if (value == null) {
      return null;
    }
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }

  static PlaceCategory _parsePlaceCategory(String value) {
    return switch (value) {
      'bank' => PlaceCategory.bank,
      'convenience_store' => PlaceCategory.convenienceStore,
      'post_office' => PlaceCategory.postOffice,
      'other' => PlaceCategory.other,
      _ => PlaceCategory.unknown,
    };
  }

  static String _placeCategoryWireValue(PlaceCategory category) {
    return switch (category) {
      PlaceCategory.bank => 'bank',
      PlaceCategory.convenienceStore => 'convenience_store',
      PlaceCategory.postOffice => 'post_office',
      PlaceCategory.other => 'other',
      PlaceCategory.unknown => 'unknown',
    };
  }

  static Map<String, Object?> _capabilitiesWireDocument(
    List<CapabilityFact> capabilities,
  ) {
    return {
      for (final fact in capabilities)
        _capabilityWireValue(fact.capability): {
          'status': switch (fact.status) {
            CapabilityStatus.confirmed => 'confirmed',
            CapabilityStatus.unknown => 'unknown',
            CapabilityStatus.unsupported => 'unsupported',
          },
          'evidence': fact.evidence == null
              ? null
              : {
                  'source': _publisherWireValue(fact.evidence!.publisher),
                  'date': _dateWireValue(fact.evidence!.sourceDate),
                  'confidence': _confidenceWireValue(fact.evidence!.confidence),
                },
        },
    };
  }

  static AtmAccessSchedule? _parseAccessSchedule(Object? raw) {
    if (raw == null) {
      return null;
    }
    final document = raw as Map<String, Object?>;
    final confirmedTwentyFourHours =
        document['confirmedTwentyFourHours'] as bool? ?? false;
    final rawPeriods = document['periods'] as List<Object?>? ?? const [];
    final periods = <AccessPeriod>[];
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
      periods.add(
        AccessPeriod(
          weekday: weekday,
          startMinute: startMinute,
          endMinute: endMinute,
        ),
      );
    }
    return AtmAccessSchedule(
      confirmedTwentyFourHours: confirmedTwentyFourHours,
      periods: List.unmodifiable(periods),
    );
  }

  static Map<String, Object?> _accessScheduleWireDocument(
    AtmAccessSchedule schedule,
  ) {
    return {
      'confirmedTwentyFourHours': schedule.confirmedTwentyFourHours,
      'periods': [
        for (final period in schedule.periods)
          {
            'weekday': period.weekday,
            'startMinute': period.startMinute,
            'endMinute': period.endMinute,
          },
      ],
    };
  }

  static String _capabilityWireValue(AtmCapability capability) {
    return switch (capability) {
      AtmCapability.deposit => 'deposit',
      AtmCapability.audioGuidance => 'audioGuidance',
      AtmCapability.visualAccessibility => 'visualAccessibility',
      AtmCapability.wheelchairAccessibility => 'wheelchairAccessibility',
      AtmCapability.foreignCurrencyWithdrawal => 'foreignCurrencyWithdrawal',
    };
  }

  static AtmLocationType _parseLocationType(String? value) {
    return switch (value) {
      'on_site' => AtmLocationType.onSite,
      'off_site' => AtmLocationType.offSite,
      null || 'unknown' => AtmLocationType.unknown,
      _ => throw const FormatException('Invalid ATM location type'),
    };
  }

  static String _locationTypeWireValue(AtmLocationType value) {
    return switch (value) {
      AtmLocationType.onSite => 'on_site',
      AtmLocationType.offSite => 'off_site',
      AtmLocationType.unknown => 'unknown',
    };
  }

  static double _haversineDistance(GeoPoint from, GeoPoint to) {
    final latitudeDelta = _toRadians(to.latitude - from.latitude);
    final longitudeDelta = _toRadians(to.longitude - from.longitude);
    final fromLatitude = _toRadians(from.latitude);
    final toLatitude = _toRadians(to.latitude);
    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(fromLatitude) *
            math.cos(toLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return 2 * _earthRadiusMeters * math.asin(math.sqrt(haversine.clamp(0, 1)));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
