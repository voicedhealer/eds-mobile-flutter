# PROMPT CURSOR - Système de Localisation Envie2Sortir Flutter

## Contexte

Implémenter un système de localisation qui :
1. Permet de sélectionner une ville et un rayon de recherche via un modal
2. Met à jour toute la page (établissements, événements, carte) selon la localisation sélectionnée
3. Conserve la barre de recherche indépendante (sa propre logique)
4. Gère les favoris et l'historique de villes
5. Utilise des rayons adaptatifs selon la taille de la ville (logique métier existante)

---

## 1. Architecture - LocationProvider avec Riverpod

### A. Modèle City

```dart
// lib/data/models/city.dart
class City {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? region;
  final String? postalCode;

  City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region,
    this.postalCode,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      region: json['region'],
      postalCode: json['postal_code'] ?? json['postalCode'],
    );
  }
}

// Villes principales de France
final majorFrenchCities = [
  City(id: 'dijon', name: 'Dijon', latitude: 47.322, longitude: 5.041, region: 'Bourgogne-Franche-Comté'),
  City(id: 'paris', name: 'Paris', latitude: 48.8566, longitude: 2.3522, region: 'Île-de-France'),
  City(id: 'lyon', name: 'Lyon', latitude: 45.7640, longitude: 4.8357, region: 'Auvergne-Rhône-Alpes'),
  City(id: 'marseille', name: 'Marseille', latitude: 43.2965, longitude: 5.3698, region: "Provence-Alpes-Côte d'Azur"),
  City(id: 'toulouse', name: 'Toulouse', latitude: 43.6047, longitude: 1.4442, region: 'Occitanie'),
  City(id: 'bordeaux', name: 'Bordeaux', latitude: 44.8378, longitude: -0.5792, region: 'Nouvelle-Aquitaine'),
  City(id: 'lille', name: 'Lille', latitude: 50.6292, longitude: 3.0573, region: 'Hauts-de-France'),
  City(id: 'nantes', name: 'Nantes', latitude: 47.2184, longitude: -1.5536, region: 'Pays de la Loire'),
  City(id: 'strasbourg', name: 'Strasbourg', latitude: 48.5734, longitude: 7.7521, region: 'Grand Est'),
  City(id: 'nice', name: 'Nice', latitude: 43.7102, longitude: 7.2620, region: "Provence-Alpes-Côte d'Azur"),
  City(id: 'rennes', name: 'Rennes', latitude: 48.1173, longitude: -1.6778, region: 'Bretagne'),
  City(id: 'reims', name: 'Reims', latitude: 49.2583, longitude: 4.0317, region: 'Grand Est'),
  City(id: 'montpellier', name: 'Montpellier', latitude: 43.6108, longitude: 3.8767, region: 'Occitanie'),
];

final defaultCity = majorFrenchCities[0]; // Dijon
```

### B. LocationState et LocationProvider

```dart
// lib/core/providers/location_provider.dart
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
            final data = Map<String, dynamic>.from(jsonDecode(json));
            return CityHistory(
              city: City.fromJson(data['city']),
              lastVisited: DateTime.parse(data['lastVisited']),
              visitCount: data['visitCount'] ?? 1,
            );
          })
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
    
    // Synchroniser avec l'API si connecté (via un autre provider)
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
```

---

## 2. Modal de Localisation

### A. LocationModal Widget

