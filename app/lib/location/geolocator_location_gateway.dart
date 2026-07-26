import 'package:atmfinder/location/location_gateway.dart';
import 'package:geolocator/geolocator.dart';

/// Foreground-only location gateway backed by the `geolocator` plugin.
///
/// Requests permission at "while in use" scope and never escalates to
/// background access. Any failure — services off, permission denied, or a
/// platform error — degrades to [LocationUnavailable] so the caller can fall
/// back gracefully instead of crashing.
class GeolocatorLocationGateway
    implements LocationGateway, LocationSettingsLauncher {
  const GeolocatorLocationGateway();

  @override
  Future<LocationOutcome> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationServicesDisabled();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationPermissionDenied();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationPermissionDeniedForever();
      }

      final accuracy = await Geolocator.getLocationAccuracy();
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return LocationAvailable(
        GeoPoint(latitude: position.latitude, longitude: position.longitude),
        accuracy: accuracy == LocationAccuracyStatus.reduced
            ? ForegroundLocationAccuracy.approximate
            : ForegroundLocationAccuracy.precise,
      );
    } on Object {
      return const LocationProviderFailure();
    }
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
