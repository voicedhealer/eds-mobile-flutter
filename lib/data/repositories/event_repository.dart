import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/event_engagement.dart';
import '../../config/supabase_config.dart';

class EventRepository {
  SupabaseClient? get _supabase => supabase;

  Future<List<Event>> getUpcomingEvents({String? city}) async {
    if (_supabase == null) return [];
    final now = DateTime.now();
    
    // Si une ville est spécifiée, utiliser une jointure avec filtre
    if (city != null) {
      final response = await _supabase!
          .from('events')
          .select('*, establishments!inner(city)')
          .eq('establishments.city', city)
          .gte('start_date', now.toIso8601String())
          .order('start_date', ascending: true);
      
      return (response as List)
          .map((json) => Event.fromJson(json))
          .toList();
    }
    
    // Sinon, récupérer tous les événements
    final response = await _supabase!
        .from('events')
        .select('*, establishments(city)')
        .gte('start_date', now.toIso8601String())
        .order('start_date', ascending: true);

    return (response as List)
        .map((json) => Event.fromJson(json))
        .toList();
  }

  Future<EngagementStats> getEngagementStats(String eventId) async {
    if (_supabase == null) {
      return EngagementStats(envie: 0, ultraEnvie: 0, intrigue: 0, pasEnvie: 0);
    }
    final response = await _supabase!
        .from('event_engagements')
        .select('type')
        .eq('event_id', eventId);

    final engagements = (response as List).cast<Map<String, dynamic>>();
    
    return EngagementStats(
      envie: engagements.where((e) => e['type'] == 'envie').length,
      ultraEnvie: engagements.where((e) => e['type'] == 'ultra-envie').length,
      intrigue: engagements.where((e) => e['type'] == 'intrigue').length,
      pasEnvie: engagements.where((e) => e['type'] == 'pas-envie').length,
    );
  }

  Future<Event?> getById(String eventId) async {
    if (_supabase == null) return null;
    final response = await _supabase!
        .from('events')
        .select()
        .eq('id', eventId)
        .maybeSingle();

    if (response == null) return null;
    return Event.fromJson(response);
  }

  Future<void> engage({
    required String eventId,
    required String userId,
    required EngagementType type,
  }) async {
    if (_supabase == null) return;
    await _supabase!.from('event_engagements').upsert({
      'event_id': eventId,
      'user_id': userId,
      'type': type.name,
    });
  }
}

