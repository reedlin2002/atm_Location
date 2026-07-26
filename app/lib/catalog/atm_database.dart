import 'package:drift/drift.dart';

part 'atm_database.g.dart';

@DataClassName('StoredAtmSite')
class AtmSites extends Table {
  TextColumn get id => text()();
  TextColumn get institutionCode => text()();
  TextColumn get institutionName => text()();
  TextColumn get placeName => text()();
  TextColumn get placeCategory => text()();
  TextColumn get county => text().withDefault(const Constant(''))();
  TextColumn get displayAddress => text()();
  TextColumn get normalizedAddress => text().withDefault(const Constant(''))();
  TextColumn get district => text().withDefault(const Constant(''))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get coordinateEvidenceSource => text().nullable()();
  TextColumn get coordinateEvidenceDate => text().nullable()();
  TextColumn get coordinateEvidenceConfidence => text().nullable()();
  TextColumn get placeCategoryEvidenceSource => text().nullable()();
  TextColumn get placeCategoryEvidenceDate => text().nullable()();
  TextColumn get placeCategoryEvidenceConfidence => text().nullable()();
  TextColumn get capabilitiesJson => text().withDefault(const Constant('{}'))();
  TextColumn get locationType =>
      text().withDefault(const Constant('unknown'))();
  TextColumn get locationTypeEvidenceSource => text().nullable()();
  TextColumn get locationTypeEvidenceDate => text().nullable()();
  TextColumn get locationTypeEvidenceConfidence => text().nullable()();
  TextColumn get accessScheduleJson => text().nullable()();
  TextColumn get accessEvidenceSource => text().nullable()();
  TextColumn get accessEvidenceDate => text().nullable()();
  TextColumn get accessEvidenceConfidence => text().nullable()();
  TextColumn get lastSeenDate => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CatalogMetadata')
class CatalogMetadataEntries extends Table {
  IntColumn get singletonKey => integer().withDefault(const Constant(1))();
  IntColumn get schemaVersion => integer()();
  TextColumn get datasetVersion => text()();
  DateTimeColumn get installedAt => dateTime()();
  DateTimeColumn get lastUpdateCheckAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {singletonKey};
}

@DataClassName('CatalogBackup')
class CatalogBackupEntries extends Table {
  IntColumn get singletonKey => integer().withDefault(const Constant(1))();
  TextColumn get datasetVersion => text()();
  TextColumn get manifestJson => text()();
  BlobColumn get compressedSnapshot => blob()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {singletonKey};
}

@DataClassName('AppPreference')
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('StoredRecentPlace')
class RecentPlaces extends Table {
  TextColumn get label => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {label};
}

@DataClassName('StoredFavorite')
class FavoriteSites extends Table {
  TextColumn get siteId => text()();
  DateTimeColumn get favoritedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {siteId};
}

@DriftDatabase(
  tables: [
    AtmSites,
    CatalogMetadataEntries,
    CatalogBackupEntries,
    AppPreferences,
    RecentPlaces,
    FavoriteSites,
  ],
)
class AtmDatabase extends _$AtmDatabase {
  AtmDatabase(super.executor);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE INDEX atm_sites_geo_active '
        'ON atm_sites (active, latitude, longitude)',
      );
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement('''
          CREATE TABLE atm_sites_v2 (
            id TEXT NOT NULL PRIMARY KEY,
            institution_code TEXT NOT NULL,
            institution_name TEXT NOT NULL,
            place_name TEXT NOT NULL,
            place_category TEXT NOT NULL,
            county TEXT NOT NULL DEFAULT '',
            display_address TEXT NOT NULL,
            latitude REAL NULL,
            longitude REAL NULL,
            active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
          )
        ''');
        await customStatement('''
          INSERT INTO atm_sites_v2 (
            id,
            institution_code,
            institution_name,
            place_name,
            place_category,
            county,
            display_address,
            latitude,
            longitude,
            active
          )
          SELECT
            id,
            institution_code,
            institution_name,
            place_name,
            place_category,
            '',
            display_address,
            latitude,
            longitude,
            active
          FROM atm_sites
        ''');
        await customStatement('DROP TABLE atm_sites');
        await customStatement('ALTER TABLE atm_sites_v2 RENAME TO atm_sites');
        await customStatement(
          'CREATE INDEX atm_sites_geo_active '
          'ON atm_sites (active, latitude, longitude)',
        );
      }
      if (from < 3) {
        await migrator.addColumn(atmSites, atmSites.coordinateEvidenceSource);
        await migrator.addColumn(atmSites, atmSites.coordinateEvidenceDate);
        await migrator.addColumn(
          atmSites,
          atmSites.coordinateEvidenceConfidence,
        );
        await migrator.addColumn(
          atmSites,
          atmSites.placeCategoryEvidenceSource,
        );
        await migrator.addColumn(atmSites, atmSites.placeCategoryEvidenceDate);
        await migrator.addColumn(
          atmSites,
          atmSites.placeCategoryEvidenceConfidence,
        );
      }
      if (from < 4) {
        await migrator.addColumn(atmSites, atmSites.capabilitiesJson);
        await migrator.addColumn(atmSites, atmSites.locationType);
        await migrator.addColumn(atmSites, atmSites.locationTypeEvidenceSource);
        await migrator.addColumn(atmSites, atmSites.locationTypeEvidenceDate);
        await migrator.addColumn(
          atmSites,
          atmSites.locationTypeEvidenceConfidence,
        );
      }
      if (from < 5) {
        await migrator.addColumn(
          catalogMetadataEntries,
          catalogMetadataEntries.lastUpdateCheckAt,
        );
        await migrator.createTable(catalogBackupEntries);
      }
      if (from < 6) {
        await migrator.addColumn(atmSites, atmSites.lastSeenDate);
      }
      if (from < 7) {
        await migrator.createTable(appPreferences);
      }
      if (from < 8) {
        await migrator.addColumn(atmSites, atmSites.normalizedAddress);
        await migrator.addColumn(atmSites, atmSites.district);
      }
      if (from < 9) {
        await migrator.createTable(recentPlaces);
      }
      if (from < 10) {
        await migrator.createTable(favoriteSites);
      }
      if (from < 11) {
        await migrator.addColumn(atmSites, atmSites.accessScheduleJson);
        await migrator.addColumn(atmSites, atmSites.accessEvidenceSource);
        await migrator.addColumn(atmSites, atmSites.accessEvidenceDate);
        await migrator.addColumn(atmSites, atmSites.accessEvidenceConfidence);
      }
    },
  );
}
