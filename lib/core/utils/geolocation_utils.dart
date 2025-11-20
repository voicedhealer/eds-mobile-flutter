import 'package:geolocator/geolocator.dart';
import '../../data/models/city.dart';

class GeolocationUtils {
  /// Vérifie si un établissement est dans le rayon de recherche
  /// en utilisant les coordonnées GPS ou le nom de la ville
  static bool isWithinRadius(
    double? latitude,
    double? longitude,
    String? cityName,
    int radiusKm,
  ) {
    // Si pas de coordonnées GPS, on ne peut pas calculer la distance
    if (latitude == null || longitude == null) {
      return false;
    }

    // Si pas de nom de ville, on ne peut pas comparer
    if (cityName == null || cityName.isEmpty) {
      return false;
    }

    // Trouver la ville dans la liste des villes principales
    final city = majorFrenchCities.firstWhere(
      (c) => c.name.toLowerCase() == cityName.toLowerCase(),
      orElse: () => City(
        id: cityName.toLowerCase(),
        name: cityName,
        latitude: 0,
        longitude: 0,
      ),
    );

    // Si la ville n'a pas de coordonnées, on ne peut pas calculer
    if (city.latitude == 0 && city.longitude == 0) {
      return false;
    }

    // Calculer la distance en mètres
    final distanceInMeters = Geolocator.distanceBetween(
      city.latitude,
      city.longitude,
      latitude,
      longitude,
    );

    // Convertir en kilomètres et comparer avec le rayon
    final distanceInKm = distanceInMeters / 1000;
    return distanceInKm <= radiusKm;
  }
}

