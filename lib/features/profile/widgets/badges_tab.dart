import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class BadgesTab extends ConsumerWidget {
  const BadgesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Karma Points
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Points Karma',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${user?.karmaPoints ?? 0}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF751F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Badges
          const Text(
            'Mes Badges',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Liste des badges
          if (user?.gamificationBadges != null &&
              (user!.gamificationBadges as List).isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: (user.gamificationBadges as List).length,
              itemBuilder: (context, index) {
                final badge = (user.gamificationBadges as List)[index];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getBadgeIcon(badge['type'] ?? badge['label']),
                        size: 48,
                        color: _getBadgeColor(badge['type'] ?? badge['label']),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge['label'] ?? 'Badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucun badge débloqué pour le moment'),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getBadgeIcon(String? type) {
    if (type == null) return Icons.star;
    
    final typeLower = type.toLowerCase();
    if (typeLower.contains('curieux') || typeLower.contains('search')) {
      return Icons.search;
    }
    if (typeLower.contains('explorateur') || typeLower.contains('explore')) {
      return Icons.explore;
    }
    if (typeLower.contains('ambassadeur') || typeLower.contains('people')) {
      return Icons.people;
    }
    if (typeLower.contains('firework') || typeLower.contains('celebration')) {
      return Icons.celebration;
    }
    return Icons.star;
  }

  Color _getBadgeColor(String? type) {
    if (type == null) return Colors.grey;
    
    final typeLower = type.toLowerCase();
    if (typeLower.contains('curieux') || typeLower.contains('search')) {
      return Colors.blue;
    }
    if (typeLower.contains('explorateur') || typeLower.contains('explore')) {
      return Colors.green;
    }
    if (typeLower.contains('ambassadeur') || typeLower.contains('people')) {
      return Colors.purple;
    }
    if (typeLower.contains('firework') || typeLower.contains('celebration')) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}

