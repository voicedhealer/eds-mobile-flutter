import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/city.dart';

class FavoritesTab extends ConsumerWidget {
  final List<City> favorites;
  final City? selectedCity;
  final Function(City) onCitySelected;

  const FavoritesTab({
    super.key,
    required this.favorites,
    this.selectedCity,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favorites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.star_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucune ville favorite',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ajoutez des villes à vos favoris depuis l\'onglet Villes',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: favorites.map((city) {
          final isSelected = selectedCity?.id == city.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue[400]! : Colors.grey[200]!,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.star,
                color: Colors.amber,
              ),
              title: Text(
                city.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              onTap: () => onCitySelected(city),
            ),
          );
        }).toList(),
      ),
    );
  }
}

