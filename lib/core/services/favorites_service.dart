import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> isFavorite(String establishmentId, String userId) async {
    final response = await _supabase
        .from('user_favorites')
        .select()
        .eq('user_id', userId)
        .eq('establishment_id', establishmentId)
        .maybeSingle();

    return response != null;
  }

  Future<void> addFavorite(String establishmentId, String userId) async {
    await _supabase.from('user_favorites').insert({
      'user_id': userId,
      'establishment_id': establishmentId,
    });
  }

  Future<void> removeFavorite(String establishmentId, String userId) async {
    await _supabase
        .from('user_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('establishment_id', establishmentId);
  }

  Future<void> toggleFavorite(String establishmentId, String userId) async {
    final isFav = await isFavorite(establishmentId, userId);
    if (isFav) {
      await removeFavorite(establishmentId, userId);
    } else {
      await addFavorite(establishmentId, userId);
    }
  }
}

