# 🔧 Solution Rapide - Erreur iOS 26.1

## Problème
```
iOS 26.1 is not installed. Please download and install the platform from Xcode > Settings > Components.
```

## Solution Rapide (2 options)

### Option 1 : Installer iOS 26.1 dans Xcode (Recommandé)

1. **Ouvrir Xcode**
2. **Xcode > Settings** (ou `Cmd + ,`)
3. Onglet **Platforms** (ou **Components** dans les anciennes versions)
4. Chercher **iOS 26.1** dans la liste
5. Cliquer sur le bouton **Download** à côté
6. Attendre la fin du téléchargement (plusieurs GB, peut prendre 10-30 minutes)

### Option 2 : Modifier la version iOS cible dans Xcode (Plus rapide)

1. **Ouvrir le projet dans Xcode** :
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Sélectionner le projet "Runner"** dans le navigateur de gauche

3. **Sélectionner le target "Runner"**

4. **Onglet "General"** ou **"Build Settings"**

5. **Chercher "iOS Deployment Target"**

6. **Changer la version de 26.1 à 26.0** (ou une version installée)

7. **Fermer Xcode**

8. **Relancer Flutter** :
   ```bash
   flutter run -d "iPhone 17 Pro"
   ```

## Alternative : Utiliser Chrome pour tester rapidement

En attendant de résoudre le problème iOS :

```bash
flutter run -d chrome
```

Cela lancera l'application dans Chrome, ce qui permet de tester rapidement l'interface et la navigation.

## Vérification

Après avoir modifié la version iOS :

```bash
flutter clean
flutter pub get
flutter run -d "iPhone 17 Pro"
```

## Si ça ne fonctionne toujours pas

1. Vérifier que le simulateur est démarré :
   ```bash
   xcrun simctl list devices | grep Booted
   ```

2. Si aucun simulateur n'est démarré :
   ```bash
   open -a Simulator
   ```

3. Redémarrer Xcode et le simulateur

4. Nettoyer le build :
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```



