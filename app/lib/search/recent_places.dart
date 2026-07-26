import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:drift/drift.dart';

class RecentPlace {
  const RecentPlace({
    required this.label,
    required this.position,
    required this.searchedAt,
  });

  final String label;
  final GeoPoint position;
  final DateTime searchedAt;
}

abstract interface class RecentPlacesRepository {
  Future<List<RecentPlace>> list();

  Future<void> save(RecentPlace place);

  Future<void> delete(String label);

  Future<void> clear();
}

class DriftRecentPlacesRepository implements RecentPlacesRepository {
  const DriftRecentPlacesRepository(this._database);

  static const _maximumPlaces = 10;

  final AtmDatabase _database;

  @override
  Future<List<RecentPlace>> list() async {
    final rows =
        await (_database.select(_database.recentPlaces)
              ..orderBy([
                (row) => OrderingTerm.desc(row.searchedAt),
                (row) => OrderingTerm.asc(row.label),
              ])
              ..limit(_maximumPlaces))
            .get();
    return List.unmodifiable(rows.map(_toDomain));
  }

  @override
  Future<void> save(RecentPlace place) async {
    final label = place.label.trim();
    if (label.isEmpty ||
        !_validLatitude(place.position.latitude) ||
        !_validLongitude(place.position.longitude)) {
      throw ArgumentError(
        'Recent place must have a label and valid coordinate',
      );
    }
    await _database.transaction(() async {
      await _database
          .into(_database.recentPlaces)
          .insertOnConflictUpdate(
            RecentPlacesCompanion.insert(
              label: label,
              latitude: place.position.latitude,
              longitude: place.position.longitude,
              searchedAt: place.searchedAt.toUtc(),
            ),
          );
      final rows =
          await (_database.select(_database.recentPlaces)..orderBy([
                (row) => OrderingTerm.desc(row.searchedAt),
                (row) => OrderingTerm.asc(row.label),
              ]))
              .get();
      final labelsToEvict = rows
          .skip(_maximumPlaces)
          .map((row) => row.label)
          .toList(growable: false);
      if (labelsToEvict.isNotEmpty) {
        await (_database.delete(
          _database.recentPlaces,
        )..where((row) => row.label.isIn(labelsToEvict))).go();
      }
    });
  }

  @override
  Future<void> delete(String label) {
    return (_database.delete(
      _database.recentPlaces,
    )..where((row) => row.label.equals(label))).go();
  }

  @override
  Future<void> clear() => _database.delete(_database.recentPlaces).go();

  static RecentPlace _toDomain(StoredRecentPlace row) {
    return RecentPlace(
      label: row.label,
      position: GeoPoint(latitude: row.latitude, longitude: row.longitude),
      searchedAt: row.searchedAt.toUtc(),
    );
  }

  static bool _validLatitude(double value) =>
      value.isFinite && value >= -90 && value <= 90;

  static bool _validLongitude(double value) =>
      value.isFinite && value >= -180 && value <= 180;
}
