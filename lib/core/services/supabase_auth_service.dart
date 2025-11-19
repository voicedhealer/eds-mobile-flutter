import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../data/models/user.dart' as app_models;
import '../../config/supabase_config.dart';

class SupabaseAuthService {
  SupabaseClient? get _supabase => supabase;

  Future<app_models.User?> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (_supabase == null) return null;
    
    try {
      final response = await _supabase!.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_type': 'user',
          'first_name': firstName,
          'last_name': lastName,
          'role': 'user',
        },
      );

      if (response.user == null) return null;

      // Récupérer les données utilisateur depuis la table users
      final userData = await _getUserData(response.user!.id);
      return userData ?? _createUserFromAuth(response.user!, firstName, lastName);
    } catch (e) {
      print('Erreur inscription: $e');
      rethrow;
    }
  }

  Future<app_models.User?> signIn({
    required String email,
    required String password,
  }) async {
    if (_supabase == null) return null;
    
    try {
      final response = await _supabase!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      // Récupérer les données utilisateur depuis la table users
      final userData = await _getUserData(response.user!.id);
      return userData ?? _createUserFromAuth(response.user!);
    } catch (e) {
      print('Erreur connexion: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_supabase == null) return;
    await _supabase!.auth.signOut();
  }

  app_models.User? get currentUser {
    if (_supabase == null) return null;
    final session = _supabase!.auth.currentSession;
    if (session?.user == null) return null;
    
    // Essayer de récupérer depuis la table users
    // Pour l'instant, on retourne les données de base depuis auth
    return _createUserFromAuth(session!.user);
  }

  // Stream de l'état d'authentification
  Stream<AuthState> get authStateChanges {
    if (_supabase == null) {
      return Stream.value(AuthState.unauthenticated);
    }
    
    return _supabase!.auth.onAuthStateChange.map((event) {
      if (event.session?.user == null) {
        return AuthState.unauthenticated;
      }
      return AuthState.authenticated;
    });
  }

  // Récupérer les données utilisateur depuis la table users
  Future<app_models.User?> _getUserData(String userId) async {
    if (_supabase == null) return null;
    
    try {
      final response = await _supabase!
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return app_models.User.fromJson(response);
    } catch (e) {
      print('Erreur récupération données utilisateur: $e');
      return null;
    }
  }

  // Créer un User depuis les données auth (fallback)
  app_models.User _createUserFromAuth(
    User authUser, [
    String? firstName,
    String? lastName,
  ]) {
    final metadata = authUser.userMetadata;
    final now = DateTime.now();
    
    // Parser les dates depuis les métadonnées ou utiliser maintenant
    DateTime? parseCreatedAt;
    if (authUser.createdAt != null) {
      parseCreatedAt = authUser.createdAt;
    } else if (metadata['created_at'] != null) {
      try {
        parseCreatedAt = DateTime.parse(metadata['created_at'].toString());
      } catch (e) {
        parseCreatedAt = now;
      }
    } else {
      parseCreatedAt = now;
    }
    
    return app_models.User(
      id: authUser.id,
      email: authUser.email ?? '',
      firstName: firstName ?? metadata['first_name'] ?? metadata['firstName'],
      lastName: lastName ?? metadata['last_name'] ?? metadata['lastName'],
      name: metadata['name'] ?? 
            (firstName != null && lastName != null 
              ? '$firstName $lastName' 
              : null),
      isVerified: authUser.emailConfirmedAt != null,
      createdAt: parseCreatedAt,
      updatedAt: authUser.updatedAt ?? parseCreatedAt,
    );
  }
}

enum AuthState {
  authenticated,
  unauthenticated,
  loading,
}

