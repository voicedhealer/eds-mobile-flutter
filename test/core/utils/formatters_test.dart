import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatPrice should format correctly', () {
      final formatted1 = Formatters.formatPrice(25.0);
      expect(formatted1, contains('25'));
      expect(formatted1, contains('€'));

      final formatted2 = Formatters.formatPrice(0.0);
      expect(formatted2, isNotEmpty);
    });

    test('formatPrice should handle different prices', () {
      final prices = [0.0, 5.0, 25.5, 100.0, 999.99];

      for (final price in prices) {
        final formatted = Formatters.formatPrice(price);
        expect(formatted, isNotEmpty);
      }
    });
  });
}

