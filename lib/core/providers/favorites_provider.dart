import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/establishment.dart';
import '../../config/supabase_config.dart';

final favoritesProvider = FutureProvider<List<Establishment>>((ref) async {
  final client = supabase;
  if (client == null) return [];
  
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await client
      .from('user_favorites')
      .select('establishments(*)')
      .eq('user_id', userId);

  final favorites = (response as List)
      .map((item) => Establishment.fromJson(item['establishments']))
      .toList();

  return favorites;
});

final favoriteIdsProvider = FutureProvider<Set<String>>((ref) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.map((e) => e.id).toSet();
});

