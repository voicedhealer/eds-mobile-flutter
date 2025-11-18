import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/geolocation_service.dart';

final geolocationServiceProvider = Provider((ref) => GeolocationService());

final currentCityProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(geolocationServiceProvider);
  return service.getCurrentCity();
});

