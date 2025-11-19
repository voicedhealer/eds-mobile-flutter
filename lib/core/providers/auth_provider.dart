import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../data/models/user.dart' as app_models;
import '../../config/supabase_config.dart';

final authProvider = StreamProvider<app_models.User?>((ref) {
  final client = supabase;
  if (client == null) {
    // Retourner un stream vide si Supabase n'est pas initialisé
    return Stream.value(null);
  }
  
  try {
    return client.auth.onAuthStateChange.map((event) {
      if (event.session?.user == null) return null;
      try {
        return app_models.User.fromJson(event.session!.user.toJson());
      } catch (e) {
        print('Error parsing user: $e');
        return null;
      }
    });
  } catch (e) {
    print('Error in authProvider: $e');
    return Stream.value(null);
  }
});

final currentUserProvider = Provider<app_models.User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull;
});

