import 'package:flutter/material.dart';

enum FilterType {
  popular,
  wanted,
  cheap,
  premium,
  newest,
  rating,
}

class FilterBar extends StatelessWidget {
  final FilterType? activeFilter;
  final Function(FilterType) onFilterChanged;

  const FilterBar({
    super.key,
    this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      _FilterItem(
        type: FilterType.popular,
        label: 'Populaire',
        icon: Icons.trending_up,
      ),
      _FilterItem(
        type: FilterType.wanted,
        label: 'Désirés ++',
        icon: Icons.favorite,
      ),
      _FilterItem(
        type: FilterType.cheap,
        label: 'Les - cher',
        icon: Icons.attach_money,
      ),
      _FilterItem(
        type: FilterType.premium,
        label: 'Notre sélection',
        icon: Icons.star,
      ),
      _FilterItem(
        type: FilterType.newest,
        label: 'Nouveaux',
        icon: Icons.access_time,
      ),
      _FilterItem(
        type: FilterType.rating,
        label: 'Mieux notés',
        icon: Icons.star_rate,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isActive = activeFilter == filter.type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(filter.icon, size: 16),
                    const SizedBox(width: 4),
                    Text(filter.label),
                  ],
                ),
                selected: isActive,
                onSelected: (selected) {
                  onFilterChanged(filter.type);
                },
                backgroundColor: Colors.grey[200],
                selectedColor: const Color(0xFFFF751F),
                labelStyle: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterItem {
  final FilterType type;
  final String label;
  final IconData icon;

  _FilterItem({
    required this.type,
    required this.label,
    required this.icon,
  });
}

