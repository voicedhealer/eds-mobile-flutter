import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<User?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? favoriteCity,
  }) async {
    final response = await _supabase.auth.signUp(
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
    return User.fromJson(response.user!.toJson());
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;
    return User.fromJson(response.user!.toJson());
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser {
    final session = _supabase.auth.currentSession;
    if (session?.user == null) return null;
    return User.fromJson(session!.user.toJson());
  }
}

