import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/core/utils/distance_utils.dart';

void main() {
  group('DistanceUtils', () {
    test('calculateDistance should return correct distance', () {
      // Paris coordinates
      const lat1 = 48.8566;
      const lon1 = 2.3522;
      
      // Lyon coordinates (approximately 392 km from Paris)
      const lat2 = 45.7640;
      const lon2 = 4.8357;

      final distance = DistanceUtils.calculateDistance(
        lat1,
        lon1,
        lat2,
        lon2,
      );

      // La distance devrait être d'environ 392 km (392000 mètres)
      expect(distance, greaterThan(390000));
      expect(distance, lessThan(400000));
    });

    test('calculateDistance should return 0 for same coordinates', () {
      const lat = 48.8566;
      const lon = 2.3522;

      final distance = DistanceUtils.calculateDistance(
        lat,
        lon,
        lat,
        lon,
      );

      expect(distance, 0);
    });

    test('formatDistance should format correctly', () {
      final formatted1 = DistanceUtils.formatDistance(500);
      expect(formatted1, contains('m'));

      final formatted2 = DistanceUtils.formatDistance(1500);
      expect(formatted2, contains('km'));

      final formatted3 = DistanceUtils.formatDistance(100000);
      expect(formatted3, contains('km'));
    });
  });
}

