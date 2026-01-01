# Instructions pour appliquer les politiques RLS Supabase

## ⚠️ IMPORTANT : Erreur de récursion infinie

Si vous rencontrez l'erreur "infinite recursion detected in policy for relation 'profiles'", suivez ces étapes :

### 1. Exécuter le fichier SQL dans Supabase

1. Connectez-vous à votre projet Supabase
2. Allez dans **SQL Editor**
3. Copiez et exécutez le contenu du fichier `supabase_policies.sql`

### 2. Vérifier que la fonction `is_admin()` existe

La fonction `is_admin()` doit être créée AVANT les politiques qui l'utilisent. Si elle n'existe pas, exécutez ce SQL :

```sql
-- Fonction pour vérifier si un utilisateur est admin (bypass RLS)
create or replace function public.is_admin()
returns boolean as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$ language sql security definer stable;
```

### 3. Ordre d'exécution recommandé

1. D'abord créer la fonction `is_admin()`
2. Ensuite créer les politiques pour `profiles` (avec la politique admin)
3. Ensuite créer les autres politiques

### 4. Vérification

Après avoir appliqué les politiques, testez en tant qu'admin :
- Vous devriez pouvoir voir tous les utilisateurs
- Vous devriez pouvoir voir toutes les transactions
- Vous devriez pouvoir voir toutes les courses

### 5. Si l'erreur persiste

1. Désactivez temporairement RLS :
   ```sql
   alter table public.profiles disable row level security;
   ```

2. Supprimez toutes les politiques :
   ```sql
   drop policy if exists profiles_select_self on public.profiles;
   drop policy if exists profiles_select_admin on public.profiles;
   -- etc.
   ```

3. Recréez-les dans le bon ordre (fonction d'abord, puis politiques)

## Notes

- La fonction `is_admin()` utilise `SECURITY DEFINER` pour bypasser RLS et éviter la récursion
- Les politiques admin permettent aux utilisateurs avec `role = 'admin'` d'accéder à toutes les données
- Les politiques utilisateur permettent à chaque utilisateur d'accéder à ses propres données

