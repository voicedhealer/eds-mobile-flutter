import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

final upcomingEventsProvider = FutureProvider.family<List<Event>, String?>((ref, city) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getUpcomingEvents(city: city);
});

class EventsListScreen extends ConsumerWidget {
  final String? city;

  const EventsListScreen({
    super.key,
    this.city,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider(city));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements à venir'),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text('Aucun événement à venir'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  event: events[index],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}

