import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RailwayApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['RAILWAY_API_URL']!,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  RailwayApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<Map<String, dynamic>>> searchEstablishments({
    required String envie,
    String? ville,
    String filter = 'popular',
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _dio.get('/api/recherche/filtered', queryParameters: {
      'envie': envie,
      if (ville != null) 'ville': ville,
      'filter': filter,
      'page': page,
      'limit': limit,
    });
    return List<Map<String, dynamic>>.from(response.data['establishments'] ?? []);
  }
}

