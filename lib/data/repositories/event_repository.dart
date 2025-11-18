import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/event_engagement.dart';

class EventRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Event>> getUpcomingEvents({String? city}) async {
    final now = DateTime.now();
    var query = _supabase
        .from('events')
        .select('*, establishments(*)')
        .gte('start_date', now.toIso8601String())
        .order('start_date', ascending: true);

    final response = await query;
    var events = (response as List)
        .map((json) => Event.fromJson(json))
        .toList();

    // Filtrer par ville côté client si nécessaire
    if (city != null) {
      // Note: Cette approche nécessite que l'établissement soit chargé
      // Pour une meilleure performance, utilisez une fonction Supabase ou RPC
      events = events.where((event) {
        // Si vous avez chargé l'établissement dans la réponse JSON
        // Sinon, vous devrez faire une requête séparée pour chaque établissement
        return true; // Placeholder - à implémenter selon votre structure de données
      }).toList();
    }

    return events;
  }

  Future<EngagementStats> getEngagementStats(String eventId) async {
    final response = await _supabase
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

  Future<void> engage({
    required String eventId,
    required String userId,
    required EngagementType type,
  }) async {
    await _supabase.from('event_engagements').upsert({
      'event_id': eventId,
      'user_id': userId,
      'type': type.name,
    });
  }
}

