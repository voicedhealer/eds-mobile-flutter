import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/event.dart';
import '../../../data/models/event_engagement.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../core/utils/error_handler.dart';
import '../../../core/providers/establishment_provider.dart' as providers;
import '../widgets/event_engagement_buttons.dart';
import '../widgets/engagement_gauge.dart';

final eventEngagementStatsProvider = FutureProvider.family<EngagementStats, String>((ref, eventId) async {
  final repository = ref.watch(providers.eventRepositoryProvider);
  return repository.getEngagementStats(eventId);
});

final userEngagementProvider = FutureProvider.family<EngagementType?, String>((ref, eventId) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  
  final response = await Supabase.instance.client
      .from('event_engagements')
      .select('type')
      .eq('event_id', eventId)
      .eq('user_id', user.id)
      .maybeSingle();
  
  if (response == null) return null;
  return EngagementType.values.firstWhere(
    (e) => e.name == response['type'],
    orElse: () => EngagementType.envie,
  );
});

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(eventEngagementStatsProvider(widget.event.id));
    final userEngagementAsync = ref.watch(userEngagementProvider(widget.event.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.event.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.event.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.event, size: 64),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.event.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      app_date_utils.DateUtils.formatDateTime(widget.event.startDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                if (widget.event.endDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Jusqu\'au ${app_date_utils.DateUtils.formatDateTime(widget.event.endDate!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                if (widget.event.price != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.euro, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.event.price!.toStringAsFixed(2)} ${widget.event.priceUnit ?? '€'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
                if (widget.event.maxCapacity != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Capacité : ${widget.event.maxCapacity} personnes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                if (widget.event.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Engagement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                statsAsync.when(
                  data: (stats) {
                    final userEngagement = userEngagementAsync.valueOrNull;
                    return Column(
                      children: [
                        EngagementGauge(
                          percentage: stats.gaugePercentage,
                          stats: stats,
                        ),
                        const SizedBox(height: 24),
                        EventEngagementButtons(
                          eventId: widget.event.id,
                          stats: stats,
                          userEngagement: userEngagement,
                          onEngage: (type) => _handleEngage(type),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Erreur: $error'),
                ),
                const SizedBox(height: 24),
                _EstablishmentButton(establishmentId: widget.event.establishmentId),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEngage(EngagementType type) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ErrorHandler.showInfo(context, 'Connectez-vous pour vous engager');
        context.push('/login');
      }
      return;
    }

    try {
      final repository = ref.read(providers.eventRepositoryProvider);
      await repository.engage(
        eventId: widget.event.id,
        userId: user.id,
        type: type,
      );
      
      ref.invalidate(eventEngagementStatsProvider(widget.event.id));
      ref.invalidate(userEngagementProvider(widget.event.id));
      
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Engagement enregistré !');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }
}

class _EstablishmentButton extends ConsumerWidget {
  final String establishmentId;

  const _EstablishmentButton({required this.establishmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishmentAsync = ref.watch(providers.establishmentByIdProvider(establishmentId));

    return establishmentAsync.when(
      data: (establishment) {
        if (establishment == null) {
          return const SizedBox.shrink();
        }
        return ElevatedButton.icon(
          onPressed: () {
            context.push('/establishment/${establishment.slug}');
          },
          icon: const Icon(Icons.store),
          label: Text('Voir ${establishment.name}'),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

