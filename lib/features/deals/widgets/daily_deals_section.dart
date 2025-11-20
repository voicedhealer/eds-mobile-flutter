import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/daily_deal.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/daily_deal_repository.dart';
import 'daily_deal_card.dart';

final dailyDealsProvider = FutureProvider<List<DailyDeal>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final radius = ref.watch(searchRadiusProvider);
  
  final repository = DailyDealRepository();
  return repository.getAllDeals(
    city: city?.name,
    radiusKm: radius,
    limit: 12,
  );
});

class DailyDealsSection extends ConsumerWidget {
  const DailyDealsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(dailyDealsProvider);
    final city = ref.watch(currentCityProvider);
    final radius = ref.watch(searchRadiusProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[50]!,
            Colors.white,
            Colors.pink[50]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec icône et titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Icône avec gradient
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF751F), Color(0xFFFF1FA9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bons plans du jour',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Profitez des offres exclusives près de chez vous',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Indicateur de localisation
                          if (city != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                city.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton "Voir tous" (desktop) - scroll vers le bas de la section
                dealsAsync.when(
                  data: (deals) {
                    if (deals.length >= 12) {
                      return TextButton.icon(
                        onPressed: () {
                          // Scroll vers le bas de la section pour voir tous les bons plans
                          // On scroll vers le bas de la liste horizontale
                          // Pas besoin de scroll supplémentaire, la section est déjà visible
                        },
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: const Text('Voir tous'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF751F),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Scroll horizontal MANUEL des bons plans
          dealsAsync.when(
            data: (deals) {
              if (deals.isEmpty) {
                return _buildEmptyState(context, city, radius);
              }
              
              return SizedBox(
                height: 520, // Hauteur fixe pour les cards avec flip
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 350, // Largeur fixe pour chaque card
                      margin: const EdgeInsets.only(right: 16),
                      child: DailyDealCard(
                        deal: deals[index],
                        redirectToEstablishment: true,
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
                        ref.invalidate(dailyDealsProvider);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bouton "Voir tous" mobile
          dealsAsync.when(
            data: (deals) {
              if (deals.length >= 12) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Les bons plans sont déjà visibles dans le scroll horizontal
                        // Pas besoin d'action supplémentaire
                      },
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      label: const Text(
                        'Voir tous les bons plans',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xFFFF751F),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, City? city, int radius) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Icône
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[100]!, Colors.pink[100]!],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎁', style: TextStyle(fontSize: 48)),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Message principal
          Text(
            'Aucun bon plan près de ${city?.name ?? 'vous'}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF171717),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Aucune offre disponible dans un rayon de ${radius}km.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '💡 Essayez d\'augmenter le rayon de recherche ou de changer de ville',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // CTA Inscription
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[50]!, Colors.pink[50]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💙', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Ne ratez aucune offre !',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Inscrivez-vous pour suivre vos établissements favoris et recevoir des notifications sur les nouveaux bons plans',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth');
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    'Créer un compte gratuitement',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFFFF751F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

