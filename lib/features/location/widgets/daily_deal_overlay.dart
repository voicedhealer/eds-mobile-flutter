import 'package:flutter/material.dart';
import '../../../data/models/daily_deal.dart';

class DailyDealOverlay extends StatelessWidget {
  final DailyDeal deal;

  const DailyDealOverlay({
    super.key,
    required this.deal,
  });

  String _getOverlayText() {
    // Prioriser les horaires sur les modalités
    if (deal.heureDebut != null && deal.heureFin != null) {
      return 'de ${deal.heureDebut} à ${deal.heureFin}';
    }
    
    if (deal.heureDebut != null) {
      return 'à partir de ${deal.heureDebut}';
    }
    
    if (deal.heureFin != null) {
      return 'jusqu\'à ${deal.heureFin}';
    }
    
    // Si pas d'horaires, afficher la modalité si disponible
    if (deal.modality != null) {
      return deal.modality!;
    }
    
    // Par défaut, toute la journée
    return 'toute la journée';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Badge "Bon plan du jour"
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF751F), Color(0xFFFF6B00)],
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎯', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text(
                'BON PLAN DU JOUR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Détails du bon plan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.orange[50]!.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(color: Colors.orange[200]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 10,
                color: Colors.orange[800],
              ),
              const SizedBox(width: 4),
              Text(
                _getOverlayText(),
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


