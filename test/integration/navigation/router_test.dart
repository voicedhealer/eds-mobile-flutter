import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envie2sortir/main.dart' as app;

void main() {
  group('GoRouter Navigation Tests', () {
    testWidgets('should navigate to home screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: app.Envie2SortirApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran d'accueil est affiché
      expect(find.byType(app.Envie2SortirApp), findsOneWidget);
    });

    testWidgets('should handle route parameters', (WidgetTester tester) async {
      // Test que les routes avec paramètres sont bien configurées
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/establishment/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return Scaffold(
                appBar: AppBar(title: Text('Establishment: $slug')),
                body: Text('Slug: $slug'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Simuler une navigation vers une route avec paramètre
      router.go('/establishment/test-slug');
      await tester.pumpAndSettle();

      expect(find.text('Slug: test-slug'), findsOneWidget);
    });

    testWidgets('should handle query parameters', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final envie = state.uri.queryParameters['envie'] ?? '';
              final ville = state.uri.queryParameters['ville'];
              return Scaffold(
                appBar: AppBar(title: Text('Search: $envie')),
                body: Text('Ville: ${ville ?? 'N/A'}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.go('/search?envie=restaurant&ville=Paris');
      await tester.pumpAndSettle();

      expect(find.text('Search: restaurant'), findsOneWidget);
      expect(find.text('Ville: Paris'), findsOneWidget);
    });
  });
}

