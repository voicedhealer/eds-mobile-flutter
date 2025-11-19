import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envie2sortir/core/providers/favorites_provider.dart';
import 'package:envie2sortir/data/models/establishment.dart';

void main() {
  group('FavoritesProvider Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('favoritesProvider should exist', () {
      // Vérifier que le provider existe
      expect(favoritesProvider, isA<FutureProvider<List<Establishment>>>());
    });

    // Note: Les tests complets nécessitent une initialisation Supabase
    // ou des mocks pour FavoritesService
  });
}

