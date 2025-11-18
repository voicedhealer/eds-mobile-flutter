class EventEngagement {
  final String id;
  final String eventId;
  final String userId;
  final EngagementType type;
  final DateTime createdAt;

  EventEngagement({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory EventEngagement.fromJson(Map<String, dynamic> json) {
    return EventEngagement(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      type: EngagementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EngagementType.envie,
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum EngagementType {
  envie,
  ultraEnvie,
  intrigue,
  pasEnvie,
}

class EngagementStats {
  final int envie;
  final int ultraEnvie;
  final int intrigue;
  final int pasEnvie;

  EngagementStats({
    this.envie = 0,
    this.ultraEnvie = 0,
    this.intrigue = 0,
    this.pasEnvie = 0,
  });

  int get totalScore {
    return (envie * 1) +
        (ultraEnvie * 3) +
        (intrigue * 2) +
        (pasEnvie * -1);
  }

  double get gaugePercentage {
    final percentage = (totalScore / 15) * 100;
    return percentage.clamp(0, 150);
  }

  bool get isFireMode => gaugePercentage >= 150;
}

