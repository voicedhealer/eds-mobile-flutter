import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/filter_bar.dart';
import '../../establishments/widgets/establishment_card.dart';
import '../../../data/models/establishment.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';

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
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  List<Establishment> _allEstablishments = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(filterProvider);
    
    final searchParams = SearchParams(
      envie: widget.envie,
      ville: widget.ville,
      filter: filterTypeToString(currentFilter),
      page: _currentPage,
      limit: 15,
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
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'Aucun résultat trouvé',
                    message: 'Essayez avec d\'autres critères de recherche',
                  );
                }
                // Mettre à jour la liste complète et vérifier s'il y a plus de résultats
                if (_currentPage == 1) {
                  _allEstablishments = establishments;
                } else {
                  _allEstablishments.addAll(establishments);
                }
                _hasMore = establishments.length >= searchParams.limit;

                return RefreshIndicator(
                  onRefresh: () async {
                    _currentPage = 1;
                    _allEstablishments.clear();
                    ref.invalidate(searchResultsProvider(searchParams));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _hasMore ? _allEstablishments.length + 1 : _allEstablishments.length,
                    itemBuilder: (context, index) {
                      if (index == _allEstablishments.length) {
                        // Bouton "Charger plus"
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentPage++;
                                });
                              },
                              child: const Text('Charger plus'),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EstablishmentCard(
                          establishment: _allEstablishments[index],
                          onTap: () {
                            context.push('/establishment/${_allEstablishments[index].slug}');
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(searchResultsProvider(searchParams));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

