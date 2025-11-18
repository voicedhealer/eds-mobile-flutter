# Installation de Flutter sur macOS

## Méthode 1 : Installation via Homebrew (Recommandée)

Si vous avez Homebrew installé (ce qui semble être le cas), c'est la méthode la plus simple :

```bash
# Installer Flutter
brew install --cask flutter

# Vérifier l'installation
flutter doctor
```

## Méthode 2 : Installation manuelle

### 1. Télécharger Flutter

```bash
# Aller dans le dossier d'installation
cd ~/development

# Télécharger Flutter (ou télécharger depuis https://docs.flutter.dev/get-started/install/macos)
git clone https://github.com/flutter/flutter.git -b stable

# Ajouter Flutter au PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Ajouter Flutter au PATH de manière permanente

Ajoutez cette ligne à votre fichier `~/.zshrc` :

```bash
# Ouvrir le fichier
nano ~/.zshrc

# Ajouter cette ligne (remplacez le chemin par votre chemin réel)
export PATH="$PATH:$HOME/development/flutter/bin"

# Sauvegarder (Ctrl+O, puis Entrée, puis Ctrl+X)
# Recharger le shell
source ~/.zshrc
```

### 3. Vérifier l'installation

```bash
flutter doctor
```

## Configuration après installation

### Installer les dépendances manquantes

Flutter Doctor vous indiquera ce qui manque. Voici les commandes courantes :

```bash
# Accepter les licences Android
flutter doctor --android-licenses

# Installer CocoaPods pour iOS (si nécessaire)
sudo gem install cocoapods
```

### Installer Xcode (pour iOS)

```bash
# Installer Xcode depuis l'App Store
# Puis installer les outils de ligne de commande
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Installer Android Studio (pour Android)

1. Téléchargez depuis https://developer.android.com/studio
2. Installez Android Studio
3. Ouvrez Android Studio et installez les SDK nécessaires
4. Configurez les variables d'environnement :

```bash
# Ajouter à ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

## Vérification finale

```bash
# Vérifier que Flutter fonctionne
flutter doctor -v

# Vérifier la version
flutter --version

# Vérifier les appareils disponibles
flutter devices
```

## Prochaines étapes

Une fois Flutter installé :

```bash
# Aller dans le projet
cd /Users/vivien/eds-mobile-flutter

# Installer les dépendances
flutter pub get

# Vérifier que tout est OK
flutter doctor

# Lancer l'application (sur un émulateur ou appareil connecté)
flutter run
```

## Dépannage

### Flutter non trouvé après installation

```bash
# Vérifier que Flutter est dans le PATH
echo $PATH | grep flutter

# Si non, ajouter manuellement pour cette session
export PATH="$PATH:/chemin/vers/flutter/bin"

# Ou utiliser le chemin complet
/chemin/vers/flutter/bin/flutter --version
```

### Erreur de permissions

```bash
# Donner les permissions d'exécution
chmod +x /chemin/vers/flutter/bin/flutter
```

### Mettre à jour Flutter

```bash
flutter upgrade
```

