import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/filter_bar.dart';
import '../../establishments/widgets/establishment_card.dart';
import '../../../core/providers/search_provider.dart';

class SearchResultsScreen extends ConsumerWidget {
  final String envie;
  final String? ville;

  const SearchResultsScreen({
    super.key,
    required this.envie,
    this.ville,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchParams = SearchParams(
      envie: envie,
      ville: ville,
      filter: 'popular',
    );
    
    final resultsAsync = ref.watch(searchResultsProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats pour "$envie"'),
      ),
      body: Column(
        children: [
          FilterBar(
            activeFilter: FilterType.popular,
            onFilterChanged: (filter) {
              // TODO: Implémenter le changement de filtre
            },
          ),
          Expanded(
            child: resultsAsync.when(
              data: (establishments) {
                if (establishments.isEmpty) {
                  return const Center(
                    child: Text('Aucun résultat trouvé'),
                  );
                }
                return ListView.builder(
                  itemCount: establishments.length,
                  itemBuilder: (context, index) {
                    return EstablishmentCard(
                      establishment: establishments[index],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

