class SearchDto {
  final String envie;
  final String? ville;
  final String filter;
  final int page;
  final int limit;

  SearchDto({
    required this.envie,
    this.ville,
    this.filter = 'popular',
    this.page = 1,
    this.limit = 15,
  });

  Map<String, dynamic> toJson() {
    return {
      'envie': envie,
      if (ville != null) 'ville': ville,
      'filter': filter,
      'page': page,
      'limit': limit,
    };
  }
}

