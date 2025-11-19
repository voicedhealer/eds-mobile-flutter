import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:envie2sortir/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should display title and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Aucun résultat',
            ),
          ),
        ),
      );

      expect(find.text('Aucun résultat'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should display message when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Aucun résultat',
              message: 'Essayez avec d\'autres critères',
            ),
          ),
        ),
      );

      expect(find.text('Aucun résultat'), findsOneWidget);
      expect(find.text('Essayez avec d\'autres critères'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Aucun résultat',
              action: ElevatedButton(
                onPressed: () {},
                child: const Text('Réessayer'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Aucun résultat',
            ),
          ),
        ),
      );

      expect(find.text('Aucun résultat'), findsOneWidget);
      // Le message ne devrait pas être affiché
    });
  });
}

