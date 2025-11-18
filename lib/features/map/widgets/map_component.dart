import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/establishment.dart';

class MapComponent extends StatefulWidget {
  final List<Establishment> establishments;
  final LatLng? initialPosition;
  final Function(Establishment)? onMarkerTap;

  const MapComponent({
    super.key,
    required this.establishments,
    this.initialPosition,
    this.onMarkerTap,
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.establishments != widget.establishments) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    _markers = widget.establishments
        .where((e) => e.latitude != null && e.longitude != null)
        .map((establishment) {
      return Marker(
        markerId: MarkerId(establishment.id),
        position: LatLng(establishment.latitude!, establishment.longitude!),
        infoWindow: InfoWindow(
          title: establishment.name,
          snippet: establishment.city,
        ),
        onTap: () {
          widget.onMarkerTap?.call(establishment);
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.initialPosition ??
        (widget.establishments.isNotEmpty &&
                widget.establishments.first.latitude != null &&
                widget.establishments.first.longitude != null
            ? LatLng(
                widget.establishments.first.latitude!,
                widget.establishments.first.longitude!,
              )
            : const LatLng(48.8566, 2.3522)); // Paris par défaut

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: _markers,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

