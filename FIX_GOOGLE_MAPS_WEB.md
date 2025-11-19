# 🔧 Correction de l'erreur Google Maps sur le Web

## Problème

L'erreur `TypeError: Cannot read properties of undefined (reading 'maps')` se produit car Google Maps JavaScript API n'est pas chargée dans le fichier `web/index.html`.

## Solution

### 1. Fichier `web/index.html` créé

Le fichier `web/index.html` a été créé avec la configuration nécessaire pour charger Google Maps JavaScript API.

### 2. Script d'injection de la clé API

Un script `scripts/inject_google_maps_key.sh` a été créé pour injecter automatiquement votre clé API Google Maps depuis le fichier `.env` dans `web/index.html`.

### 3. Utilisation

#### Option 1 : Utiliser le script automatique (Recommandé)

```bash
./scripts/inject_google_maps_key.sh
flutter run -d chrome
```

#### Option 2 : Modifier manuellement `web/index.html`

1. Ouvrez `web/index.html`
2. Remplacez `YOUR_GOOGLE_MAPS_API_KEY` par votre clé API Google Maps (trouvée dans votre fichier `.env` sous `GOOGLE_PLACES_API_KEY`)
3. Relancez l'application

### 4. Vérification

Après avoir injecté la clé, vérifiez que :
- Le script Google Maps est chargé dans la console du navigateur (F12)
- Aucune erreur "Cannot read properties of undefined" n'apparaît
- La carte s'affiche correctement

## Notes importantes

- **Sécurité** : Ne commitez jamais votre fichier `web/index.html` avec votre clé API en production
- **Restrictions** : Configurez les restrictions de domaine dans Google Cloud Console pour limiter l'utilisation de votre clé API
- **Build** : Pour la production, utilisez un script de build qui injecte la clé API au moment du build

## Prochaines étapes

1. Exécutez le script d'injection : `./scripts/inject_google_maps_key.sh`
2. Relancez l'application : `flutter run -d chrome`
3. Testez la carte : Cliquez sur "Carte" dans l'application

## En cas de problème

Si l'erreur persiste :

1. Vérifiez que votre clé API Google Maps est valide
2. Vérifiez que l'API Google Maps JavaScript est activée dans Google Cloud Console
3. Vérifiez la console du navigateur (F12) pour d'autres erreurs
4. Assurez-vous que le script Google Maps est bien chargé dans l'onglet Network