```dart
// lib/features/location/widgets/location_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/city.dart';
import 'radius_selector.dart';
import 'city_list_tab.dart';

class LocationModal extends ConsumerStatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const LocationModal({
    super.key,
    required this.isOpen,
    required this.onClose,
  });

  @override
  ConsumerState<LocationModal> createState() => _LocationModalState();
}

class _LocationModalState extends ConsumerState<LocationModal> {
  City? _selectedCity;
  int? _selectedRadius;
  int _activeTab = 0; // 0: Villes, 1: Favoris, 2: Récents

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  void _initializeSelection() {
    final locationState = ref.read(locationProvider);
    _selectedCity = locationState.currentCity;
    _selectedRadius = locationState.searchRadius;
  }

  bool get _hasPendingChanges {
    final locationState = ref.read(locationProvider);
    return (_selectedCity?.id != locationState.currentCity?.id) ||
        (_selectedRadius != locationState.searchRadius);
  }

  Future<void> _handleValidate() async {
    final locationNotifier = ref.read(locationProvider.notifier);
    
    if (_selectedCity != null) {
      await locationNotifier.changeCity(_selectedCity!);
    }
    
    if (_selectedRadius != null) {
      await locationNotifier.changeRadius(_selectedRadius!);
    }
    
    if (widget.isOpen) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.currentCity;
    final currentRadius = locationState.searchRadius;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF751F), Color(0xFFFF1FA9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Localisation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              
              // Sélecteur de rayon
              Padding(
                padding: const EdgeInsets.all(16),
                child: RadiusSelector(
                  selectedRadius: _selectedRadius ?? currentRadius,
                  onRadiusChanged: (radius) {
                    setState(() {
                      _selectedRadius = radius;
                    });
                  },
                  selectedCity: _selectedCity?.name,
                ),
              ),
              
              // Onglets
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTab(0, Icons.location_on, 'Villes'),
                    _buildTab(1, Icons.star, 'Favoris (${locationState.favorites.length})'),
                    _buildTab(2, Icons.history, 'Récents (${locationState.history.length})'),
                  ],
                ),
              ),
              
              // Contenu des onglets (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  child: _buildTabContent(),
                ),
              ),
              
              // Bouton de validation (si modifications en attente)
              if (_hasPendingChanges)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border(
                      top: BorderSide(color: Colors.green[200]!),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleValidate,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Valider la sélection',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Text(
                  _hasPendingChanges
                      ? 'Modifications en attente de validation'
                      : 'Vos préférences sont enregistrées automatiquement',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFFFF751F) : Colors.transparent,
                width: 2,
              ),
            ),
            color: isActive ? Colors.orange[50] : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? const Color(0xFFFF751F) : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFFFF751F) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final locationState = ref.watch(locationProvider);
    
    switch (_activeTab) {
      case 0: // Villes
        return CityListTab(
          selectedCity: _selectedCity,
          onCitySelected: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
        );
      case 1: // Favoris
        return FavoritesTab(
          favorites: locationState.favorites,
          selectedCity: _selectedCity,
          onCitySelected: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
        );
      case 2: // Récents
        return RecentCitiesTab(
          history: locationState.history,
          selectedCity: _selectedCity,
          onCitySelected: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
```

### B. RadiusSelector avec Logique Adaptative

```dart
// lib/features/location/widgets/radius_selector.dart
import 'package:flutter/material.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/city.dart';

class RadiusSelector extends StatelessWidget {
  final int selectedRadius;
  final Function(int) onRadiusChanged;
  final String? selectedCity;

  const RadiusSelector({
    super.key,
    required this.selectedRadius,
    required this.onRadiusChanged,
    this.selectedCity,
  });

  // Liste des grandes villes françaises
  static const List<String> largeCities = [
    'Paris', 'Lyon', 'Marseille', 'Toulouse', 'Nice', 'Nantes',
    'Strasbourg', 'Montpellier', 'Bordeaux', 'Lille', 'Rennes',
    'Reims', 'Saint-Étienne', 'Toulon', 'Le Havre', 'Angers',
    'Grenoble', 'Villeurbanne', 'Le Mans', 'Aix-en-Provence'
  ];

  bool get _isLargeCity {
    if (selectedCity == null) return false;
    return largeCities.any((city) =>
      selectedCity!.toLowerCase().contains(city.toLowerCase()) ||
      city.toLowerCase().contains(selectedCity!.toLowerCase())
    );
  }

  List<RadiusOption> get _adaptiveRadiusOptions {
    if (_isLargeCity) {
      return [
        RadiusOption(value: 1, label: '1km'),
        RadiusOption(value: 5, label: '5km'),
        RadiusOption(value: 10, label: '10km'),
        RadiusOption(value: 20, label: '20km'),
        RadiusOption(value: 50, label: '50km'),
      ];
    } else {
      return [
        RadiusOption(value: 10, label: '10km'),
        RadiusOption(value: 20, label: '20km'),
        RadiusOption(value: 50, label: '50km'),
        RadiusOption(value: 100, label: 'Toute la région'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _adaptiveRadiusOptions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rayon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isLargeCity)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🏙️ Grande ville',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedRadius == option.value;
            return InkWell(
              onTap: () => onRadiusChanged(option.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFF751F), Color(0xFFFF1FA9)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RadiusOption {
  final int value;
  final String label;

  RadiusOption({required this.value, required this.label});
}
```

### C. CityListTab avec Recherche

