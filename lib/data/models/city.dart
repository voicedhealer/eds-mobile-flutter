class City {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? region;
  final String? postalCode;

  City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region,
    this.postalCode,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? json['name']?.toLowerCase().replaceAll(' ', '-') ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? json['lon'] ?? 0.0).toDouble(),
      region: json['region'],
      postalCode: json['postal_code'] ?? json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'region': region,
      'postal_code': postalCode,
    };
  }
}

// Villes principales de France
final majorFrenchCities = [
  City(id: 'dijon', name: 'Dijon', latitude: 47.322, longitude: 5.041, region: 'Bourgogne-Franche-Comté'),
  City(id: 'paris', name: 'Paris', latitude: 48.8566, longitude: 2.3522, region: 'Île-de-France'),
  City(id: 'lyon', name: 'Lyon', latitude: 45.7640, longitude: 4.8357, region: 'Auvergne-Rhône-Alpes'),
  City(id: 'marseille', name: 'Marseille', latitude: 43.2965, longitude: 5.3698, region: "Provence-Alpes-Côte d'Azur"),
  City(id: 'toulouse', name: 'Toulouse', latitude: 43.6047, longitude: 1.4442, region: 'Occitanie'),
  City(id: 'bordeaux', name: 'Bordeaux', latitude: 44.8378, longitude: -0.5792, region: 'Nouvelle-Aquitaine'),
  City(id: 'lille', name: 'Lille', latitude: 50.6292, longitude: 3.0573, region: 'Hauts-de-France'),
  City(id: 'nantes', name: 'Nantes', latitude: 47.2184, longitude: -1.5536, region: 'Pays de la Loire'),
  City(id: 'strasbourg', name: 'Strasbourg', latitude: 48.5734, longitude: 7.7521, region: 'Grand Est'),
  City(id: 'nice', name: 'Nice', latitude: 43.7102, longitude: 7.2620, region: "Provence-Alpes-Côte d'Azur"),
  City(id: 'rennes', name: 'Rennes', latitude: 48.1173, longitude: -1.6778, region: 'Bretagne'),
  City(id: 'reims', name: 'Reims', latitude: 49.2583, longitude: 4.0317, region: 'Grand Est'),
  City(id: 'montpellier', name: 'Montpellier', latitude: 43.6108, longitude: 3.8767, region: 'Occitanie'),
];

final defaultCity = majorFrenchCities[0]; // Dijon

