import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/establishment.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/establishment_repository.dart';
import '../../establishments/widgets/establishment_card.dart';

final bestPlacesProvider = FutureProvider<List<Establishment>>((ref) async {
  final locationState = ref.watch(locationProvider);
  final city = locationState.currentCity;
  final radius = locationState.searchRadius;
  
  if (city == null) return [];
  
  final repository = EstablishmentRepository();
  return repository.getByLocation(
    latitude: city.latitude,
    longitude: city.longitude,
    radiusKm: radius,
    limit: 12, // Limiter à 12 établissements
  );
});

class BestPlacesSection extends ConsumerWidget {
  const BestPlacesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishmentsAsync = ref.watch(bestPlacesProvider);
    final locationState = ref.watch(locationProvider);
    final city = locationState.currentCity;
    final radius = locationState.searchRadius;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et localisation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nos meilleurs endroits',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Indicateur de localisation
                      if (city != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFFFF751F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${city.name} • Rayon ${radius}km',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Lien "Voir tous"
                TextButton(
                  onPressed: () {
                    context.push('/search');
                  },
                  child: const Text(
                    'Voir tous →',
                    style: TextStyle(
                      color: Color(0xFFFF751F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Scroll horizontal MANUEL (pas automatique)
          establishmentsAsync.when(
            data: (establishments) {
              if (establishments.isEmpty) {
                return _buildEmptyState(context, city, radius);
              }
              
              return SizedBox(
                height: 400, // Hauteur fixe pour les cards
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: establishments.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 320, // Largeur fixe pour chaque card
                      margin: const EdgeInsets.only(right: 16),
                      child: EstablishmentCard(
                        establishment: establishments[index],
                        onTap: () => context.push('/establishment/${establishments[index].slug}'),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Color(0xFFFF751F),
                ),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(bestPlacesProvider);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, City? city, int radius) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun établissement trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'dans un rayon de ${radius}km autour de ${city?.name ?? 'cette zone'}.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Essayez d\'augmenter le rayon de recherche',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}