```dart
// lib/features/location/widgets/city_list_tab.dart
import 'package:flutter/material.dart';
import '../../../data/models/city.dart';
import '../../../core/providers/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityListTab extends ConsumerStatefulWidget {
  final City? selectedCity;
  final Function(City) onCitySelected;

  const CityListTab({
    super.key,
    this.selectedCity,
    required this.onCitySelected,
  });

  @override
  ConsumerState<CityListTab> createState() => _CityListTabState();
}

class _CityListTabState extends ConsumerState<CityListTab> {
  String _searchQuery = '';
  List<City> _searchResults = [];
  bool _isSearching = false;
  bool _showMoreCities = false;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.currentCity;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showMoreCities) ...[
            // Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une ville...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _handleSearch,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _showMoreCities = false;
                  _searchQuery = '';
                  _searchResults = [];
                });
              },
              child: const Text('← Retour'),
            ),
            const SizedBox(height: 8),
          ],
          
          // Liste des villes
          if (!_showMoreCities)
            ...majorFrenchCities.take(8).map((city) {
              final isCurrent = currentCity?.id == city.id;
              final isSelected = widget.selectedCity?.id == city.id;
              
              return _buildCityItem(
                city: city,
                isCurrent: isCurrent,
                isSelected: isSelected,
              );
            }),
          
          if (!_showMoreCities) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showMoreCities = true;
                });
              },
              icon: const Icon(Icons.search),
              label: const Text('Voir + de villes'),
            ),
          ],
          
          // Résultats de recherche
          if (_showMoreCities && _searchResults.isNotEmpty)
            ..._searchResults.map((city) {
              final isCurrent = currentCity?.id == city.id;
              final isSelected = widget.selectedCity?.id == city.id;
              
              return _buildCityItem(
                city: city,
                isCurrent: isCurrent,
                isSelected: isSelected,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCityItem({
    required City city,
    required bool isCurrent,
    required bool isSelected,
  }) {
    final locationNotifier = ref.read(locationProvider.notifier);
    final isFavorite = locationNotifier.isFavorite(city.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.orange[50]
            : isSelected
                ? Colors.blue[50]
                : Colors.white,
        border: Border.all(
          color: isCurrent
              ? Colors.orange[300]!
              : isSelected
                  ? Colors.blue[400]!
                  : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isCurrent
              ? Colors.orange[600]
              : isSelected
                  ? Colors.blue[600]
                  : Colors.grey[400],
        ),
        title: Text(
          city.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCurrent || isSelected ? Colors.black87 : Colors.black87,
          ),
        ),
        subtitle: city.region != null
            ? Text(
                city.region!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : Colors.grey[400],
          ),
          onPressed: () {
            locationNotifier.toggleFavorite(city);
          },
        ),
        onTap: () {
          widget.onCitySelected(city);
        },
      ),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });
    
    // Recherche avec debounce (300ms)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (query.length < 2) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }
      
      // Recherche dans les villes principales + appel API si nécessaire
      final results = majorFrenchCities
          .where((city) =>
              city.name.toLowerCase().contains(query.toLowerCase()) ||
              (city.region?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      
      // TODO: Appel API pour rechercher d'autres villes via Railway backend
    });
  }
}
```

---

## 3. Impact sur la Page d'Accueil

### A. HomeScreen avec Localisation

```dart
// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/location_provider.dart';
import '../../establishments/widgets/establishment_grid.dart';
import '../../events/widgets/events_carousel.dart';
import '../../location/widgets/location_modal.dart';
import '../../search/widgets/envie_search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showLocationModal = false;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.currentCity;
    final searchRadius = locationState.searchRadius;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche (logique indépendante)
            const Padding(
              padding: EdgeInsets.all(16),
              child: EnvieSearchBar(),
            ),
            
            // Badge de localisation (ouvre le modal)
            InkWell(
              onTap: () {
                setState(() {
                  _showLocationModal = true;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    Text(
                      currentCity != null
                          ? '${currentCity.name} • Rayon ${searchRadius}km'
                          : 'Sélectionner une localisation',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contenu qui se met à jour selon la localisation
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Recharger les données avec la nouvelle localisation
                  ref.invalidate(establishmentsProvider);
                  ref.invalidate(eventsProvider);
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Grille d'établissements (filtrée par localisation)
                      EstablishmentGrid(
                        city: currentCity,
                        radius: searchRadius,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Carrousel d'événements (filtré par localisation)
                      EventsCarousel(
                        city: currentCity,
                        radius: searchRadius,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Modal de localisation
      locationModal: LocationModal(
        isOpen: _showLocationModal,
        onClose: () {
          setState(() {
            _showLocationModal = false;
          });
        },
      ),
    );
  }
}
```

