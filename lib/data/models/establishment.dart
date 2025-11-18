import 'professional.dart';

class Establishment {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String address;
  final String? city;
  final String? postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? instagram;
  final String? facebook;
  final Map<String, dynamic>? activities;
  final String specialites;
  final String? motsClesRecherche;
  final Map<String, dynamic>? services;
  final Map<String, dynamic>? ambiance;
  final Map<String, dynamic>? paymentMethods;
  final Map<String, dynamic>? horairesOuverture;
  final double? prixMoyen;
  final int? capaciteMax;
  final bool accessibilite;
  final bool parking;
  final bool terrasse;
  final EstablishmentStatus status;
  final SubscriptionPlan subscription;
  final String ownerId;
  final int viewsCount;
  final int clicksCount;
  final double? avgRating;
  final int totalComments;
  final String? imageUrl;
  final double? priceMin;
  final double? priceMax;
  final DateTime createdAt;
  final DateTime updatedAt;

  Establishment({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.address,
    this.city,
    this.postalCode,
    this.country = 'France',
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.instagram,
    this.facebook,
    this.activities,
    this.specialites = '',
    this.motsClesRecherche,
    this.services,
    this.ambiance,
    this.paymentMethods,
    this.horairesOuverture,
    this.prixMoyen,
    this.capaciteMax,
    this.accessibilite = false,
    this.parking = false,
    this.terrasse = false,
    this.status = EstablishmentStatus.pending,
    this.subscription = SubscriptionPlan.free,
    required this.ownerId,
    this.viewsCount = 0,
    this.clicksCount = 0,
    this.avgRating,
    this.totalComments = 0,
    this.imageUrl,
    this.priceMin,
    this.priceMax,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      country: json['country'] ?? 'France',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      activities: json['activities'],
      specialites: json['specialites'] ?? '',
      motsClesRecherche: json['mots_cles_recherche'],
      services: json['services'],
      ambiance: json['ambiance'],
      paymentMethods: json['payment_methods'],
      horairesOuverture: json['horaires_ouverture'],
      prixMoyen: json['prix_moyen']?.toDouble(),
      capaciteMax: json['capacite_max'],
      accessibilite: json['accessibilite'] ?? false,
      parking: json['parking'] ?? false,
      terrasse: json['terrasse'] ?? false,
      status: EstablishmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EstablishmentStatus.pending,
      ),
      subscription: SubscriptionPlan.values.firstWhere(
        (e) => e.name.toUpperCase() == json['subscription'],
        orElse: () => SubscriptionPlan.free,
      ),
      ownerId: json['owner_id'],
      viewsCount: json['views_count'] ?? 0,
      clicksCount: json['clicks_count'] ?? 0,
      avgRating: json['avg_rating']?.toDouble(),
      totalComments: json['total_comments'] ?? 0,
      imageUrl: json['image_url'],
      priceMin: json['price_min']?.toDouble(),
      priceMax: json['price_max']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

enum EstablishmentStatus {
  pending,
  approved,
  rejected,
}

