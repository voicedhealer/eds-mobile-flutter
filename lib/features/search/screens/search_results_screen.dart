import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/filter_bar.dart';
import '../widgets/results_overlay.dart';
import '../../establishments/widgets/establishment_card.dart';
import '../../../data/models/establishment.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/services/geolocation_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../map/widgets/map_component.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String envie;
  final String ville; // OBLIGATOIRE maintenant
  final int radiusKm; // Périmètre adaptatif

  const SearchResultsScreen({
    super.key,
    required this.envie,
    required this.ville,
    this.radiusKm = 10,
  });

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GeolocationService _geolocationService = GeolocationService();
  int _currentPage = 1;
  bool _hasMore = true;
  List<Establishment> _allEstablishments = [];
  LatLng? _cityPosition;
  bool _isLoadingCityPosition = false;

  @override
  void initState() {
    super.initState();
    _loadCityPosition();
  }

  Future<void> _loadCityPosition() async {
    if (widget.ville.isEmpty) return;
    
    setState(() {
      _isLoadingCityPosition = true;
    });
    
    try {
      final position = await _geolocationService.getPositionFromCity(widget.ville);
      if (position != null && mounted) {
        setState(() {
          _cityPosition = LatLng(position.latitude, position.longitude);
          _isLoadingCityPosition = false;
        });
      } else {
        setState(() {
          _isLoadingCityPosition = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de la position de la ville: $e');
      setState(() {
        _isLoadingCityPosition = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(filterProvider);
    
    final searchParams = SearchParams(
      envie: widget.envie,
      ville: widget.ville,
      radiusKm: widget.radiusKm,
      filter: filterTypeToString(currentFilter),
      page: _currentPage,
      limit: 15,
    );
    
    final resultsAsync = ref.watch(searchResultsProvider(searchParams));

    return Scaffold(
      body: Stack(
        children: [
          // Carte en arrière-plan
          resultsAsync.when(
            data: (establishments) {
              // Mettre à jour la liste complète
              if (_currentPage == 1) {
                _allEstablishments = establishments;
              } else {
                _allEstablishments.addAll(establishments);
              }
              _hasMore = establishments.length >= searchParams.limit;

              return MapComponent(
                establishments: _allEstablishments,
                searchCenter: _cityPosition,
                radiusKm: widget.radiusKm,
                onMarkerTap: (establishment) {
                  context.push('/establishment/${establishment.slug}');
                },
              );
            },
            loading: () => MapComponent(
              establishments: [],
              searchCenter: _cityPosition,
              radiusKm: widget.radiusKm,
            ),
            error: (error, stack) => MapComponent(
              establishments: [],
              searchCenter: _cityPosition,
              radiusKm: widget.radiusKm,
            ),
          ),
          
          // Barre de recherche en haut
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Envie de ${widget.envie}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              widget.ville,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Rayon : ${widget.radiusKm}km',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      // Ouvrir le filtre
                      ref.read(filterProvider.notifier).setFilter(currentFilter);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Overlay avec les résultats (cards par-dessus la carte)
          resultsAsync.when(
            data: (establishments) {
              if (establishments.isEmpty) {
                return Center(
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
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'Aucun résultat trouvé',
                      message: 'Essayez avec d\'autres critères de recherche',
                    ),
                  ),
                );
              }
              
              return ResultsOverlay(
                establishments: _allEstablishments,
                scrollController: _scrollController,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ErrorState(
                  message: error.toString(),
                  onRetry: () {
                    ref.invalidate(searchResultsProvider(searchParams));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

