# ✅ Configuration Railway avec Cloudflare

## Configuration détectée

D'après votre configuration Railway :
- **Domaine public** : `envie2sortir.fr`
- **Proxy Cloudflare** : ✅ Détecté
- **Port** : 8080
- **Domaine interne** : `envie2sortir.railway.internal` (pour communication interne)

## Configuration pour Flutter

Ajoutez cette ligne dans votre fichier `.env` :

```env
RAILWAY_API_URL=https://envie2sortir.fr
```

**Important** : Utilisez `https://envie2sortir.fr` (votre domaine public), pas le domaine Railway généré automatiquement.

## Pourquoi Cloudflare ?

Cloudflare agit comme proxy devant votre backend Railway :
- ✅ Protection DDoS
- ✅ SSL/TLS automatique (HTTPS)
- ✅ Cache et optimisation
- ✅ CDN

Votre application Flutter communiquera avec `https://envie2sortir.fr` qui redirige vers Railway sur le port 8080.

## Vérification

Après avoir ajouté `RAILWAY_API_URL=https://envie2sortir.fr` dans `.env` :

1. Relancez l'application
2. Vérifiez les logs :
   ```
   ✅ Railway API configurée: https://envie2sortir.fr
   ```

## Endpoints disponibles

Une fois configuré, votre application pourra appeler :
- `https://envie2sortir.fr/api/recherche/filtered` (recherche avancée)

## Note

Le domaine interne `envie2sortir.railway.internal` est uniquement pour la communication entre services Railway, pas pour votre application Flutter.

