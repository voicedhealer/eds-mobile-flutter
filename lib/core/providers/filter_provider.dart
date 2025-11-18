import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/search/widgets/filter_bar.dart';

class FilterNotifier extends StateNotifier<FilterType> {
  FilterNotifier() : super(FilterType.popular);

  void setFilter(FilterType filter) {
    state = filter;
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterType>((ref) {
  return FilterNotifier();
});

String filterTypeToString(FilterType filter) {
  switch (filter) {
    case FilterType.popular:
      return 'popular';
    case FilterType.wanted:
      return 'wanted';
    case FilterType.cheap:
      return 'cheap';
    case FilterType.premium:
      return 'premium';
    case FilterType.newest:
      return 'newest';
    case FilterType.rating:
      return 'rating';
  }
}

