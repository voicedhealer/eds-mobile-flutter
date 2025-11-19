import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/models/establishment.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository());

final searchResultsProvider = FutureProvider.family<List<Establishment>, SearchParams>((ref, params) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.search(
    envie: params.envie,
    ville: params.ville,
    filter: params.filter,
    page: params.page,
    limit: params.limit,
  );
});

class SearchParams {
  final String envie;
  final String? ville;
  final String filter;
  final int page;
  final int limit;

  SearchParams({
    required this.envie,
    this.ville,
    this.filter = 'popular',
    this.page = 1,
    this.limit = 15,
  });

  SearchParams copyWith({
    String? envie,
    String? ville,
    String? filter,
    int? page,
    int? limit,
  }) {
    return SearchParams(
      envie: envie ?? this.envie,
      ville: ville ?? this.ville,
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
        other.filter == filter &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return Object.hash(envie, ville, filter, page, limit);
  }
}

