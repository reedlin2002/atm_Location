import 'package:atmfinder/location/location_gateway.dart';
import 'package:flutter/widgets.dart';

/// Where the map camera looks. Uses the domain [GeoPoint] so nothing in the
/// core depends on a concrete map SDK.
class MapCameraPosition {
  const MapCameraPosition({required this.target, this.zoom = 15});

  final GeoPoint target;
  final double zoom;
}

/// A single ATM plotted on the map, identified by its stable ATM id so the
/// list and the map can share one selection.
class MapMarker {
  const MapMarker({
    required this.siteId,
    required this.position,
    required this.label,
    this.selected = false,
    this.clusterSiteIds = const [],
  });

  final String siteId;
  final GeoPoint position;
  final String label;
  final bool selected;
  final List<String> clusterSiteIds;

  bool get isCluster => clusterSiteIds.isNotEmpty;
}

/// Everything a [MapAdapter] needs to render, plus the callbacks it raises.
///
/// This is the seam between the domain/UI and whichever map SDK renders the
/// tiles. Production wires a Google Maps implementation; tests wire a fake.
class MapPresentation {
  const MapPresentation({
    required this.camera,
    required this.markers,
    required this.selectedSiteId,
    required this.onMarkerSelected,
    required this.onMapError,
    this.onCameraMoved,
    this.onCameraIdle,
  });

  final MapCameraPosition camera;
  final List<MapMarker> markers;
  final String? selectedSiteId;

  /// Raised when the user taps a marker. Carries the stable ATM id.
  final ValueChanged<String> onMarkerSelected;

  /// Raised when the map cannot initialise or render (missing/invalid API key,
  /// service error). The host degrades to the list + detail flow.
  final VoidCallback onMapError;
  final ValueChanged<MapCameraPosition>? onCameraMoved;
  final VoidCallback? onCameraIdle;
}

/// Renders a map from a [MapPresentation]. Implementations must not leak their
/// SDK's types across this boundary — the host only ever sees Flutter widgets
/// and the domain types above.
abstract interface class MapAdapter {
  Widget buildMap(MapPresentation presentation);
}
