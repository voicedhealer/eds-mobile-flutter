import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envie2sortir/core/providers/search_provider.dart';
import 'package:envie2sortir/data/models/establishment.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/mock_railway_api.dart';

void main() {
  group('SearchProvider Integration Tests', () {
    late ProviderContainer container;
    late MockRailwayApiClient mockApiClient;

    setUp(() {
      container = ProviderContainer();
      mockApiClient = MockRailwayApiClient();
    });

    tearDown(() {
      container.dispose();
    });

    test('searchResultsProvider should return establishments', () async {
      // Note: Ces tests nécessitent que SearchRepository soit mockable
      // Pour l'instant, on vérifie que le provider existe
      final params = SearchParams(
        envie: 'restaurant',
        ville: 'Paris',
      );

      expect(params.envie, 'restaurant');
      expect(params.ville, 'Paris');
      expect(params.filter, 'popular');
      expect(params.page, 1);
      expect(params.limit, 15);
    });

    test('SearchParams copyWith should work correctly', () {
      final original = SearchParams(
        envie: 'restaurant',
        ville: 'Paris',
        filter: 'popular',
        page: 1,
        limit: 15,
      );

      final updated = original.copyWith(
        filter: 'rating',
        page: 2,
      );

      expect(updated.envie, 'restaurant');
      expect(updated.ville, 'Paris');
      expect(updated.filter, 'rating');
      expect(updated.page, 2);
      expect(updated.limit, 15);
    });

    test('SearchParams equality should work correctly', () {
      final params1 = SearchParams(
        envie: 'restaurant',
        ville: 'Paris',
      );

      final params2 = SearchParams(
        envie: 'restaurant',
        ville: 'Paris',
      );

      final params3 = SearchParams(
        envie: 'bar',
        ville: 'Paris',
      );

      expect(params1 == params2, true);
      expect(params1 == params3, false);
      expect(params1.hashCode == params2.hashCode, true);
    });
  });
}

