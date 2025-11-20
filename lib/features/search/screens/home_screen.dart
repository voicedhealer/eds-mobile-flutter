import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/envie_search_bar.dart';
import '../../location/widgets/location_modal.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../home/widgets/best_places_section.dart';
import '../../events/widgets/upcoming_events_section.dart';
import '../../deals/widgets/daily_deals_section.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showLocationModal = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _dealsSectionKey = GlobalKey();
  
  void _handleLocationTap() {
    setState(() {
      _showLocationModal = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Configurer la status bar pour qu'elle soit transparente avec du texte blanc
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero Section avec titre sticky
                SliverAppBar(
                  expandedHeight: 320.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 0, // Pas de toolbar, on utilise un SliverPersistentHeader séparé
                  flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Container(
                          decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                                Color(0xFFFF751F),
                                Color(0xFFFF1FA9),
                                Color(0xFFFF3A3A),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.white.withOpacity(0.1),
                              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // En-tête avec titre, localisation et bouton connexion
                    Row(
                      children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Text(
                      'Envie2Sortir',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                            fontFamily: 'LemonTuesday',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Icône de localisation
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final locationState = ref.watch(locationProvider);
                                          final currentCity = locationState.currentCity;
                                          
                                          return IconButton(
                                            icon: Stack(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                ),
                                                if (currentCity != null)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            onPressed: _handleLocationTap,
                                            tooltip: currentCity != null
                                                ? '${currentCity.name} • ${locationState.searchRadius}km'
                                                : 'Changer la localisation',
                                          );
                                        },
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
                    // Barre de recherche
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EnvieSearchBar(isInteractive: true),
                    ),
                    const SizedBox(height: 20),
                    // Boutons d'action rapide
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
                          Consumer(
                            builder: (context, ref, child) {
                              return _QuickActionButton(
                                icon: Icons.event,
                                label: 'Événements',
                                onTap: () {
                                  final locationState = ref.read(locationProvider);
                                  final city = locationState.currentCity;
                                  context.push('/events${city != null ? '?city=${city.name}' : ''}');
                                },
                              );
                            },
                          ),
                          _QuickActionButton(
                            icon: Icons.local_offer,
                            label: 'Bons plans',
                            onTap: () {
                              // Scroll vers la section "Bons plans du jour"
                              final dealsContext = _dealsSectionKey.currentContext;
                              if (dealsContext != null) {
                                Scrollable.ensureVisible(
                                  dealsContext,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
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
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Contenu principal
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Section "Nos meilleurs endroits"
                      const BestPlacesSection(),
                      // Section "Événements à venir"
                      const UpcomingEventsSection(),
                      // Section "Bons plans du jour"
                      DailyDealsSection(key: _dealsSectionKey),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Modal de localisation
          LocationModal(
            isOpen: _showLocationModal,
            onClose: () {
              setState(() {
                _showLocationModal = false;
              });
            },
          ),
        ],
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
