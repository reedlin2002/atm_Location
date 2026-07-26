import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/favorites/favorites.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('使用者可從詳細資料收藏與取消收藏 ATM', (tester) async {
    final database = AtmDatabase(NativeDatabase.memory());
    final site = AtmSite(
      id: 'site-1',
      institutionCode: '004',
      institutionName: '臺灣銀行',
      placeName: '館前分行',
      placeCategory: PlaceCategory.bank,
      displayAddress: '臺北市中正區館前路 49 號',
      position: const GeoPoint(latitude: 25.045, longitude: 121.515),
    );
    final repository = DriftFavoritesRepository(
      database,
      _SingleSiteLookup(site),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(repository),
          catalogSnapshotProvider.overrideWith((ref) async => null),
          catalogIsStaleProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          locale: const Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AtmDetailPage(site: site),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('favorite-toggle-site-1')));
    await tester.pumpAndSettle();
    expect(await repository.contains('site-1'), isTrue);

    await tester.tap(find.byKey(const ValueKey('favorite-toggle-site-1')));
    await tester.pumpAndSettle();
    expect(await repository.contains('site-1'), isFalse);
  });
}

class _SingleSiteLookup implements AtmSiteLookup {
  const _SingleSiteLookup(this.site);

  final AtmSite site;

  @override
  Future<AtmSite?> findById(String id, {bool includeRetired = false}) async {
    return id == site.id ? site : null;
  }
}
