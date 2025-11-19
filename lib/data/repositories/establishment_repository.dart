import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/establishment.dart';
import '../../config/supabase_config.dart';

class EstablishmentRepository {
  SupabaseClient? get _supabase => supabase;

  Future<Establishment?> getBySlug(String slug) async {
    if (_supabase == null) return null;
    final response = await _supabase!
        .from('establishments')
        .select()
        .eq('slug', slug)
        .eq('status', 'approved')
        .maybeSingle();

    if (response == null) return null;
    return Establishment.fromJson(response);
  }

  Future<List<Establishment>> getByCity(String city) async {
    if (_supabase == null) return [];
    final response = await _supabase!
        .from('establishments')
        .select()
        .eq('city', city)
        .eq('status', 'approved')
        .order('views_count', ascending: false);

    return (response as List)
        .map((json) => Establishment.fromJson(json))
        .toList();
  }

  Future<Establishment?> getById(String id) async {
    if (_supabase == null) return null;
    final response = await _supabase!
        .from('establishments')
        .select()
        .eq('id', id)
        .eq('status', 'approved')
        .maybeSingle();

    if (response == null) return null;
    return Establishment.fromJson(response);
  }
}

