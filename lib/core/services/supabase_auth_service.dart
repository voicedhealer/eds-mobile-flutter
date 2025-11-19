import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../data/models/user.dart' as app_models;
import '../../config/supabase_config.dart';

class SupabaseAuthService {
  SupabaseClient? get _supabase => supabase;

  Future<app_models.User?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? favoriteCity,
  }) async {
    if (_supabase == null) return null;
    final response = await _supabase!.auth.signUp(
      email: email,
      password: password,
      data: {
        'user_type': 'user',
        'first_name': firstName,
        'last_name': lastName,
        'favorite_city': favoriteCity,
      },
    );

    if (response.user == null) return null;
    return app_models.User.fromJson(response.user!.toJson());
  }

  Future<app_models.User?> signIn({
    required String email,
    required String password,
  }) async {
    if (_supabase == null) return null;
    final response = await _supabase!.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;
    return app_models.User.fromJson(response.user!.toJson());
  }

  Future<void> signOut() async {
    if (_supabase == null) return;
    await _supabase!.auth.signOut();
  }

  app_models.User? get currentUser {
    if (_supabase == null) return null;
    final session = _supabase!.auth.currentSession;
    if (session?.user == null) return null;
    return app_models.User.fromJson(session!.user.toJson());
  }
}

