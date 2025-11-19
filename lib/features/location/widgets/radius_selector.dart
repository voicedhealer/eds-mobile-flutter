import 'package:flutter/material.dart';

class RadiusOption {
  final int value;
  final String label;

  RadiusOption({required this.value, required this.label});
}

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

