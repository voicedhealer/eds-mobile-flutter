import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/establishment.dart';

void main() {
  group('Establishment', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': '123',
        'name': 'Test Establishment',
        'slug': 'test-establishment',
        'address': '123 Test St',
        'city': 'Paris',
        'status': 'approved',
        'subscription': 'FREE',
        'owner_id': 'owner123',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final establishment = Establishment.fromJson(json);

      expect(establishment.id, '123');
      expect(establishment.name, 'Test Establishment');
      expect(establishment.slug, 'test-establishment');
    });
  });
}

