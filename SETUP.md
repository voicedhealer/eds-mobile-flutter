# Guide de Configuration - Envie2Sortir Mobile

## Prérequis

- Flutter SDK 3.24 ou supérieur
- Dart 3.0 ou supérieur
- Android Studio / Xcode (pour le développement mobile)
- Compte Supabase
- Compte Railway (pour le backend API)
- Clé API Google Places

## Installation de Flutter

**⚠️ IMPORTANT : Si Flutter n'est pas installé, suivez d'abord le guide [INSTALL_FLUTTER.md](./INSTALL_FLUTTER.md)**

Vérifiez que Flutter est installé :

```bash
flutter --version
```

Si vous obtenez "command not found", installez Flutter en suivant le guide d'installation.

## Installation du projet

### 1. Cloner et installer les dépendances

```bash
git clone <repository-url>
cd eds-mobile-flutter
flutter pub get
```

### 2. Configuration des variables d'environnement

Créez un fichier `.env` à la racine du projet :

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
RAILWAY_API_URL=https://your-backend.railway.app
GOOGLE_PLACES_API_KEY=your-places-key
```

### 3. Configuration Android

#### AndroidManifest.xml

Ajoutez les permissions et la clé API Google Maps dans `android/app/src/main/AndroidManifest.xml` :

```xml
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

#### build.gradle

Vérifiez que `minSdkVersion` est au moins 21 dans `android/app/build.gradle`.

### 4. Configuration iOS

#### Info.plist

Ajoutez les permissions de localisation dans `ios/Runner/Info.plist` :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour vous montrer les établissements près de chez vous</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour vous montrer les établissements près de chez vous</string>
```

#### Google Maps pour iOS

Ajoutez votre clé API dans `ios/Runner/AppDelegate.swift` :

```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_PLACES_API_KEY")
```

### 5. Configuration Supabase

1. Créez un projet sur [Supabase](https://supabase.com)
2. Récupérez votre URL et clé anonyme depuis les paramètres du projet
3. Configurez les tables nécessaires :
   - `users`
   - `professionals`
   - `establishments`
   - `events`
   - `event_engagements`
   - `user_favorites`

### 6. Configuration Railway

1. Déployez votre backend API sur Railway
2. Configurez les variables d'environnement nécessaires
3. Récupérez l'URL de votre API

## Vérification

Lancez l'application pour vérifier que tout fonctionne :

```bash
flutter run
```

## Dépannage

### Erreur de connexion Supabase
- Vérifiez que les variables d'environnement sont correctement définies
- Vérifiez que le fichier `.env` est bien à la racine du projet
- Vérifiez que `flutter_dotenv` charge bien le fichier

### Erreur de localisation
- Vérifiez les permissions dans AndroidManifest.xml / Info.plist
- Testez sur un appareil réel (l'émulateur peut avoir des problèmes de localisation)

### Erreur Google Maps
- Vérifiez que la clé API est correctement configurée
- Vérifiez que les restrictions de la clé API permettent votre usage
- Pour iOS, vérifiez que la clé est bien dans AppDelegate.swift

## Structure des données Supabase

Assurez-vous que vos tables Supabase correspondent aux modèles définis dans `lib/data/models/`.

Voir le fichier `cursorroles.md` pour plus de détails sur la structure attendue.

