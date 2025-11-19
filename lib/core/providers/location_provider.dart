import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/city.dart';

class LocationState {
  final City? currentCity;
  final int searchRadius; // en km
  final bool loading;
  final String? error;
  final bool isDetected;
  final List<City> favorites;
  final List<CityHistory> history;

  LocationState({
    this.currentCity,
    this.searchRadius = 10,
    this.loading = false,
    this.error,
    this.isDetected = false,
    this.favorites = const [],
    this.history = const [],
  });

  LocationState copyWith({
    City? currentCity,
    int? searchRadius,
    bool? loading,
    String? error,
    bool? isDetected,
    List<City>? favorites,
    List<CityHistory>? history,
  }) {
    return LocationState(
      currentCity: currentCity ?? this.currentCity,
      searchRadius: searchRadius ?? this.searchRadius,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      isDetected: isDetected ?? this.isDetected,
      favorites: favorites ?? this.favorites,
      history: history ?? this.history,
    );
  }
}

class CityHistory {
  final City city;
  final DateTime lastVisited;
  final int visitCount;

  CityHistory({
    required this.city,
    required this.lastVisited,
    this.visitCount = 1,
  });
}

// Provider pour l'état de localisation
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    state = state.copyWith(loading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Charger la ville actuelle
      final cityJson = prefs.getString('currentCity');
      final city = cityJson != null 
          ? City.fromJson(Map<String, dynamic>.from(jsonDecode(cityJson)))
          : defaultCity;
      
      // Charger le rayon
      final radius = prefs.getInt('searchRadius') ?? 10;
      
      // Charger les favoris
      final favoritesJson = prefs.getStringList('cityFavorites') ?? [];
      final favorites = favoritesJson
          .map((json) => City.fromJson(Map<String, dynamic>.from(jsonDecode(json))))
          .toList();
      
      // Charger l'historique
      final historyJson = prefs.getStringList('cityHistory') ?? [];
      final history = historyJson
          .map((json) {
            try {
              final data = Map<String, dynamic>.from(jsonDecode(json));
              return CityHistory(
                city: City.fromJson(data['city']),
                lastVisited: DateTime.parse(data['lastVisited']),
                visitCount: data['visitCount'] ?? 1,
              );
            } catch (e) {
              return null;
            }
          })
          .whereType<CityHistory>()
          .toList();
      
      state = state.copyWith(
        currentCity: city,
        searchRadius: radius,
        favorites: favorites,
        history: history,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        currentCity: defaultCity,
        searchRadius: 10,
        loading: false,
        error: 'Erreur lors du chargement de la localisation',
      );
    }
  }

  Future<void> changeCity(City city) async {
    // Ajouter à l'historique
    final existingHistory = state.history.firstWhere(
      (h) => h.city.id == city.id,
      orElse: () => CityHistory(
        city: city,
        lastVisited: DateTime.now(),
        visitCount: 0,
      ),
    );
    
    final updatedHistory = [
      CityHistory(
        city: city,
        lastVisited: DateTime.now(),
        visitCount: existingHistory.visitCount + 1,
      ),
      ...state.history.where((h) => h.city.id != city.id),
    ].take(10).toList(); // Garder seulement les 10 dernières
    
    state = state.copyWith(
      currentCity: city,
      history: updatedHistory,
      isDetected: false,
    );
    
    // Sauvegarder
    await _saveLocation();
    await _saveHistory(updatedHistory);
  }

  Future<void> changeRadius(int radius) async {
    state = state.copyWith(searchRadius: radius);
    await _saveLocation();
  }

  Future<void> toggleFavorite(City city) async {
    final isFavorite = state.favorites.any((f) => f.id == city.id);
    final updatedFavorites = isFavorite
        ? state.favorites.where((f) => f.id != city.id).toList()
        : [...state.favorites, city];
    
    state = state.copyWith(favorites: updatedFavorites);
    
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = updatedFavorites
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList('cityFavorites', favoritesJson);
  }

  bool isFavorite(String cityId) {
    return state.favorites.any((f) => f.id == cityId);
  }

  Future<void> _saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.currentCity != null) {
      await prefs.setString('currentCity', jsonEncode(state.currentCity!.toJson()));
    }
    await prefs.setInt('searchRadius', state.searchRadius);
  }

  Future<void> _saveHistory(List<CityHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history
        .map((h) => jsonEncode({
              'city': h.city.toJson(),
              'lastVisited': h.lastVisited.toIso8601String(),
              'visitCount': h.visitCount,
            }))
        .toList();
    await prefs.setStringList('cityHistory', historyJson);
  }
}

// Helpers pour accéder facilement
final currentCityProvider = Provider<City?>((ref) {
  return ref.watch(locationProvider).currentCity;
});

final searchRadiusProvider = Provider<int>((ref) {
  return ref.watch(locationProvider).searchRadius;
});
