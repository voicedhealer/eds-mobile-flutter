import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/favorites_tab.dart';
import '../widgets/comments_tab.dart';
import '../widgets/badges_tab.dart';
import '../widgets/profile_settings_tab.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon Compte')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Vous devez être connecté',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Connectez-vous pour accéder à votre profil'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.push('/login');
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bonjour ${user?.firstName ?? 'Utilisateur'} !'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: 'Favoris'),
              Tab(icon: Icon(Icons.comment), text: 'Avis'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Badges'),
              Tab(icon: Icon(Icons.settings), text: 'Profil'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FavoritesTab(),
            CommentsTab(),
            BadgesTab(),
            ProfileSettingsTab(),
          ],
        ),
      ),
    );
  }
}

