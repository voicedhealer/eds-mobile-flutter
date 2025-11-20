import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';

class StickyTitle extends ConsumerWidget {
  final VoidCallback onLocationTap;

  const StickyTitle({
    super.key,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.currentCity;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Row(
      children: [
        Text(
          'Envie2Sortir',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'LemonTuesday',
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        // Icône de localisation
        IconButton(
          icon: Stack(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
              if (currentCity != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: onLocationTap,
          tooltip: currentCity != null
              ? '${currentCity.name} • ${locationState.searchRadius}km'
              : 'Changer la localisation',
        ),
        // Bouton connexion/inscription
        if (isAuthenticated)
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.push('/profile'),
            tooltip: 'Mon profil',
          )
        else
          IconButton(
            icon: const Icon(
              Icons.login,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.push('/login'),
            tooltip: 'Se connecter',
          ),
      ],
    );
  }
}

