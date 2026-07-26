import 'dart:math' as math;

import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';

class MapViewport {
  const MapViewport({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;

  bool contains(GeoPoint point) =>
      point.latitude >= south &&
      point.latitude <= north &&
      point.longitude >= west &&
      point.longitude <= east;

  @override
  bool operator ==(Object other) =>
      other is MapViewport &&
      other.south == south &&
      other.west == west &&
      other.north == north &&
      other.east == east;

  @override
  int get hashCode => Object.hash(south, west, north, east);
}

enum MapAreaSearchDecision { currentArea, cameraMoving, offerSearch }

class MapAreaSearchController {
  MapAreaSearchController({required MapViewport initialViewport})
    : _confirmedViewport = initialViewport;

  MapViewport _confirmedViewport;
  MapViewport? _pendingViewport;
  MapAreaSearchDecision _decision = MapAreaSearchDecision.currentArea;

  MapViewport get confirmedViewport => _confirmedViewport;
  MapAreaSearchDecision get decision => _decision;

  void cameraMoved(MapViewport viewport) {
    _pendingViewport = viewport;
    _decision = MapAreaSearchDecision.cameraMoving;
  }

  void cameraIdle() {
    final pending = _pendingViewport;
    _decision = pending != null && pending != _confirmedViewport
        ? MapAreaSearchDecision.offerSearch
        : MapAreaSearchDecision.currentArea;
  }

  MapViewport? confirmSearch() {
    if (_decision != MapAreaSearchDecision.offerSearch) {
      return null;
    }
    final viewport = _pendingViewport;
    if (viewport == null) {
      return null;
    }
    _confirmedViewport = viewport;
    _decision = MapAreaSearchDecision.currentArea;
    return viewport;
  }
}

sealed class MapClusterItem {
  const MapClusterItem();

  String get stableKey;
  List<String> get siteIds;
  GeoPoint get position;
}

class SingleMapMarker extends MapClusterItem {
  const SingleMapMarker(this.marker);

  final MapMarker marker;

  @override
  String get stableKey => 'site:${marker.siteId}';

  @override
  List<String> get siteIds => [marker.siteId];

  @override
  GeoPoint get position => marker.position;
}

class MarkerCluster extends MapClusterItem {
  const MarkerCluster({
    required this.stableKey,
    required this.siteIds,
    required this.position,
  });

  @override
  final String stableKey;
  @override
  final List<String> siteIds;
  @override
  final GeoPoint position;
}

class MapClusterEngine {
  const MapClusterEngine({this.maxVisibleItems = 80});

  final int maxVisibleItems;

  List<MapClusterItem> cluster(
    Iterable<MapMarker> markers, {
    required double zoom,
    required MapViewport viewport,
  }) {
    if (maxVisibleItems <= 0) {
      return const [];
    }
    final visible =
        markers.where((marker) => viewport.contains(marker.position)).toList()
          ..sort((left, right) => left.siteId.compareTo(right.siteId));
    if (visible.isEmpty) {
      return const [];
    }

    var cellDegrees = 360 / math.pow(2, zoom.clamp(0, 22) + 4);
    var items = _group(visible, cellDegrees);
    while (items.length > maxVisibleItems && cellDegrees < 180) {
      cellDegrees *= 2;
      items = _group(visible, cellDegrees);
    }
    return List.unmodifiable(items);
  }

  static List<MapClusterItem> _group(
    List<MapMarker> markers,
    double cellDegrees,
  ) {
    final buckets = <String, List<MapMarker>>{};
    for (final marker in markers) {
      final row = ((marker.position.latitude + 90) / cellDegrees).floor();
      final column = ((marker.position.longitude + 180) / cellDegrees).floor();
      buckets.putIfAbsent('$row:$column', () => []).add(marker);
    }
    final keys = buckets.keys.toList()..sort();
    return [
      for (final key in keys)
        if (buckets[key]!.length == 1)
          SingleMapMarker(buckets[key]!.single)
        else
          _clusterFor(buckets[key]!),
    ];
  }

  static MarkerCluster _clusterFor(List<MapMarker> markers) {
    final ids = markers.map((marker) => marker.siteId).toList()..sort();
    final latitude =
        markers.fold<double>(
          0,
          (sum, marker) => sum + marker.position.latitude,
        ) /
        markers.length;
    final longitude =
        markers.fold<double>(
          0,
          (sum, marker) => sum + marker.position.longitude,
        ) /
        markers.length;
    return MarkerCluster(
      stableKey: 'cluster:${ids.join(',')}',
      siteIds: List.unmodifiable(ids),
      position: GeoPoint(latitude: latitude, longitude: longitude),
    );
  }
}
