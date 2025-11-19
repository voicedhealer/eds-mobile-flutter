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
    if (_supabase == null) {
      print('⚠️ Supabase not initialized');
      return [];
    }
    
    try {
      // Recherche insensible à la casse et aux accents
      final normalizedCity = city.trim();
      print('🔍 Recherche d\'établissements à: $normalizedCity');
      
      // Essayer d'abord une recherche exacte, puis insensible à la casse
      var response = await _supabase!
          .from('establishments')
          .select()
          .ilike('city', '%$normalizedCity%') // Recherche insensible à la casse avec wildcards
          .eq('status', 'approved')
          .order('views_count', ascending: false);
      
      // Si aucun résultat, essayer une recherche exacte
      if ((response as List).isEmpty) {
        response = await _supabase!
            .from('establishments')
            .select()
            .eq('city', normalizedCity)
            .eq('status', 'approved')
            .order('views_count', ascending: false);
      }

      final establishments = (response as List)
          .map((json) => Establishment.fromJson(json))
          .toList();
      
      print('✅ Trouvé ${establishments.length} établissement(s) à $normalizedCity');
      if (establishments.isEmpty) {
        print('ℹ️ Aucun établissement trouvé. Vérifiez que:');
        print('   - La table "establishments" existe dans Supabase');
        print('   - Il y a des établissements avec city="$normalizedCity"');
        print('   - Les établissements ont status="approved"');
      }
      
      return establishments;
    } catch (e) {
      print('❌ Erreur lors de la recherche: $e');
      print('Stack: ${StackTrace.current}');
      return [];
    }
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

  /// Récupère les établissements les plus populaires (sans filtre de ville)
  Future<List<Establishment>> getPopular({int limit = 20}) async {
    if (_supabase == null) {
      print('⚠️ Supabase not initialized');
      return [];
    }
    
    try {
      print('🔍 Récupération des établissements populaires (limite: $limit)');
      
      final response = await _supabase!
          .from('establishments')
          .select()
          .eq('status', 'approved')
          .order('views_count', ascending: false)
          .limit(limit);

      print('📦 Type de réponse: ${response.runtimeType}');
      print('📦 Contenu de la réponse: ${response is List ? (response as List).length : 'N/A'} éléments');
      
      // Vérifier que la réponse est une liste
      if (response is! List) {
        print('❌ La réponse n\'est pas une liste: ${response.runtimeType}');
        return [];
      }

      final List<Establishment> establishments = [];
      
      for (var item in (response as List)) {
        try {
          // Vérifier que l'élément est un Map
          if (item is Map<String, dynamic>) {
            establishments.add(Establishment.fromJson(item));
          } else {
            print('⚠️ Élément ignoré (pas un Map): ${item.runtimeType}');
          }
        } catch (e) {
          print('⚠️ Erreur lors du parsing d\'un établissement: $e');
          print('   Données: $item');
        }
      }
      
      print('✅ Trouvé ${establishments.length} établissement(s) populaire(s)');
      
      return establishments;
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la récupération des établissements populaires: $e');
      print('   Stack trace: $stackTrace');
      return [];
    }
  }
}

