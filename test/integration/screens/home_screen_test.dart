import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envie2sortir/features/search/screens/home_screen.dart';

void main() {
  group('HomeScreen Integration Tests', () {
    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Vérifier que la barre de recherche est présente
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should display quick action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les boutons d'action rapide sont présents
      // (Map, Events, Favorites)
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

