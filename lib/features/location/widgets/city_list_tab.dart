import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/city.dart';
import '../../../core/providers/location_provider.dart';

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
      
      // Recherche dans les villes principales
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

