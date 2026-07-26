import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/catalog/catalog_asset_source.dart';
import 'package:atmfinder/catalog/catalog_update.dart';
import 'package:atmfinder/diagnostics/crash_diagnostics.dart';
import 'package:atmfinder/external/external_actions.dart';
import 'package:atmfinder/favorites/favorites.dart';
import 'package:atmfinder/home/home_search.dart';
import 'package:atmfinder/location/geolocator_location_gateway.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/google_maps_adapter.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/onboarding/onboarding_preferences.dart';
import 'package:atmfinder/search/recent_places.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/search/place_resolver.dart';
import 'package:atmfinder/settings/local_settings_manager.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.datasetVersion,
    required this.installedAt,
    required this.lastRefreshedAt,
  });

  final String datasetVersion;
  final DateTime installedAt;
  final DateTime lastRefreshedAt;
}

final clockProvider = Provider<UpdateClock>((ref) => const _SystemClock());

class _SystemClock implements UpdateClock {
  const _SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

final catalogSnapshotProvider = FutureProvider<CatalogSnapshot?>((ref) async {
  final db = ref.watch(atmDatabaseProvider);
  final metadata = await (db.select(
    db.catalogMetadataEntries,
  )..limit(1)).getSingleOrNull();
  if (metadata == null) return null;
  return CatalogSnapshot(
    datasetVersion: metadata.datasetVersion,
    installedAt: metadata.installedAt,
    lastRefreshedAt: metadata.lastUpdateCheckAt ?? metadata.installedAt,
  );
});

final catalogIsStaleProvider = FutureProvider<bool>((ref) async {
  final snapshot = await ref.watch(catalogSnapshotProvider.future);
  if (snapshot == null) return false;
  final now = ref.watch(clockProvider).nowUtc();
  return now.difference(snapshot.lastRefreshedAt).inDays > 30;
});

final databaseExecutorProvider = Provider<QueryExecutor>((ref) {
  return driftDatabase(name: 'atm_catalog');
});

final catalogAssetSourceProvider = Provider<CatalogAssetSource>(
  (ref) => const RootBundleCatalogAssetSource(),
);

final locationGatewayProvider = Provider<LocationGateway>(
  (ref) => const GeolocatorLocationGateway(),
);

/// Production map surface. Overridden with a fake in widget tests so the SDK is
/// never exercised there (issue #24 acceptance).
final mapAdapterProvider = Provider<MapAdapter>(
  (ref) => const GoogleMapsAdapter(),
);

final atmDatabaseProvider = Provider<AtmDatabase>((ref) {
  final database = AtmDatabase(ref.watch(databaseExecutorProvider));
  ref.onDispose(database.close);
  return database;
});

final driftAtmCatalogProvider = Provider<DriftAtmCatalog>(
  (ref) => DriftAtmCatalog(
    ref.watch(atmDatabaseProvider),
    ref.watch(catalogAssetSourceProvider),
  ),
);

final atmCatalogProvider = Provider<AtmCatalog>(
  (ref) => ref.watch(driftAtmCatalogProvider),
);

final atmSiteLookupProvider = Provider<AtmSiteLookup>(
  (ref) => ref.watch(driftAtmCatalogProvider),
);

final onboardingPreferencesProvider = Provider<OnboardingPreferences>(
  (ref) => DriftOnboardingPreferences(ref.watch(atmDatabaseProvider)),
);

final recentPlacesRepositoryProvider = Provider<RecentPlacesRepository>(
  (ref) => DriftRecentPlacesRepository(ref.watch(atmDatabaseProvider)),
);

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>(
  (ref) => DriftUserSettingsRepository(ref.watch(atmDatabaseProvider)),
);

final localSettingsManagerProvider = Provider<LocalSettingsManager>(
  (ref) => LocalSettingsManager(
    ref.watch(atmDatabaseProvider),
    ref.watch(userSettingsRepositoryProvider),
  ),
);

final diagnosticsConsentRepositoryProvider =
    Provider<DiagnosticsConsentRepository>(
      (ref) =>
          DriftDiagnosticsConsentRepository(ref.watch(atmDatabaseProvider)),
    );

final crashDiagnosticsProvider = Provider<CrashDiagnosticsProvider?>(
  (ref) => null,
);

final crashDiagnosticsBoundaryProvider = Provider<CrashDiagnosticsBoundary>(
  (ref) => CrashDiagnosticsBoundary(
    consent: ref.watch(diagnosticsConsentRepositoryProvider),
    provider: ref.watch(crashDiagnosticsProvider),
  ),
);

final diagnosticsConsentProvider =
    AsyncNotifierProvider<DiagnosticsConsentController, bool>(
      DiagnosticsConsentController.new,
    );

class DiagnosticsConsentController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(diagnosticsConsentRepositoryProvider).isEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await ref.read(crashDiagnosticsBoundaryProvider).setEnabled(enabled);
    state = AsyncData(enabled);
  }
}

final userSettingsProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettings>(
      UserSettingsController.new,
    );

