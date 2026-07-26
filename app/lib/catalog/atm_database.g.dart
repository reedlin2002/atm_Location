// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atm_database.dart';

// ignore_for_file: type=lint
class $AtmSitesTable extends AtmSites
    with TableInfo<$AtmSitesTable, StoredAtmSite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AtmSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionCodeMeta = const VerificationMeta(
    'institutionCode',
  );
  @override
  late final GeneratedColumn<String> institutionCode = GeneratedColumn<String>(
    'institution_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionNameMeta = const VerificationMeta(
    'institutionName',
  );
  @override
  late final GeneratedColumn<String> institutionName = GeneratedColumn<String>(
    'institution_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta(
    'placeName',
  );
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeCategoryMeta = const VerificationMeta(
    'placeCategory',
  );
  @override
  late final GeneratedColumn<String> placeCategory = GeneratedColumn<String>(
    'place_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countyMeta = const VerificationMeta('county');
  @override
  late final GeneratedColumn<String> county = GeneratedColumn<String>(
    'county',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _displayAddressMeta = const VerificationMeta(
    'displayAddress',
  );
  @override
  late final GeneratedColumn<String> displayAddress = GeneratedColumn<String>(
    'display_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedAddressMeta = const VerificationMeta(
    'normalizedAddress',
  );
  @override
  late final GeneratedColumn<String> normalizedAddress =
      GeneratedColumn<String>(
        'normalized_address',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coordinateEvidenceSourceMeta =
      const VerificationMeta('coordinateEvidenceSource');
  @override
  late final GeneratedColumn<String> coordinateEvidenceSource =
      GeneratedColumn<String>(
        'coordinate_evidence_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _coordinateEvidenceDateMeta =
      const VerificationMeta('coordinateEvidenceDate');
  @override
  late final GeneratedColumn<String> coordinateEvidenceDate =
      GeneratedColumn<String>(
        'coordinate_evidence_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _coordinateEvidenceConfidenceMeta =
      const VerificationMeta('coordinateEvidenceConfidence');
  @override
  late final GeneratedColumn<String> coordinateEvidenceConfidence =
      GeneratedColumn<String>(
        'coordinate_evidence_confidence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _placeCategoryEvidenceSourceMeta =
      const VerificationMeta('placeCategoryEvidenceSource');
  @override
  late final GeneratedColumn<String> placeCategoryEvidenceSource =
      GeneratedColumn<String>(
        'place_category_evidence_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _placeCategoryEvidenceDateMeta =
      const VerificationMeta('placeCategoryEvidenceDate');
  @override
  late final GeneratedColumn<String> placeCategoryEvidenceDate =
      GeneratedColumn<String>(
        'place_category_evidence_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _placeCategoryEvidenceConfidenceMeta =
      const VerificationMeta('placeCategoryEvidenceConfidence');
  @override
  late final GeneratedColumn<String> placeCategoryEvidenceConfidence =
      GeneratedColumn<String>(
        'place_category_evidence_confidence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _capabilitiesJsonMeta = const VerificationMeta(
    'capabilitiesJson',
  );
  @override
  late final GeneratedColumn<String> capabilitiesJson = GeneratedColumn<String>(
    'capabilities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _locationTypeMeta = const VerificationMeta(
    'locationType',
  );
  @override
  late final GeneratedColumn<String> locationType = GeneratedColumn<String>(
    'location_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _locationTypeEvidenceSourceMeta =
      const VerificationMeta('locationTypeEvidenceSource');
  @override
  late final GeneratedColumn<String> locationTypeEvidenceSource =
      GeneratedColumn<String>(
        'location_type_evidence_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _locationTypeEvidenceDateMeta =
      const VerificationMeta('locationTypeEvidenceDate');
  @override
  late final GeneratedColumn<String> locationTypeEvidenceDate =
      GeneratedColumn<String>(
        'location_type_evidence_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _locationTypeEvidenceConfidenceMeta =
      const VerificationMeta('locationTypeEvidenceConfidence');
  @override
  late final GeneratedColumn<String> locationTypeEvidenceConfidence =
      GeneratedColumn<String>(
        'location_type_evidence_confidence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accessScheduleJsonMeta =
      const VerificationMeta('accessScheduleJson');
  @override
  late final GeneratedColumn<String> accessScheduleJson =
      GeneratedColumn<String>(
        'access_schedule_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accessEvidenceSourceMeta =
      const VerificationMeta('accessEvidenceSource');
  @override
  late final GeneratedColumn<String> accessEvidenceSource =
      GeneratedColumn<String>(
        'access_evidence_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accessEvidenceDateMeta =
      const VerificationMeta('accessEvidenceDate');
  @override
  late final GeneratedColumn<String> accessEvidenceDate =
      GeneratedColumn<String>(
        'access_evidence_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accessEvidenceConfidenceMeta =
      const VerificationMeta('accessEvidenceConfidence');
  @override
  late final GeneratedColumn<String> accessEvidenceConfidence =
      GeneratedColumn<String>(
        'access_evidence_confidence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSeenDateMeta = const VerificationMeta(
    'lastSeenDate',
  );
  @override
  late final GeneratedColumn<String> lastSeenDate = GeneratedColumn<String>(
    'last_seen_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    institutionCode,
    institutionName,
    placeName,
    placeCategory,
    county,
    displayAddress,
    normalizedAddress,
    district,
    latitude,
    longitude,
    coordinateEvidenceSource,
    coordinateEvidenceDate,
    coordinateEvidenceConfidence,
    placeCategoryEvidenceSource,
    placeCategoryEvidenceDate,
    placeCategoryEvidenceConfidence,
    capabilitiesJson,
    locationType,
    locationTypeEvidenceSource,
    locationTypeEvidenceDate,
    locationTypeEvidenceConfidence,
    accessScheduleJson,
    accessEvidenceSource,
    accessEvidenceDate,
    accessEvidenceConfidence,
    lastSeenDate,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'atm_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredAtmSite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('institution_code')) {
      context.handle(
        _institutionCodeMeta,
        institutionCode.isAcceptableOrUnknown(
          data['institution_code']!,
          _institutionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionCodeMeta);
    }
    if (data.containsKey('institution_name')) {
      context.handle(
        _institutionNameMeta,
        institutionName.isAcceptableOrUnknown(
          data['institution_name']!,
          _institutionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionNameMeta);
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_placeNameMeta);
    }
    if (data.containsKey('place_category')) {
      context.handle(
        _placeCategoryMeta,
        placeCategory.isAcceptableOrUnknown(
          data['place_category']!,
          _placeCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeCategoryMeta);
    }
    if (data.containsKey('county')) {
      context.handle(
        _countyMeta,
        county.isAcceptableOrUnknown(data['county']!, _countyMeta),
      );
    }
    if (data.containsKey('display_address')) {
      context.handle(
        _displayAddressMeta,
        displayAddress.isAcceptableOrUnknown(
          data['display_address']!,
          _displayAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayAddressMeta);
    }
    if (data.containsKey('normalized_address')) {
      context.handle(
        _normalizedAddressMeta,
        normalizedAddress.isAcceptableOrUnknown(
          data['normalized_address']!,
          _normalizedAddressMeta,
        ),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('coordinate_evidence_source')) {
      context.handle(
        _coordinateEvidenceSourceMeta,
        coordinateEvidenceSource.isAcceptableOrUnknown(
          data['coordinate_evidence_source']!,
          _coordinateEvidenceSourceMeta,
        ),
      );
    }
    if (data.containsKey('coordinate_evidence_date')) {
      context.handle(
        _coordinateEvidenceDateMeta,
        coordinateEvidenceDate.isAcceptableOrUnknown(
          data['coordinate_evidence_date']!,
          _coordinateEvidenceDateMeta,
        ),
      );
    }
    if (data.containsKey('coordinate_evidence_confidence')) {
      context.handle(
        _coordinateEvidenceConfidenceMeta,
        coordinateEvidenceConfidence.isAcceptableOrUnknown(
          data['coordinate_evidence_confidence']!,
          _coordinateEvidenceConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('place_category_evidence_source')) {
      context.handle(
        _placeCategoryEvidenceSourceMeta,
        placeCategoryEvidenceSource.isAcceptableOrUnknown(
          data['place_category_evidence_source']!,
          _placeCategoryEvidenceSourceMeta,
        ),
      );
    }
    if (data.containsKey('place_category_evidence_date')) {
      context.handle(
        _placeCategoryEvidenceDateMeta,
        placeCategoryEvidenceDate.isAcceptableOrUnknown(
          data['place_category_evidence_date']!,
          _placeCategoryEvidenceDateMeta,
        ),
      );
    }
    if (data.containsKey('place_category_evidence_confidence')) {
      context.handle(
        _placeCategoryEvidenceConfidenceMeta,
        placeCategoryEvidenceConfidence.isAcceptableOrUnknown(
          data['place_category_evidence_confidence']!,
          _placeCategoryEvidenceConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('capabilities_json')) {
      context.handle(
        _capabilitiesJsonMeta,
        capabilitiesJson.isAcceptableOrUnknown(
          data['capabilities_json']!,
          _capabilitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('location_type')) {
      context.handle(
        _locationTypeMeta,
        locationType.isAcceptableOrUnknown(
          data['location_type']!,
          _locationTypeMeta,
        ),
      );
    }
    if (data.containsKey('location_type_evidence_source')) {
      context.handle(
        _locationTypeEvidenceSourceMeta,
        locationTypeEvidenceSource.isAcceptableOrUnknown(
          data['location_type_evidence_source']!,
          _locationTypeEvidenceSourceMeta,
        ),
      );
    }
    if (data.containsKey('location_type_evidence_date')) {
      context.handle(
        _locationTypeEvidenceDateMeta,
        locationTypeEvidenceDate.isAcceptableOrUnknown(
          data['location_type_evidence_date']!,
          _locationTypeEvidenceDateMeta,
        ),
      );
    }
    if (data.containsKey('location_type_evidence_confidence')) {
      context.handle(
        _locationTypeEvidenceConfidenceMeta,
        locationTypeEvidenceConfidence.isAcceptableOrUnknown(
          data['location_type_evidence_confidence']!,
          _locationTypeEvidenceConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('access_schedule_json')) {
      context.handle(
        _accessScheduleJsonMeta,
        accessScheduleJson.isAcceptableOrUnknown(
          data['access_schedule_json']!,
          _accessScheduleJsonMeta,
        ),
      );
    }
    if (data.containsKey('access_evidence_source')) {
      context.handle(
        _accessEvidenceSourceMeta,
        accessEvidenceSource.isAcceptableOrUnknown(
          data['access_evidence_source']!,
          _accessEvidenceSourceMeta,
        ),
      );
    }
    if (data.containsKey('access_evidence_date')) {
      context.handle(
        _accessEvidenceDateMeta,
        accessEvidenceDate.isAcceptableOrUnknown(
          data['access_evidence_date']!,
          _accessEvidenceDateMeta,
        ),
      );
    }
    if (data.containsKey('access_evidence_confidence')) {
      context.handle(
        _accessEvidenceConfidenceMeta,
        accessEvidenceConfidence.isAcceptableOrUnknown(
          data['access_evidence_confidence']!,
          _accessEvidenceConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_date')) {
      context.handle(
        _lastSeenDateMeta,
        lastSeenDate.isAcceptableOrUnknown(
          data['last_seen_date']!,
          _lastSeenDateMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredAtmSite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredAtmSite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      institutionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_code'],
      )!,
      institutionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_name'],
      )!,
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      )!,
      placeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_category'],
      )!,
      county: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}county'],
      )!,
      displayAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_address'],
      )!,
      normalizedAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_address'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      coordinateEvidenceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coordinate_evidence_source'],
      ),
      coordinateEvidenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coordinate_evidence_date'],
      ),
      coordinateEvidenceConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coordinate_evidence_confidence'],
      ),
      placeCategoryEvidenceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_category_evidence_source'],
      ),
      placeCategoryEvidenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_category_evidence_date'],
      ),
      placeCategoryEvidenceConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_category_evidence_confidence'],
      ),
      capabilitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capabilities_json'],
      )!,
      locationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_type'],
      )!,
      locationTypeEvidenceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_type_evidence_source'],
      ),
      locationTypeEvidenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_type_evidence_date'],
      ),
      locationTypeEvidenceConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_type_evidence_confidence'],
      ),
      accessScheduleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_schedule_json'],
      ),
      accessEvidenceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_evidence_source'],
      ),
      accessEvidenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_evidence_date'],
      ),
      accessEvidenceConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_evidence_confidence'],
      ),
      lastSeenDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $AtmSitesTable createAlias(String alias) {
    return $AtmSitesTable(attachedDatabase, alias);
  }
}

class StoredAtmSite extends DataClass implements Insertable<StoredAtmSite> {
  final String id;
  final String institutionCode;
  final String institutionName;
  final String placeName;
  final String placeCategory;
  final String county;
  final String displayAddress;
  final String normalizedAddress;
  final String district;
  final double? latitude;
  final double? longitude;
  final String? coordinateEvidenceSource;
  final String? coordinateEvidenceDate;
  final String? coordinateEvidenceConfidence;
  final String? placeCategoryEvidenceSource;
  final String? placeCategoryEvidenceDate;
  final String? placeCategoryEvidenceConfidence;
  final String capabilitiesJson;
  final String locationType;
  final String? locationTypeEvidenceSource;
  final String? locationTypeEvidenceDate;
  final String? locationTypeEvidenceConfidence;
  final String? accessScheduleJson;
  final String? accessEvidenceSource;
  final String? accessEvidenceDate;
  final String? accessEvidenceConfidence;
  final String? lastSeenDate;
  final bool active;
  const StoredAtmSite({
    required this.id,
    required this.institutionCode,
    required this.institutionName,
    required this.placeName,
    required this.placeCategory,
    required this.county,
    required this.displayAddress,
    required this.normalizedAddress,
    required this.district,
    this.latitude,
    this.longitude,
    this.coordinateEvidenceSource,
    this.coordinateEvidenceDate,
    this.coordinateEvidenceConfidence,
    this.placeCategoryEvidenceSource,
    this.placeCategoryEvidenceDate,
    this.placeCategoryEvidenceConfidence,
    required this.capabilitiesJson,
    required this.locationType,
    this.locationTypeEvidenceSource,
    this.locationTypeEvidenceDate,
    this.locationTypeEvidenceConfidence,
    this.accessScheduleJson,
    this.accessEvidenceSource,
    this.accessEvidenceDate,
    this.accessEvidenceConfidence,
    this.lastSeenDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['institution_code'] = Variable<String>(institutionCode);
    map['institution_name'] = Variable<String>(institutionName);
    map['place_name'] = Variable<String>(placeName);
    map['place_category'] = Variable<String>(placeCategory);
    map['county'] = Variable<String>(county);
    map['display_address'] = Variable<String>(displayAddress);
    map['normalized_address'] = Variable<String>(normalizedAddress);
    map['district'] = Variable<String>(district);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || coordinateEvidenceSource != null) {
      map['coordinate_evidence_source'] = Variable<String>(
        coordinateEvidenceSource,
      );
    }
    if (!nullToAbsent || coordinateEvidenceDate != null) {
      map['coordinate_evidence_date'] = Variable<String>(
        coordinateEvidenceDate,
      );
    }
    if (!nullToAbsent || coordinateEvidenceConfidence != null) {
      map['coordinate_evidence_confidence'] = Variable<String>(
        coordinateEvidenceConfidence,
      );
    }
    if (!nullToAbsent || placeCategoryEvidenceSource != null) {
      map['place_category_evidence_source'] = Variable<String>(
        placeCategoryEvidenceSource,
      );
    }
    if (!nullToAbsent || placeCategoryEvidenceDate != null) {
      map['place_category_evidence_date'] = Variable<String>(
        placeCategoryEvidenceDate,
      );
    }
    if (!nullToAbsent || placeCategoryEvidenceConfidence != null) {
      map['place_category_evidence_confidence'] = Variable<String>(
        placeCategoryEvidenceConfidence,
      );
    }
    map['capabilities_json'] = Variable<String>(capabilitiesJson);
    map['location_type'] = Variable<String>(locationType);
    if (!nullToAbsent || locationTypeEvidenceSource != null) {
      map['location_type_evidence_source'] = Variable<String>(
        locationTypeEvidenceSource,
      );
    }
    if (!nullToAbsent || locationTypeEvidenceDate != null) {
      map['location_type_evidence_date'] = Variable<String>(
        locationTypeEvidenceDate,
      );
    }
    if (!nullToAbsent || locationTypeEvidenceConfidence != null) {
      map['location_type_evidence_confidence'] = Variable<String>(
        locationTypeEvidenceConfidence,
      );
    }
    if (!nullToAbsent || accessScheduleJson != null) {
      map['access_schedule_json'] = Variable<String>(accessScheduleJson);
    }
    if (!nullToAbsent || accessEvidenceSource != null) {
      map['access_evidence_source'] = Variable<String>(accessEvidenceSource);
    }
    if (!nullToAbsent || accessEvidenceDate != null) {
      map['access_evidence_date'] = Variable<String>(accessEvidenceDate);
    }
    if (!nullToAbsent || accessEvidenceConfidence != null) {
      map['access_evidence_confidence'] = Variable<String>(
        accessEvidenceConfidence,
      );
    }
    if (!nullToAbsent || lastSeenDate != null) {
      map['last_seen_date'] = Variable<String>(lastSeenDate);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  AtmSitesCompanion toCompanion(bool nullToAbsent) {
    return AtmSitesCompanion(
      id: Value(id),
      institutionCode: Value(institutionCode),
      institutionName: Value(institutionName),
      placeName: Value(placeName),
      placeCategory: Value(placeCategory),
      county: Value(county),
      displayAddress: Value(displayAddress),
      normalizedAddress: Value(normalizedAddress),
      district: Value(district),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      coordinateEvidenceSource: coordinateEvidenceSource == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinateEvidenceSource),
      coordinateEvidenceDate: coordinateEvidenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinateEvidenceDate),
      coordinateEvidenceConfidence:
          coordinateEvidenceConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinateEvidenceConfidence),
      placeCategoryEvidenceSource:
          placeCategoryEvidenceSource == null && nullToAbsent
          ? const Value.absent()
          : Value(placeCategoryEvidenceSource),
      placeCategoryEvidenceDate:
          placeCategoryEvidenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(placeCategoryEvidenceDate),
      placeCategoryEvidenceConfidence:
          placeCategoryEvidenceConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(placeCategoryEvidenceConfidence),
      capabilitiesJson: Value(capabilitiesJson),
      locationType: Value(locationType),
      locationTypeEvidenceSource:
          locationTypeEvidenceSource == null && nullToAbsent
          ? const Value.absent()
          : Value(locationTypeEvidenceSource),
      locationTypeEvidenceDate: locationTypeEvidenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(locationTypeEvidenceDate),
      locationTypeEvidenceConfidence:
          locationTypeEvidenceConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(locationTypeEvidenceConfidence),
      accessScheduleJson: accessScheduleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(accessScheduleJson),
      accessEvidenceSource: accessEvidenceSource == null && nullToAbsent
          ? const Value.absent()
          : Value(accessEvidenceSource),
      accessEvidenceDate: accessEvidenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(accessEvidenceDate),
      accessEvidenceConfidence: accessEvidenceConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(accessEvidenceConfidence),
      lastSeenDate: lastSeenDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenDate),
      active: Value(active),
    );
  }

  factory StoredAtmSite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredAtmSite(
      id: serializer.fromJson<String>(json['id']),
      institutionCode: serializer.fromJson<String>(json['institutionCode']),
      institutionName: serializer.fromJson<String>(json['institutionName']),
      placeName: serializer.fromJson<String>(json['placeName']),
      placeCategory: serializer.fromJson<String>(json['placeCategory']),
      county: serializer.fromJson<String>(json['county']),
      displayAddress: serializer.fromJson<String>(json['displayAddress']),
      normalizedAddress: serializer.fromJson<String>(json['normalizedAddress']),
      district: serializer.fromJson<String>(json['district']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      coordinateEvidenceSource: serializer.fromJson<String?>(
        json['coordinateEvidenceSource'],
      ),
      coordinateEvidenceDate: serializer.fromJson<String?>(
        json['coordinateEvidenceDate'],
      ),
      coordinateEvidenceConfidence: serializer.fromJson<String?>(
        json['coordinateEvidenceConfidence'],
      ),
      placeCategoryEvidenceSource: serializer.fromJson<String?>(
        json['placeCategoryEvidenceSource'],
      ),
      placeCategoryEvidenceDate: serializer.fromJson<String?>(
        json['placeCategoryEvidenceDate'],
      ),
      placeCategoryEvidenceConfidence: serializer.fromJson<String?>(
        json['placeCategoryEvidenceConfidence'],
      ),
      capabilitiesJson: serializer.fromJson<String>(json['capabilitiesJson']),
      locationType: serializer.fromJson<String>(json['locationType']),
      locationTypeEvidenceSource: serializer.fromJson<String?>(
        json['locationTypeEvidenceSource'],
      ),
      locationTypeEvidenceDate: serializer.fromJson<String?>(
        json['locationTypeEvidenceDate'],
      ),
      locationTypeEvidenceConfidence: serializer.fromJson<String?>(
        json['locationTypeEvidenceConfidence'],
      ),
      accessScheduleJson: serializer.fromJson<String?>(
        json['accessScheduleJson'],
      ),
      accessEvidenceSource: serializer.fromJson<String?>(
        json['accessEvidenceSource'],
      ),
      accessEvidenceDate: serializer.fromJson<String?>(
        json['accessEvidenceDate'],
      ),
      accessEvidenceConfidence: serializer.fromJson<String?>(
        json['accessEvidenceConfidence'],
      ),
      lastSeenDate: serializer.fromJson<String?>(json['lastSeenDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'institutionCode': serializer.toJson<String>(institutionCode),
      'institutionName': serializer.toJson<String>(institutionName),
      'placeName': serializer.toJson<String>(placeName),
      'placeCategory': serializer.toJson<String>(placeCategory),
      'county': serializer.toJson<String>(county),
      'displayAddress': serializer.toJson<String>(displayAddress),
      'normalizedAddress': serializer.toJson<String>(normalizedAddress),
      'district': serializer.toJson<String>(district),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'coordinateEvidenceSource': serializer.toJson<String?>(
        coordinateEvidenceSource,
      ),
      'coordinateEvidenceDate': serializer.toJson<String?>(
        coordinateEvidenceDate,
      ),
      'coordinateEvidenceConfidence': serializer.toJson<String?>(
        coordinateEvidenceConfidence,
      ),
      'placeCategoryEvidenceSource': serializer.toJson<String?>(
        placeCategoryEvidenceSource,
      ),
      'placeCategoryEvidenceDate': serializer.toJson<String?>(
        placeCategoryEvidenceDate,
      ),
      'placeCategoryEvidenceConfidence': serializer.toJson<String?>(
        placeCategoryEvidenceConfidence,
      ),
      'capabilitiesJson': serializer.toJson<String>(capabilitiesJson),
      'locationType': serializer.toJson<String>(locationType),
      'locationTypeEvidenceSource': serializer.toJson<String?>(
        locationTypeEvidenceSource,
      ),
      'locationTypeEvidenceDate': serializer.toJson<String?>(
        locationTypeEvidenceDate,
      ),
      'locationTypeEvidenceConfidence': serializer.toJson<String?>(
        locationTypeEvidenceConfidence,
      ),
      'accessScheduleJson': serializer.toJson<String?>(accessScheduleJson),
      'accessEvidenceSource': serializer.toJson<String?>(accessEvidenceSource),
      'accessEvidenceDate': serializer.toJson<String?>(accessEvidenceDate),
      'accessEvidenceConfidence': serializer.toJson<String?>(
        accessEvidenceConfidence,
      ),
      'lastSeenDate': serializer.toJson<String?>(lastSeenDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  StoredAtmSite copyWith({
    String? id,
    String? institutionCode,
    String? institutionName,
    String? placeName,
    String? placeCategory,
    String? county,
    String? displayAddress,
    String? normalizedAddress,
    String? district,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> coordinateEvidenceSource = const Value.absent(),
    Value<String?> coordinateEvidenceDate = const Value.absent(),
    Value<String?> coordinateEvidenceConfidence = const Value.absent(),
    Value<String?> placeCategoryEvidenceSource = const Value.absent(),
    Value<String?> placeCategoryEvidenceDate = const Value.absent(),
    Value<String?> placeCategoryEvidenceConfidence = const Value.absent(),
    String? capabilitiesJson,
    String? locationType,
    Value<String?> locationTypeEvidenceSource = const Value.absent(),
    Value<String?> locationTypeEvidenceDate = const Value.absent(),
    Value<String?> locationTypeEvidenceConfidence = const Value.absent(),
    Value<String?> accessScheduleJson = const Value.absent(),
    Value<String?> accessEvidenceSource = const Value.absent(),
    Value<String?> accessEvidenceDate = const Value.absent(),
    Value<String?> accessEvidenceConfidence = const Value.absent(),
    Value<String?> lastSeenDate = const Value.absent(),
    bool? active,
  }) => StoredAtmSite(
    id: id ?? this.id,
    institutionCode: institutionCode ?? this.institutionCode,
    institutionName: institutionName ?? this.institutionName,
    placeName: placeName ?? this.placeName,
    placeCategory: placeCategory ?? this.placeCategory,
    county: county ?? this.county,
    displayAddress: displayAddress ?? this.displayAddress,
    normalizedAddress: normalizedAddress ?? this.normalizedAddress,
    district: district ?? this.district,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    coordinateEvidenceSource: coordinateEvidenceSource.present
        ? coordinateEvidenceSource.value
        : this.coordinateEvidenceSource,
    coordinateEvidenceDate: coordinateEvidenceDate.present
        ? coordinateEvidenceDate.value
        : this.coordinateEvidenceDate,
    coordinateEvidenceConfidence: coordinateEvidenceConfidence.present
        ? coordinateEvidenceConfidence.value
        : this.coordinateEvidenceConfidence,
    placeCategoryEvidenceSource: placeCategoryEvidenceSource.present
        ? placeCategoryEvidenceSource.value
        : this.placeCategoryEvidenceSource,
    placeCategoryEvidenceDate: placeCategoryEvidenceDate.present
        ? placeCategoryEvidenceDate.value
        : this.placeCategoryEvidenceDate,
    placeCategoryEvidenceConfidence: placeCategoryEvidenceConfidence.present
        ? placeCategoryEvidenceConfidence.value
        : this.placeCategoryEvidenceConfidence,
    capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
    locationType: locationType ?? this.locationType,
    locationTypeEvidenceSource: locationTypeEvidenceSource.present
        ? locationTypeEvidenceSource.value
        : this.locationTypeEvidenceSource,
    locationTypeEvidenceDate: locationTypeEvidenceDate.present
        ? locationTypeEvidenceDate.value
        : this.locationTypeEvidenceDate,
    locationTypeEvidenceConfidence: locationTypeEvidenceConfidence.present
        ? locationTypeEvidenceConfidence.value
        : this.locationTypeEvidenceConfidence,
    accessScheduleJson: accessScheduleJson.present
        ? accessScheduleJson.value
        : this.accessScheduleJson,
    accessEvidenceSource: accessEvidenceSource.present
        ? accessEvidenceSource.value
        : this.accessEvidenceSource,
    accessEvidenceDate: accessEvidenceDate.present
        ? accessEvidenceDate.value
        : this.accessEvidenceDate,
    accessEvidenceConfidence: accessEvidenceConfidence.present
        ? accessEvidenceConfidence.value
        : this.accessEvidenceConfidence,
    lastSeenDate: lastSeenDate.present ? lastSeenDate.value : this.lastSeenDate,
    active: active ?? this.active,
  );
  StoredAtmSite copyWithCompanion(AtmSitesCompanion data) {
    return StoredAtmSite(
      id: data.id.present ? data.id.value : this.id,
      institutionCode: data.institutionCode.present
          ? data.institutionCode.value
          : this.institutionCode,
      institutionName: data.institutionName.present
          ? data.institutionName.value
          : this.institutionName,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      placeCategory: data.placeCategory.present
          ? data.placeCategory.value
          : this.placeCategory,
      county: data.county.present ? data.county.value : this.county,
      displayAddress: data.displayAddress.present
          ? data.displayAddress.value
          : this.displayAddress,
      normalizedAddress: data.normalizedAddress.present
          ? data.normalizedAddress.value
          : this.normalizedAddress,
      district: data.district.present ? data.district.value : this.district,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      coordinateEvidenceSource: data.coordinateEvidenceSource.present
          ? data.coordinateEvidenceSource.value
          : this.coordinateEvidenceSource,
      coordinateEvidenceDate: data.coordinateEvidenceDate.present
          ? data.coordinateEvidenceDate.value
          : this.coordinateEvidenceDate,
      coordinateEvidenceConfidence: data.coordinateEvidenceConfidence.present
          ? data.coordinateEvidenceConfidence.value
          : this.coordinateEvidenceConfidence,
      placeCategoryEvidenceSource: data.placeCategoryEvidenceSource.present
          ? data.placeCategoryEvidenceSource.value
          : this.placeCategoryEvidenceSource,
      placeCategoryEvidenceDate: data.placeCategoryEvidenceDate.present
          ? data.placeCategoryEvidenceDate.value
          : this.placeCategoryEvidenceDate,
      placeCategoryEvidenceConfidence:
          data.placeCategoryEvidenceConfidence.present
          ? data.placeCategoryEvidenceConfidence.value
          : this.placeCategoryEvidenceConfidence,
      capabilitiesJson: data.capabilitiesJson.present
          ? data.capabilitiesJson.value
          : this.capabilitiesJson,
      locationType: data.locationType.present
          ? data.locationType.value
          : this.locationType,
      locationTypeEvidenceSource: data.locationTypeEvidenceSource.present
          ? data.locationTypeEvidenceSource.value
          : this.locationTypeEvidenceSource,
      locationTypeEvidenceDate: data.locationTypeEvidenceDate.present
          ? data.locationTypeEvidenceDate.value
          : this.locationTypeEvidenceDate,
      locationTypeEvidenceConfidence:
          data.locationTypeEvidenceConfidence.present
          ? data.locationTypeEvidenceConfidence.value
          : this.locationTypeEvidenceConfidence,
      accessScheduleJson: data.accessScheduleJson.present
          ? data.accessScheduleJson.value
          : this.accessScheduleJson,
      accessEvidenceSource: data.accessEvidenceSource.present
          ? data.accessEvidenceSource.value
          : this.accessEvidenceSource,
      accessEvidenceDate: data.accessEvidenceDate.present
          ? data.accessEvidenceDate.value
          : this.accessEvidenceDate,
      accessEvidenceConfidence: data.accessEvidenceConfidence.present
          ? data.accessEvidenceConfidence.value
          : this.accessEvidenceConfidence,
      lastSeenDate: data.lastSeenDate.present
          ? data.lastSeenDate.value
          : this.lastSeenDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredAtmSite(')
          ..write('id: $id, ')
          ..write('institutionCode: $institutionCode, ')
          ..write('institutionName: $institutionName, ')
          ..write('placeName: $placeName, ')
          ..write('placeCategory: $placeCategory, ')
          ..write('county: $county, ')
          ..write('displayAddress: $displayAddress, ')
          ..write('normalizedAddress: $normalizedAddress, ')
          ..write('district: $district, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('coordinateEvidenceSource: $coordinateEvidenceSource, ')
          ..write('coordinateEvidenceDate: $coordinateEvidenceDate, ')
          ..write(
            'coordinateEvidenceConfidence: $coordinateEvidenceConfidence, ',
          )
          ..write('placeCategoryEvidenceSource: $placeCategoryEvidenceSource, ')
          ..write('placeCategoryEvidenceDate: $placeCategoryEvidenceDate, ')
          ..write(
            'placeCategoryEvidenceConfidence: $placeCategoryEvidenceConfidence, ',
          )
          ..write('capabilitiesJson: $capabilitiesJson, ')
          ..write('locationType: $locationType, ')
          ..write('locationTypeEvidenceSource: $locationTypeEvidenceSource, ')
          ..write('locationTypeEvidenceDate: $locationTypeEvidenceDate, ')
          ..write(
            'locationTypeEvidenceConfidence: $locationTypeEvidenceConfidence, ',
          )
          ..write('accessScheduleJson: $accessScheduleJson, ')
          ..write('accessEvidenceSource: $accessEvidenceSource, ')
          ..write('accessEvidenceDate: $accessEvidenceDate, ')
          ..write('accessEvidenceConfidence: $accessEvidenceConfidence, ')
          ..write('lastSeenDate: $lastSeenDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    institutionCode,
    institutionName,
    placeName,
    placeCategory,
    county,
    displayAddress,
    normalizedAddress,
    district,
    latitude,
    longitude,
    coordinateEvidenceSource,
    coordinateEvidenceDate,
    coordinateEvidenceConfidence,
    placeCategoryEvidenceSource,
    placeCategoryEvidenceDate,
    placeCategoryEvidenceConfidence,
    capabilitiesJson,
    locationType,
    locationTypeEvidenceSource,
    locationTypeEvidenceDate,
    locationTypeEvidenceConfidence,
    accessScheduleJson,
    accessEvidenceSource,
    accessEvidenceDate,
    accessEvidenceConfidence,
    lastSeenDate,
    active,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredAtmSite &&
          other.id == this.id &&
          other.institutionCode == this.institutionCode &&
          other.institutionName == this.institutionName &&
          other.placeName == this.placeName &&
          other.placeCategory == this.placeCategory &&
          other.county == this.county &&
          other.displayAddress == this.displayAddress &&
          other.normalizedAddress == this.normalizedAddress &&
          other.district == this.district &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.coordinateEvidenceSource == this.coordinateEvidenceSource &&
          other.coordinateEvidenceDate == this.coordinateEvidenceDate &&
          other.coordinateEvidenceConfidence ==
              this.coordinateEvidenceConfidence &&
          other.placeCategoryEvidenceSource ==
              this.placeCategoryEvidenceSource &&
          other.placeCategoryEvidenceDate == this.placeCategoryEvidenceDate &&
          other.placeCategoryEvidenceConfidence ==
              this.placeCategoryEvidenceConfidence &&
          other.capabilitiesJson == this.capabilitiesJson &&
          other.locationType == this.locationType &&
          other.locationTypeEvidenceSource == this.locationTypeEvidenceSource &&
          other.locationTypeEvidenceDate == this.locationTypeEvidenceDate &&
          other.locationTypeEvidenceConfidence ==
              this.locationTypeEvidenceConfidence &&
          other.accessScheduleJson == this.accessScheduleJson &&
          other.accessEvidenceSource == this.accessEvidenceSource &&
          other.accessEvidenceDate == this.accessEvidenceDate &&
          other.accessEvidenceConfidence == this.accessEvidenceConfidence &&
          other.lastSeenDate == this.lastSeenDate &&
          other.active == this.active);
}

class AtmSitesCompanion extends UpdateCompanion<StoredAtmSite> {
  final Value<String> id;
  final Value<String> institutionCode;
  final Value<String> institutionName;
  final Value<String> placeName;
  final Value<String> placeCategory;
  final Value<String> county;
  final Value<String> displayAddress;
  final Value<String> normalizedAddress;
  final Value<String> district;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> coordinateEvidenceSource;
  final Value<String?> coordinateEvidenceDate;
  final Value<String?> coordinateEvidenceConfidence;
  final Value<String?> placeCategoryEvidenceSource;
  final Value<String?> placeCategoryEvidenceDate;
  final Value<String?> placeCategoryEvidenceConfidence;
  final Value<String> capabilitiesJson;
  final Value<String> locationType;
  final Value<String?> locationTypeEvidenceSource;
  final Value<String?> locationTypeEvidenceDate;
  final Value<String?> locationTypeEvidenceConfidence;
  final Value<String?> accessScheduleJson;
  final Value<String?> accessEvidenceSource;
  final Value<String?> accessEvidenceDate;
  final Value<String?> accessEvidenceConfidence;
  final Value<String?> lastSeenDate;
  final Value<bool> active;
  final Value<int> rowid;
  const AtmSitesCompanion({
    this.id = const Value.absent(),
    this.institutionCode = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.placeName = const Value.absent(),
    this.placeCategory = const Value.absent(),
    this.county = const Value.absent(),
    this.displayAddress = const Value.absent(),
    this.normalizedAddress = const Value.absent(),
    this.district = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.coordinateEvidenceSource = const Value.absent(),
    this.coordinateEvidenceDate = const Value.absent(),
    this.coordinateEvidenceConfidence = const Value.absent(),
    this.placeCategoryEvidenceSource = const Value.absent(),
    this.placeCategoryEvidenceDate = const Value.absent(),
    this.placeCategoryEvidenceConfidence = const Value.absent(),
    this.capabilitiesJson = const Value.absent(),
    this.locationType = const Value.absent(),
    this.locationTypeEvidenceSource = const Value.absent(),
    this.locationTypeEvidenceDate = const Value.absent(),
    this.locationTypeEvidenceConfidence = const Value.absent(),
    this.accessScheduleJson = const Value.absent(),
    this.accessEvidenceSource = const Value.absent(),
    this.accessEvidenceDate = const Value.absent(),
    this.accessEvidenceConfidence = const Value.absent(),
    this.lastSeenDate = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AtmSitesCompanion.insert({
    required String id,
    required String institutionCode,
    required String institutionName,
    required String placeName,
    required String placeCategory,
    this.county = const Value.absent(),
    required String displayAddress,
    this.normalizedAddress = const Value.absent(),
    this.district = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.coordinateEvidenceSource = const Value.absent(),
    this.coordinateEvidenceDate = const Value.absent(),
    this.coordinateEvidenceConfidence = const Value.absent(),
    this.placeCategoryEvidenceSource = const Value.absent(),
    this.placeCategoryEvidenceDate = const Value.absent(),
    this.placeCategoryEvidenceConfidence = const Value.absent(),
    this.capabilitiesJson = const Value.absent(),
    this.locationType = const Value.absent(),
    this.locationTypeEvidenceSource = const Value.absent(),
    this.locationTypeEvidenceDate = const Value.absent(),
    this.locationTypeEvidenceConfidence = const Value.absent(),
    this.accessScheduleJson = const Value.absent(),
    this.accessEvidenceSource = const Value.absent(),
    this.accessEvidenceDate = const Value.absent(),
    this.accessEvidenceConfidence = const Value.absent(),
    this.lastSeenDate = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       institutionCode = Value(institutionCode),
       institutionName = Value(institutionName),
       placeName = Value(placeName),
       placeCategory = Value(placeCategory),
       displayAddress = Value(displayAddress);
  static Insertable<StoredAtmSite> custom({
    Expression<String>? id,
    Expression<String>? institutionCode,
    Expression<String>? institutionName,
    Expression<String>? placeName,
    Expression<String>? placeCategory,
    Expression<String>? county,
    Expression<String>? displayAddress,
    Expression<String>? normalizedAddress,
    Expression<String>? district,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? coordinateEvidenceSource,
    Expression<String>? coordinateEvidenceDate,
    Expression<String>? coordinateEvidenceConfidence,
    Expression<String>? placeCategoryEvidenceSource,
    Expression<String>? placeCategoryEvidenceDate,
    Expression<String>? placeCategoryEvidenceConfidence,
    Expression<String>? capabilitiesJson,
    Expression<String>? locationType,
    Expression<String>? locationTypeEvidenceSource,
    Expression<String>? locationTypeEvidenceDate,
    Expression<String>? locationTypeEvidenceConfidence,
    Expression<String>? accessScheduleJson,
    Expression<String>? accessEvidenceSource,
    Expression<String>? accessEvidenceDate,
    Expression<String>? accessEvidenceConfidence,
    Expression<String>? lastSeenDate,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (institutionCode != null) 'institution_code': institutionCode,
      if (institutionName != null) 'institution_name': institutionName,
      if (placeName != null) 'place_name': placeName,
      if (placeCategory != null) 'place_category': placeCategory,
      if (county != null) 'county': county,
      if (displayAddress != null) 'display_address': displayAddress,
      if (normalizedAddress != null) 'normalized_address': normalizedAddress,
      if (district != null) 'district': district,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (coordinateEvidenceSource != null)
        'coordinate_evidence_source': coordinateEvidenceSource,
      if (coordinateEvidenceDate != null)
        'coordinate_evidence_date': coordinateEvidenceDate,
      if (coordinateEvidenceConfidence != null)
        'coordinate_evidence_confidence': coordinateEvidenceConfidence,
      if (placeCategoryEvidenceSource != null)
        'place_category_evidence_source': placeCategoryEvidenceSource,
      if (placeCategoryEvidenceDate != null)
        'place_category_evidence_date': placeCategoryEvidenceDate,
      if (placeCategoryEvidenceConfidence != null)
        'place_category_evidence_confidence': placeCategoryEvidenceConfidence,
      if (capabilitiesJson != null) 'capabilities_json': capabilitiesJson,
      if (locationType != null) 'location_type': locationType,
      if (locationTypeEvidenceSource != null)
        'location_type_evidence_source': locationTypeEvidenceSource,
      if (locationTypeEvidenceDate != null)
        'location_type_evidence_date': locationTypeEvidenceDate,
      if (locationTypeEvidenceConfidence != null)
        'location_type_evidence_confidence': locationTypeEvidenceConfidence,
      if (accessScheduleJson != null)
        'access_schedule_json': accessScheduleJson,
      if (accessEvidenceSource != null)
        'access_evidence_source': accessEvidenceSource,
      if (accessEvidenceDate != null)
        'access_evidence_date': accessEvidenceDate,
      if (accessEvidenceConfidence != null)
        'access_evidence_confidence': accessEvidenceConfidence,
      if (lastSeenDate != null) 'last_seen_date': lastSeenDate,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AtmSitesCompanion copyWith({
    Value<String>? id,
    Value<String>? institutionCode,
    Value<String>? institutionName,
    Value<String>? placeName,
    Value<String>? placeCategory,
    Value<String>? county,
    Value<String>? displayAddress,
    Value<String>? normalizedAddress,
    Value<String>? district,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? coordinateEvidenceSource,
    Value<String?>? coordinateEvidenceDate,
    Value<String?>? coordinateEvidenceConfidence,
    Value<String?>? placeCategoryEvidenceSource,
    Value<String?>? placeCategoryEvidenceDate,
    Value<String?>? placeCategoryEvidenceConfidence,
    Value<String>? capabilitiesJson,
    Value<String>? locationType,
    Value<String?>? locationTypeEvidenceSource,
    Value<String?>? locationTypeEvidenceDate,
    Value<String?>? locationTypeEvidenceConfidence,
    Value<String?>? accessScheduleJson,
    Value<String?>? accessEvidenceSource,
    Value<String?>? accessEvidenceDate,
    Value<String?>? accessEvidenceConfidence,
    Value<String?>? lastSeenDate,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return AtmSitesCompanion(
      id: id ?? this.id,
      institutionCode: institutionCode ?? this.institutionCode,
      institutionName: institutionName ?? this.institutionName,
      placeName: placeName ?? this.placeName,
      placeCategory: placeCategory ?? this.placeCategory,
      county: county ?? this.county,
      displayAddress: displayAddress ?? this.displayAddress,
      normalizedAddress: normalizedAddress ?? this.normalizedAddress,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coordinateEvidenceSource:
          coordinateEvidenceSource ?? this.coordinateEvidenceSource,
      coordinateEvidenceDate:
          coordinateEvidenceDate ?? this.coordinateEvidenceDate,
      coordinateEvidenceConfidence:
          coordinateEvidenceConfidence ?? this.coordinateEvidenceConfidence,
      placeCategoryEvidenceSource:
          placeCategoryEvidenceSource ?? this.placeCategoryEvidenceSource,
      placeCategoryEvidenceDate:
          placeCategoryEvidenceDate ?? this.placeCategoryEvidenceDate,
      placeCategoryEvidenceConfidence:
          placeCategoryEvidenceConfidence ??
          this.placeCategoryEvidenceConfidence,
      capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
      locationType: locationType ?? this.locationType,
      locationTypeEvidenceSource:
          locationTypeEvidenceSource ?? this.locationTypeEvidenceSource,
      locationTypeEvidenceDate:
          locationTypeEvidenceDate ?? this.locationTypeEvidenceDate,
      locationTypeEvidenceConfidence:
          locationTypeEvidenceConfidence ?? this.locationTypeEvidenceConfidence,
      accessScheduleJson: accessScheduleJson ?? this.accessScheduleJson,
      accessEvidenceSource: accessEvidenceSource ?? this.accessEvidenceSource,
      accessEvidenceDate: accessEvidenceDate ?? this.accessEvidenceDate,
      accessEvidenceConfidence:
          accessEvidenceConfidence ?? this.accessEvidenceConfidence,
      lastSeenDate: lastSeenDate ?? this.lastSeenDate,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (institutionCode.present) {
      map['institution_code'] = Variable<String>(institutionCode.value);
    }
    if (institutionName.present) {
      map['institution_name'] = Variable<String>(institutionName.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (placeCategory.present) {
      map['place_category'] = Variable<String>(placeCategory.value);
    }
    if (county.present) {
      map['county'] = Variable<String>(county.value);
    }
    if (displayAddress.present) {
      map['display_address'] = Variable<String>(displayAddress.value);
    }
    if (normalizedAddress.present) {
      map['normalized_address'] = Variable<String>(normalizedAddress.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (coordinateEvidenceSource.present) {
      map['coordinate_evidence_source'] = Variable<String>(
        coordinateEvidenceSource.value,
      );
    }
    if (coordinateEvidenceDate.present) {
      map['coordinate_evidence_date'] = Variable<String>(
        coordinateEvidenceDate.value,
      );
    }
    if (coordinateEvidenceConfidence.present) {
      map['coordinate_evidence_confidence'] = Variable<String>(
        coordinateEvidenceConfidence.value,
      );
    }
    if (placeCategoryEvidenceSource.present) {
      map['place_category_evidence_source'] = Variable<String>(
        placeCategoryEvidenceSource.value,
      );
    }
    if (placeCategoryEvidenceDate.present) {
      map['place_category_evidence_date'] = Variable<String>(
        placeCategoryEvidenceDate.value,
      );
    }
    if (placeCategoryEvidenceConfidence.present) {
      map['place_category_evidence_confidence'] = Variable<String>(
        placeCategoryEvidenceConfidence.value,
      );
    }
    if (capabilitiesJson.present) {
      map['capabilities_json'] = Variable<String>(capabilitiesJson.value);
    }
    if (locationType.present) {
      map['location_type'] = Variable<String>(locationType.value);
    }
    if (locationTypeEvidenceSource.present) {
      map['location_type_evidence_source'] = Variable<String>(
        locationTypeEvidenceSource.value,
      );
    }
    if (locationTypeEvidenceDate.present) {
      map['location_type_evidence_date'] = Variable<String>(
        locationTypeEvidenceDate.value,
      );
    }
    if (locationTypeEvidenceConfidence.present) {
      map['location_type_evidence_confidence'] = Variable<String>(
        locationTypeEvidenceConfidence.value,
      );
    }
    if (accessScheduleJson.present) {
      map['access_schedule_json'] = Variable<String>(accessScheduleJson.value);
    }
    if (accessEvidenceSource.present) {
      map['access_evidence_source'] = Variable<String>(
        accessEvidenceSource.value,
      );
    }
    if (accessEvidenceDate.present) {
      map['access_evidence_date'] = Variable<String>(accessEvidenceDate.value);
    }
    if (accessEvidenceConfidence.present) {
      map['access_evidence_confidence'] = Variable<String>(
        accessEvidenceConfidence.value,
      );
    }
    if (lastSeenDate.present) {
      map['last_seen_date'] = Variable<String>(lastSeenDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AtmSitesCompanion(')
          ..write('id: $id, ')
          ..write('institutionCode: $institutionCode, ')
          ..write('institutionName: $institutionName, ')
          ..write('placeName: $placeName, ')
          ..write('placeCategory: $placeCategory, ')
          ..write('county: $county, ')
          ..write('displayAddress: $displayAddress, ')
          ..write('normalizedAddress: $normalizedAddress, ')
          ..write('district: $district, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('coordinateEvidenceSource: $coordinateEvidenceSource, ')
          ..write('coordinateEvidenceDate: $coordinateEvidenceDate, ')
          ..write(
            'coordinateEvidenceConfidence: $coordinateEvidenceConfidence, ',
          )
          ..write('placeCategoryEvidenceSource: $placeCategoryEvidenceSource, ')
          ..write('placeCategoryEvidenceDate: $placeCategoryEvidenceDate, ')
          ..write(
            'placeCategoryEvidenceConfidence: $placeCategoryEvidenceConfidence, ',
          )
          ..write('capabilitiesJson: $capabilitiesJson, ')
          ..write('locationType: $locationType, ')
          ..write('locationTypeEvidenceSource: $locationTypeEvidenceSource, ')
          ..write('locationTypeEvidenceDate: $locationTypeEvidenceDate, ')
          ..write(
            'locationTypeEvidenceConfidence: $locationTypeEvidenceConfidence, ',
          )
          ..write('accessScheduleJson: $accessScheduleJson, ')
          ..write('accessEvidenceSource: $accessEvidenceSource, ')
          ..write('accessEvidenceDate: $accessEvidenceDate, ')
          ..write('accessEvidenceConfidence: $accessEvidenceConfidence, ')
          ..write('lastSeenDate: $lastSeenDate, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogMetadataEntriesTable extends CatalogMetadataEntries
    with TableInfo<$CatalogMetadataEntriesTable, CatalogMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogMetadataEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datasetVersionMeta = const VerificationMeta(
    'datasetVersion',
  );
  @override
  late final GeneratedColumn<String> datasetVersion = GeneratedColumn<String>(
    'dataset_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateCheckAtMeta = const VerificationMeta(
    'lastUpdateCheckAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateCheckAt =
      GeneratedColumn<DateTime>(
        'last_update_check_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    singletonKey,
    schemaVersion,
    datasetVersion,
    installedAt,
    lastUpdateCheckAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_metadata_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogMetadata> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('dataset_version')) {
      context.handle(
        _datasetVersionMeta,
        datasetVersion.isAcceptableOrUnknown(
          data['dataset_version']!,
          _datasetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_datasetVersionMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('last_update_check_at')) {
      context.handle(
        _lastUpdateCheckAtMeta,
        lastUpdateCheckAt.isAcceptableOrUnknown(
          data['last_update_check_at']!,
          _lastUpdateCheckAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonKey};
  @override
  CatalogMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogMetadata(
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      datasetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_version'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      lastUpdateCheckAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_check_at'],
      ),
    );
  }

  @override
  $CatalogMetadataEntriesTable createAlias(String alias) {
    return $CatalogMetadataEntriesTable(attachedDatabase, alias);
  }
}

class CatalogMetadata extends DataClass implements Insertable<CatalogMetadata> {
  final int singletonKey;
  final int schemaVersion;
  final String datasetVersion;
  final DateTime installedAt;
  final DateTime? lastUpdateCheckAt;
  const CatalogMetadata({
    required this.singletonKey,
    required this.schemaVersion,
    required this.datasetVersion,
    required this.installedAt,
    this.lastUpdateCheckAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_key'] = Variable<int>(singletonKey);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['dataset_version'] = Variable<String>(datasetVersion);
    map['installed_at'] = Variable<DateTime>(installedAt);
    if (!nullToAbsent || lastUpdateCheckAt != null) {
      map['last_update_check_at'] = Variable<DateTime>(lastUpdateCheckAt);
    }
    return map;
  }

  CatalogMetadataEntriesCompanion toCompanion(bool nullToAbsent) {
    return CatalogMetadataEntriesCompanion(
      singletonKey: Value(singletonKey),
      schemaVersion: Value(schemaVersion),
      datasetVersion: Value(datasetVersion),
      installedAt: Value(installedAt),
      lastUpdateCheckAt: lastUpdateCheckAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateCheckAt),
    );
  }

  factory CatalogMetadata.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogMetadata(
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      datasetVersion: serializer.fromJson<String>(json['datasetVersion']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      lastUpdateCheckAt: serializer.fromJson<DateTime?>(
        json['lastUpdateCheckAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonKey': serializer.toJson<int>(singletonKey),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'datasetVersion': serializer.toJson<String>(datasetVersion),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'lastUpdateCheckAt': serializer.toJson<DateTime?>(lastUpdateCheckAt),
    };
  }

  CatalogMetadata copyWith({
    int? singletonKey,
    int? schemaVersion,
    String? datasetVersion,
    DateTime? installedAt,
    Value<DateTime?> lastUpdateCheckAt = const Value.absent(),
  }) => CatalogMetadata(
    singletonKey: singletonKey ?? this.singletonKey,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    datasetVersion: datasetVersion ?? this.datasetVersion,
    installedAt: installedAt ?? this.installedAt,
    lastUpdateCheckAt: lastUpdateCheckAt.present
        ? lastUpdateCheckAt.value
        : this.lastUpdateCheckAt,
  );
  CatalogMetadata copyWithCompanion(CatalogMetadataEntriesCompanion data) {
    return CatalogMetadata(
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      datasetVersion: data.datasetVersion.present
          ? data.datasetVersion.value
          : this.datasetVersion,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      lastUpdateCheckAt: data.lastUpdateCheckAt.present
          ? data.lastUpdateCheckAt.value
          : this.lastUpdateCheckAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogMetadata(')
          ..write('singletonKey: $singletonKey, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('datasetVersion: $datasetVersion, ')
          ..write('installedAt: $installedAt, ')
          ..write('lastUpdateCheckAt: $lastUpdateCheckAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonKey,
    schemaVersion,
    datasetVersion,
    installedAt,
    lastUpdateCheckAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogMetadata &&
          other.singletonKey == this.singletonKey &&
          other.schemaVersion == this.schemaVersion &&
          other.datasetVersion == this.datasetVersion &&
          other.installedAt == this.installedAt &&
          other.lastUpdateCheckAt == this.lastUpdateCheckAt);
}

class CatalogMetadataEntriesCompanion extends UpdateCompanion<CatalogMetadata> {
  final Value<int> singletonKey;
  final Value<int> schemaVersion;
  final Value<String> datasetVersion;
  final Value<DateTime> installedAt;
  final Value<DateTime?> lastUpdateCheckAt;
  const CatalogMetadataEntriesCompanion({
    this.singletonKey = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.datasetVersion = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.lastUpdateCheckAt = const Value.absent(),
  });
  CatalogMetadataEntriesCompanion.insert({
    this.singletonKey = const Value.absent(),
    required int schemaVersion,
    required String datasetVersion,
    required DateTime installedAt,
    this.lastUpdateCheckAt = const Value.absent(),
  }) : schemaVersion = Value(schemaVersion),
       datasetVersion = Value(datasetVersion),
       installedAt = Value(installedAt);
  static Insertable<CatalogMetadata> custom({
    Expression<int>? singletonKey,
    Expression<int>? schemaVersion,
    Expression<String>? datasetVersion,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? lastUpdateCheckAt,
  }) {
    return RawValuesInsertable({
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (datasetVersion != null) 'dataset_version': datasetVersion,
      if (installedAt != null) 'installed_at': installedAt,
      if (lastUpdateCheckAt != null) 'last_update_check_at': lastUpdateCheckAt,
    });
  }

  CatalogMetadataEntriesCompanion copyWith({
    Value<int>? singletonKey,
    Value<int>? schemaVersion,
    Value<String>? datasetVersion,
    Value<DateTime>? installedAt,
    Value<DateTime?>? lastUpdateCheckAt,
  }) {
    return CatalogMetadataEntriesCompanion(
      singletonKey: singletonKey ?? this.singletonKey,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      datasetVersion: datasetVersion ?? this.datasetVersion,
      installedAt: installedAt ?? this.installedAt,
      lastUpdateCheckAt: lastUpdateCheckAt ?? this.lastUpdateCheckAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (datasetVersion.present) {
      map['dataset_version'] = Variable<String>(datasetVersion.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (lastUpdateCheckAt.present) {
      map['last_update_check_at'] = Variable<DateTime>(lastUpdateCheckAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogMetadataEntriesCompanion(')
          ..write('singletonKey: $singletonKey, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('datasetVersion: $datasetVersion, ')
          ..write('installedAt: $installedAt, ')
          ..write('lastUpdateCheckAt: $lastUpdateCheckAt')
          ..write(')'))
        .toString();
  }
}

class $CatalogBackupEntriesTable extends CatalogBackupEntries
    with TableInfo<$CatalogBackupEntriesTable, CatalogBackup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogBackupEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _datasetVersionMeta = const VerificationMeta(
    'datasetVersion',
  );
  @override
  late final GeneratedColumn<String> datasetVersion = GeneratedColumn<String>(
    'dataset_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestJsonMeta = const VerificationMeta(
    'manifestJson',
  );
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
    'manifest_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compressedSnapshotMeta =
      const VerificationMeta('compressedSnapshot');
  @override
  late final GeneratedColumn<Uint8List> compressedSnapshot =
      GeneratedColumn<Uint8List>(
        'compressed_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonKey,
    datasetVersion,
    manifestJson,
    compressedSnapshot,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_backup_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogBackup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('dataset_version')) {
      context.handle(
        _datasetVersionMeta,
        datasetVersion.isAcceptableOrUnknown(
          data['dataset_version']!,
          _datasetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_datasetVersionMeta);
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
        _manifestJsonMeta,
        manifestJson.isAcceptableOrUnknown(
          data['manifest_json']!,
          _manifestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestJsonMeta);
    }
    if (data.containsKey('compressed_snapshot')) {
      context.handle(
        _compressedSnapshotMeta,
        compressedSnapshot.isAcceptableOrUnknown(
          data['compressed_snapshot']!,
          _compressedSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compressedSnapshotMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonKey};
  @override
  CatalogBackup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogBackup(
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      datasetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_version'],
      )!,
      manifestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_json'],
      )!,
      compressedSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}compressed_snapshot'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CatalogBackupEntriesTable createAlias(String alias) {
    return $CatalogBackupEntriesTable(attachedDatabase, alias);
  }
}

class CatalogBackup extends DataClass implements Insertable<CatalogBackup> {
  final int singletonKey;
  final String datasetVersion;
  final String manifestJson;
  final Uint8List compressedSnapshot;
  final DateTime createdAt;
  const CatalogBackup({
    required this.singletonKey,
    required this.datasetVersion,
    required this.manifestJson,
    required this.compressedSnapshot,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_key'] = Variable<int>(singletonKey);
    map['dataset_version'] = Variable<String>(datasetVersion);
    map['manifest_json'] = Variable<String>(manifestJson);
    map['compressed_snapshot'] = Variable<Uint8List>(compressedSnapshot);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CatalogBackupEntriesCompanion toCompanion(bool nullToAbsent) {
    return CatalogBackupEntriesCompanion(
      singletonKey: Value(singletonKey),
      datasetVersion: Value(datasetVersion),
      manifestJson: Value(manifestJson),
      compressedSnapshot: Value(compressedSnapshot),
      createdAt: Value(createdAt),
    );
  }

  factory CatalogBackup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogBackup(
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      datasetVersion: serializer.fromJson<String>(json['datasetVersion']),
      manifestJson: serializer.fromJson<String>(json['manifestJson']),
      compressedSnapshot: serializer.fromJson<Uint8List>(
        json['compressedSnapshot'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonKey': serializer.toJson<int>(singletonKey),
      'datasetVersion': serializer.toJson<String>(datasetVersion),
      'manifestJson': serializer.toJson<String>(manifestJson),
      'compressedSnapshot': serializer.toJson<Uint8List>(compressedSnapshot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CatalogBackup copyWith({
    int? singletonKey,
    String? datasetVersion,
    String? manifestJson,
    Uint8List? compressedSnapshot,
    DateTime? createdAt,
  }) => CatalogBackup(
    singletonKey: singletonKey ?? this.singletonKey,
    datasetVersion: datasetVersion ?? this.datasetVersion,
    manifestJson: manifestJson ?? this.manifestJson,
    compressedSnapshot: compressedSnapshot ?? this.compressedSnapshot,
    createdAt: createdAt ?? this.createdAt,
  );
  CatalogBackup copyWithCompanion(CatalogBackupEntriesCompanion data) {
    return CatalogBackup(
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      datasetVersion: data.datasetVersion.present
          ? data.datasetVersion.value
          : this.datasetVersion,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
      compressedSnapshot: data.compressedSnapshot.present
          ? data.compressedSnapshot.value
          : this.compressedSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBackup(')
          ..write('singletonKey: $singletonKey, ')
          ..write('datasetVersion: $datasetVersion, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('compressedSnapshot: $compressedSnapshot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonKey,
    datasetVersion,
    manifestJson,
    $driftBlobEquality.hash(compressedSnapshot),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogBackup &&
          other.singletonKey == this.singletonKey &&
          other.datasetVersion == this.datasetVersion &&
          other.manifestJson == this.manifestJson &&
          $driftBlobEquality.equals(
            other.compressedSnapshot,
            this.compressedSnapshot,
          ) &&
          other.createdAt == this.createdAt);
}

class CatalogBackupEntriesCompanion extends UpdateCompanion<CatalogBackup> {
  final Value<int> singletonKey;
  final Value<String> datasetVersion;
  final Value<String> manifestJson;
  final Value<Uint8List> compressedSnapshot;
  final Value<DateTime> createdAt;
  const CatalogBackupEntriesCompanion({
    this.singletonKey = const Value.absent(),
    this.datasetVersion = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.compressedSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CatalogBackupEntriesCompanion.insert({
    this.singletonKey = const Value.absent(),
    required String datasetVersion,
    required String manifestJson,
    required Uint8List compressedSnapshot,
    required DateTime createdAt,
  }) : datasetVersion = Value(datasetVersion),
       manifestJson = Value(manifestJson),
       compressedSnapshot = Value(compressedSnapshot),
       createdAt = Value(createdAt);
  static Insertable<CatalogBackup> custom({
    Expression<int>? singletonKey,
    Expression<String>? datasetVersion,
    Expression<String>? manifestJson,
    Expression<Uint8List>? compressedSnapshot,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (datasetVersion != null) 'dataset_version': datasetVersion,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (compressedSnapshot != null) 'compressed_snapshot': compressedSnapshot,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CatalogBackupEntriesCompanion copyWith({
    Value<int>? singletonKey,
    Value<String>? datasetVersion,
    Value<String>? manifestJson,
    Value<Uint8List>? compressedSnapshot,
    Value<DateTime>? createdAt,
  }) {
    return CatalogBackupEntriesCompanion(
      singletonKey: singletonKey ?? this.singletonKey,
      datasetVersion: datasetVersion ?? this.datasetVersion,
      manifestJson: manifestJson ?? this.manifestJson,
      compressedSnapshot: compressedSnapshot ?? this.compressedSnapshot,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (datasetVersion.present) {
      map['dataset_version'] = Variable<String>(datasetVersion.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (compressedSnapshot.present) {
      map['compressed_snapshot'] = Variable<Uint8List>(
        compressedSnapshot.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBackupEntriesCompanion(')
          ..write('singletonKey: $singletonKey, ')
          ..write('datasetVersion: $datasetVersion, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('compressedSnapshot: $compressedSnapshot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final String key;
  final String value;
  const AppPreference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppPreference copyWith({String? key, String? value}) =>
      AppPreference(key: key ?? this.key, value: value ?? this.value);
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentPlacesTable extends RecentPlaces
    with TableInfo<$RecentPlacesTable, StoredRecentPlace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentPlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    label,
    latitude,
    longitude,
    searchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_places';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredRecentPlace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {label};
  @override
  StoredRecentPlace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredRecentPlace(
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentPlacesTable createAlias(String alias) {
    return $RecentPlacesTable(attachedDatabase, alias);
  }
}

class StoredRecentPlace extends DataClass
    implements Insertable<StoredRecentPlace> {
  final String label;
  final double latitude;
  final double longitude;
  final DateTime searchedAt;
  const StoredRecentPlace({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['label'] = Variable<String>(label);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentPlacesCompanion toCompanion(bool nullToAbsent) {
    return RecentPlacesCompanion(
      label: Value(label),
      latitude: Value(latitude),
      longitude: Value(longitude),
      searchedAt: Value(searchedAt),
    );
  }

  factory StoredRecentPlace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredRecentPlace(
      label: serializer.fromJson<String>(json['label']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'label': serializer.toJson<String>(label),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  StoredRecentPlace copyWith({
    String? label,
    double? latitude,
    double? longitude,
    DateTime? searchedAt,
  }) => StoredRecentPlace(
    label: label ?? this.label,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  StoredRecentPlace copyWithCompanion(RecentPlacesCompanion data) {
    return StoredRecentPlace(
      label: data.label.present ? data.label.value : this.label,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredRecentPlace(')
          ..write('label: $label, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(label, latitude, longitude, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredRecentPlace &&
          other.label == this.label &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.searchedAt == this.searchedAt);
}

class RecentPlacesCompanion extends UpdateCompanion<StoredRecentPlace> {
  final Value<String> label;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> searchedAt;
  final Value<int> rowid;
  const RecentPlacesCompanion({
    this.label = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentPlacesCompanion.insert({
    required String label,
    required double latitude,
    required double longitude,
    required DateTime searchedAt,
    this.rowid = const Value.absent(),
  }) : label = Value(label),
       latitude = Value(latitude),
       longitude = Value(longitude),
       searchedAt = Value(searchedAt);
  static Insertable<StoredRecentPlace> custom({
    Expression<String>? label,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (label != null) 'label': label,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentPlacesCompanion copyWith({
    Value<String>? label,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? searchedAt,
    Value<int>? rowid,
  }) {
    return RecentPlacesCompanion(
      label: label ?? this.label,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentPlacesCompanion(')
          ..write('label: $label, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteSitesTable extends FavoriteSites
    with TableInfo<$FavoriteSitesTable, StoredFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoritedAtMeta = const VerificationMeta(
    'favoritedAt',
  );
  @override
  late final GeneratedColumn<DateTime> favoritedAt = GeneratedColumn<DateTime>(
    'favorited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [siteId, favoritedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredFavorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('favorited_at')) {
      context.handle(
        _favoritedAtMeta,
        favoritedAt.isAcceptableOrUnknown(
          data['favorited_at']!,
          _favoritedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_favoritedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {siteId};
  @override
  StoredFavorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredFavorite(
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      favoritedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorited_at'],
      )!,
    );
  }

  @override
  $FavoriteSitesTable createAlias(String alias) {
    return $FavoriteSitesTable(attachedDatabase, alias);
  }
}

class StoredFavorite extends DataClass implements Insertable<StoredFavorite> {
  final String siteId;
  final DateTime favoritedAt;
  const StoredFavorite({required this.siteId, required this.favoritedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['site_id'] = Variable<String>(siteId);
    map['favorited_at'] = Variable<DateTime>(favoritedAt);
    return map;
  }

  FavoriteSitesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteSitesCompanion(
      siteId: Value(siteId),
      favoritedAt: Value(favoritedAt),
    );
  }

  factory StoredFavorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredFavorite(
      siteId: serializer.fromJson<String>(json['siteId']),
      favoritedAt: serializer.fromJson<DateTime>(json['favoritedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'siteId': serializer.toJson<String>(siteId),
      'favoritedAt': serializer.toJson<DateTime>(favoritedAt),
    };
  }

  StoredFavorite copyWith({String? siteId, DateTime? favoritedAt}) =>
      StoredFavorite(
        siteId: siteId ?? this.siteId,
        favoritedAt: favoritedAt ?? this.favoritedAt,
      );
  StoredFavorite copyWithCompanion(FavoriteSitesCompanion data) {
    return StoredFavorite(
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      favoritedAt: data.favoritedAt.present
          ? data.favoritedAt.value
          : this.favoritedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredFavorite(')
          ..write('siteId: $siteId, ')
          ..write('favoritedAt: $favoritedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(siteId, favoritedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredFavorite &&
          other.siteId == this.siteId &&
          other.favoritedAt == this.favoritedAt);
}

class FavoriteSitesCompanion extends UpdateCompanion<StoredFavorite> {
  final Value<String> siteId;
  final Value<DateTime> favoritedAt;
  final Value<int> rowid;
  const FavoriteSitesCompanion({
    this.siteId = const Value.absent(),
    this.favoritedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteSitesCompanion.insert({
    required String siteId,
    required DateTime favoritedAt,
    this.rowid = const Value.absent(),
  }) : siteId = Value(siteId),
       favoritedAt = Value(favoritedAt);
  static Insertable<StoredFavorite> custom({
    Expression<String>? siteId,
    Expression<DateTime>? favoritedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (siteId != null) 'site_id': siteId,
      if (favoritedAt != null) 'favorited_at': favoritedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteSitesCompanion copyWith({
    Value<String>? siteId,
    Value<DateTime>? favoritedAt,
    Value<int>? rowid,
  }) {
    return FavoriteSitesCompanion(
      siteId: siteId ?? this.siteId,
      favoritedAt: favoritedAt ?? this.favoritedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (favoritedAt.present) {
      map['favorited_at'] = Variable<DateTime>(favoritedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteSitesCompanion(')
          ..write('siteId: $siteId, ')
          ..write('favoritedAt: $favoritedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AtmDatabase extends GeneratedDatabase {
  _$AtmDatabase(QueryExecutor e) : super(e);
  $AtmDatabaseManager get managers => $AtmDatabaseManager(this);
  late final $AtmSitesTable atmSites = $AtmSitesTable(this);
  late final $CatalogMetadataEntriesTable catalogMetadataEntries =
      $CatalogMetadataEntriesTable(this);
  late final $CatalogBackupEntriesTable catalogBackupEntries =
      $CatalogBackupEntriesTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $RecentPlacesTable recentPlaces = $RecentPlacesTable(this);
  late final $FavoriteSitesTable favoriteSites = $FavoriteSitesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    atmSites,
    catalogMetadataEntries,
    catalogBackupEntries,
    appPreferences,
    recentPlaces,
    favoriteSites,
  ];
}

typedef $$AtmSitesTableCreateCompanionBuilder =
    AtmSitesCompanion Function({
      required String id,
      required String institutionCode,
      required String institutionName,
      required String placeName,
      required String placeCategory,
      Value<String> county,
      required String displayAddress,
      Value<String> normalizedAddress,
      Value<String> district,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> coordinateEvidenceSource,
      Value<String?> coordinateEvidenceDate,
      Value<String?> coordinateEvidenceConfidence,
      Value<String?> placeCategoryEvidenceSource,
      Value<String?> placeCategoryEvidenceDate,
      Value<String?> placeCategoryEvidenceConfidence,
      Value<String> capabilitiesJson,
      Value<String> locationType,
      Value<String?> locationTypeEvidenceSource,
      Value<String?> locationTypeEvidenceDate,
      Value<String?> locationTypeEvidenceConfidence,
      Value<String?> accessScheduleJson,
      Value<String?> accessEvidenceSource,
      Value<String?> accessEvidenceDate,
      Value<String?> accessEvidenceConfidence,
      Value<String?> lastSeenDate,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$AtmSitesTableUpdateCompanionBuilder =
    AtmSitesCompanion Function({
      Value<String> id,
      Value<String> institutionCode,
      Value<String> institutionName,
      Value<String> placeName,
      Value<String> placeCategory,
      Value<String> county,
      Value<String> displayAddress,
      Value<String> normalizedAddress,
      Value<String> district,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> coordinateEvidenceSource,
      Value<String?> coordinateEvidenceDate,
      Value<String?> coordinateEvidenceConfidence,
      Value<String?> placeCategoryEvidenceSource,
      Value<String?> placeCategoryEvidenceDate,
      Value<String?> placeCategoryEvidenceConfidence,
      Value<String> capabilitiesJson,
      Value<String> locationType,
      Value<String?> locationTypeEvidenceSource,
      Value<String?> locationTypeEvidenceDate,
      Value<String?> locationTypeEvidenceConfidence,
      Value<String?> accessScheduleJson,
      Value<String?> accessEvidenceSource,
      Value<String?> accessEvidenceDate,
      Value<String?> accessEvidenceConfidence,
      Value<String?> lastSeenDate,
      Value<bool> active,
      Value<int> rowid,
    });

class $$AtmSitesTableFilterComposer
    extends Composer<_$AtmDatabase, $AtmSitesTable> {
  $$AtmSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionCode => $composableBuilder(
    column: $table.institutionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get county => $composableBuilder(
    column: $table.county,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayAddress => $composableBuilder(
    column: $table.displayAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coordinateEvidenceSource => $composableBuilder(
    column: $table.coordinateEvidenceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coordinateEvidenceDate => $composableBuilder(
    column: $table.coordinateEvidenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coordinateEvidenceConfidence => $composableBuilder(
    column: $table.coordinateEvidenceConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCategoryEvidenceSource => $composableBuilder(
    column: $table.placeCategoryEvidenceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCategoryEvidenceDate => $composableBuilder(
    column: $table.placeCategoryEvidenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCategoryEvidenceConfidence =>
      $composableBuilder(
        column: $table.placeCategoryEvidenceConfidence,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationTypeEvidenceSource => $composableBuilder(
    column: $table.locationTypeEvidenceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationTypeEvidenceDate => $composableBuilder(
    column: $table.locationTypeEvidenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationTypeEvidenceConfidence =>
      $composableBuilder(
        column: $table.locationTypeEvidenceConfidence,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get accessScheduleJson => $composableBuilder(
    column: $table.accessScheduleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessEvidenceSource => $composableBuilder(
    column: $table.accessEvidenceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessEvidenceDate => $composableBuilder(
    column: $table.accessEvidenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessEvidenceConfidence => $composableBuilder(
    column: $table.accessEvidenceConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSeenDate => $composableBuilder(
    column: $table.lastSeenDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AtmSitesTableOrderingComposer
    extends Composer<_$AtmDatabase, $AtmSitesTable> {
  $$AtmSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionCode => $composableBuilder(
    column: $table.institutionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get county => $composableBuilder(
    column: $table.county,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayAddress => $composableBuilder(
    column: $table.displayAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coordinateEvidenceSource => $composableBuilder(
    column: $table.coordinateEvidenceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coordinateEvidenceDate => $composableBuilder(
    column: $table.coordinateEvidenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coordinateEvidenceConfidence =>
      $composableBuilder(
        column: $table.coordinateEvidenceConfidence,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get placeCategoryEvidenceSource => $composableBuilder(
    column: $table.placeCategoryEvidenceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCategoryEvidenceDate => $composableBuilder(
    column: $table.placeCategoryEvidenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCategoryEvidenceConfidence =>
      $composableBuilder(
        column: $table.placeCategoryEvidenceConfidence,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationTypeEvidenceSource => $composableBuilder(
    column: $table.locationTypeEvidenceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationTypeEvidenceDate => $composableBuilder(
    column: $table.locationTypeEvidenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationTypeEvidenceConfidence =>
      $composableBuilder(
        column: $table.locationTypeEvidenceConfidence,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get accessScheduleJson => $composableBuilder(
    column: $table.accessScheduleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessEvidenceSource => $composableBuilder(
    column: $table.accessEvidenceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessEvidenceDate => $composableBuilder(
    column: $table.accessEvidenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessEvidenceConfidence => $composableBuilder(
    column: $table.accessEvidenceConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSeenDate => $composableBuilder(
    column: $table.lastSeenDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AtmSitesTableAnnotationComposer
    extends Composer<_$AtmDatabase, $AtmSitesTable> {
  $$AtmSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get institutionCode => $composableBuilder(
    column: $table.institutionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get county =>
      $composableBuilder(column: $table.county, builder: (column) => column);

  GeneratedColumn<String> get displayAddress => $composableBuilder(
    column: $table.displayAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get coordinateEvidenceSource => $composableBuilder(
    column: $table.coordinateEvidenceSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coordinateEvidenceDate => $composableBuilder(
    column: $table.coordinateEvidenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coordinateEvidenceConfidence =>
      $composableBuilder(
        column: $table.coordinateEvidenceConfidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get placeCategoryEvidenceSource => $composableBuilder(
    column: $table.placeCategoryEvidenceSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCategoryEvidenceDate => $composableBuilder(
    column: $table.placeCategoryEvidenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeCategoryEvidenceConfidence =>
      $composableBuilder(
        column: $table.placeCategoryEvidenceConfidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationTypeEvidenceSource => $composableBuilder(
    column: $table.locationTypeEvidenceSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationTypeEvidenceDate => $composableBuilder(
    column: $table.locationTypeEvidenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationTypeEvidenceConfidence =>
      $composableBuilder(
        column: $table.locationTypeEvidenceConfidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get accessScheduleJson => $composableBuilder(
    column: $table.accessScheduleJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessEvidenceSource => $composableBuilder(
    column: $table.accessEvidenceSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessEvidenceDate => $composableBuilder(
    column: $table.accessEvidenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessEvidenceConfidence => $composableBuilder(
    column: $table.accessEvidenceConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSeenDate => $composableBuilder(
    column: $table.lastSeenDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$AtmSitesTableTableManager
    extends
        RootTableManager<
          _$AtmDatabase,
          $AtmSitesTable,
          StoredAtmSite,
          $$AtmSitesTableFilterComposer,
          $$AtmSitesTableOrderingComposer,
          $$AtmSitesTableAnnotationComposer,
          $$AtmSitesTableCreateCompanionBuilder,
          $$AtmSitesTableUpdateCompanionBuilder,
          (
            StoredAtmSite,
            BaseReferences<_$AtmDatabase, $AtmSitesTable, StoredAtmSite>,
          ),
          StoredAtmSite,
          PrefetchHooks Function()
        > {
  $$AtmSitesTableTableManager(_$AtmDatabase db, $AtmSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AtmSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AtmSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AtmSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> institutionCode = const Value.absent(),
                Value<String> institutionName = const Value.absent(),
                Value<String> placeName = const Value.absent(),
                Value<String> placeCategory = const Value.absent(),
                Value<String> county = const Value.absent(),
                Value<String> displayAddress = const Value.absent(),
                Value<String> normalizedAddress = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> coordinateEvidenceSource = const Value.absent(),
                Value<String?> coordinateEvidenceDate = const Value.absent(),
                Value<String?> coordinateEvidenceConfidence =
                    const Value.absent(),
                Value<String?> placeCategoryEvidenceSource =
                    const Value.absent(),
                Value<String?> placeCategoryEvidenceDate = const Value.absent(),
                Value<String?> placeCategoryEvidenceConfidence =
                    const Value.absent(),
                Value<String> capabilitiesJson = const Value.absent(),
                Value<String> locationType = const Value.absent(),
                Value<String?> locationTypeEvidenceSource =
                    const Value.absent(),
                Value<String?> locationTypeEvidenceDate = const Value.absent(),
                Value<String?> locationTypeEvidenceConfidence =
                    const Value.absent(),
                Value<String?> accessScheduleJson = const Value.absent(),
                Value<String?> accessEvidenceSource = const Value.absent(),
                Value<String?> accessEvidenceDate = const Value.absent(),
                Value<String?> accessEvidenceConfidence = const Value.absent(),
                Value<String?> lastSeenDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AtmSitesCompanion(
                id: id,
                institutionCode: institutionCode,
                institutionName: institutionName,
                placeName: placeName,
                placeCategory: placeCategory,
                county: county,
                displayAddress: displayAddress,
                normalizedAddress: normalizedAddress,
                district: district,
                latitude: latitude,
                longitude: longitude,
                coordinateEvidenceSource: coordinateEvidenceSource,
                coordinateEvidenceDate: coordinateEvidenceDate,
                coordinateEvidenceConfidence: coordinateEvidenceConfidence,
                placeCategoryEvidenceSource: placeCategoryEvidenceSource,
                placeCategoryEvidenceDate: placeCategoryEvidenceDate,
                placeCategoryEvidenceConfidence:
                    placeCategoryEvidenceConfidence,
                capabilitiesJson: capabilitiesJson,
                locationType: locationType,
                locationTypeEvidenceSource: locationTypeEvidenceSource,
                locationTypeEvidenceDate: locationTypeEvidenceDate,
                locationTypeEvidenceConfidence: locationTypeEvidenceConfidence,
                accessScheduleJson: accessScheduleJson,
                accessEvidenceSource: accessEvidenceSource,
                accessEvidenceDate: accessEvidenceDate,
                accessEvidenceConfidence: accessEvidenceConfidence,
                lastSeenDate: lastSeenDate,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String institutionCode,
                required String institutionName,
                required String placeName,
                required String placeCategory,
                Value<String> county = const Value.absent(),
                required String displayAddress,
                Value<String> normalizedAddress = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> coordinateEvidenceSource = const Value.absent(),
                Value<String?> coordinateEvidenceDate = const Value.absent(),
                Value<String?> coordinateEvidenceConfidence =
                    const Value.absent(),
                Value<String?> placeCategoryEvidenceSource =
                    const Value.absent(),
                Value<String?> placeCategoryEvidenceDate = const Value.absent(),
                Value<String?> placeCategoryEvidenceConfidence =
                    const Value.absent(),
                Value<String> capabilitiesJson = const Value.absent(),
                Value<String> locationType = const Value.absent(),
                Value<String?> locationTypeEvidenceSource =
                    const Value.absent(),
                Value<String?> locationTypeEvidenceDate = const Value.absent(),
                Value<String?> locationTypeEvidenceConfidence =
                    const Value.absent(),
                Value<String?> accessScheduleJson = const Value.absent(),
                Value<String?> accessEvidenceSource = const Value.absent(),
                Value<String?> accessEvidenceDate = const Value.absent(),
                Value<String?> accessEvidenceConfidence = const Value.absent(),
                Value<String?> lastSeenDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AtmSitesCompanion.insert(
                id: id,
                institutionCode: institutionCode,
                institutionName: institutionName,
                placeName: placeName,
                placeCategory: placeCategory,
                county: county,
                displayAddress: displayAddress,
                normalizedAddress: normalizedAddress,
                district: district,
                latitude: latitude,
                longitude: longitude,
                coordinateEvidenceSource: coordinateEvidenceSource,
                coordinateEvidenceDate: coordinateEvidenceDate,
                coordinateEvidenceConfidence: coordinateEvidenceConfidence,
                placeCategoryEvidenceSource: placeCategoryEvidenceSource,
                placeCategoryEvidenceDate: placeCategoryEvidenceDate,
                placeCategoryEvidenceConfidence:
                    placeCategoryEvidenceConfidence,
                capabilitiesJson: capabilitiesJson,
                locationType: locationType,
                locationTypeEvidenceSource: locationTypeEvidenceSource,
                locationTypeEvidenceDate: locationTypeEvidenceDate,
                locationTypeEvidenceConfidence: locationTypeEvidenceConfidence,
                accessScheduleJson: accessScheduleJson,
                accessEvidenceSource: accessEvidenceSource,
                accessEvidenceDate: accessEvidenceDate,
                accessEvidenceConfidence: accessEvidenceConfidence,
                lastSeenDate: lastSeenDate,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AtmSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AtmDatabase,
      $AtmSitesTable,
      StoredAtmSite,
      $$AtmSitesTableFilterComposer,
      $$AtmSitesTableOrderingComposer,
      $$AtmSitesTableAnnotationComposer,
      $$AtmSitesTableCreateCompanionBuilder,
      $$AtmSitesTableUpdateCompanionBuilder,
      (
        StoredAtmSite,
        BaseReferences<_$AtmDatabase, $AtmSitesTable, StoredAtmSite>,
      ),
      StoredAtmSite,
      PrefetchHooks Function()
    >;
typedef $$CatalogMetadataEntriesTableCreateCompanionBuilder =
    CatalogMetadataEntriesCompanion Function({
      Value<int> singletonKey,
      required int schemaVersion,
      required String datasetVersion,
      required DateTime installedAt,
      Value<DateTime?> lastUpdateCheckAt,
    });
typedef $$CatalogMetadataEntriesTableUpdateCompanionBuilder =
    CatalogMetadataEntriesCompanion Function({
      Value<int> singletonKey,
      Value<int> schemaVersion,
      Value<String> datasetVersion,
      Value<DateTime> installedAt,
      Value<DateTime?> lastUpdateCheckAt,
    });

class $$CatalogMetadataEntriesTableFilterComposer
    extends Composer<_$AtmDatabase, $CatalogMetadataEntriesTable> {
  $$CatalogMetadataEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateCheckAt => $composableBuilder(
    column: $table.lastUpdateCheckAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogMetadataEntriesTableOrderingComposer
    extends Composer<_$AtmDatabase, $CatalogMetadataEntriesTable> {
  $$CatalogMetadataEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateCheckAt => $composableBuilder(
    column: $table.lastUpdateCheckAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogMetadataEntriesTableAnnotationComposer
    extends Composer<_$AtmDatabase, $CatalogMetadataEntriesTable> {
  $$CatalogMetadataEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdateCheckAt => $composableBuilder(
    column: $table.lastUpdateCheckAt,
    builder: (column) => column,
  );
}

class $$CatalogMetadataEntriesTableTableManager
    extends
        RootTableManager<
          _$AtmDatabase,
          $CatalogMetadataEntriesTable,
          CatalogMetadata,
          $$CatalogMetadataEntriesTableFilterComposer,
          $$CatalogMetadataEntriesTableOrderingComposer,
          $$CatalogMetadataEntriesTableAnnotationComposer,
          $$CatalogMetadataEntriesTableCreateCompanionBuilder,
          $$CatalogMetadataEntriesTableUpdateCompanionBuilder,
          (
            CatalogMetadata,
            BaseReferences<
              _$AtmDatabase,
              $CatalogMetadataEntriesTable,
              CatalogMetadata
            >,
          ),
          CatalogMetadata,
          PrefetchHooks Function()
        > {
  $$CatalogMetadataEntriesTableTableManager(
    _$AtmDatabase db,
    $CatalogMetadataEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogMetadataEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CatalogMetadataEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogMetadataEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> datasetVersion = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime?> lastUpdateCheckAt = const Value.absent(),
              }) => CatalogMetadataEntriesCompanion(
                singletonKey: singletonKey,
                schemaVersion: schemaVersion,
                datasetVersion: datasetVersion,
                installedAt: installedAt,
                lastUpdateCheckAt: lastUpdateCheckAt,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                required int schemaVersion,
                required String datasetVersion,
                required DateTime installedAt,
                Value<DateTime?> lastUpdateCheckAt = const Value.absent(),
              }) => CatalogMetadataEntriesCompanion.insert(
                singletonKey: singletonKey,
                schemaVersion: schemaVersion,
                datasetVersion: datasetVersion,
                installedAt: installedAt,
                lastUpdateCheckAt: lastUpdateCheckAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogMetadataEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AtmDatabase,
      $CatalogMetadataEntriesTable,
      CatalogMetadata,
      $$CatalogMetadataEntriesTableFilterComposer,
      $$CatalogMetadataEntriesTableOrderingComposer,
      $$CatalogMetadataEntriesTableAnnotationComposer,
      $$CatalogMetadataEntriesTableCreateCompanionBuilder,
      $$CatalogMetadataEntriesTableUpdateCompanionBuilder,
      (
        CatalogMetadata,
        BaseReferences<
          _$AtmDatabase,
          $CatalogMetadataEntriesTable,
          CatalogMetadata
        >,
      ),
      CatalogMetadata,
      PrefetchHooks Function()
    >;
typedef $$CatalogBackupEntriesTableCreateCompanionBuilder =
    CatalogBackupEntriesCompanion Function({
      Value<int> singletonKey,
      required String datasetVersion,
      required String manifestJson,
      required Uint8List compressedSnapshot,
      required DateTime createdAt,
    });
typedef $$CatalogBackupEntriesTableUpdateCompanionBuilder =
    CatalogBackupEntriesCompanion Function({
      Value<int> singletonKey,
      Value<String> datasetVersion,
      Value<String> manifestJson,
      Value<Uint8List> compressedSnapshot,
      Value<DateTime> createdAt,
    });

class $$CatalogBackupEntriesTableFilterComposer
    extends Composer<_$AtmDatabase, $CatalogBackupEntriesTable> {
  $$CatalogBackupEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get compressedSnapshot => $composableBuilder(
    column: $table.compressedSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogBackupEntriesTableOrderingComposer
    extends Composer<_$AtmDatabase, $CatalogBackupEntriesTable> {
  $$CatalogBackupEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get compressedSnapshot => $composableBuilder(
    column: $table.compressedSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogBackupEntriesTableAnnotationComposer
    extends Composer<_$AtmDatabase, $CatalogBackupEntriesTable> {
  $$CatalogBackupEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get compressedSnapshot => $composableBuilder(
    column: $table.compressedSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CatalogBackupEntriesTableTableManager
    extends
        RootTableManager<
          _$AtmDatabase,
          $CatalogBackupEntriesTable,
          CatalogBackup,
          $$CatalogBackupEntriesTableFilterComposer,
          $$CatalogBackupEntriesTableOrderingComposer,
          $$CatalogBackupEntriesTableAnnotationComposer,
          $$CatalogBackupEntriesTableCreateCompanionBuilder,
          $$CatalogBackupEntriesTableUpdateCompanionBuilder,
          (
            CatalogBackup,
            BaseReferences<
              _$AtmDatabase,
              $CatalogBackupEntriesTable,
              CatalogBackup
            >,
          ),
          CatalogBackup,
          PrefetchHooks Function()
        > {
  $$CatalogBackupEntriesTableTableManager(
    _$AtmDatabase db,
    $CatalogBackupEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogBackupEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogBackupEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogBackupEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                Value<String> datasetVersion = const Value.absent(),
                Value<String> manifestJson = const Value.absent(),
                Value<Uint8List> compressedSnapshot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CatalogBackupEntriesCompanion(
                singletonKey: singletonKey,
                datasetVersion: datasetVersion,
                manifestJson: manifestJson,
                compressedSnapshot: compressedSnapshot,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                required String datasetVersion,
                required String manifestJson,
                required Uint8List compressedSnapshot,
                required DateTime createdAt,
              }) => CatalogBackupEntriesCompanion.insert(
                singletonKey: singletonKey,
                datasetVersion: datasetVersion,
                manifestJson: manifestJson,
                compressedSnapshot: compressedSnapshot,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogBackupEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AtmDatabase,
      $CatalogBackupEntriesTable,
      CatalogBackup,
      $$CatalogBackupEntriesTableFilterComposer,
      $$CatalogBackupEntriesTableOrderingComposer,
      $$CatalogBackupEntriesTableAnnotationComposer,
      $$CatalogBackupEntriesTableCreateCompanionBuilder,
      $$CatalogBackupEntriesTableUpdateCompanionBuilder,
      (
        CatalogBackup,
        BaseReferences<
          _$AtmDatabase,
          $CatalogBackupEntriesTable,
          CatalogBackup
        >,
      ),
      CatalogBackup,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AtmDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AtmDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AtmDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AtmDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<_$AtmDatabase, $AppPreferencesTable, AppPreference>,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AtmDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppPreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AtmDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$AtmDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;
typedef $$RecentPlacesTableCreateCompanionBuilder =
    RecentPlacesCompanion Function({
      required String label,
      required double latitude,
      required double longitude,
      required DateTime searchedAt,
      Value<int> rowid,
    });
typedef $$RecentPlacesTableUpdateCompanionBuilder =
    RecentPlacesCompanion Function({
      Value<String> label,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> searchedAt,
      Value<int> rowid,
    });

class $$RecentPlacesTableFilterComposer
    extends Composer<_$AtmDatabase, $RecentPlacesTable> {
  $$RecentPlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentPlacesTableOrderingComposer
    extends Composer<_$AtmDatabase, $RecentPlacesTable> {
  $$RecentPlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentPlacesTableAnnotationComposer
    extends Composer<_$AtmDatabase, $RecentPlacesTable> {
  $$RecentPlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentPlacesTableTableManager
    extends
        RootTableManager<
          _$AtmDatabase,
          $RecentPlacesTable,
          StoredRecentPlace,
          $$RecentPlacesTableFilterComposer,
          $$RecentPlacesTableOrderingComposer,
          $$RecentPlacesTableAnnotationComposer,
          $$RecentPlacesTableCreateCompanionBuilder,
          $$RecentPlacesTableUpdateCompanionBuilder,
          (
            StoredRecentPlace,
            BaseReferences<
              _$AtmDatabase,
              $RecentPlacesTable,
              StoredRecentPlace
            >,
          ),
          StoredRecentPlace,
          PrefetchHooks Function()
        > {
  $$RecentPlacesTableTableManager(_$AtmDatabase db, $RecentPlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentPlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentPlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentPlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> label = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentPlacesCompanion(
                label: label,
                latitude: latitude,
                longitude: longitude,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String label,
                required double latitude,
                required double longitude,
                required DateTime searchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentPlacesCompanion.insert(
                label: label,
                latitude: latitude,
                longitude: longitude,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentPlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AtmDatabase,
      $RecentPlacesTable,
      StoredRecentPlace,
      $$RecentPlacesTableFilterComposer,
      $$RecentPlacesTableOrderingComposer,
      $$RecentPlacesTableAnnotationComposer,
      $$RecentPlacesTableCreateCompanionBuilder,
      $$RecentPlacesTableUpdateCompanionBuilder,
      (
        StoredRecentPlace,
        BaseReferences<_$AtmDatabase, $RecentPlacesTable, StoredRecentPlace>,
      ),
      StoredRecentPlace,
      PrefetchHooks Function()
    >;
typedef $$FavoriteSitesTableCreateCompanionBuilder =
    FavoriteSitesCompanion Function({
      required String siteId,
      required DateTime favoritedAt,
      Value<int> rowid,
    });
typedef $$FavoriteSitesTableUpdateCompanionBuilder =
    FavoriteSitesCompanion Function({
      Value<String> siteId,
      Value<DateTime> favoritedAt,
      Value<int> rowid,
    });

class $$FavoriteSitesTableFilterComposer
    extends Composer<_$AtmDatabase, $FavoriteSitesTable> {
  $$FavoriteSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteSitesTableOrderingComposer
    extends Composer<_$AtmDatabase, $FavoriteSitesTable> {
  $$FavoriteSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteSitesTableAnnotationComposer
    extends Composer<_$AtmDatabase, $FavoriteSitesTable> {
  $$FavoriteSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => column,
  );
}

class $$FavoriteSitesTableTableManager
    extends
        RootTableManager<
          _$AtmDatabase,
          $FavoriteSitesTable,
          StoredFavorite,
          $$FavoriteSitesTableFilterComposer,
          $$FavoriteSitesTableOrderingComposer,
          $$FavoriteSitesTableAnnotationComposer,
          $$FavoriteSitesTableCreateCompanionBuilder,
          $$FavoriteSitesTableUpdateCompanionBuilder,
          (
            StoredFavorite,
            BaseReferences<_$AtmDatabase, $FavoriteSitesTable, StoredFavorite>,
          ),
          StoredFavorite,
          PrefetchHooks Function()
        > {
  $$FavoriteSitesTableTableManager(_$AtmDatabase db, $FavoriteSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> siteId = const Value.absent(),
                Value<DateTime> favoritedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteSitesCompanion(
                siteId: siteId,
                favoritedAt: favoritedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String siteId,
                required DateTime favoritedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteSitesCompanion.insert(
                siteId: siteId,
                favoritedAt: favoritedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AtmDatabase,
      $FavoriteSitesTable,
      StoredFavorite,
      $$FavoriteSitesTableFilterComposer,
      $$FavoriteSitesTableOrderingComposer,
      $$FavoriteSitesTableAnnotationComposer,
      $$FavoriteSitesTableCreateCompanionBuilder,
      $$FavoriteSitesTableUpdateCompanionBuilder,
      (
        StoredFavorite,
        BaseReferences<_$AtmDatabase, $FavoriteSitesTable, StoredFavorite>,
      ),
      StoredFavorite,
      PrefetchHooks Function()
    >;

class $AtmDatabaseManager {
  final _$AtmDatabase _db;
  $AtmDatabaseManager(this._db);
  $$AtmSitesTableTableManager get atmSites =>
      $$AtmSitesTableTableManager(_db, _db.atmSites);
  $$CatalogMetadataEntriesTableTableManager get catalogMetadataEntries =>
      $$CatalogMetadataEntriesTableTableManager(
        _db,
        _db.catalogMetadataEntries,
      );
  $$CatalogBackupEntriesTableTableManager get catalogBackupEntries =>
      $$CatalogBackupEntriesTableTableManager(_db, _db.catalogBackupEntries);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$RecentPlacesTableTableManager get recentPlaces =>
      $$RecentPlacesTableTableManager(_db, _db.recentPlaces);
  $$FavoriteSitesTableTableManager get favoriteSites =>
      $$FavoriteSitesTableTableManager(_db, _db.favoriteSites);
}
