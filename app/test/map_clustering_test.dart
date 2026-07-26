import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/map/map_clustering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('密集 ATM 在相同 zoom 與 viewport 產生可重現且受限的叢集', () {
    final markers = [
      for (var index = 0; index < 120; index += 1)
        MapMarker(
          siteId: 'site-$index',
          position: GeoPoint(
            latitude: 25.0478 + (index % 12) * 0.00005,
            longitude: 121.5170 + (index ~/ 12) * 0.00005,
          ),
          label: 'ATM $index',
        ),
    ];
    const viewport = MapViewport(
      south: 25.03,
      west: 121.50,
      north: 25.06,
      east: 121.54,
    );
    const engine = MapClusterEngine(maxVisibleItems: 50);

    final first = engine.cluster(markers, zoom: 14, viewport: viewport);
    final second = engine.cluster(markers, zoom: 14, viewport: viewport);

    expect(first.length, lessThanOrEqualTo(50));
    expect(first.any((item) => item is MarkerCluster), isTrue);
    expect(
      first.map((item) => item.stableKey),
      second.map((item) => item.stableKey),
    );
    expect(
      first.expand((item) => item.siteIds).toSet(),
      markers.map((marker) => marker.siteId).toSet(),
    );
  });

  test('相機停止後只提示搜尋此區域，明確確認才產生查詢 viewport', () {
    const initial = MapViewport(
      south: 25.03,
      west: 121.50,
      north: 25.06,
      east: 121.54,
    );
    const moved = MapViewport(
      south: 25.05,
      west: 121.52,
      north: 25.08,
      east: 121.56,
    );
    final controller = MapAreaSearchController(initialViewport: initial);

    controller.cameraMoved(moved);
    expect(controller.decision, MapAreaSearchDecision.cameraMoving);
    expect(controller.confirmSearch(), isNull);

    controller.cameraIdle();
    expect(controller.decision, MapAreaSearchDecision.offerSearch);
    expect(controller.confirmedViewport, same(initial));

    expect(controller.confirmSearch(), same(moved));
    expect(controller.confirmedViewport, same(moved));
    expect(controller.decision, MapAreaSearchDecision.currentArea);
  });
}
