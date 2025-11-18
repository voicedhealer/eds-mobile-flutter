# 📱 GUIDE FLUTTER COMPLET - ENVIE2SORTIR

## Table des Matières

1. [Introduction](#introduction)
2. [Architecture Technique](#architecture-technique)
3. [Configuration de l'Environnement](#configuration-de-lenvironnement)
4. [Modèles de Données](#modèles-de-données)
5. [Services et Repositories](#services-et-repositories)
6. [Providers Riverpod](#providers-riverpod)
7. [Écrans Principaux](#écrans-principaux)
8. [Composants UI](#composants-ui)
9. [Design System](#design-system)
10. [Intégrations Backend](#intégrations-backend)
11. [Tests](#tests)
12. [Déploiement](#déploiement)
13. [Annexes](#annexes)

---

## 1. Introduction
500 à 600 lignes de code par fichier avant refactorisation 

### Présentation du Projet

**Envie2Sortir** est une plateforme ultra-locale permettant de découvrir des établissements de divertissement (restaurants, bars, escape games, VR, bowling, etc.) près de chez soi.

### Objectifs de l'Application Mobile

L'application Flutter reproduit fidèlement le site web [envie2sortir.fr](https://github.com/voicedhealer/envie2sortir) avec :
- Recherche intelligente avec filtres
- Carte interactive avec géolocalisation
- Système d'engagement événementiel
- Gestion des favoris
- Authentification multi-tenants (User/Professional)

### Technologies Utilisées

- **Flutter** : 3.24+
- **Supabase** : Authentification + Base de données PostgreSQL
- **Railway** : Backend dockerisé (API REST)
- **Google Places API** : Enrichissement des données
- **Riverpod** : Gestion d'état réactive
- **GoRouter** : Navigation déclarative

---

## 2. Architecture Technique

### Stack Technique Flutter

#### Packages Essentiels (`pubspec.yaml`)

```yaml
name: envie2sortir
description: Application mobile Envie2Sortir
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Authentification & Base de données
  supabase_flutter: ^2.0.0
  
  # Navigation
  go_router: ^14.0.0
  
  # State Management
  flutter_riverpod: ^2.5.0
  
  # HTTP Client
  dio: ^5.4.0
  
  # Maps & Géolocalisation
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.0
  
  # Images
  cached_network_image: ^3.3.0
  image_picker: ^1.0.5
  
  # UI
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Utilitaires
  intl: ^0.19.0
  uuid: ^4.0.0
  flutter_dotenv: ^5.1.0
  shared_preferences: ^2.2.0
  
  # Google Fonts
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Architecture de Dossiers

```
lib/
├── config/
│   ├── constants.dart          # Couleurs, API keys, URLs backend
│   ├── supabase_config.dart    # Config Supabase
│   ├── theme.dart              # ThemeData avec design system
│   └── env.dart                # Variables d'environnement
│
├── core/
│   ├── providers/              # Riverpod providers globaux
│   │   ├── auth_provider.dart
│   │   ├── search_provider.dart
│   │   └── favorites_provider.dart
│   ├── services/               # Services API (Dio clients)
│   │   ├── railway_api_client.dart
│   │   ├── supabase_auth_service.dart
│   │   └── geolocation_service.dart
│   └── utils/                  # Helpers (date, distance, formatage)
│       ├── date_utils.dart
│       ├── distance_utils.dart
│       └── formatters.dart
│
├── data/
│   ├── models/                 # Data classes (15 modèles du README)
│   │   ├── user.dart
│   │   ├── professional.dart
│   │   ├── establishment.dart
│   │   ├── event.dart
│   │   └── ...
│   ├── repositories/           # Data sources (Supabase + Railway API)
│   │   ├── establishment_repository.dart
│   │   ├── search_repository.dart
│   │   └── event_repository.dart
│   └── dto/                    # Data Transfer Objects
│       └── search_dto.dart
│
├── features/
│   ├── auth/                   # Authentification (Supabase Auth)
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/
│   │       └── auth_form.dart
│   │
│   ├── search/                 # Recherche + filtres
│   │   ├── screens/
│   │   │   └── search_results_screen.dart
│   │   └── widgets/
│   │       ├── envie_search_bar.dart
│   │       └── filter_bar.dart
│   │
│   ├── establishments/         # Détails établissements
│   │   ├── screens/
│   │   │   └── establishment_detail_screen.dart
│   │   └── widgets/
│   │       └── establishment_card.dart
│   │
│   ├── events/                 # Événements + engagement
│   │   ├── screens/
│   │   │   └── events_list_screen.dart
│   │   └── widgets/
│   │       ├── event_card.dart
│   │       ├── event_engagement_buttons.dart
│   │       └── engagement_gauge.dart
│   │
│   ├── map/                    # Carte interactive
│   │   ├── screens/
│   │   │   └── map_screen.dart
│   │   └── widgets/
│   │       └── map_component.dart
│   │
│   ├── favorites/              # Favoris utilisateur
│   │   └── screens/
│   │       └── favorites_screen.dart
│   │
│   └── profile/                # Profil + paramètres
│       └── screens/
│           └── profile_screen.dart
│
└── shared/
    ├── widgets/                # Composants réutilisables
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    └── extensions/             # Extensions Dart
        └── string_extensions.dart
```

---

## 3. Configuration de l'Environnement

### Variables d'Environnement (`.env`)

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Railway Backend API
RAILWAY_API_URL=https://your-backend.railway.app

# Google Places API
GOOGLE_PLACES_API_KEY=your-places-key

# Cloudflare Worker (optionnel)
CLOUDFLARE_WORKER_URL=https://your-worker.workers.dev
```

### Configuration Supabase

```dart
// lib/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Sécurité renforcée
    ),
  );
}

final supabase = Supabase.instance.client;
```

### Configuration Railway API Client

```dart
// lib/core/services/railway_api_client.dart
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
```

---

## 4. Modèles de Données

### User (Utilisateur Final)

```dart
// lib/data/models/user.dart
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? phone;
  final String? avatar;
  final bool isVerified;
  final String? favoriteCity;
  final UserRole role;
  final int karmaPoints;
  final List<dynamic>? gamificationBadges;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.name,
    this.phone,
    this.avatar,
    this.isVerified = false,
    this.favoriteCity,
    this.role = UserRole.user,
    this.karmaPoints = 0,
    this.gamificationBadges,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
      favoriteCity: json['favorite_city'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      karmaPoints: json['karma_points'] ?? 0,
      gamificationBadges: json['gamification_badges'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'is_verified': isVerified,
      'favorite_city': favoriteCity,
      'role': role.name,
      'karma_points': karmaPoints,
      'gamification_badges': gamificationBadges,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum UserRole {
  user,
  admin,
}
```

### Professional (Propriétaire d'Établissement)

```dart
// lib/data/models/professional.dart
class Professional {
  final String id;
  final String siret;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String companyName;
  final String legalStatus;
  final SubscriptionPlan subscriptionPlan;
  final bool siretVerified;
  final DateTime? siretVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Professional({
    required this.id,
    required this.siret,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.legalStatus,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.siretVerified = false,
    this.siretVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'],
      siret: json['siret'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      companyName: json['company_name'],
      legalStatus: json['legal_status'],
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (e) => e.name.toUpperCase() == json['subscription_plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      siretVerified: json['siret_verified'] ?? false,
      siretVerifiedAt: json['siret_verified_at'] != null
          ? DateTime.parse(json['siret_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

enum SubscriptionPlan {
  free,
  premium,
}
```

### Establishment (Établissement)

```dart
// lib/data/models/establishment.dart
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
```

### Event (Événement)

```dart
// lib/data/models/event.dart
class Event {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String establishmentId;
  final DateTime startDate;
  final DateTime? endDate;
  final double? price;
  final String? priceUnit;
  final int? maxCapacity;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.establishmentId,
    required this.startDate,
    this.endDate,
    this.price,
    this.priceUnit,
    this.maxCapacity,
    this.isRecurring = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      establishmentId: json['establishment_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      price: json['price']?.toDouble(),
      priceUnit: json['price_unit'],
      maxCapacity: json['max_capacity'],
      isRecurring: json['is_recurring'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

### EventEngagement (Engagement Événementiel)

```dart
// lib/data/models/event_engagement.dart
class EventEngagement {
  final String id;
  final String eventId;
  final String userId;
  final EngagementType type;
  final DateTime createdAt;

  EventEngagement({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory EventEngagement.fromJson(Map<String, dynamic> json) {
    return EventEngagement(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      type: EngagementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EngagementType.envie,
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum EngagementType {
  envie,
  ultaEnvie,
  intrigue,
  pasEnvie,
}

class EngagementStats {
  final int envie;
  final int ultraEnvie;
  final int intrigue;
  final int pasEnvie;

  EngagementStats({
    this.envie = 0,
    this.ulraEnvie = 0,
    this.intrigue = 0,
    this.pasEnvie = 0,
  });

  int get totalScore {
    return (envie * 1) +
        (ultraEnvie * 3) +
        (intrigue * 2) +
        (pasEnvie * -1);
  }

  double get gaugePercentage {
    final percentage = (totalScore / 15) * 100;
    return percentage.clamp(0, 150);
  }

  bool get isFireMode => gaugePercentage >= 150;
}
```

---

## 5. Services et Repositories

### EstablishmentRepository

```dart
// lib/data/repositories/establishment_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/establishment.dart';

class EstablishmentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Establishment?> getBySlug(String slug) async {
    final response = await _supabase
        .from('establishments')
        .select()
        .eq('slug', slug)
        .eq('status', 'approved')
        .single();

    if (response == null) return null;
    return Establishment.fromJson(response);
  }

  Future<List<Establishment>> getByCity(String city) async {
    final response = await _supabase
        .from('establishments')
        .select()
        .eq('city', city)
        .eq('status', 'approved')
        .order('views_count', ascending: false);

    return (response as List)
        .map((json) => Establishment.fromJson(json))
        .toList();
  }
}
```

### SearchRepository

```dart
// lib/data/repositories/search_repository.dart
import 'package:dio/dio.dart';
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
```

### EventRepository

```dart
// lib/data/repositories/event_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/event_engagement.dart';

class EventRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Event>> getUpcomingEvents({String? city}) async {
    final now = DateTime.now();
    var query = _supabase
        .from('events')
        .select()
        .gte('start_date', now.toIso8601String())
        .order('start_date', ascending: true);

    if (city != null) {
      // Joindre avec establishments pour filtrer par ville
      query = query.eq('establishments.city', city);
    }

    final response = await query;
    return (response as List)
        .map((json) => Event.fromJson(json))
        .toList();
  }

  Future<EngagementStats> getEngagementStats(String eventId) async {
    final response = await _supabase
        .from('event_engagements')
        .select('type')
        .eq('event_id', eventId);

    final engagements = (response as List).cast<Map<String, dynamic>>();
    
    return EngagementStats(
      envie: engagements.where((e) => e['type'] == 'envie').length,
      ultraEnvie: engagements.where((e) => e['type'] == 'ultra-envie').length,
      intrigue: engagements.where((e) => e['type'] == 'intrigue').length,
      pasEnvie: engagements.where((e) => e['type'] == 'pas-envie').length,
    );
  }

  Future<void> engage({
    required String eventId,
    required String userId,
    required EngagementType type,
  }) async {
    await _supabase.from('event_engagements').upsert({
      'event_id': eventId,
      'user_id': userId,
      'type': type.name,
    });
  }
}
```

---

## 6. Providers Riverpod

### AuthProvider

```dart
// lib/core/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user.dart';

final authProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    if (event.session?.user == null) return null;
    return User.fromJson(event.session!.user.toJson());
  });
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull;
});
```

### SearchProvider

```dart
// lib/core/providers/search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/models/establishment.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository());

final searchResultsProvider = FutureProvider.family<List<Establishment>, SearchParams>((ref, params) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.search(
    envie: params.envie,
    ville: params.ville,
    filter: params.filter,
    page: params.page,
    limit: params.limit,
  );
});

class SearchParams {
  final String envie;
  final String? ville;
  final String filter;
  final int page;
  final int limit;

  SearchParams({
    required this.envie,
    this.ville,
    this.filter = 'popular',
    this.page = 1,
    this.limit = 15,
  });
}
```

---

## 7. Écrans Principaux

### HomeScreen

```dart
// lib/features/search/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/envie_search_bar.dart';
import '../../establishments/widgets/establishment_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section avec gradient
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF751F),
                      const Color(0xFFFF1FA9),
                      const Color(0xFFFF3A3A),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Envie2Sortir',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: EnvieSearchBar(),
                    ),
                  ],
                ),
              ),
              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Découvrez près de chez vous',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    // Grille d'établissements
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### SearchResultsScreen

```dart
// lib/features/search/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/filter_bar.dart';
import '../../establishments/widgets/establishment_card.dart';
import '../../../core/providers/search_provider.dart';

class SearchResultsScreen extends ConsumerWidget {
  final String envie;
  final String? ville;

  const SearchResultsScreen({
    super.key,
    required this.envie,
    this.ville,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchParams = SearchParams(
      envie: envie,
      ville: ville,
      filter: 'popular',
    );
    
    final resultsAsync = ref.watch(searchResultsProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats pour "$envie"'),
      ),
      body: Column(
        children: [
          const FilterBar(),
          Expanded(
            child: resultsAsync.when(
              data: (establishments) {
                if (establishments.isEmpty) {
                  return const Center(
                    child: Text('Aucun résultat trouvé'),
                  );
                }
                return ListView.builder(
                  itemCount: establishments.length,
                  itemBuilder: (context, index) {
                    return EstablishmentCard(
                      establishment: establishments[index],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 8. Composants UI

### EstablishmentCard

```dart
// lib/features/establishments/widgets/establishment_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/establishment.dart';

class EstablishmentCard extends StatelessWidget {
  final Establishment establishment;

  const EstablishmentCard({
    super.key,
    required this.establishment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec badge premium
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: establishment.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: establishment.imageUrl!,
                        height: 192,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 192,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 64),
                      ),
              ),
              if (establishment.subscription == SubscriptionPlan.premium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF751F),
                          Color(0xFFFF1FA9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Informations
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  establishment.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  establishment.city ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (establishment.avgRating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        establishment.avgRating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### EnvieSearchBar avec Typewriter Effect

```dart
// lib/features/search/widgets/envie_search_bar.dart
import 'package:flutter/material.dart';
import 'dart:async';

class EnvieSearchBar extends StatefulWidget {
  const EnvieSearchBar({super.key});

  @override
  State<EnvieSearchBar> createState() => _EnvieSearchBarState();
}

class _EnvieSearchBarState extends State<EnvieSearchBar>
    with SingleTickerProviderStateMixin {
  final _phrases = [
    'manger une crêpe au nutella',
    'boire une bière artisanale',
    'faire un laser game',
    'jouer au bowling',
    'tester la réalité virtuelle',
    'résoudre un escape game',
    'danser toute la nuit',
    'manger un burger',
    'boire un cocktail',
    'voir un concert',
    'faire du karaoké',
    'jouer au billard',
  ];

  late AnimationController _cursorController;
  String _currentPhrase = '';
  int _phraseIndex = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _startTypewriter();
  }

  void _startTypewriter() async {
    while (mounted) {
      await _typePhrase(_phrases[_phraseIndex]);
      await Future.delayed(const Duration(seconds: 2));
      await _erasePhrase();
      _phraseIndex = (_phraseIndex + 1) % _phrases.length;
    }
  }

  Future<void> _typePhrase(String phrase) async {
    for (int i = 0; i <= phrase.length; i++) {
      if (!mounted) break;
      setState(() {
        _currentPhrase = phrase.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _erasePhrase() async {
    for (int i = _currentPhrase.length; i >= 0; i--) {
      if (!mounted) break;
      setState(() {
        _currentPhrase = _currentPhrase.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Envie de',
            style: TextStyle(
              color: const Color(0xFFFF751F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentPhrase,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          AnimatedBuilder(
            animation: _cursorController,
            builder: (context, child) {
              return Opacity(
                opacity: _cursorController.value,
                child: Container(
                  width: 2,
                  height: 20,
                  color: const Color(0xFFFF751F),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### FilterBar (6 Filtres)

```dart
// lib/features/search/widgets/filter_bar.dart
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum FilterType {
  popular,
  wanted,
  cheap,
  premium,
  newest,
  rating,
}

class FilterBar extends StatelessWidget {
  final FilterType? activeFilter;
  final Function(FilterType) onFilterChanged;

  const FilterBar({
    super.key,
    this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      _FilterItem(
        type: FilterType.popular,
        label: 'Populaire',
        icon: Icons.trending_up,
      ),
      _FilterItem(
        type: FilterType.wanted,
        label: 'Désirés ++',
        icon: Icons.favorite,
      ),
      _FilterItem(
        type: FilterType.cheap,
        label: 'Les - cher',
        icon: Icons.attach_money,
      ),
      _FilterItem(
        type: FilterType.premium,
        label: 'Notre sélection',
        icon: Icons.star,
      ),
      _FilterItem(
        type: FilterType.newest,
        label: 'Nouveaux',
        icon: Icons.access_time,
      ),
      _FilterItem(
        type: FilterType.rating,
        label: 'Mieux notés',
        icon: Icons.star_rate,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isActive = activeFilter == filter.type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(filter.icon, size: 16),
                    const SizedBox(width: 4),
                    Text(filter.label),
                  ],
                ),
                selected: isActive,
                onSelected: (selected) {
                  onFilterChanged(filter.type);
                },
                backgroundColor: Colors.grey[200],
                selectedColor: const Color(0xFFFF751F),
                labelStyle: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterItem {
  final FilterType type;
  final String label;
  final IconData icon;

  _FilterItem({
    required this.type,
    required this.label,
    required this.icon,
  });
}
```

### EventEngagementButtons

```dart
// lib/features/events/widgets/event_engagement_buttons.dart
import 'package:flutter/material.dart';
import '../../../data/models/event_engagement.dart';

class EventEngagementButtons extends StatelessWidget {
  final String eventId;
  final EngagementStats stats;
  final EngagementType? userEngagement;
  final Function(EngagementType) onEngage;

  const EventEngagementButtons({
    super.key,
    required this.eventId,
    required this.stats,
    this.userEngagement,
    required this.onEngage,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _EngagementButton(
        type: EngagementType.envie,
        label: '👍 Envie',
        color: Colors.green,
        count: stats.envie,
        isActive: userEngagement == EngagementType.envie,
        onTap: () => onEngage(EngagementType.envie),
      ),
      _EngagementButton(
        type: EngagementType.grandeEnvie,
        label: '🔥 Grande Envie',
        color: Colors.orange,
        count: stats.grandeEnvie,
        isActive: userEngagement == EngagementType.grandeEnvie,
        onTap: () => onEngage(EngagementType.grandeEnvie),
      ),
      _EngagementButton(
        type: EngagementType.decouvrir,
        label: '🔍 Découvrir',
        color: Colors.blue,
        count: stats.decouvrir,
        isActive: userEngagement == EngagementType.decouvrir,
        onTap: () => onEngage(EngagementType.decouvrir),
      ),
      _EngagementButton(
        type: EngagementType.pasEnvie,
        label: '👎 Pas Envie',
        color: Colors.red,
        count: stats.pasEnvie,
        isActive: userEngagement == EngagementType.pasEnvie,
        onTap: () => onEngage(EngagementType.pasEnvie),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final EngagementType type;
  final String label;
  final Color color;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _EngagementButton({
    required this.type,
    required this.label,
    required this.color,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? color : Colors.white,
            foregroundColor: isActive ? Colors.white : color,
            side: BorderSide(color: color, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### EngagementGauge avec Fire Mode

```dart
// lib/features/events/widgets/engagement_gauge.dart
import 'package:flutter/material.dart';
import '../../../data/models/event_engagement.dart';

class EngagementGauge extends StatelessWidget {
  final double percentage;
  final EngagementStats stats;

  const EngagementGauge({
    super.key,
    required this.percentage,
    required this.stats,
  });

  Color _getGaugeColor(double percentage) {
    if (percentage >= 150) return Colors.purple;
    if (percentage >= 100) return Colors.amber;
    if (percentage >= 75) return Colors.orange;
    if (percentage >= 50) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isFire = percentage >= 150;
    final normalizedPercentage = (percentage / 150).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          children: [
            LinearProgressIndicator(
              value: normalizedPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getGaugeColor(percentage),
              ),
              minHeight: 20,
            ),
            if (isFire)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.3),
                        Colors.purple.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isFire)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🔥 C\'EST LE FEU ! 🔥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          )
        else
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}
```

---

## 9. Design System

### Couleurs et Typographie

```dart
// lib/config/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const brandOrange = Color(0xFFFF751F);
  static const brandPink = Color(0xFFFF1FA9);
  static const brandRed = Color(0xFFFF3A3A);
  static const background = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF171717);
  static const textSecondary = Color(0xFF6B7280);
}

class AppTypography {
  static const fontFamily = 'Inter';
  
  static const h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );
  
  static const h2 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );
}
```

### ThemeData

```dart
// lib/config/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.brandOrange,
    secondary: AppColors.brandPink,
    error: AppColors.brandRed,
    surface: AppColors.background,
  ),
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: GoogleFonts.inter(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandOrange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
```

### Gradients

```dart
// lib/config/gradients.dart
import 'package:flutter/material.dart';
import 'constants.dart';

class AppGradients {
  // Gradient Hero (135deg orange → pink → rouge)
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandOrange,
      AppColors.brandPink,
      AppColors.brandRed,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Gradient Bouton (135deg orange → pink)
  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandOrange,
      AppColors.brandPink,
    ],
  );
}
```

---

## 10. Intégrations Backend

### Authentification Supabase

```dart
// lib/core/services/supabase_auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<User?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? favoriteCity,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'user_type': 'user',
        'first_name': firstName,
        'last_name': lastName,
        'favorite_city': favoriteCity,
      },
    );

    if (response.user == null) return null;
    return User.fromJson(response.user!.toJson());
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;
    return User.fromJson(response.user!.toJson());
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser {
    final session = _supabase.auth.currentSession;
    if (session?.user == null) return null;
    return User.fromJson(session!.user.toJson());
  }
}
```

---

## 11. Tests

### Tests Unitaires

```dart
// test/data/models/establishment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/establishment.dart';

void main() {
  group('Establishment', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': '123',
        'name': 'Test Establishment',
        'slug': 'test-establishment',
        'address': '123 Test St',
        'city': 'Paris',
        'status': 'approved',
        'subscription': 'FREE',
        'owner_id': 'owner123',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final establishment = Establishment.fromJson(json);

      expect(establishment.id, '123');
      expect(establishment.name, 'Test Establishment');
      expect(establishment.slug, 'test-establishment');
    });
  });
}
```

---

## 12. Déploiement

### Configuration Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="${GOOGLE_PLACES_API_KEY}"/>
  </application>
</manifest>
```

### Configuration iOS

```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour vous montrer les établissements près de chez vous</string>
```

---

## 13. Annexes

### pubspec.yaml Complet

Voir section [Stack Technique Flutter](#stack-technique-flutter)

### .env.example

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
RAILWAY_API_URL=https://your-backend.railway.app
GOOGLE_PLACES_API_KEY=your-places-key
```

### Checklist de Développement

- [ ] Initialiser projet Flutter
- [ ] Configurer Supabase
- [ ] Configurer Railway API
- [ ] Implémenter authentification
- [ ] Créer écrans principaux
- [ ] Intégrer Google Maps
- [ ] Implémenter système d'engagement
- [ ] Tests unitaires
- [ ] Build Android/iOS
- [ ] Déploiement

---

**Document généré pour Envie2Sortir Flutter App** 🚀

Ce document fournit une base complète pour développer l'application mobile Flutter qui reproduit fidèlement le site web Envie2Sortir. Tous les composants, services, modèles et configurations sont détaillés pour permettre un développement rapide et efficace.

---

Le document est prêt. Il couvre l'architecture, les modèles de données, les services, les écrans, les composants UI, le design system, les tests et le déploiement. Souhaitez-vous que je détaille une section spécifique ou que j'ajoute des éléments ?