import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/event.dart';
import '../../../data/models/event_engagement.dart';

class EventOverlay extends StatelessWidget {
  final Event event;
  final bool isInProgress;
  final EngagementStats? engagement;
  final String? establishmentSlug;

  const EventOverlay({
    super.key,
    required this.event,
    required this.isInProgress,
    this.engagement,
    this.establishmentSlug,
  });

  String _formatEventDate() {
    final startDate = event.startDate;
    final endDate = event.endDate;
    final now = DateTime.now();
    
    // Calculer la durée en jours
    final durationInDays = endDate != null
        ? endDate.difference(startDate).inDays
        : 0;
    
    // Détecter si c'est un événement récurrent (durée > 1 jour)
    final isRecurringEvent = durationInDays > 1;
    
    if (isRecurringEvent) {
      // Pour les événements récurrents, afficher la plage de dates + horaires
      final startDay = startDate.day;
      final startMonth = _getMonthName(startDate.month);
      final endDay = endDate?.day ?? startDay;
      final endMonth = endDate != null 
          ? _getMonthName(endDate.month) 
          : startMonth;
      
      final startTime = _formatTime(startDate);
      final endTime = endDate != null ? _formatTime(endDate) : startTime;
      
      String dateRange;
      if (startMonth == endMonth) {
        dateRange = '$startDay-$endDay $startMonth';
      } else {
        dateRange = '$startDay $startMonth - $endDay $endMonth';
      }
      
      return '$dateRange • $startTime-$endTime';
    } else {
      // Pour les événements ponctuels
      final isToday = startDate.year == now.year &&
          startDate.month == now.month &&
          startDate.day == now.day;
      final isTomorrow = startDate.year == now.year &&
          startDate.month == now.month &&
          startDate.day == now.day + 1;
      
      final endTime = endDate != null ? _formatTime(endDate) : null;
      final startTime = _formatTime(startDate);
      
      if (isToday) {
        return endTime != null 
            ? 'Aujourd\'hui • $startTime-$endTime'
            : 'Aujourd\'hui • $startTime';
      } else if (isTomorrow) {
        return endTime != null 
            ? 'Demain • $startTime-$endTime'
            : 'Demain • $startTime';
      } else {
        final dayName = _getDayName(startDate.weekday);
        final dayNumber = startDate.day;
        final monthName = _getMonthName(startDate.month);
        return endTime != null 
            ? '$dayName $dayNumber $monthName • $startTime-$endTime'
            : '$dayName $dayNumber $monthName • $startTime';
      }
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return months[month - 1];
  }

  String _getBadgeIcon() {
    if (engagement?.isFireMode == true) return '🔥';
    final percentage = engagement?.gaugePercentage ?? 0.0;
    if (percentage >= 100) return '🏆';
    if (percentage >= 50) return '⭐';
    if (percentage >= 25) return '👍';
    return '❄️';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7F00FE).withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Première ligne : Badge + Titre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isInProgress ? Colors.green : Colors.yellow[400],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 10,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      isInProgress ? 'Évent en cours' : 'Évent à venir',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isInProgress ? Colors.green[300] : Colors.yellow[300],
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Deuxième ligne : Date/heure et pourcentage d'engagement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatEventDate(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Système de vote - Affichage simple icône + pourcentage
              if (engagement != null)
                Row(
                  children: [
                    Text(
                      _getBadgeIcon(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${engagement!.gaugePercentage.round()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Troisième ligne : Prix et bouton Voir plus
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (event.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.euro,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.price}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                
                // Bouton Voir plus
                TextButton.icon(
                  onPressed: () {
                    if (establishmentSlug != null) {
                      context.push('/establishment/$establishmentSlug');
                    }
                  },
                  icon: const Icon(
                    Icons.open_in_new,
                    size: 10,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'Voir plus',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

