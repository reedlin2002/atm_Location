import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/google_maps_adapter.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wiring smoke test for the production adapter. It confirms the adapter builds
/// a widget from a [MapPresentation] without ever touching real Google
/// services (no pump, no platform view). Rendering an actual Google map needs a
/// configured API key (issue #23) and belongs in an on-device integration test.
void main() {
  test('GoogleMapsAdapter builds a widget without calling Google services', () {
    const adapter = GoogleMapsAdapter();

    final widget = adapter.buildMap(
      MapPresentation(
        camera: const MapCameraPosition(
          target: GeoPoint(latitude: 25.0478, longitude: 121.5180),
        ),
        markers: const [
          MapMarker(
            siteId: 'atm-bank-001',
            position: GeoPoint(latitude: 25.0478, longitude: 121.5180),
            label: '臺灣銀行',
          ),
        ],
        selectedSiteId: null,
        onMarkerSelected: (_) {},
        onMapError: () {},
      ),
    );

    expect(widget, isA<StatefulWidget>());
  });
}
