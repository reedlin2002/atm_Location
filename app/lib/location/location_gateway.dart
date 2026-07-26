class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

enum ForegroundLocationAccuracy { precise, approximate }

sealed class LocationOutcome {
  const LocationOutcome();
}

class LocationAvailable extends LocationOutcome {
  const LocationAvailable(
    this.position, {
    this.accuracy = ForegroundLocationAccuracy.precise,
  });

  final GeoPoint position;
  final ForegroundLocationAccuracy accuracy;
}

class LocationUnavailable extends LocationOutcome {
  const LocationUnavailable();
}

class LocationPermissionDenied extends LocationOutcome {
  const LocationPermissionDenied();
}

class LocationPermissionDeniedForever extends LocationOutcome {
  const LocationPermissionDeniedForever();
}

class LocationServicesDisabled extends LocationOutcome {
  const LocationServicesDisabled();
}

class LocationProviderFailure extends LocationOutcome {
  const LocationProviderFailure();
}

abstract interface class LocationGateway {
  Future<LocationOutcome> currentPosition();
}

abstract interface class LocationSettingsLauncher {
  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();
}

class UnavailableLocationGateway implements LocationGateway {
  const UnavailableLocationGateway();

  @override
  Future<LocationOutcome> currentPosition() async {
    return const LocationProviderFailure();
  }
}
