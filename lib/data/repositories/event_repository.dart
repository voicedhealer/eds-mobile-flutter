import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/event_engagement.dart';

class EventRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Event>> getUpcomingEvents({String? city}) async {
    final now = DateTime.now();
    var query = _supabase
        .from('events')
        .select()
        .gte('start_date', now.toIso8601String())
        .order('start_date', ascending: true);

    if (city != null) {
      // Joindre avec establishments pour filtrer par ville
      query = query.eq('establishments.city', city);
    }

    final response = await query;
    return (response as List)
        .map((json) => Event.fromJson(json))
        .toList();
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

