import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/establishment.dart';
import 'package:envie2sortir/data/models/professional.dart';

void main() {
  group('Establishment', () {
    test('fromJson should parse correctly with all fields', () {
      final json = {
        'id': '123',
        'name': 'Test Establishment',
        'slug': 'test-establishment',
        'description': 'A test establishment',
        'address': '123 Test St',
        'city': 'Paris',
        'postal_code': '75001',
        'country': 'France',
        'latitude': 48.8566,
        'longitude': 2.3522,
        'phone': '+33123456789',
        'email': 'test@example.com',
        'website': 'https://test.com',
        'instagram': '@test',
        'facebook': 'test',
        'specialites': 'Restaurant, Bar',
        'prix_moyen': 25.0,
        'capacite_max': 50,
        'accessibilite': true,
        'parking': false,
        'terrasse': true,
        'status': 'approved',
        'subscription': 'PREMIUM',
        'owner_id': 'owner123',
        'views_count': 100,
        'clicks_count': 50,
        'avg_rating': 4.5,
        'total_comments': 10,
        'image_url': 'https://test.com/image.jpg',
        'price_min': 15.0,
        'price_max': 35.0,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final establishment = Establishment.fromJson(json);

      expect(establishment.id, '123');
      expect(establishment.name, 'Test Establishment');
      expect(establishment.slug, 'test-establishment');
      expect(establishment.description, 'A test establishment');
      expect(establishment.city, 'Paris');
      expect(establishment.latitude, 48.8566);
      expect(establishment.longitude, 2.3522);
      expect(establishment.status, EstablishmentStatus.approved);
      expect(establishment.subscription, SubscriptionPlan.premium);
      expect(establishment.avgRating, 4.5);
      expect(establishment.prixMoyen, 25.0);
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        'id': '123',
        'name': 'Test Establishment',
        'slug': 'test-establishment',
        'address': '123 Test St',
        'country': 'France',
        'specialites': '',
        'status': 'pending',
        'subscription': 'FREE',
        'owner_id': 'owner123',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final establishment = Establishment.fromJson(json);

      expect(establishment.description, isNull);
      expect(establishment.city, isNull);
      expect(establishment.latitude, isNull);
      expect(establishment.avgRating, isNull);
      expect(establishment.accessibilite, false);
      expect(establishment.parking, false);
    });

    test('fromJson should handle default values', () {
      final json = {
        'id': '123',
        'name': 'Test',
        'slug': 'test',
        'address': '123 Test St',
        'specialites': '',
        'status': 'approved',
        'subscription': 'FREE',
        'owner_id': 'owner123',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final establishment = Establishment.fromJson(json);

      expect(establishment.country, 'France');
      expect(establishment.viewsCount, 0);
      expect(establishment.clicksCount, 0);
      expect(establishment.totalComments, 0);
    });
  });
}

