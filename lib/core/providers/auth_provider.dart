import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;
import '../../core/services/supabase_auth_service.dart';
import '../../data/models/user.dart' as app_models;

final authServiceProvider = Provider((ref) => SupabaseAuthService());

final authProvider = StreamProvider<app_models.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.asyncMap((state) async {
    if (state == supabase_lib.AuthChangeEvent.signedIn) {
      return authService.currentUser;
    }
    return null;
  });
});

final currentUserProvider = Provider<app_models.User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

