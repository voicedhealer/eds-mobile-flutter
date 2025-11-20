import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DealEngagementRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['RAILWAY_API_URL']!,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Enregistre un engagement (liked/disliked) sur un bon plan
  /// 
  /// **Endpoint Railway** : `POST /api/deals/engagement`
  /// **Body** :
  /// ```json
  /// {
  ///   "dealId": "string",
  ///   "type": "liked" | "disliked",
  ///   "timestamp": "ISO 8601 string"
  /// }
  /// ```
  /// 
  /// **Logique backend** :
  /// - Vérifie que le bon plan existe
  /// - Récupère l'IP de l'utilisateur (via headers `x-forwarded-for` ou `x-real-ip`)
  /// - Vérifie si l'utilisateur a déjà donné son avis (anti-doublon par IP)
  /// - Si existe : met à jour l'engagement existant
  /// - Si n'existe pas : crée un nouvel engagement
  /// 
  /// **Table Supabase** : `deal_engagements`
  /// - `deal_id` : ID du bon plan
  /// - `establishment_id` : ID de l'établissement
  /// - `type` : 'liked' | 'disliked'
  /// - `user_ip` : IP de l'utilisateur (pour anti-doublon)
  /// - `timestamp` : Date/heure de l'engagement
  Future<bool> recordEngagement({
    required String dealId,
    required String type, // 'liked' | 'disliked'
  }) async {
    try {
      final response = await _dio.post(
        '/api/deals/engagement',
        data: {
          'dealId': dealId,
          'type': type,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Erreur enregistrement engagement: $e');
      return false;
    }
  }

  /// Récupère les statistiques d'engagement d'un bon plan ou d'un établissement
  /// 
  /// **Endpoint Railway** : `GET /api/deals/engagement`
  /// **Query Parameters** :
  /// - `dealId` : ID du bon plan (optionnel)
  /// - `establishmentId` : ID de l'établissement (optionnel)
  /// 
  /// **Réponse** :
  /// ```json
  /// {
  ///   "success": true,
  ///   "stats": {
  ///     "liked": 10,
  ///     "disliked": 2,
  ///     "total": 12,
  ///     "engagementRate": 83.33
  ///   },
  ///   "engagements": [...]
  /// }
  /// ```
  Future<DealEngagementStats?> getEngagementStats({
    String? dealId,
    String? establishmentId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (dealId != null) queryParams['dealId'] = dealId;
      if (establishmentId != null) queryParams['establishmentId'] = establishmentId;

      final response = await _dio.get(
        '/api/deals/engagement',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DealEngagementStats.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Erreur récupération stats engagement: $e');
      return null;
    }
  }
}

class DealEngagementStats {
  final int liked;
  final int disliked;
  final int total;
  final double engagementRate;

  DealEngagementStats({
    required this.liked,
    required this.disliked,
    required this.total,
    required this.engagementRate,
  });

  factory DealEngagementStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return DealEngagementStats(
      liked: stats['liked'] ?? 0,
      disliked: stats['disliked'] ?? 0,
      total: stats['total'] ?? 0,
      engagementRate: (stats['engagementRate'] ?? 0).toDouble(),
    );
  }
}

