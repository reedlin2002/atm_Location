import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/location/location_gateway.dart';

sealed class HomeSearchResult {
  const HomeSearchResult();
}

class HomeSearchIdle extends HomeSearchResult {
  const HomeSearchIdle();
}

class HomeSearchSuccess extends HomeSearchResult {
  const HomeSearchSuccess(this.sites, {required this.radiusMeters});

  final List<NearbyAtmSite> sites;
  final double radiusMeters;
}

class HomeSearchFailure extends HomeSearchResult {
  const HomeSearchFailure();
}

class HomeSearchLocationDenied extends HomeSearchResult {
  const HomeSearchLocationDenied();
}

class HomeSearchLocationDeniedForever extends HomeSearchResult {
  const HomeSearchLocationDeniedForever();
}

class HomeSearchLocationServicesDisabled extends HomeSearchResult {
  const HomeSearchLocationServicesDisabled();
}

class HomeSearchLocationProviderFailure extends HomeSearchResult {
  const HomeSearchLocationProviderFailure();
}

class SearchCoordinator {
  const SearchCoordinator(this._catalog, this._locationGateway);

  static const _minimumUsefulResults = 20;
  static const _radiusStepsMeters = <double>[1000, 3000, 5000, 10000];

  final AtmCatalog _catalog;
  final LocationGateway _locationGateway;

  Future<HomeSearchResult> loadNearby({bool expanded = false}) async {
    try {
      final installResult = await _catalog.ensureBundledCatalogInstalled();
      if (installResult is CatalogInstallFailed) {
        return const HomeSearchFailure();
      }

      final location = await _locationGateway.currentPosition();
      switch (location) {
        case LocationPermissionDenied():
          return const HomeSearchLocationDenied();
        case LocationPermissionDeniedForever():
          return const HomeSearchLocationDeniedForever();
        case LocationServicesDisabled():
          return const HomeSearchLocationServicesDisabled();
        case LocationProviderFailure() || LocationUnavailable():
          return const HomeSearchLocationProviderFailure();
        case LocationAvailable():
          break;
      }

      final radii = expanded
          ? [..._radiusStepsMeters, 25000.0]
          : _radiusStepsMeters;
      for (final radius in radii) {
        final sites = await _catalog.findNearby(
          location.position,
          radiusMeters: radius,
          limit: 50,
        );
        if (sites.length >= _minimumUsefulResults || radius == radii.last) {
          return HomeSearchSuccess(sites, radiusMeters: radius);
        }
      }
      throw StateError('Radius ladder must contain at least one step');
    } on Object {
      return const HomeSearchFailure();
    }
  }
}
