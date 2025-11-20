import '../../data/models/daily_deal.dart';

class DealUtils {
  /// Vérifie si un bon plan est actif (dans sa période de validité)
  static bool isDealActive(DailyDeal deal) {
    if (!deal.isActive) return false;

    final now = DateTime.now();

    // Pour les bons plans récurrents
    if (deal.isRecurring) {
      // Vérifier si on n'a pas dépassé la date de fin de récurrence
      if (deal.recurrenceEndDate != null) {
        if (now.isAfter(deal.recurrenceEndDate!)) {
          return false;
        }
      }

      // Vérifier les jours de la semaine pour la récurrence hebdomadaire
      if (deal.recurrenceType == 'weekly' &&
          deal.recurrenceDays != null &&
          deal.recurrenceDays!.isNotEmpty) {
        final currentDay = now.weekday; // 1 = Lundi, 7 = Dimanche
        if (!deal.recurrenceDays!.contains(currentDay)) {
          return false;
        }
      }
    } else {
      // Pour les bons plans non récurrents, vérifier les dates
      if (now.isBefore(deal.dateDebut) || now.isAfter(deal.dateFin)) {
        return false;
      }
    }

    // Vérifier les horaires (pour tous les types de bons plans)
    if (deal.heureDebut == null && deal.heureFin == null) {
      return true; // Actif toute la journée
    }

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Si les deux heures sont identiques, considérer comme actif toute la journée
    if (deal.heureDebut != null &&
        deal.heureFin != null &&
        deal.heureDebut == deal.heureFin) {
      return true;
    }

    // Si seulement heure de début définie
    if (deal.heureDebut != null && deal.heureFin == null) {
      return currentTime.compareTo(deal.heureDebut!) >= 0;
    }

    // Si seulement heure de fin définie
    if (deal.heureDebut == null && deal.heureFin != null) {
      return currentTime.compareTo(deal.heureFin!) <= 0;
    }

    // Si les deux heures sont définies
    if (deal.heureDebut != null && deal.heureFin != null) {
      return currentTime.compareTo(deal.heureDebut!) >= 0 &&
          currentTime.compareTo(deal.heureFin!) <= 0;
    }

    return true;
  }

  /// Formater uniquement la date/jour d'un bon plan (sans les horaires)
  static String formatDateForFront(DailyDeal deal) {
    // Pour les bons plans récurrents
    if (deal.isRecurring) {
      if (deal.recurrenceType == 'weekly' &&
          deal.recurrenceDays != null &&
          deal.recurrenceDays!.isNotEmpty) {
        const dayNames = [
          '',
          'Lundi',
          'Mardi',
          'Mercredi',
          'Jeudi',
          'Vendredi',
          'Samedi',
          'Dimanche'
        ];
        final selectedDays = deal.recurrenceDays!
            .map((day) => dayNames[day])
            .toList();

        // Grouper les jours de semaine et weekend
        const weekdays = [1, 2, 3, 4, 5]; // Lundi à Vendredi
        const weekends = [6, 7]; // Samedi et Dimanche

        final hasWeekdays = deal.recurrenceDays!.any((day) => weekdays.contains(day));
        final hasWeekends = deal.recurrenceDays!.any((day) => weekends.contains(day));

        // Vérifier si c'est exactement tous les jours de semaine
        final isAllWeekdays = weekdays.every((day) => deal.recurrenceDays!.contains(day));
        // Vérifier si c'est exactement tous les jours de weekend
        final isAllWeekends = weekends.every((day) => deal.recurrenceDays!.contains(day));
        // Vérifier si c'est tous les jours
        final isAllDays = isAllWeekdays && isAllWeekends;

        if (isAllDays) {
          return 'Tous les jours';
        } else if (isAllWeekdays && !hasWeekends) {
          return 'En semaine';
        } else if (isAllWeekends && !hasWeekdays) {
          return 'Le weekend';
        } else {
          return 'Tous les ${selectedDays.join(', ')}';
        }
      }

      if (deal.recurrenceType == 'monthly') {
        return 'Tous les mois';
      }

      // Récurrence quotidienne par défaut
      return 'Tous les jours';
    }

    // Pour les bons plans non récurrents
    final day = deal.dateDebut.day.toString().padLeft(2, '0');
    final month = _getMonthName(deal.dateDebut.month);
    final year = deal.dateDebut.year;

    return 'Le $day $month $year';
  }

  /// Formater la date complète d'un bon plan
  static String formatDealDate(DailyDeal deal) {
    final dateDebut = deal.dateDebut;
    final dateFin = deal.dateFin;

    // Si c'est le même jour
    final isSameDay = dateDebut.year == dateFin.year &&
        dateDebut.month == dateFin.month &&
        dateDebut.day == dateFin.day;

    if (isSameDay) {
      final today = DateTime.now();
      final isToday = dateDebut.year == today.year &&
          dateDebut.month == today.month &&
          dateDebut.day == today.day;

      if (isToday) {
        return 'Aujourd\'hui';
      } else {
        final dayName = _getDayName(dateDebut.weekday);
        final dayNumber = dateDebut.day;
        final monthName = _getMonthName(dateDebut.month);
        return 'Le $dayName $dayNumber $monthName';
      }
    }

    // Si c'est sur plusieurs jours
    final dateDebutStr = '${dateDebut.day} ${_getMonthName(dateDebut.month)}';
    final dateFinStr = '${dateFin.day} ${_getMonthName(dateFin.month)}';

    return 'Du $dateDebutStr au $dateFinStr';
  }

  /// Formater le prix avec le symbole €
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} €';
  }

  /// Calculer le pourcentage de réduction
  static int calculateDiscount(double? originalPrice, double? discountedPrice) {
    if (originalPrice == null ||
        discountedPrice == null ||
        originalPrice <= discountedPrice) {
      return 0;
    }

    return (((originalPrice - discountedPrice) / originalPrice) * 100).round();
  }

  static String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  static String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return months[month - 1];
  }
}

