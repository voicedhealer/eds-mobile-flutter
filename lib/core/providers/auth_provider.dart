import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../data/models/user.dart' as app_models;

final authProvider = StreamProvider<app_models.User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    if (event.session?.user == null) return null;
    return app_models.User.fromJson(event.session!.user.toJson());
  });
});

final currentUserProvider = Provider<app_models.User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull;
});

