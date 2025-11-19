import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/services/geolocation_service.dart';
import '../../../data/models/establishment.dart';
import '../widgets/map_component.dart';
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
    if (widget.envie != null && widget.ville != null && widget.ville!.isNotEmpty) {
      final searchParams = SearchParams(
        envie: widget.envie!,
        ville: widget.ville!,
        filter: 'popular',
      );
      final resultsAsync = ref.watch(searchResultsProvider(searchParams));
      
      return Scaffold(
        appBar: AppBar(
          title: Text('Carte - ${widget.envie}'),
        ),
        body: resultsAsync.when(
          data: (establishments) => Stack(
            children: [
              MapComponent(
                establishments: establishments,
                initialPosition: _userLocation,
                onMarkerTap: _handleMarkerTap,
              ),
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
          loading: () => Stack(
            children: [
              MapComponent(
                establishments: [],
                initialPosition: _userLocation,
                onMarkerTap: _handleMarkerTap,
              ),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          error: (error, stack) {
            // Afficher un message d'erreur plus explicite
            String errorMessage = 'Une erreur est survenue';
            final errorString = error.toString();
            
            if (errorString.contains('NotInitializedError')) {
              errorMessage = 'Supabase n\'est pas initialisé.\n\nVérifiez que votre fichier .env contient:\n- SUPABASE_URL\n- SUPABASE_ANON_KEY';
            } else if (errorString.contains('RAILWAY_API_URL') || errorString.contains('Railway')) {
              errorMessage = 'L\'API Railway n\'est pas configurée.\n\nVérifiez que votre fichier .env contient:\n- RAILWAY_API_URL';
            } else {
              errorMessage = errorString.replaceAll('Instance of \'', '').replaceAll('\'', '');
            }
            
            return Stack(
              children: [
                MapComponent(
                  establishments: [],
                  initialPosition: _userLocation,
                  onMarkerTap: _handleMarkerTap,
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(searchResultsProvider(searchParams));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Si pas de recherche, afficher juste la carte vide
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des établissements'),
      ),
      body: MapComponent(
        establishments: [],
        initialPosition: _userLocation,
        onMarkerTap: _handleMarkerTap,
      ),
    );
  }
}