### B. Providers pour Établissements et Événements Filtrés

```dart
// lib/core/providers/establishments_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/establishment_repository.dart';
import '../../data/models/establishment.dart';
import 'location_provider.dart';

final establishmentsProvider = FutureProvider<List<Establishment>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final radius = ref.watch(searchRadiusProvider);
  
  if (city == null) return [];
  
  final repository = EstablishmentRepository();
  return repository.getByLocation(
    latitude: city.latitude,
    longitude: city.longitude,
    radiusKm: radius,
  );
});

// lib/core/providers/events_provider.dart
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final radius = ref.watch(searchRadiusProvider);
  
  if (city == null) return [];
  
  final repository = EventRepository();
  return repository.getUpcomingEvents(
    city: city.name,
    radiusKm: radius,
  );
});
```

---

## 4. Mise à Jour de la Carte

### A. MapComponent avec Cercle de Périmètre

```dart
// lib/features/map/widgets/map_component.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/establishment.dart';

class MapComponent extends ConsumerWidget {
  final List<Establishment> establishments;

  const MapComponent({
    super.key,
    required this.establishments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(currentCityProvider);
    final radius = ref.watch(searchRadiusProvider);
    
    if (city == null) {
      return const Center(child: Text('Aucune localisation sélectionnée'));
    }

    final center = LatLng(city.latitude, city.longitude);
    
    // Créer le cercle de périmètre
    final circle = Circle(
      circleId: const CircleId('search_radius'),
      center: center,
      radius: radius * 1000, // Convertir km en mètres
      fillColor: const Color(0xFFFF751F).withOpacity(0.2),
      strokeColor: const Color(0xFFFF751F),
      strokeWidth: 2,
    );
    
    // Créer les marqueurs pour les établissements
    final markers = establishments
        .where((est) => est.latitude != null && est.longitude != null)
        .map((est) {
      return Marker(
        markerId: MarkerId(est.id),
        position: LatLng(est.latitude!, est.longitude!),
        infoWindow: InfoWindow(
          title: est.name,
          snippet: est.address,
        ),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: _calculateZoom(radius),
      ),
      circles: {circle},
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        // Optionnel : ajuster la vue pour inclure tous les marqueurs
      },
    );
  }

  double _calculateZoom(int radiusKm) {
    // Calculer le zoom approprié selon le rayon
    if (radiusKm <= 1) return 14;
    if (radiusKm <= 5) return 13;
    if (radiusKm <= 10) return 12;
    if (radiusKm <= 20) return 11;
    if (radiusKm <= 50) return 10;
    return 9;
  }
}
```

---

## 5. Checklist de Développement

- [ ] Créer modèle City avec villes principales
- [ ] Créer LocationProvider avec Riverpod
- [ ] Implémenter sauvegarde dans SharedPreferences
- [ ] Créer LocationModal avec header gradient
- [ ] Créer RadiusSelector avec logique adaptative
- [ ] Créer CityListTab avec recherche
- [ ] Créer FavoritesTab
- [ ] Créer RecentCitiesTab
- [ ] Implémenter toggleFavorite
- [ ] Créer badge de localisation dans HomeScreen
- [ ] Modifier EstablishmentGrid pour filtrer par localisation
- [ ] Modifier EventsCarousel pour filtrer par localisation
- [ ] Modifier MapComponent pour afficher cercle de périmètre
- [ ] Tester changement de ville → mise à jour page
- [ ] Tester changement de rayon → mise à jour cercle carte
- [ ] Tester favoris et historique
- [ ] Tester recherche de villes

---

## 6. Points Importants

1. La barre de recherche reste indépendante (sa propre logique)
2. Le changement de localisation met à jour :
   - La grille d'établissements
   - Le carrousel d'événements
   - La carte (centre + cercle de périmètre)
   - Tous les composants qui utilisent `currentCityProvider` et `searchRadiusProvider`
3. Rayons adaptatifs selon grande/petite ville (logique métier originale)
4. Favoris et historique sauvegardés localement
5. Synchronisation API si utilisateur connecté (via un autre provider)
6. Design cohérent avec le design system (orange/pink/rouge)

---

Ce prompt couvre le système de localisation complet avec modal, rayons adaptatifs, favoris, historique et impact sur toute la page. Prêt à être utilisé dans Cursor.