class UserSettingsController extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() {
    return ref.watch(userSettingsRepositoryProvider).load();
  }

  Future<void> replace(UserSettings settings) async {
    await ref.read(userSettingsRepositoryProvider).save(settings);
    state = AsyncData(settings);
  }

  Future<void> clearFilters() async {
    state = AsyncData(
      await ref.read(localSettingsManagerProvider).clearFilters(),
    );
  }
}

final atmResultPolicyProvider = Provider<AtmResultPolicy>(
  (ref) => const AtmResultPolicy(),
);

const _supportEmail = String.fromEnvironment(
  'ATM_SUPPORT_EMAIL',
  defaultValue: 'support@example.com',
);

final externalActionGatewayProvider = Provider<ExternalActionGateway>(
  (ref) => const PlatformExternalActionGateway(),
);

final externalPayloadBuilderProvider = Provider<AtmExternalPayloadBuilder>(
  (ref) => const AtmExternalPayloadBuilder(
    supportEmail: _supportEmail,
    appVersion: '1.0.0+1',
  ),
);

final externalActionsControllerProvider = Provider<ExternalActionsController>(
  (ref) => ExternalActionsController(
    gateway: ref.watch(externalActionGatewayProvider),
    payloads: ref.watch(externalPayloadBuilderProvider),
  ),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => DriftFavoritesRepository(
    ref.watch(atmDatabaseProvider),
    ref.watch(atmSiteLookupProvider),
  ),
);

final favoritesProvider =
    AsyncNotifierProvider<FavoritesController, List<FavoriteAtm>>(
      FavoritesController.new,
    );

class FavoritesController extends AsyncNotifier<List<FavoriteAtm>> {
  @override
  Future<List<FavoriteAtm>> build() {
    return ref.watch(favoritesRepositoryProvider).list();
  }

  Future<void> toggle(String siteId) async {
    final repository = ref.read(favoritesRepositoryProvider);
    if (await repository.contains(siteId)) {
      await repository.remove(siteId);
    } else {
      await repository.add(siteId);
    }
    state = AsyncData(await repository.list());
  }

  Future<void> clear() async {
    final repository = ref.read(favoritesRepositoryProvider);
    await repository.clear();
    state = const AsyncData([]);
  }
}

final placeResolverGatewayProvider = Provider<PlaceResolverGateway?>(
  (ref) => null,
);

final placeResolverProvider = Provider<PlaceResolver>((ref) {
  final gateway = ref.watch(placeResolverGatewayProvider);
  if (gateway == null) {
    return const UnavailablePlaceResolver();
  }
  return SessionQuotaAwarePlaceResolver(gateway: gateway);
});

final placeSearchCoordinatorProvider = Provider<PlaceSearchCoordinator>(
  (ref) => PlaceSearchCoordinator(
    catalog: ref.watch(atmCatalogProvider),
    recentPlaces: ref.watch(recentPlacesRepositoryProvider),
    resolver: ref.watch(placeResolverProvider),
  ),
);

sealed class AppStartupResult {
  const AppStartupResult();
}

class AppStartupReady extends AppStartupResult {
  const AppStartupReady({required this.onboardingComplete});

  final bool onboardingComplete;
}

class AppStartupCatalogFailure extends AppStartupResult {
  const AppStartupCatalogFailure();
}

final appStartupProvider = FutureProvider<AppStartupResult>((ref) async {
  final installResult = await ref
      .watch(atmCatalogProvider)
      .ensureBundledCatalogInstalled();
  if (installResult is CatalogInstallFailed) {
    return const AppStartupCatalogFailure();
  }
  return AppStartupReady(
    onboardingComplete: await ref
        .watch(onboardingPreferencesProvider)
        .isComplete(),
  );
});

final searchCoordinatorProvider = Provider<SearchCoordinator>(
  (ref) => SearchCoordinator(
    ref.watch(atmCatalogProvider),
    ref.watch(locationGatewayProvider),
  ),
);

final homeSearchProvider =
    NotifierProvider<HomeSearchController, AsyncValue<HomeSearchResult>>(
      HomeSearchController.new,
    );

class HomeSearchController extends Notifier<AsyncValue<HomeSearchResult>> {
  @override
  AsyncValue<HomeSearchResult> build() {
    return const AsyncData(HomeSearchIdle());
  }

  Future<void> findNearby({bool expanded = false}) async {
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(searchCoordinatorProvider).loadNearby(expanded: expanded),
    );
  }

  Future<void> searchArea(GeoPoint center) async {
    state = const AsyncLoading();
    try {
      final sites = await ref
          .read(atmCatalogProvider)
          .findNearby(center, radiusMeters: 10000, limit: 50);
      state = AsyncData(HomeSearchSuccess(sites, radiusMeters: 10000));
    } on Object {
      state = const AsyncData(HomeSearchFailure());
    }
  }

  Future<void> openAppSettings() async {
    final gateway = ref.read(locationGatewayProvider);
    if (gateway is LocationSettingsLauncher) {
      await (gateway as LocationSettingsLauncher).openAppSettings();
    }
  }

  Future<void> openLocationSettings() async {
    final gateway = ref.read(locationGatewayProvider);
    if (gateway is LocationSettingsLauncher) {
      await (gateway as LocationSettingsLauncher).openLocationSettings();
    }
  }

  void reset() {
    state = const AsyncData(HomeSearchIdle());
  }
}
