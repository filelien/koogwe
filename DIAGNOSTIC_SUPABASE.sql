-- ============================================
-- Script de Diagnostic Supabase - KOOGWE
-- ============================================
-- Exécutez ce script dans Supabase Dashboard → SQL Editor
-- pour vérifier que tout est correctement configuré

-- 1. Vérifier que les extensions sont installées
SELECT 
  extname as extension_name,
  extversion as version
FROM pg_extension
WHERE extname IN ('pgcrypto', 'uuid-ossp');

-- 2. Vérifier que les tables existent
SELECT 
  table_name,
  table_schema
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('profiles', 'rides', 'wallet_transactions', 'vehicles', 'ratings')
ORDER BY table_name;

-- 3. Vérifier que RLS est activé
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'rides', 'wallet_transactions', 'vehicles', 'ratings')
ORDER BY tablename;

-- 4. Vérifier les politiques RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd as command
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'rides', 'wallet_transactions')
ORDER BY tablename, policyname;

-- 5. Vérifier les triggers
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  OR (trigger_schema = 'auth' AND trigger_name = 'on_auth_user_created')
ORDER BY event_object_table, trigger_name;

-- 6. Vérifier les fonctions
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('handle_new_user', 'update_updated_at_column')
ORDER BY routine_name;

-- 7. Compter les utilisateurs
SELECT COUNT(*) as total_users FROM auth.users;

-- 8. Compter les profils
SELECT COUNT(*) as total_profiles FROM public.profiles;

-- 9. Vérifier la structure de la table profiles
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 10. Test de connexion (doit retourner 0 ou plus)
SELECT COUNT(*) as test_connection FROM public.profiles LIMIT 1;

-- ============================================
-- Résumé des vérifications
-- ============================================
-- Si toutes les requêtes ci-dessus fonctionnent :
-- ✅ Les tables existent
-- ✅ RLS est activé
-- ✅ Les politiques sont créées
-- ✅ Les triggers sont en place
-- ✅ La connexion fonctionne

-- Si certaines requêtes échouent :
-- ❌ Exécutez SUPABASE_SETUP.sql pour corriger

