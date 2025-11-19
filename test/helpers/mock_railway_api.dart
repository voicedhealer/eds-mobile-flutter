import 'package:mockito/mockito.dart';
import 'package:envie2sortir/core/services/railway_api_client.dart';
import 'package:dio/dio.dart';

// Mock pour RailwayApiClient
class MockRailwayApiClient extends Mock implements RailwayApiClient {}

// Helper pour créer des réponses mockées
class RailwayApiMocks {
  static List<Map<String, dynamic>> createEstablishmentResponse({
    int count = 3,
  }) {
    return List.generate(count, (index) => {
      'id': 'est_$index',
      'name': 'Establishment $index',
      'slug': 'establishment-$index',
      'address': '${index} Test Street',
      'city': 'Paris',
      'country': 'France',
      'specialites': 'Restaurant',
      'status': 'approved',
      'subscription': 'FREE',
      'owner_id': 'owner_$index',
      'views_count': index * 10,
      'clicks_count': index * 5,
      'total_comments': index * 2,
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    });
  }

  static DioException createDioException({
    int? statusCode,
    String message = 'Network error',
  }) {
    return DioException(
      requestOptions: RequestOptions(path: '/search'),
      response: statusCode != null
          ? Response(
              statusCode: statusCode,
              requestOptions: RequestOptions(path: '/search'),
              data: {'error': message},
            )
          : null,
      type: DioExceptionType.connectionTimeout,
      error: message,
    );
  }
}

