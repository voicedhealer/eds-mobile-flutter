import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/services/geolocation_service.dart';
import '../../../data/models/establishment.dart';
import '../widgets/map_component.dart';
import '../../establishments/screens/establishment_detail_screen.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? envie;
  final String? ville;

  const MapScreen({
    super.key,
    this.envie,
    this.ville,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final GeolocationService _geolocationService = GeolocationService();
  LatLng? _userLocation;
  List<Establishment> _establishments = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final position = await _geolocationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _handleMarkerTap(Establishment establishment) {
    context.push('/establishment/${establishment.slug}');
  }

  @override
  Widget build(BuildContext context) {
    List<Establishment> establishments = [];

    if (widget.envie != null) {
      final searchParams = SearchParams(
        envie: widget.envie!,
        ville: widget.ville,
        filter: 'popular',
      );
      final resultsAsync = ref.watch(searchResultsProvider(searchParams));
      
      resultsAsync.when(
        data: (data) {
          establishments = data;
        },
        loading: () {},
        error: (_, __) {},
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.envie != null
            ? 'Carte - ${widget.envie}'
            : 'Carte des établissements'),
      ),
      body: Stack(
        children: [
          MapComponent(
            establishments: establishments,
            initialPosition: _userLocation,
            onMarkerTap: _handleMarkerTap,
          ),
          if (widget.envie != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${establishments.length} établissement${establishments.length > 1 ? 's' : ''} trouvé${establishments.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

