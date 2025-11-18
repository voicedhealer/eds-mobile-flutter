import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/establishment_repository.dart';
import '../../data/models/establishment.dart';

final establishmentRepositoryProvider =
    Provider((ref) => EstablishmentRepository());

final establishmentBySlugProvider =
    FutureProvider.family<Establishment?, String>((ref, slug) async {
  final repository = ref.watch(establishmentRepositoryProvider);
  return repository.getBySlug(slug);
});

