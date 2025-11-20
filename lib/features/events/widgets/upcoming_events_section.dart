import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/event.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/event_repository.dart';
import 'event_card.dart';

enum EventFilter { all, today, week, weekend }

final eventFilterProvider = StateProvider<EventFilter>((ref) => EventFilter.all);

final upcomingEventsSectionProvider = FutureProvider<List<Event>>((ref) async {
  final locationState = ref.watch(locationProvider);
  final city = locationState.currentCity;
  final filter = ref.watch(eventFilterProvider);
  
  final repository = EventRepository();
  final events = await repository.getUpcomingEvents(
    city: city?.name,
  );
  
  // Appliquer le filtre temporel
  return _applyTimeFilter(events, filter);
});

List<Event> _applyTimeFilter(List<Event> events, EventFilter filter) {
  final now = DateTime.now();
  
  switch (filter) {
    case EventFilter.today:
      return events.where((event) {
        final startDate = event.startDate;
        return startDate.year == now.year &&
            startDate.month == now.month &&
            startDate.day == now.day;
      }).toList();
      
    case EventFilter.week:
      final weekEnd = now.add(const Duration(days: 7));
      return events.where((event) {
        return event.startDate.isBefore(weekEnd) ||
            event.startDate.isAtSameMomentAs(weekEnd);
      }).toList();
      
    case EventFilter.weekend:
      return events.where((event) {
        final startDate = event.startDate;
        final weekday = startDate.weekday;
        final hour = startDate.hour;
        final minute = startDate.minute;
        
        // Vendredi à partir de 18h00
        if (weekday == 5 && (hour > 18 || (hour == 18 && minute >= 0))) {
          return true;
        }
        // Samedi toute la journée
        if (weekday == 6) {
          return true;
        }
        // Dimanche jusqu'à 23h00
        if (weekday == 7 && hour < 23) {
          return true;
        }
        
        return false;
      }).toList();
      
    case EventFilter.all:
    default:
      return events;
  }
}

class UpcomingEventsSection extends ConsumerWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsSectionProvider);
    final locationState = ref.watch(locationProvider);
    final city = locationState.currentCity;
    final radius = locationState.searchRadius;
    final filter = ref.watch(eventFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[50]!, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '🎉 Événements à venir',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171717),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Indicateur de localisation
                if (city != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${city.name} • Rayon ${radius}km',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 16),
                
                // Filtres rapides
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        ref,
                        'Aujourd\'hui',
                        EventFilter.today,
                        filter == EventFilter.today,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        ref,
                        'Cette semaine',
                        EventFilter.week,
                        filter == EventFilter.week,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        ref,
                        'Week-end',
                        EventFilter.weekend,
                        filter == EventFilter.weekend,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        ref,
                        'Tous',
                        EventFilter.all,
                        filter == EventFilter.all,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Scroll horizontal MANUEL des événements
          eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return _buildEmptyState(context, city, filter);
              }
              
              return SizedBox(
                height: 400, // Hauteur fixe pour les cards
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 320, // Largeur fixe pour chaque card
                      margin: const EdgeInsets.only(right: 16),
                      child: EventCard(
                        event: events[index],
                        onTap: () => context.push('/event/${events[index].id}'),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Color(0xFFFF751F),
                ),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(upcomingEventsSectionProvider);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bouton "Voir tous les événements"
          if (eventsAsync.hasValue && eventsAsync.value!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/events');
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text(
                    'Voir tous les événements',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF751F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    EventFilter filterValue,
    bool isSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(eventFilterProvider.notifier).state = filterValue;
      },
      selectedColor: const Color(0xFFFF751F),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.transparent : Colors.grey[300]!,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, City? city, EventFilter filter) {
    String message;
    switch (filter) {
      case EventFilter.today:
        message = 'Aucun événement aujourd\'hui près de ${city?.name ?? 'vous'}, mais de belles surprises vous attendent !';
        break;
      case EventFilter.week:
        message = 'Cette semaine est calme près de ${city?.name ?? 'vous'}, mais la semaine prochaine sera animée !';
        break;
      case EventFilter.weekend:
        message = 'Aucun événement ce week-end près de ${city?.name ?? 'vous'}, mais les professionnels préparent de belles surprises !';
        break;
      default:
        message = 'Aucun événement trouvé près de ${city?.name ?? 'vous'}. Les professionnels préparent de superbes événements pour vous !';
    }
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Découvrez vos futurs événements ici',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}


