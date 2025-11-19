import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/establishment.dart';

class MapComponent extends StatefulWidget {
  final List<Establishment> establishments;
  final LatLng? initialPosition;
  final Function(Establishment)? onMarkerTap;
  final int? radiusKm; // Périmètre de recherche en km
  final LatLng? searchCenter; // Centre de recherche (ville)

  const MapComponent({
    super.key,
    required this.establishments,
    this.initialPosition,
    this.onMarkerTap,
    this.radiusKm,
    this.searchCenter,
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createCircle();
  }

  @override
  void didUpdateWidget(MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.establishments != widget.establishments ||
        oldWidget.radiusKm != widget.radiusKm ||
        oldWidget.searchCenter != widget.searchCenter) {
      _createMarkers();
      _createCircle();
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

  void _createCircle() {
    _circles.clear();
    if (widget.searchCenter != null && widget.radiusKm != null && widget.radiusKm! > 0) {
      _circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: widget.searchCenter!,
          radius: widget.radiusKm! * 1000, // Convertir km en mètres
          fillColor: const Color(0xFFFF751F).withOpacity(0.2),
          strokeColor: const Color(0xFFFF751F),
          strokeWidth: 2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser le centre de recherche si disponible, sinon la position initiale
    final centerPosition = widget.searchCenter ??
        widget.initialPosition ??
        (widget.establishments.isNotEmpty &&
                widget.establishments.first.latitude != null &&
                widget.establishments.first.longitude != null
            ? LatLng(
                widget.establishments.first.latitude!,
                widget.establishments.first.longitude!,
              )
            : const LatLng(48.8566, 2.3522)); // Paris par défaut

    // Ajuster le zoom selon le rayon de recherche
    double zoom = 12;
    if (widget.radiusKm != null) {
      if (widget.radiusKm! <= 1) {
        zoom = 14; // Zoom élevé pour 1km
      } else if (widget.radiusKm! <= 5) {
        zoom = 13;
      } else if (widget.radiusKm! <= 10) {
        zoom = 12;
      } else if (widget.radiusKm! <= 20) {
        zoom = 11;
      } else {
        zoom = 10; // Zoom faible pour grandes distances
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: centerPosition,
        zoom: zoom,
      ),
      markers: _markers,
      circles: _circles,
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

