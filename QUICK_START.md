# 🚀 Démarrage Rapide - Envie2Sortir Mobile

## ✅ Installation Complète

Flutter est maintenant installé et les dépendances sont téléchargées !

## Prochaines Étapes

### 1. Vérifier la configuration

Assurez-vous que le fichier `.env` existe et contient vos clés API :

```bash
cat .env
```

Si le fichier n'existe pas, créez-le avec vos clés :

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
RAILWAY_API_URL=https://your-backend.railway.app
GOOGLE_PLACES_API_KEY=your-places-key
```

### 2. Lancer l'application

Vous avez plusieurs options :

#### Sur iOS Simulator (Recommandé pour commencer)
```bash
flutter run -d "iPhone 16e"
```

#### Sur macOS Desktop
```bash
flutter run -d macos
```

#### Sur Chrome (Web)
```bash
flutter run -d chrome
```

### 3. Appareils disponibles

Actuellement détectés :
- ✅ iPhone 16e (iOS Simulator)
- ✅ macOS (Desktop)
- ✅ Chrome (Web)

Pour voir tous les appareils :
```bash
flutter devices
```

## Commandes Utiles

### Vérifier l'état de Flutter
```bash
flutter doctor
```

### Analyser le code
```bash
flutter analyze
```

### Formater le code
```bash
flutter format .
```

### Lancer les tests
```bash
flutter test
```

### Nettoyer le projet
```bash
flutter clean
flutter pub get
```

## Configuration Requise

### Pour iOS
- ✅ Xcode installé (détecté)
- ⚠️ CocoaPods peut être nécessaire : `sudo gem install cocoapods`

### Pour Android
- ⚠️ Android Studio non installé (optionnel pour iOS/macOS)
- Si vous voulez développer pour Android, installez Android Studio

## Dépannage

### Erreur "command not found: flutter"
- Flutter est installé via Homebrew
- Vérifiez avec : `which flutter`
- Si nécessaire, redémarrez le terminal

### Erreur de chargement du .env
- Vérifiez que le fichier `.env` existe à la racine du projet
- Vérifiez les permissions du fichier

### Erreur Supabase
- Vérifiez que les clés dans `.env` sont correctes
- Vérifiez que votre projet Supabase est actif

## Documentation

- [SETUP.md](./SETUP.md) - Guide de configuration complet
- [INSTALL_FLUTTER.md](./INSTALL_FLUTTER.md) - Installation de Flutter
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Guide de contribution
- [cursorroles.md](./cursorroles.md) - Documentation technique complète

## Support

En cas de problème, vérifiez :
1. `flutter doctor` pour les problèmes de configuration
2. Les logs d'erreur dans le terminal
3. La documentation dans `cursorroles.md`

