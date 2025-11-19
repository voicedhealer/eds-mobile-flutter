import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../models/user_comment.dart';

class CommentsRepository {
  SupabaseClient? get _supabase => supabase;

  Future<List<UserComment>> getUserComments() async {
    if (_supabase == null) return [];
    
    final userId = _supabase!.auth.currentUser?.id;
    if (userId == null) throw Exception('Non authentifié');

    try {
      final response = await _supabase!
          .from('user_comments')
          .select('''
            *,
            establishment:establishments!user_comments_establishment_id_fkey (
              id,
              name,
              slug,
              image_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response == null) return [];
      
      return (response as List)
          .map((json) => UserComment.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur récupération commentaires: $e');
      return [];
    }
  }

  Future<void> createComment({
    required String establishmentId,
    required String content,
    int? rating,
  }) async {
    if (_supabase == null) throw Exception('Supabase non initialisé');
    
    final userId = _supabase!.auth.currentUser?.id;
    if (userId == null) throw Exception('Non authentifié');

    await _supabase!.from('user_comments').insert({
      'user_id': userId,
      'establishment_id': establishmentId,
      'content': content,
      'rating': rating,
    });
  }

  Future<void> deleteComment(String commentId) async {
    if (_supabase == null) throw Exception('Supabase non initialisé');
    
    await _supabase!.from('user_comments').delete().eq('id', commentId);
  }
}

