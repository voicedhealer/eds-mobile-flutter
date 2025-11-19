import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envie2sortir/core/providers/filter_provider.dart';
import 'package:envie2sortir/features/search/widgets/filter_bar.dart';

void main() {
  group('FilterProvider Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('filterProvider should have default value', () {
      final filter = container.read(filterProvider);
      expect(filter, isA<FilterType>());
    });

    test('setFilter should update the filter', () {
      final notifier = container.read(filterProvider.notifier);
      
      notifier.setFilter(FilterType.rating);
      final filter = container.read(filterProvider);
      expect(filter, FilterType.rating);

      notifier.setFilter(FilterType.popular);
      final newFilter = container.read(filterProvider);
      expect(newFilter, FilterType.popular);
    });

    test('setFilter should handle all filter types', () {
      final notifier = container.read(filterProvider.notifier);
      final allFilters = FilterType.values;

      for (final filterType in allFilters) {
        notifier.setFilter(filterType);
        final currentFilter = container.read(filterProvider);
        expect(currentFilter, filterType);
      }
    });
  });
}

