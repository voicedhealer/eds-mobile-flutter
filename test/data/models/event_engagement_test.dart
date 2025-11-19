import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/event_engagement.dart';

void main() {
  group('EngagementStats', () {
    test('totalScore calculation with all types', () {
      final stats = EngagementStats(
        envie: 5,
        ultraEnvie: 3,
        intrigue: 2,
        pasEnvie: 1,
      );

      // envie: 5 * 1 = 5
      // ultraEnvie: 3 * 3 = 9
      // intrigue: 2 * 2 = 4
      // pasEnvie: 1 * -1 = -1
      // Total: 5 + 9 + 4 - 1 = 17
      expect(stats.totalScore, 17);
    });

    test('totalScore with only positive engagements', () {
      final stats = EngagementStats(
        envie: 10,
        ultraEnvie: 5,
        intrigue: 0,
        pasEnvie: 0,
      );

      // totalScore: (10 * 1) + (5 * 3) = 25
      expect(stats.totalScore, 25);
    });

    test('totalScore with negative engagements', () {
      final stats = EngagementStats(
        envie: 5,
        ultraEnvie: 2,
        intrigue: 1,
        pasEnvie: 10,
      );

      // totalScore: (5 * 1) + (2 * 3) + (1 * 2) + (10 * -1) = 5 + 6 + 2 - 10 = 3
      expect(stats.totalScore, 3);
    });

    test('gaugePercentage calculation', () {
      final stats = EngagementStats(
        envie: 10,
        ultraEnvie: 5,
        intrigue: 0,
        pasEnvie: 0,
      );

      // totalScore: (10 * 1) + (5 * 3) = 25
      // percentage: (25 / 15) * 100 = 166.67%
      // clamped to 150%
      expect(stats.gaugePercentage, 150.0);
    });

    test('gaugePercentage should not exceed 150', () {
      final stats = EngagementStats(
        envie: 100,
        ultraEnvie: 50,
        intrigue: 0,
        pasEnvie: 0,
      );

      expect(stats.gaugePercentage, 150.0);
    });

    test('gaugePercentage should not be negative', () {
      final stats = EngagementStats(
        envie: 0,
        ultraEnvie: 0,
        intrigue: 0,
        pasEnvie: 100,
      );

      expect(stats.gaugePercentage, greaterThanOrEqualTo(0));
    });

    test('isFireMode when gaugePercentage >= 150', () {
      final stats = EngagementStats(
        envie: 15,
        ultraEnvie: 10,
        intrigue: 0,
        pasEnvie: 0,
      );

      expect(stats.isFireMode, true);
    });

    test('isFireMode when gaugePercentage < 150', () {
      final stats = EngagementStats(
        envie: 5,
        ultraEnvie: 2,
        intrigue: 1,
        pasEnvie: 0,
      );

      expect(stats.isFireMode, false);
    });

    test('default values should be zero', () {
      final stats = EngagementStats();

      expect(stats.envie, 0);
      expect(stats.ultraEnvie, 0);
      expect(stats.intrigue, 0);
      expect(stats.pasEnvie, 0);
      expect(stats.totalScore, 0);
      expect(stats.gaugePercentage, 0);
      expect(stats.isFireMode, false);
    });
  });

  group('EventEngagement', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': '123',
        'event_id': 'event123',
        'user_id': 'user123',
        'type': 'envie',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final engagement = EventEngagement.fromJson(json);

      expect(engagement.id, '123');
      expect(engagement.eventId, 'event123');
      expect(engagement.userId, 'user123');
      expect(engagement.type, EngagementType.envie);
      expect(engagement.createdAt, DateTime.parse('2024-01-01T00:00:00Z'));
    });

    test('fromJson should parse all engagement types', () {
      // Tester chaque type individuellement car le parsing utilise firstWhere avec le nom de l'enum
      final testCases = [
        {'type': 'envie', 'expected': EngagementType.envie},
        {'type': 'ultraEnvie', 'expected': EngagementType.ultraEnvie},
        {'type': 'intrigue', 'expected': EngagementType.intrigue},
        {'type': 'pasEnvie', 'expected': EngagementType.pasEnvie},
      ];

      for (final testCase in testCases) {
        final json = {
          'id': '123',
          'event_id': 'event123',
          'user_id': 'user123',
          'type': testCase['type'] as String,
          'created_at': '2024-01-01T00:00:00Z',
        };

        final engagement = EventEngagement.fromJson(json);
        expect(engagement.type, testCase['expected'] as EngagementType);
      }
    });

    test('fromJson should default to envie for unknown type', () {
      final json = {
        'id': '123',
        'event_id': 'event123',
        'user_id': 'user123',
        'type': 'unknown',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final engagement = EventEngagement.fromJson(json);
      expect(engagement.type, EngagementType.envie);
    });
  });

  group('EngagementType', () {
    test('should have correct enum values', () {
      expect(EngagementType.envie.name, 'envie');
      expect(EngagementType.ultraEnvie.name, 'ultraEnvie');
      expect(EngagementType.intrigue.name, 'intrigue');
      expect(EngagementType.pasEnvie.name, 'pasEnvie');
    });
  });
}


