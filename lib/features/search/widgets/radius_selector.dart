import 'package:flutter/material.dart';

class RadiusOption {
  final int value;
  final String label;

  RadiusOption({required this.value, required this.label});
}

class RadiusSelector extends StatelessWidget {
  final String? selectedCity;
  final int selectedRadius;
  final Function(int) onRadiusChanged;
  final int? establishmentCount; // Pour détection dynamique

  const RadiusSelector({
    super.key,
    required this.selectedCity,
    required this.selectedRadius,
    required this.onRadiusChanged,
    this.establishmentCount,
  });

  // Liste des grandes villes françaises
  static const List<String> largeCities = [
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
    'Strasbourg',
    'Montpellier',
    'Bordeaux',
    'Lille',
    'Rennes',
    'Reims',
    'Saint-Étienne',
    'Toulon',
    'Le Havre',
    'Angers',
    'Grenoble',
    'Villeurbanne',
    'Le Mans',
    'Aix-en-Provence',
  ];

  bool get _isLargeCity {
    if (selectedCity == null) return false;

    // Vérifier si la ville est dans la liste des grandes villes
    final isInLargeCitiesList = largeCities.any((city) =>
        selectedCity!.toLowerCase().contains(city.toLowerCase()) ||
        city.toLowerCase().contains(selectedCity!.toLowerCase()));

    // OU si on a beaucoup d'établissements (> 50)
    final hasManyEstablishments =
        establishmentCount != null && establishmentCount! > 50;

    return isInLargeCitiesList || hasManyEstablishments;
  }

  List<RadiusOption> get _adaptiveRadiusOptions {
    if (_isLargeCity) {
      // Rayons plus petits pour les grandes villes
      return [
        RadiusOption(value: 1, label: '1km'),
        RadiusOption(value: 5, label: '5km'),
        RadiusOption(value: 10, label: '10km'),
        RadiusOption(value: 20, label: '20km'),
        RadiusOption(value: 50, label: '50km'),
      ];
    } else {
      // Rayons normaux pour les petites villes
      return [
        RadiusOption(value: 10, label: '10km'),
        RadiusOption(value: 20, label: '20km'),
        RadiusOption(value: 50, label: '50km'),
        RadiusOption(value: 100, label: 'Toute la région'),
      ];
    }
  }

  int get _defaultRadius => _isLargeCity ? 1 : 10;

  @override
  Widget build(BuildContext context) {
    final options = _adaptiveRadiusOptions;
    final currentRadius = selectedRadius > 0 ? selectedRadius : _defaultRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Périmètre de recherche *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentRadius == option.value;
            return ChoiceChip(
              label: Text(
                option.label,
                style: TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onRadiusChanged(option.value);
              },
              selectedColor: const Color(0xFFFF751F),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}

