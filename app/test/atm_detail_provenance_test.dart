import 'dart:io';

import 'package:atmfinder/app.dart';
import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/catalog_update.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/map/nearby_map_page.dart';
import 'package:atmfinder/onboarding/onboarding_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Cycle 1: tracer bullet ──────────────────────────────────────────────
  // Click list item → see ATM facts + catalog version + at least one 未知 capability.
  testWidgets(
    '點擊清單項目後詳情顯示 ATM 事實、catalog 版本與至少一個未知能力',
    (tester) async {
      final database = AtmDatabase(NativeDatabase.memory());
      final bundledJson = File(
        'assets/catalog/baseline_fixture.json',
      ).readAsStringSync();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            atmDatabaseProvider.overrideWithValue(database),
            catalogAssetSourceProvider.overrideWithValue(
              _StringCatalogAssetSource(bundledJson),
            ),
            onboardingPreferencesProvider.overrideWithValue(
              const _CompletedOnboardingPreferences(),
            ),
            locationGatewayProvider.overrideWithValue(
              const _FixedLocationGateway(
                GeoPoint(latitude: 25.0478, longitude: 121.5170),
              ),
            ),
            mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
            selectedSiteProvider.overrideWith(SelectedSiteController.new),
            mapAvailableProvider.overrideWith(MapAvailabilityController.new),
          ],
          child: const AtmFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('找我附近'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('臺灣銀行'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('atm-summary-detail-atm-bank-001')),
      );
      await tester.pumpAndSettle();

      // ATM identity
      expect(find.text('臺灣銀行館前分行'), findsOneWidget);
      expect(find.text('臺北市中正區館前路 49 號'), findsOneWidget);

      // At least one capability shown as unknown (fixture declares no capabilities)
      expect(find.text('存款功能：未知'), findsOneWidget);

      // Catalog version from the installed fixture
      expect(find.textContaining('fixture-2026-07-25'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  // ── Cycle 2: catalog version + refreshed date in standalone detail ──────
  testWidgets('ATM 詳情顯示 catalog 版本與最近更新日期', (tester) async {
    final site = _minimalSite('atm-meta-001');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogSnapshotProvider.overrideWith(
            (_) async => CatalogSnapshot(
              datasetVersion: '2026-07-25-v1',
              installedAt: DateTime.utc(2026, 7, 25),
              lastRefreshedAt: DateTime.utc(2026, 7, 25),
            ),
          ),
          catalogIsStaleProvider.overrideWith((_) async => false),
        ],
        child: _detailApp(site),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('資料集版本：2026-07-25-v1'), findsOneWidget);
    expect(find.text('最近更新：2026-07-25'), findsOneWidget);
  });

  // ── Cycle 3: distance when origin available ──────────────────────────────
  testWidgets('有原點時 ATM 詳情顯示距離', (tester) async {
    final site = _minimalSite('atm-dist-001');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogSnapshotProvider.overrideWith((_) async => null),
          catalogIsStaleProvider.overrideWith((_) async => false),
        ],
        child: _detailApp(site, distanceMeters: 100),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('距離：100 公尺'), findsOneWidget);
  });

  testWidgets('無原點時 ATM 詳情不顯示距離', (tester) async {
    final site = _minimalSite('atm-nodist-001');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogSnapshotProvider.overrideWith((_) async => null),
          catalogIsStaleProvider.overrideWith((_) async => false),
        ],
        child: _detailApp(site),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('距離：'), findsNothing);
  });

  // ── Cycle 4: stale warning on detail ─────────────────────────────────────
  testWidgets('Catalog 超過 30 天未更新時詳情顯示舊資料警示', (tester) async {
    final site = _minimalSite('atm-stale-001');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogSnapshotProvider.overrideWith(
            (_) async => CatalogSnapshot(
              datasetVersion: 'old-version',
              installedAt: DateTime.utc(2026, 6, 1),
              lastRefreshedAt: DateTime.utc(2026, 6, 1),
            ),
          ),
          catalogIsStaleProvider.overrideWith((_) async => true),
        ],
        child: _detailApp(site),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ATM 資料超過 30 天未更新，可能有遺漏的最新變化'), findsOneWidget);
  });

  testWidgets('30 天內更新的 catalog 詳情不顯示舊資料警示', (tester) async {
    final site = _minimalSite('atm-fresh-001');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogSnapshotProvider.overrideWith((_) async => null),
          catalogIsStaleProvider.overrideWith((_) async => false),
        ],
        child: _detailApp(site),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('30 天'), findsNothing);
  });

  // ── Cycle 5: stale warning on home page via injectable clock ─────────────
  testWidgets(
    'Catalog 超過 30 天未更新時首頁顯示舊資料警示但不阻止使用',
    (tester) async {
      final database = AtmDatabase(NativeDatabase.memory());
      final bundledJson = File(
        'assets/catalog/baseline_fixture.json',
      ).readAsStringSync();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            atmDatabaseProvider.overrideWithValue(database),
            catalogAssetSourceProvider.overrideWithValue(
              _StringCatalogAssetSource(bundledJson),
            ),
            onboardingPreferencesProvider.overrideWithValue(
              const _CompletedOnboardingPreferences(),
            ),
            locationGatewayProvider.overrideWithValue(
              const _FixedLocationGateway(
                GeoPoint(latitude: 25.0478, longitude: 121.5170),
              ),
            ),
            mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
            selectedSiteProvider.overrideWith(SelectedSiteController.new),
            mapAvailableProvider.overrideWith(MapAvailabilityController.new),
            // Clock is 31 days ahead of when the fixture will be installed (now)
            clockProvider.overrideWithValue(
              _FakeClock(DateTime.now().toUtc().add(const Duration(days: 31))),
            ),
          ],
          child: const AtmFinderApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Stale warning visible on home
      expect(find.text('ATM 資料超過 30 天未更新，可能有遺漏的最新變化'), findsOneWidget);

      // Search still works despite warning
      await tester.tap(find.text('找我附近'));
      await tester.pumpAndSettle();

      expect(find.text('臺灣銀行'), findsOneWidget);
      expect(find.text('ATM 資料超過 30 天未更新，可能有遺漏的最新變化'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}

// ── Helpers ─────────────────────────────────────────────────────────────────

AtmSite _minimalSite(String id) => AtmSite(
  id: id,
  institutionCode: '004',
  institutionName: '臺灣銀行',
  placeName: '館前分行',
  placeCategory: PlaceCategory.bank,
  county: '臺北市',
  displayAddress: '臺北市中正區館前路49號',
  position: const GeoPoint(latitude: 25.0461, longitude: 121.5141),
);

Widget _detailApp(AtmSite site, {double? distanceMeters}) {
  return MaterialApp(
    locale: const Locale('zh', 'TW'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AtmDetailPage(
      site: site,
      distanceMeters: distanceMeters,
      showFavoriteAction: false,
    ),
  );
}

class _StringCatalogAssetSource implements CatalogAssetSource {
  const _StringCatalogAssetSource(this.json);

  final String json;

  @override
  Future<String> loadBundledCatalog() async => json;
}

class _StubMapAdapter implements MapAdapter {
  const _StubMapAdapter();

  @override
  Widget buildMap(MapPresentation presentation) => const SizedBox.shrink();
}

class _FixedLocationGateway implements LocationGateway {
  const _FixedLocationGateway(this.position);

  final GeoPoint position;

  @override
  Future<LocationOutcome> currentPosition() async =>
      LocationAvailable(position);
}

class _CompletedOnboardingPreferences implements OnboardingPreferences {
  const _CompletedOnboardingPreferences();

  @override
  Future<bool> isComplete() async => true;

  @override
  Future<void> markComplete() async {}
}

class _FakeClock implements UpdateClock {
  const _FakeClock(this._now);

  final DateTime _now;

  @override
  DateTime nowUtc() => _now;
}
