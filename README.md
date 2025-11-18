# 📱 Envie2Sortir - Application Mobile Flutter

Application mobile Flutter pour la plateforme Envie2Sortir, permettant de découvrir des établissements de divertissement près de chez soi.

## 🚀 Démarrage rapide

### Prérequis

- Flutter 3.24+
- Dart 3.0+
- Compte Supabase
- Compte Railway (pour le backend API)
- Clé API Google Places

### Installation

1. Cloner le projet :
```bash
git clone <repository-url>
cd eds-mobile-flutter
```

2. Installer les dépendances :
```bash
flutter pub get
```

3. Configurer les variables d'environnement :
```bash
cp .env.example .env
```

Éditer le fichier `.env` avec vos clés API :
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
RAILWAY_API_URL=https://your-backend.railway.app
GOOGLE_PLACES_API_KEY=your-places-key
```

4. Lancer l'application :
```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── config/              # Configuration (thème, constants, Supabase)
├── core/                # Services, providers, utils
├── data/                # Modèles, repositories, DTOs
├── features/            # Features par domaine fonctionnel
│   ├── auth/
│   ├── search/
│   ├── establishments/
│   ├── events/
│   ├── favorites/
│   └── profile/
└── shared/              # Composants et extensions partagés
```

## 🏗️ Architecture

- **State Management** : Riverpod
- **Navigation** : GoRouter
- **Backend** : Supabase (Auth + DB) + Railway (API REST)
- **Maps** : Google Maps Flutter
- **Design System** : Material 3 avec thème personnalisé

## 📚 Documentation

Voir le fichier `cursorroles.md` pour la documentation complète du projet.

## 🧪 Tests

```bash
flutter test
```

## 📦 Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 Licence

[À définir]
