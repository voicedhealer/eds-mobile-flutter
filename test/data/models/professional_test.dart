import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/professional.dart';

void main() {
  group('Professional', () {
    test('fromJson should parse correctly with all fields', () {
      final json = {
        'id': 'prof123',
        'siret': '12345678901234',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john@example.com',
        'phone': '+33123456789',
        'company_name': 'Test Company',
        'legal_status': 'SARL',
        'subscription_plan': 'PREMIUM',
        'siret_verified': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final professional = Professional.fromJson(json);

      expect(professional.id, 'prof123');
      expect(professional.siret, '12345678901234');
      expect(professional.firstName, 'John');
      expect(professional.lastName, 'Doe');
      expect(professional.email, 'john@example.com');
      expect(professional.companyName, 'Test Company');
      expect(professional.subscriptionPlan, SubscriptionPlan.premium);
      expect(professional.siretVerified, true);
    });

    test('fromJson should handle different subscription plans', () {
      final plans = ['FREE', 'PREMIUM'];
      final expectedPlans = [
        SubscriptionPlan.free,
        SubscriptionPlan.premium,
      ];

      for (var i = 0; i < plans.length; i++) {
        final json = {
          'id': 'prof123',
          'siret': '12345678901234',
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john@example.com',
          'phone': '+33123456789',
          'company_name': 'Test Company',
          'legal_status': 'SARL',
          'subscription_plan': plans[i],
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        };

        final professional = Professional.fromJson(json);
        expect(professional.subscriptionPlan, expectedPlans[i]);
      }
    });

    test('fromJson should default to FREE for unknown plan', () {
      final json = {
        'id': 'prof123',
        'siret': '12345678901234',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john@example.com',
        'phone': '+33123456789',
        'company_name': 'Test Company',
        'legal_status': 'SARL',
        'subscription_plan': 'UNKNOWN',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final professional = Professional.fromJson(json);
      expect(professional.subscriptionPlan, SubscriptionPlan.free);
    });
  });

  group('SubscriptionPlan', () {
    test('should have correct enum values', () {
      expect(SubscriptionPlan.free.name, 'free');
      expect(SubscriptionPlan.premium.name, 'premium');
    });
  });
}

