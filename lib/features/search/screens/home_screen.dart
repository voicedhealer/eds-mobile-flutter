import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/envie_search_bar.dart';
import '../../establishments/widgets/establishment_card.dart';
import '../../../core/services/geolocation_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/repositories/establishment_repository.dart';
import '../../../data/models/establishment.dart';

final popularEstablishmentsProvider = FutureProvider<List<Establishment>>((ref) async {
  try {
    final repository = EstablishmentRepository();
    // Récupérer la ville de l'utilisateur ou utiliser une ville par défaut
    final geolocationService = GeolocationService();
    String? city;
    
    // Timeout pour éviter que la géolocalisation bloque
    try {
      city = await geolocationService.getCurrentCity()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      print('📍 Ville détectée: $city');
    } catch (e) {
      print('⚠️ Erreur géolocalisation: $e');
    }
    
    // Si une ville est détectée, chercher les établissements de cette ville
    if (city != null && city.isNotEmpty) {
      try {
        final establishments = await repository.getByCity(city)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          print('⏱️ Timeout lors de la récupération des établissements');
          return [];
        });
        
        // Si on trouve des établissements dans la ville, les retourner
        if (establishments.isNotEmpty) {
          return establishments;
        }
        
        // Sinon, fallback sur les établissements populaires
        print('ℹ️ Aucun établissement trouvé à $city, chargement des établissements populaires');
        return await repository.getPopular(limit: 20);
      } catch (e) {
        print('❌ Erreur lors de la récupération: $e');
        // En cas d'erreur, essayer quand même de charger les populaires
        return await repository.getPopular(limit: 20);
      }
    } else {
      // Si pas de ville détectée, charger les établissements populaires
      print('ℹ️ Aucune ville détectée, chargement des établissements populaires');
      return await repository.getPopular(limit: 20);
    }
  } catch (e) {
    print('Error in popularEstablishmentsProvider: $e');
    return [];
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularEstablishmentsAsync = ref.watch(popularEstablishmentsProvider);

    // Configurer la status bar pour qu'elle soit transparente avec du texte blanc
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Icônes blanches pour iOS
        statusBarBrightness: Brightness.dark, // Texte sombre pour Android
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section avec gradient qui couvre toute la hauteur
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF751F),
                      const Color(0xFFFF1FA9),
                      const Color(0xFFFF3A3A),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // En-tête avec titre et bouton connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // Espace pour équilibrer
                        Expanded(
                          child: Text(
                            'Envie2Sortir',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              // Utilisez 'LemonTuesday' une fois le fichier de police ajouté
                              // fontFamily: 'LemonTuesday',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Bouton connexion/inscription
                        Consumer(
                          builder: (context, ref, child) {
                            final isAuthenticated = ref.watch(isAuthenticatedProvider);
                            if (isAuthenticated) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.push('/profile');
                                  },
                                  tooltip: 'Mon profil',
                                ),
                              );
                            }
                            // Si non connecté, afficher une icône de connexion
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.login,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  context.push('/login');
                                },
                                tooltip: 'Se connecter',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EnvieSearchBar(isInteractive: true),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _QuickActionButton(
                            icon: Icons.map,
                            label: 'Carte',
                            onTap: () => context.push('/map'),
                          ),
                          _QuickActionButton(
                            icon: Icons.event,
                            label: 'Événements',
                            onTap: () => context.push('/events'),
                          ),
                          _QuickActionButton(
                            icon: Icons.local_offer,
                            label: 'Bons plans',
                            onTap: () {
                              // TODO: Implémenter la navigation vers les bons plans
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bons plans - À venir'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          _QuickActionButton(
                            icon: Icons.favorite,
                            label: 'Favoris',
                            onTap: () => context.push('/favorites'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Découvrez près de chez vous',
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => context.push('/map'),
                          child: const Text('Voir la carte'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    popularEstablishmentsAsync.when(
                      data: (establishments) {
                        if (establishments.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Aucun établissement trouvé près de vous.\nUtilisez la recherche pour découvrir des lieux !',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: establishments.take(6).map((establishment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EstablishmentCard(
                                establishment: establishment,
                                onTap: () => context.push('/establishment/${establishment.slug}'),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('Erreur: $error'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

