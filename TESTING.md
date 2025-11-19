# 🧪 Guide des Tests - Envie2Sortir Mobile

## Vue d'ensemble

L'application dispose d'une suite de tests complète couvrant :
- **Tests unitaires** : Modèles de données, utilitaires
- **Tests d'intégration** : Repositories, providers, services, widgets
- **Tests end-to-end** : Navigation, écrans principaux

## Structure des Tests

```
test/
├── data/
│   ├── models/              # Tests des modèles de données
│   └── repositories/        # Tests de structure des repositories
├── core/
│   └── utils/               # Tests des utilitaires
├── integration/
│   ├── repositories/        # Tests d'intégration des repositories
│   ├── providers/           # Tests d'intégration des providers Riverpod
│   ├── services/            # Tests d'intégration des services
│   ├── screens/             # Tests des écrans principaux
│   ├── navigation/          # Tests de navigation GoRouter
│   └── widgets/             # Tests des widgets UI
└── helpers/
    ├── mock_supabase.dart   # Helpers pour mocker Supabase
    └── mock_railway_api.dart # Helpers pour mocker Railway API
```

## Exécution des Tests

### Tous les tests
```bash
flutter test
```

### Tests spécifiques
```bash
# Tests unitaires uniquement
flutter test test/data/ test/core/

# Tests d'intégration uniquement
flutter test test/integration/

# Un fichier spécifique
flutter test test/data/models/establishment_test.dart
```

### Avec couverture
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Types de Tests

### 1. Tests Unitaires

#### Modèles de Données
- Parsing JSON
- Sérialisation JSON
- Valeurs par défaut
- Gestion des champs optionnels

#### Utilitaires
- Formatage (dates, prix, distances)
- Calculs métier (scores d'engagement)
- Gestion d'erreurs réseau
- Retry avec backoff exponentiel

### 2. Tests d'Intégration

#### Repositories
- Structure des méthodes
- Gestion des erreurs
- Filtrage et pagination

#### Providers Riverpod
- État initial
- Mise à jour de l'état
- Gestion des erreurs async

#### Services
- Authentification
- Géolocalisation
- Favoris

#### Widgets
- Affichage correct
- Interactions utilisateur
- États (loading, error, empty)

### 3. Tests End-to-End

#### Navigation
- Routes avec paramètres
- Query parameters
- Navigation entre écrans

#### Écrans
- Affichage des composants principaux
- Interactions utilisateur
- Gestion des états

## Utilitaires de Test

### NetworkUtils
Détecte et classe les erreurs réseau :
- Erreurs de connexion
- Erreurs d'authentification
- Erreurs serveur
- Messages d'erreur conviviaux

### RetryHelper
Gère les retries automatiques avec backoff exponentiel :
- Retry simple
- Retry avec callback de progression
- Callback de condition de retry

### Mocks
- `SupabaseMocks` : Création de données de test Supabase
- `RailwayApiMocks` : Création de réponses mockées Railway

## Bonnes Pratiques

1. **Isolation** : Chaque test doit être indépendant
2. **Nommage** : Noms descriptifs expliquant ce qui est testé
3. **AAA Pattern** : Arrange, Act, Assert
4. **Mocks** : Utiliser des mocks pour les dépendances externes
5. **Couverture** : Viser au moins 70% de couverture de code

## Tests à Venir

- [ ] Tests avec mocks complets Supabase
- [ ] Tests avec mocks complets Railway API
- [ ] Tests de performance
- [ ] Tests d'accessibilité
- [ ] Tests de cache et offline
- [ ] Tests de sécurité

## Dépannage

### Tests qui échouent
1. Vérifier les dépendances : `flutter pub get`
2. Vérifier les mocks : S'assurer que les mocks sont correctement configurés
3. Vérifier les imports : S'assurer que tous les imports sont corrects

### Tests lents
- Utiliser `setUp` et `tearDown` pour la configuration
- Éviter les délais inutiles
- Utiliser des mocks plutôt que de vraies API

## Documentation

Pour plus d'informations sur les tests Flutter :
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Riverpod Testing](https://riverpod.dev/docs/concepts/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)

