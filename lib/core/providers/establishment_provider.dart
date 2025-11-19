import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/establishment_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/models/establishment.dart';
import '../../data/models/event.dart';

final establishmentRepositoryProvider =
    Provider((ref) => EstablishmentRepository());

final establishmentBySlugProvider =
    FutureProvider.family<Establishment?, String>((ref, slug) async {
  final repository = ref.watch(establishmentRepositoryProvider);
  return repository.getBySlug(slug);
});

final eventRepositoryProvider = Provider((ref) => EventRepository());

final eventByIdProvider = FutureProvider.family<Event?, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getById(eventId);
});

final establishmentByIdProvider = FutureProvider.family<Establishment?, String>((ref, id) async {
  final repository = ref.watch(establishmentRepositoryProvider);
  return repository.getById(id);
});

