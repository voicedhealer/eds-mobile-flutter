import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/establishment.dart';
import '../../config/supabase_config.dart';

final favoritesProvider = FutureProvider<List<Establishment>>((ref) async {
  final client = supabase;
  if (client == null) return [];
  
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  try {
    // Étape 1: Récupérer les IDs des établissements favoris
    final favoritesResponse = await client
        .from('user_favorites')
        .select('establishment_id')
        .eq('user_id', userId);

    if (favoritesResponse is! List || (favoritesResponse as List).isEmpty) {
      return [];
    }

    // Extraire les IDs
    final establishmentIds = (favoritesResponse as List)
        .map((item) => item['establishment_id'] as String)
        .toList();

    // Étape 2: Récupérer les établissements correspondants
    final establishmentsResponse = await client
        .from('establishments')
        .select()
        .inFilter('id', establishmentIds);

    final favorites = (establishmentsResponse as List)
        .map((json) => Establishment.fromJson(json))
        .toList();

    return favorites;
  } catch (e) {
    print('❌ Erreur lors de la récupération des favoris: $e');
    return [];
  }
});

final favoriteIdsProvider = FutureProvider<Set<String>>((ref) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.map((e) => e.id).toSet();
});

