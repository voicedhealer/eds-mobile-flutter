# 📱 Configuration iOS - Envie2Sortir

## Problème : iOS 26.1 non installé

Si vous rencontrez l'erreur :
```
iOS 26.1 is not installed. Please download and install the platform from Xcode > Settings > Components.
```

## Solution 1 : Installer iOS 26.1 dans Xcode

1. Ouvrir Xcode
2. Aller dans **Xcode > Settings** (ou **Preferences**)
3. Onglet **Platforms** (ou **Components**)
4. Cliquer sur le bouton **+** pour ajouter une plateforme
5. Sélectionner **iOS 26.1** et cliquer sur **Download**
6. Attendre la fin du téléchargement (plusieurs GB)

## Solution 2 : Utiliser un simulateur avec une version iOS installée

1. Ouvrir Xcode
2. Aller dans **Window > Devices and Simulators**
3. Vérifier quelles versions iOS sont installées
4. Créer un nouveau simulateur avec une version iOS disponible :
   - Cliquer sur **+** pour créer un simulateur
   - Choisir un appareil (ex: iPhone 15 Pro)
   - Choisir une version iOS installée (ex: iOS 17.0)

## Solution 3 : Utiliser macOS ou Chrome pour tester

En attendant d'installer iOS 26.1, vous pouvez tester l'application sur :

### macOS Desktop
```bash
flutter run -d macos
```

### Chrome (Web)
```bash
flutter run -d chrome
```

## Solution 4 : Utiliser un iPhone physique

1. Connecter votre iPhone via USB
2. Déverrouiller l'iPhone et autoriser l'ordinateur
3. Vérifier la détection :
```bash
flutter devices
```

4. Lancer l'application :
```bash
flutter run
```

**Note** : Pour un iPhone physique, vous devez :
- Avoir un compte développeur Apple (gratuit suffit pour le développement)
- Configurer le provisioning dans Xcode
- Faire confiance à l'ordinateur sur l'iPhone

## Vérification

Après avoir installé iOS 26.1 ou créé un nouveau simulateur :

```bash
flutter devices
```

Vous devriez voir vos simulateurs disponibles.

## Commandes utiles

### Lister tous les simulateurs disponibles
```bash
xcrun simctl list devices available
```

### Démarrer un simulateur spécifique
```bash
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator
```

### Arrêter un simulateur
```bash
xcrun simctl shutdown all
```

## Dépannage

### Erreur "No devices found"
- Vérifier que Xcode est installé : `xcode-select --print-path`
- Vérifier que les simulateurs sont disponibles : `xcrun simctl list devices`

### Erreur de build iOS
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### Erreur de certificat
- Ouvrir le projet dans Xcode : `open ios/Runner.xcworkspace`
- Sélectionner le target Runner
- Aller dans Signing & Capabilities
- Sélectionner votre équipe de développement



