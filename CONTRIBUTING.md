# Guide de Contribution

## Structure du Projet

Le projet suit une architecture feature-based avec séparation claire des responsabilités :

- `lib/config/` : Configuration globale (thème, constants, Supabase)
- `lib/core/` : Services, providers Riverpod, utilitaires
- `lib/data/` : Modèles de données, repositories, DTOs
- `lib/features/` : Features organisées par domaine fonctionnel
- `lib/shared/` : Composants et extensions partagés

## Règles de Développement

### Nommage
- Fichiers : `snake_case.dart`
- Classes : `PascalCase`
- Variables/fonctions : `camelCase`
- Constantes : `camelCase` ou `SCREAMING_SNAKE_CASE`

### Architecture
- Un fichier = une responsabilité principale
- Maximum 500-600 lignes par fichier avant refactorisation
- Utiliser Riverpod pour la gestion d'état
- Utiliser GoRouter pour la navigation

### Code Style
- Suivre les règles de `flutter_lints`
- Utiliser `const` quand possible
- Préférer les widgets stateless quand possible
- Documenter les fonctions publiques complexes

### Tests
- Écrire des tests unitaires pour les modèles et repositories
- Tester les providers Riverpod
- Tester les widgets critiques

## Workflow Git

1. Créer une branche depuis `main`
2. Développer la feature
3. Écrire/ajouter les tests
4. Vérifier avec `flutter analyze`
5. Créer une Pull Request

## Checklist avant PR

- [ ] Code suit les conventions du projet
- [ ] Tests passent (`flutter test`)
- [ ] Aucune erreur de lint (`flutter analyze`)
- [ ] Documentation à jour si nécessaire
- [ ] Compatible avec les versions Flutter 3.24+

