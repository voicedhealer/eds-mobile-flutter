import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/core/utils/date_utils.dart';

void main() {
  group('DateUtils', () {
    test('formatDateTime should format correctly', () {
      final date = DateTime(2024, 12, 31, 20, 30);
      final formatted = DateUtils.formatDateTime(date);
      
      // Le format exact dépend de l'implémentation, mais devrait contenir la date
      expect(formatted, isNotEmpty);
      expect(formatted, contains('2024'));
    });

    test('formatDateTime should handle different dates', () {
      final dates = [
        DateTime(2024, 1, 1, 12, 0),
        DateTime(2024, 6, 15, 18, 45),
        DateTime(2024, 12, 31, 23, 59),
      ];

      for (final date in dates) {
        final formatted = DateUtils.formatDateTime(date);
        expect(formatted, isNotEmpty);
      }
    });
  });
}

