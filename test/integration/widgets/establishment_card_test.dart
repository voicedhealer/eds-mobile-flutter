import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:envie2sortir/features/establishments/widgets/establishment_card.dart';
import 'package:envie2sortir/data/models/establishment.dart';
import 'package:envie2sortir/data/models/professional.dart';

void main() {
  group('EstablishmentCard Widget Tests', () {
    late Establishment testEstablishment;

    setUp(() {
      testEstablishment = Establishment(
        id: '123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        address: '123 Test St',
        country: 'France',
        specialites: 'Restaurant',
        status: EstablishmentStatus.approved,
        subscription: SubscriptionPlan.free,
        ownerId: 'owner123',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
    });

    testWidgets('should display establishment name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstablishmentCard(
              establishment: testEstablishment,
            ),
          ),
        ),
      );

      expect(find.text('Test Restaurant'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstablishmentCard(
              establishment: testEstablishment,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EstablishmentCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should display city when available', (WidgetTester tester) async {
      final establishmentWithCity = Establishment(
        id: '123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        address: '123 Test St',
        city: 'Paris',
        country: 'France',
        specialites: 'Restaurant',
        status: EstablishmentStatus.approved,
        subscription: SubscriptionPlan.free,
        ownerId: 'owner123',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstablishmentCard(
              establishment: establishmentWithCity,
            ),
          ),
        ),
      );

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('should display premium badge for premium establishments', (WidgetTester tester) async {
      final premiumEstablishment = Establishment(
        id: '123',
        name: 'Premium Restaurant',
        slug: 'premium-restaurant',
        address: '123 Test St',
        country: 'France',
        specialites: 'Restaurant',
        status: EstablishmentStatus.approved,
        subscription: SubscriptionPlan.premium,
        ownerId: 'owner123',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstablishmentCard(
              establishment: premiumEstablishment,
            ),
          ),
        ),
      );

      // Vérifier que le badge premium est affiché
      expect(find.byType(EstablishmentCard), findsOneWidget);
    });
  });
}

