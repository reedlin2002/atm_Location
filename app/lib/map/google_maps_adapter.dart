import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Production [MapAdapter] backed by Google Maps Flutter.
///
/// This is the ONLY file that imports the Google Maps SDK. Everything else —
/// domain, catalog/repository, and the [NearbyMapPage] host — depends only on
/// [MapAdapter] and the domain types, keeping the SDK swappable and the core
/// testable without real Google services.
class GoogleMapsAdapter implements MapAdapter {
  const GoogleMapsAdapter();

  @override
  Widget buildMap(MapPresentation presentation) {
    return _GoogleMapView(presentation: presentation);
  }
}

class _GoogleMapView extends StatefulWidget {
  const _GoogleMapView({required this.presentation});

  final MapPresentation presentation;

  @override
  State<_GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<_GoogleMapView> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(_GoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedId = widget.presentation.selectedSiteId;
    if (selectedId != oldWidget.presentation.selectedSiteId &&
        selectedId != null) {
      _focusOn(selectedId);
    }
  }

  void _focusOn(String siteId) {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    for (final marker in widget.presentation.markers) {
      if (marker.siteId == siteId) {
        controller.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(marker.position.latitude, marker.position.longitude),
          ),
        );
        return;
      }
    }
  }

  Set<Marker> _buildMarkers() {
    return {
      for (final marker in widget.presentation.markers)
        Marker(
          markerId: MarkerId(marker.siteId),
          position: LatLng(marker.position.latitude, marker.position.longitude),
          infoWindow: InfoWindow(title: marker.label),
          onTap: () => widget.presentation.onMarkerSelected(marker.siteId),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.presentation.camera;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(camera.target.latitude, camera.target.longitude),
        zoom: camera.zoom,
      ),
      markers: _buildMarkers(),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onCameraMove: (position) {
        widget.presentation.onCameraMoved?.call(
          MapCameraPosition(
            target: GeoPoint(
              latitude: position.target.latitude,
              longitude: position.target.longitude,
            ),
            zoom: position.zoom,
          ),
        );
      },
      onCameraIdle: () => widget.presentation.onCameraIdle?.call(),
      onMapCreated: (controller) {
        _controller = controller;
        final selectedId = widget.presentation.selectedSiteId;
        if (selectedId != null) {
          _focusOn(selectedId);
        }
      },
    );
  }
}
