import 'package:flutter/material.dart';
import '../../../data/models/event_engagement.dart';

class EngagementGauge extends StatelessWidget {
  final double percentage;
  final EngagementStats stats;

  const EngagementGauge({
    super.key,
    required this.percentage,
    required this.stats,
  });

  Color _getGaugeColor(double percentage) {
    if (percentage >= 150) return Colors.purple;
    if (percentage >= 100) return Colors.amber;
    if (percentage >= 75) return Colors.orange;
    if (percentage >= 50) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isFire = percentage >= 150;
    final normalizedPercentage = (percentage / 150).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          children: [
            LinearProgressIndicator(
              value: normalizedPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getGaugeColor(percentage),
              ),
              minHeight: 20,
            ),
            if (isFire)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.3),
                        Colors.purple.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isFire)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🔥 C\'EST LE FEU ! 🔥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          )
        else
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}

