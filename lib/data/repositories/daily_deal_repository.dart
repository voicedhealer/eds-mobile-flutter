import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/daily_deal.dart';
import '../../core/utils/deal_utils.dart';
import '../../core/utils/geolocation_utils.dart';

class DailyDealRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['RAILWAY_API_URL']!,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Récupère tous les bons plans actifs
  /// 
  /// **Endpoint Railway** : `GET /api/deals/all`
  /// **Paramètres** :
  /// - `limit` : Nombre maximum de bons plans à retourner (défaut: 12)
  /// 
  /// **Réponse** :
  /// ```json
  /// {
  ///   "success": true,
  ///   "deals": [...],
  ///   "total": 12
  /// }
  /// ```
  /// 
  /// **Filtrage côté API** :
  /// - `is_active = true`
  /// - `date_debut <= demain`
  /// - `date_fin >= aujourd'hui`
  /// - Tri par `created_at DESC`
  /// 
  /// **Filtrage côté client** :
  /// - Par localisation (ville + rayon)
  /// - Par horaires quotidiens (via `isDealActive`)
  /// - Par jours de récurrence (pour récurrents)
  Future<List<DailyDeal>> getAllDeals({
    String? city,
    int? radiusKm,
    int limit = 12,
  }) async {
    try {
      final response = await _dio.get(
        '/api/deals/all',
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final deals = (response.data['deals'] as List)
            .map((json) => DailyDeal.fromJson(json))
            .toList();

        // Filtrer par localisation si spécifiée
        List<DailyDeal> filteredDeals = deals;
        
        if (city != null && radiusKm != null) {
          filteredDeals = deals.where((deal) {
            final establishment = deal.establishment;
            
            // Si l'établissement a des coordonnées GPS
            if (establishment.latitude != null &&
                establishment.longitude != null) {
              // Utiliser le calcul de distance
              return GeolocationUtils.isWithinRadius(
                establishment.latitude!,
                establishment.longitude!,
                city,
                radiusKm,
              );
            }
            
            // Sinon, comparer par nom de ville
            return establishment.city?.toLowerCase() == city.toLowerCase();
          }).toList();
        }

        // Filtrer les bons plans actifs maintenant (horaires + récurrence)
        return filteredDeals
            .where((deal) => DealUtils.isDealActive(deal))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erreur récupération bons plans: $e');
      return [];
    }
  }

  /// Récupère les bons plans actifs d'un établissement spécifique
  /// 
  /// **Endpoint Railway** : `GET /api/deals/active/:establishmentId`
  /// 
  /// **Réponse** :
  /// ```json
  /// {
  ///   "success": true,
  ///   "deals": [...]
  /// }
  /// ```
  Future<List<DailyDeal>> getActiveDealsByEstablishment(
    String establishmentId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/deals/active/$establishmentId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['deals'] as List)
            .map((json) => DailyDeal.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Erreur récupération bons plans établissement: $e');
      return [];
    }
  }
}

