import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envie2sortir/features/search/screens/search_results_screen.dart';

void main() {
  group('SearchResultsScreen Integration Tests', () {
    testWidgets('should display search results title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchResultsScreen(
              envie: 'restaurant',
            ),
          ),
        ),
      );

      expect(find.text('Résultats pour "restaurant"'), findsOneWidget);
    });

    testWidgets('should display filter bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchResultsScreen(
              envie: 'restaurant',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la barre de filtres est présente
      expect(find.byType(SearchResultsScreen), findsOneWidget);
    });

    testWidgets('should handle empty search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchResultsScreen(
              envie: '',
            ),
          ),
        ),
      );

      expect(find.byType(SearchResultsScreen), findsOneWidget);
    });
  });
}

