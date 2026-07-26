import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/search/recent_places.dart';

class PlaceCandidate {
  const PlaceCandidate({
    required this.label,
    required this.position,
    required this.countryCode,
  });

  final String label;
  final GeoPoint position;
  final String countryCode;

  bool get isInTaiwan => countryCode.toUpperCase() == 'TW';
}

sealed class PlaceResolution {
  const PlaceResolution();
}

class PlaceCandidates extends PlaceResolution {
  const PlaceCandidates(this.values);

  final List<PlaceCandidate> values;
}

class PlaceNoResults extends PlaceResolution {
  const PlaceNoResults();
}

class PlaceResolverOffline extends PlaceResolution {
  const PlaceResolverOffline();
}

class PlaceResolverUnavailable extends PlaceResolution {
  const PlaceResolverUnavailable();
}

class PlaceResolverQuotaExceeded extends PlaceResolution {
  const PlaceResolverQuotaExceeded();
}

class PlaceResolverFailure extends PlaceResolution {
  const PlaceResolverFailure();
}

class PlaceOutsideTaiwanUnsupported extends PlaceResolution {
  const PlaceOutsideTaiwanUnsupported();
}

abstract interface class PlaceResolver {
  Future<PlaceResolution> resolve(String query);
}

class PlaceResolverRequest {
  const PlaceResolverRequest({required this.query, required this.sessionToken});

  final String query;
  final String sessionToken;
}

/// Provider boundary for online place implementations. Provider-specific
/// request/response types must be translated before crossing this interface.
abstract interface class PlaceResolverGateway {
  Future<PlaceResolution> resolve(PlaceResolverRequest request);
}

abstract interface class SessionManagedPlaceResolver implements PlaceResolver {
  void endSession();
}

typedef PlaceResolverDelay = Future<void> Function(Duration duration);
typedef PlaceResolverNow = DateTime Function();
typedef PlaceSessionTokenFactory = String Function();

/// Debounces requests within one selection session and locally cools down after
/// a quota response so repeated UI actions cannot continue spending quota.
class SessionQuotaAwarePlaceResolver implements SessionManagedPlaceResolver {
  SessionQuotaAwarePlaceResolver({
    required this.gateway,
    this.debounce = const Duration(milliseconds: 300),
    this.quotaCooldown = const Duration(minutes: 1),
    PlaceResolverDelay? delay,
    PlaceResolverNow? now,
    PlaceSessionTokenFactory? sessionTokenFactory,
  }) : delay = delay ?? Future<void>.delayed,
       now = now ?? DateTime.now,
       sessionTokenFactory =
           sessionTokenFactory ?? _defaultPlaceSessionTokenFactory;

  final PlaceResolverGateway gateway;
  final Duration debounce;
  final Duration quotaCooldown;
  final PlaceResolverDelay delay;
  final PlaceResolverNow now;
  final PlaceSessionTokenFactory sessionTokenFactory;

  int _generation = 0;
  String? _sessionToken;
  DateTime? _quotaBlockedUntil;

  @override
  Future<PlaceResolution> resolve(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const PlaceNoResults();
    }
    final requestedAt = now();
    if (_quotaBlockedUntil case final blockedUntil?
        when requestedAt.isBefore(blockedUntil)) {
      return const PlaceResolverQuotaExceeded();
    }

    final generation = ++_generation;
    final sessionToken = _sessionToken ??= sessionTokenFactory();
    await delay(debounce);
    if (generation != _generation) {
      return const PlaceNoResults();
    }
    final afterDebounce = now();
    if (_quotaBlockedUntil case final blockedUntil?
        when afterDebounce.isBefore(blockedUntil)) {
      return const PlaceResolverQuotaExceeded();
    }

    try {
      final result = await gateway.resolve(
        PlaceResolverRequest(query: normalized, sessionToken: sessionToken),
      );
      if (result is PlaceResolverQuotaExceeded) {
        _quotaBlockedUntil = afterDebounce.add(quotaCooldown);
      }
      return result;
    } on Object {
      return const PlaceResolverFailure();
    }
  }

  @override
  void endSession() {
    _generation += 1;
    _sessionToken = null;
  }

  static String _defaultPlaceSessionTokenFactory() {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    return 'place-$timestamp';
  }
}

class UnavailablePlaceResolver implements PlaceResolver {
  const UnavailablePlaceResolver();

  @override
  Future<PlaceResolution> resolve(String query) async {
    return const PlaceResolverUnavailable();
  }
}

class PlaceSearchCoordinator {
  const PlaceSearchCoordinator({
    required this.catalog,
    required this.recentPlaces,
    required this.resolver,
  });

  final AtmCatalog catalog;
  final RecentPlacesRepository recentPlaces;
  final PlaceResolver resolver;

  Future<PlaceResolution> resolve(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const PlaceNoResults();
    }
    try {
      final result = await resolver.resolve(normalized);
      if (result case PlaceCandidates(:final values)) {
        final supported = values
            .where((candidate) => candidate.isInTaiwan)
            .toList(growable: false);
        if (supported.isEmpty && values.isNotEmpty) {
          return const PlaceOutsideTaiwanUnsupported();
        }
        return PlaceCandidates(List.unmodifiable(supported));
      }
      return result;
    } on Object {
      return const PlaceResolverFailure();
    }
  }

  Future<List<NearbyAtmSite>> select(PlaceCandidate candidate) async {
    if (!candidate.isInTaiwan) {
      return const [];
    }
    await recentPlaces.save(
      RecentPlace(
        label: candidate.label,
        position: candidate.position,
        searchedAt: DateTime.now().toUtc(),
      ),
    );
    if (resolver is SessionManagedPlaceResolver) {
      (resolver as SessionManagedPlaceResolver).endSession();
    }
    return catalog.findNearby(
      candidate.position,
      radiusMeters: 10000,
      limit: 50,
    );
  }
}
