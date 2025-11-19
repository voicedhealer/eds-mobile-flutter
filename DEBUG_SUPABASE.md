# 🔍 Débogage Supabase - Vérification des établissements

## Problème
Aucun établissement trouvé à Beaune alors que la carte fonctionne.

## Vérifications effectuées

### 1. Logs ajoutés
- ✅ Logs dans `getByCity()` pour voir ce qui est recherché
- ✅ Logs dans `popularEstablishmentsProvider` pour voir la ville détectée
- ✅ Logs dans `initSupabase()` pour confirmer l'initialisation

### 2. Améliorations apportées
- ✅ Recherche insensible à la casse avec `.ilike()` au lieu de `.eq()`
- ✅ Messages d'erreur plus détaillés
- ✅ Vérification de l'initialisation Supabase

## Comment déboguer

### 1. Vérifier les logs dans la console
Lancez l'application et regardez les logs :
```bash
flutter run -d "iPhone 17 Pro"
```

Vous devriez voir :
- `✅ Supabase initialisé avec succès`
- `📍 Ville détectée: Beaune` (ou autre)
- `🔍 Recherche d'établissements à: Beaune`
- `✅ Trouvé X établissement(s)` ou `ℹ️ Aucun établissement trouvé`

### 2. Vérifier dans Supabase
Connectez-vous à votre projet Supabase et vérifiez :

1. **La table `establishments` existe-t-elle ?**
   ```sql
   SELECT * FROM establishments LIMIT 5;
   ```

2. **Y a-t-il des établissements à Beaune ?**
   ```sql
   SELECT * FROM establishments WHERE city ILIKE '%beaune%';
   ```

3. **Les établissements ont-ils le status 'approved' ?**
   ```sql
   SELECT city, status, COUNT(*) 
   FROM establishments 
   GROUP BY city, status;
   ```

### 3. Problèmes possibles

#### Problème 1 : Ville différente dans la base
- La base peut avoir "BEAUNE" en majuscules
- La base peut avoir des accents différents
- Solution : Utilisation de `.ilike()` pour recherche flexible

#### Problème 2 : Aucun établissement avec status='approved'
- Vérifiez le status des établissements
- Modifiez temporairement la requête pour voir tous les établissements

#### Problème 3 : Supabase non initialisé
- Vérifiez les logs au démarrage
- Vérifiez que SUPABASE_URL et SUPABASE_ANON_KEY sont corrects dans `.env`

## Test rapide

Pour tester directement Supabase, vous pouvez temporairement modifier `getByCity()` :

```dart
// Test : récupérer tous les établissements
final response = await _supabase!
    .from('establishments')
    .select()
    .limit(10);
```

Cela vous permettra de voir s'il y a des données dans la table.

