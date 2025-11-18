import '../models/establishment.dart';
import '../../core/services/railway_api_client.dart';

class SearchRepository {
  final RailwayApiClient _apiClient = RailwayApiClient();

  Future<List<Establishment>> search({
    required String envie,
    String? ville,
    String filter = 'popular',
    int page = 1,
    int limit = 15,
  }) async {
    final results = await _apiClient.searchEstablishments(
      envie: envie,
      ville: ville,
      filter: filter,
      page: page,
      limit: limit,
    );

    return results
        .map((json) => Establishment.fromJson(json))
        .toList();
  }
}

