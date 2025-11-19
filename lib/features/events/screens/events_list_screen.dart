import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/event_card.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/geolocation_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

final upcomingEventsProvider = FutureProvider.family<List<Event>, String?>((ref, city) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getUpcomingEvents(city: city);
});

class EventsListScreen extends ConsumerStatefulWidget {
  final String? city;

  const EventsListScreen({
    super.key,
    this.city,
  });

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.city;
    _loadUserCity();
  }

  Future<void> _loadUserCity() async {
    if (_selectedCity == null) {
      final geolocationService = GeolocationService();
      final city = await geolocationService.getCurrentCity();
      if (city != null && mounted) {
        setState(() => _selectedCity = city);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider(_selectedCity));

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCity != null 
            ? 'Événements à $_selectedCity' 
            : 'Événements à venir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCityFilterDialog(context),
            tooltip: 'Filtrer par ville',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(upcomingEventsProvider(_selectedCity));
        },
        child: eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return EmptyState(
                icon: Icons.event_busy,
                title: 'Aucun événement à venir',
                message: _selectedCity != null
                    ? 'Aucun événement trouvé pour $_selectedCity'
                    : 'Aucun événement trouvé',
                action: ElevatedButton(
                  onPressed: () => _showCityFilterDialog(context),
                  child: const Text('Changer de ville'),
                ),
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
                  onTap: () {
                    context.push('/event/${events[index].id}');
                  },
                ),
              );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorState(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(upcomingEventsProvider(_selectedCity));
            },
          ),
        ),
      ),
    );
  }

  void _showCityFilterDialog(BuildContext context) {
    final cityController = TextEditingController(text: _selectedCity);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par ville'),
        content: TextField(
          controller: cityController,
          decoration: const InputDecoration(
            labelText: 'Ville',
            hintText: 'Paris, Lyon, Marseille...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedCity = null);
              Navigator.of(context).pop();
            },
            child: const Text('Toutes les villes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final city = cityController.text.trim();
              setState(() => _selectedCity = city.isEmpty ? null : city);
              Navigator.of(context).pop();
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }
}

