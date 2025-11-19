import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes pour Supabase
// Note: Les mocks complets nécessitent une configuration complexe
// Pour l'instant, on définit les classes de base
class MockSupabaseClient extends Mock implements SupabaseClient {}

// Helper pour créer des données de test Supabase
class SupabaseMocks {
  // Créer des données de test pour les établissements
  static Map<String, dynamic> createEstablishmentJson({
    String id = '123',
    String name = 'Test Establishment',
    String slug = 'test-establishment',
  }) {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'address': '123 Test St',
      'city': 'Paris',
      'country': 'France',
      'specialites': 'Restaurant',
      'status': 'approved',
      'subscription': 'FREE',
      'owner_id': 'owner123',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    };
  }

  // Créer des données de test pour les événements
  static Map<String, dynamic> createEventJson({
    String id = 'event123',
    String title = 'Test Event',
  }) {
    return {
      'id': id,
      'title': title,
      'establishment_id': 'est123',
      'start_date': '2024-12-31T20:00:00Z',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    };
  }
}

