import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class GeolocationService {
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCityFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> getCurrentCity() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return await getCityFromPosition(position);
  }

  Future<Position?> getPositionFromCity(String cityName) async {
    try {
      final locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        return Position(
          latitude: locations.first.latitude,
          longitude: locations.first.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      print('Erreur lors de la recherche de la ville: $e');
    }
    return null;
  }
}

