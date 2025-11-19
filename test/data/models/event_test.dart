import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/event.dart';

void main() {
  group('Event', () {
    test('fromJson should parse correctly with all fields', () {
      final json = {
        'id': 'event123',
        'title': 'Concert Test',
        'description': 'A test concert',
        'image_url': 'https://test.com/image.jpg',
        'establishment_id': 'est123',
        'start_date': '2024-12-31T20:00:00Z',
        'end_date': '2025-01-01T02:00:00Z',
        'price': 25.0,
        'price_unit': '€',
        'max_capacity': 100,
        'is_recurring': false,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final event = Event.fromJson(json);

      expect(event.id, 'event123');
      expect(event.title, 'Concert Test');
      expect(event.description, 'A test concert');
      expect(event.imageUrl, 'https://test.com/image.jpg');
      expect(event.establishmentId, 'est123');
      expect(event.price, 25.0);
      expect(event.priceUnit, '€');
      expect(event.maxCapacity, 100);
      expect(event.isRecurring, false);
      expect(event.endDate, isNotNull);
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        'id': 'event123',
        'title': 'Event Test',
        'establishment_id': 'est123',
        'start_date': '2024-12-31T20:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final event = Event.fromJson(json);

      expect(event.description, isNull);
      expect(event.imageUrl, isNull);
      expect(event.endDate, isNull);
      expect(event.price, isNull);
      expect(event.maxCapacity, isNull);
      expect(event.isRecurring, false);
    });

    test('fromJson should parse dates correctly', () {
      final json = {
        'id': 'event123',
        'title': 'Event Test',
        'establishment_id': 'est123',
        'start_date': '2024-12-31T20:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final event = Event.fromJson(json);

      expect(event.startDate, DateTime.parse('2024-12-31T20:00:00Z'));
      expect(event.createdAt, DateTime.parse('2024-01-01T00:00:00Z'));
      expect(event.updatedAt, DateTime.parse('2024-01-01T00:00:00Z'));
    });
  });
}

