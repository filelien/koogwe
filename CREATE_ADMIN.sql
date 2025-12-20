-- ============================================
-- Script SQL pour créer/configurer le compte Admin
-- KOOGWE - admin@koogwe.com
-- ============================================
-- IMPORTANT: Créez d'abord l'utilisateur via Supabase Dashboard
-- puis exécutez ce script pour configurer le rôle et le profil

-- Étape 1: Vérifier que l'utilisateur existe
DO $$
DECLARE
  admin_user_id UUID;
  user_exists BOOLEAN;
BEGIN
  -- Vérifier si l'utilisateur existe
  SELECT EXISTS(
    SELECT 1 FROM auth.users WHERE email = 'admin@koogwe.com'
  ) INTO user_exists;

  IF NOT user_exists THEN
    RAISE EXCEPTION '❌ Utilisateur admin@koogwe.com non trouvé. 
    
    Veuillez d''abord créer l''utilisateur via Supabase Dashboard:
    1. Allez dans Authentication → Users
    2. Cliquez sur "Add user" → "Create new user"
    3. Email: admin@koogwe.com
    4. Password: Password
    5. Cochez "Auto Confirm User"
    6. Cliquez sur "Create user"
    
    Ensuite, réexécutez ce script.';
  END IF;

  -- Récupérer l'ID de l'utilisateur
  SELECT id INTO admin_user_id
  FROM auth.users
  WHERE email = 'admin@koogwe.com';

  RAISE NOTICE '✅ Utilisateur trouvé: %', admin_user_id;

  -- Étape 2: Créer ou mettre à jour le profil
  INSERT INTO public.profiles (
    id,
    email,
    username,
    first_name,
    last_name,
    phone_number,
    role,
    balance,
    created_at,
    updated_at
  ) VALUES (
    admin_user_id,
    'admin@koogwe.com',
    'admin_koogwe',
    'Admin',
    'KOOGWE',
    NULL,
    'admin',
    0,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    role = 'admin',
    first_name = 'Admin',
    last_name = 'KOOGWE',
    username = 'admin_koogwe',
    updated_at = NOW();

  RAISE NOTICE '✅ Profil créé/mis à jour avec le rôle admin';

  -- Étape 3: Mettre à jour les métadonnées de l'utilisateur
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object(
    'role', 'admin',
    'firstName', 'Admin',
    'lastName', 'KOOGWE',
    'username', 'admin_koogwe'
  )
  WHERE id = admin_user_id;

  RAISE NOTICE '✅ Métadonnées utilisateur mises à jour';

  -- Étape 4: Vérification finale
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ COMPTE ADMIN CONFIGURÉ AVEC SUCCÈS!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Email: admin@koogwe.com';
  RAISE NOTICE 'Password: Password';
  RAISE NOTICE 'Role: admin';
  RAISE NOTICE 'User ID: %', admin_user_id;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  IMPORTANT: Changez le mot de passe après la première connexion!';
  RAISE NOTICE '========================================';

END $$;

-- Vérification: Afficher les informations du compte admin
SELECT 
  u.id,
  u.email,
  u.email_confirmed_at,
  u.created_at,
  p.role,
  p.first_name,
  p.last_name,
  p.username
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE u.email = 'admin@koogwe.com';

