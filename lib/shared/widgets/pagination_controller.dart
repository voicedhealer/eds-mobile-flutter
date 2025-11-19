import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationController extends StateNotifier<int> {
  PaginationController() : super(1);

  void nextPage() {
    state = state + 1;
  }

  void previousPage() {
    if (state > 1) {
      state = state - 1;
    }
  }

  void goToPage(int page) {
    if (page >= 1) {
      state = page;
    }
  }

  void reset() {
    state = 1;
  }
}

final paginationControllerProvider = StateNotifierProvider<PaginationController, int>((ref) {
  return PaginationController();
});

