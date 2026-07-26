import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:drift/drift.dart';

class FavoriteAtm {
  const FavoriteAtm({
    required this.site,
    required this.favoritedAt,
    required this.retired,
  });

  final AtmSite site;
  final DateTime favoritedAt;
  final bool retired;
}

abstract interface class FavoritesRepository {
  Future<List<FavoriteAtm>> list();

  Future<void> add(String siteId);

  Future<void> remove(String siteId);

  Future<bool> contains(String siteId);

  Future<void> clear();
}

class DriftFavoritesRepository implements FavoritesRepository {
  const DriftFavoritesRepository(this._database, this._lookup);

  final AtmDatabase _database;
  final AtmSiteLookup _lookup;

  @override
  Future<List<FavoriteAtm>> list() async {
    final rows = await (_database.select(
      _database.favoriteSites,
    )..orderBy([(row) => OrderingTerm.desc(row.favoritedAt)])).get();
    final favorites = <FavoriteAtm>[];
    for (final row in rows) {
      final active = await _lookup.findById(row.siteId);
      final site =
          active ?? await _lookup.findById(row.siteId, includeRetired: true);
      if (site != null) {
        favorites.add(
          FavoriteAtm(
            site: site,
            favoritedAt: row.favoritedAt.toUtc(),
            retired: active == null,
          ),
        );
      }
    }
    return List.unmodifiable(favorites);
  }

  @override
  Future<void> add(String siteId) async {
    final id = siteId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(siteId, 'siteId');
    }
    await _database
        .into(_database.favoriteSites)
        .insertOnConflictUpdate(
          FavoriteSitesCompanion.insert(
            siteId: id,
            favoritedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> remove(String siteId) {
    return (_database.delete(
      _database.favoriteSites,
    )..where((row) => row.siteId.equals(siteId))).go();
  }

  @override
  Future<bool> contains(String siteId) async {
    final row = await (_database.select(
      _database.favoriteSites,
    )..where((favorite) => favorite.siteId.equals(siteId))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> clear() => _database.delete(_database.favoriteSites).go();
}
