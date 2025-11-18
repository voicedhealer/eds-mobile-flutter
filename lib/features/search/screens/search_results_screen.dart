import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/filter_bar.dart';
import '../../establishments/widgets/establishment_card.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/providers/filter_provider.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String envie;
  final String? ville;

  const SearchResultsScreen({
    super.key,
    required this.envie,
    this.ville,
  });

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(filterProvider);
    
    final searchParams = SearchParams(
      envie: widget.envie,
      ville: widget.ville,
      filter: filterTypeToString(currentFilter),
    );
    
    final resultsAsync = ref.watch(searchResultsProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats pour "${widget.envie}"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              context.push('/map?envie=${Uri.encodeComponent(widget.envie)}${widget.ville != null ? '&ville=${Uri.encodeComponent(widget.ville!)}' : ''}');
            },
            tooltip: 'Voir sur la carte',
          ),
        ],
      ),
      body: Column(
        children: [
          FilterBar(
            activeFilter: currentFilter,
            onFilterChanged: (filter) {
              ref.read(filterProvider.notifier).setFilter(filter);
            },
          ),
          Expanded(
            child: resultsAsync.when(
              data: (establishments) {
                if (establishments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat trouvé',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez avec d\'autres critères de recherche',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(searchResultsProvider(searchParams));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: establishments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EstablishmentCard(
                          establishment: establishments[index],
                          onTap: () {
                            context.push('/establishment/${establishments[index].slug}');
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(searchResultsProvider(searchParams));
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

