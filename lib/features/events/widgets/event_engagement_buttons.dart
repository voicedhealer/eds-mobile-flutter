import 'package:flutter/material.dart';
import '../../../data/models/event_engagement.dart';

class EventEngagementButtons extends StatelessWidget {
  final String eventId;
  final EngagementStats stats;
  final EngagementType? userEngagement;
  final Function(EngagementType) onEngage;

  const EventEngagementButtons({
    super.key,
    required this.eventId,
    required this.stats,
    this.userEngagement,
    required this.onEngage,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _EngagementButton(
        type: EngagementType.envie,
        label: '👍 Envie',
        color: Colors.green,
        count: stats.envie,
        isActive: userEngagement == EngagementType.envie,
        onTap: () => onEngage(EngagementType.envie),
      ),
      _EngagementButton(
        type: EngagementType.ultraEnvie,
        label: '🔥 Grande Envie',
        color: Colors.orange,
        count: stats.ultraEnvie,
        isActive: userEngagement == EngagementType.ultraEnvie,
        onTap: () => onEngage(EngagementType.ultraEnvie),
      ),
      _EngagementButton(
        type: EngagementType.intrigue,
        label: '🔍 Découvrir',
        color: Colors.blue,
        count: stats.intrigue,
        isActive: userEngagement == EngagementType.intrigue,
        onTap: () => onEngage(EngagementType.intrigue),
      ),
      _EngagementButton(
        type: EngagementType.pasEnvie,
        label: '👎 Pas Envie',
        color: Colors.red,
        count: stats.pasEnvie,
        isActive: userEngagement == EngagementType.pasEnvie,
        onTap: () => onEngage(EngagementType.pasEnvie),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final EngagementType type;
  final String label;
  final Color color;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _EngagementButton({
    required this.type,
    required this.label,
    required this.color,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? color : Colors.white,
            foregroundColor: isActive ? Colors.white : color,
            side: BorderSide(color: color, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

