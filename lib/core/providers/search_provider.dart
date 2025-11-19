import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/models/establishment.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository());

final searchResultsProvider = FutureProvider.family<List<Establishment>, SearchParams>((ref, params) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.search(
    envie: params.envie,
    ville: params.ville,
    radiusKm: params.radiusKm,
    filter: params.filter,
    page: params.page,
    limit: params.limit,
  );
});

class SearchParams {
  final String envie;
  final String ville; // OBLIGATOIRE maintenant
  final int radiusKm; // Périmètre adaptatif selon la ville
  final String filter;
  final int page;
  final int limit;

  SearchParams({
    required this.envie,
    required this.ville, // required au lieu de String?
    this.radiusKm = 10, // Valeur par défaut (sera adaptée selon la ville)
    this.filter = 'popular',
    this.page = 1,
    this.limit = 15,
  });

  // Méthode pour déterminer le rayon par défaut selon la ville
  static int getDefaultRadius(String? ville, {int? establishmentCount}) {
    final largeCities = [
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

    if (ville == null) return 10;

    final isLargeCity = largeCities.any((city) =>
            ville.toLowerCase().contains(city.toLowerCase()) ||
            city.toLowerCase().contains(ville.toLowerCase())) ||
        (establishmentCount != null && establishmentCount > 50);

    return isLargeCity ? 1 : 10; // 1km pour grandes villes, 10km pour petites
  }

  SearchParams copyWith({
    String? envie,
    String? ville,
    int? radiusKm,
    String? filter,
    int? page,
    int? limit,
  }) {
    return SearchParams(
      envie: envie ?? this.envie,
      ville: ville ?? this.ville,
      radiusKm: radiusKm ?? this.radiusKm,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams &&
        other.envie == envie &&
        other.ville == ville &&
        other.radiusKm == radiusKm &&
        other.filter == filter &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return Object.hash(envie, ville, radiusKm, filter, page, limit);
  }
}

