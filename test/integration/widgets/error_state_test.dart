import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:envie2sortir/shared/widgets/error_state.dart';

void main() {
  group('ErrorState Widget Tests', () {
    testWidgets('should display error message and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Une erreur est survenue',
            ),
          ),
        ),
      );

      expect(find.text('Erreur'), findsOneWidget);
      expect(find.text('Une erreur est survenue'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Erreur réseau',
              icon: Icons.wifi_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should call onRetry when retry button is tapped', (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Erreur',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      expect(retried, true);
    });

    testWidgets('should not display retry button when onRetry is not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Erreur',
            ),
          ),
        ),
      );

      expect(find.text('Réessayer'), findsNothing);
    });
  });
}

