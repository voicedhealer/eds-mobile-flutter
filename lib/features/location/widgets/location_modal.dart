import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/city.dart';
import 'radius_selector.dart';
import 'city_list_tab.dart';
import 'favorites_tab.dart';
import 'recent_cities_tab.dart';

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
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? const Color(0xFFFF751F) : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
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
          onCitySelected: (City city) {
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

