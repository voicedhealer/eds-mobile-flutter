import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class RailwayApiClient {
  final Dio _dio;
  
  RailwayApiClient() : _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['RAILWAY_API_URL'] ?? '',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  )) {
    final baseUrl = dotenv.env['RAILWAY_API_URL'] ?? '';
    if (baseUrl.isEmpty) {
      print('⚠️ RAILWAY_API_URL non configurée dans .env');
      print('   Railway API ne fonctionnera pas sans cette URL');
    } else {
      print('✅ Railway API configurée: $baseUrl');
    }
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final client = supabase;
        if (client != null) {
          final session = client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('❌ Erreur Railway API: ${error.message}');
        print('   URL: ${error.requestOptions.uri}');
        if (error.response != null) {
          print('   Status: ${error.response?.statusCode}');
          print('   Data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Future<List<Map<String, dynamic>>> searchEstablishments({
    required String envie,
    required String ville, // required
    int radiusKm = 10, // Périmètre adaptatif
    String filter = 'popular',
    int page = 1,
    int limit = 15,
  }) async {
    final baseUrl = dotenv.env['RAILWAY_API_URL'] ?? '';
    if (baseUrl.isEmpty) {
      print('⚠️ Railway API non configurée, retour d\'une liste vide');
      return [];
    }
    
    try {
      print('🔍 Recherche Railway API: envie=$envie, ville=$ville, rayon=${radiusKm}km');
      final response = await _dio.get('/api/recherche/filtered', queryParameters: {
        'envie': envie,
        'ville': ville,
        'rayon': radiusKm, // Paramètre rayon
        'filter': filter,
        'page': page,
        'limit': limit,
      });
      final establishments = List<Map<String, dynamic>>.from(response.data['establishments'] ?? []);
      print('✅ Railway API: ${establishments.length} établissement(s) trouvé(s)');
      return establishments;
    } catch (e) {
      print('❌ Erreur lors de la recherche Railway: $e');
      return [];
    }
  }
}

