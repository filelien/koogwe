-- ============================================
-- KOOGWE - Script de configuration Supabase
-- ============================================
-- Exécutez ce script dans l'éditeur SQL de Supabase Dashboard
-- https://oesykhvutfleamrplvxt.supabase.co

-- ============================================
-- 1. EXTENSIONS
-- ============================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 2. TABLES
-- ============================================

-- PROFILES: Table des profils utilisateurs (1:1 avec auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  username TEXT UNIQUE,
  first_name TEXT,
  last_name TEXT,
  phone_number TEXT,
  role TEXT NOT NULL DEFAULT 'passenger' CHECK (role IN ('passenger','driver','admin','business')),
  avatar_url TEXT,
  balance NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles (email);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles (username);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles (role);

-- RIDES: Table des courses
CREATE TABLE IF NOT EXISTS public.rides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES auth.users(id),
  pickup_text TEXT NOT NULL,
  dropoff_text TEXT NOT NULL,
  pickup_lat NUMERIC(10, 8),
  pickup_lng NUMERIC(11, 8),
  dropoff_lat NUMERIC(10, 8),
  dropoff_lng NUMERIC(11, 8),
  vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('eco','comfort','premium','suv','van')),
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested','accepted','in_progress','completed','cancelled')),
  estimated_price NUMERIC(12,2),
  distance_m INTEGER,
  duration_s INTEGER,
  fare NUMERIC(12,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index pour les courses
CREATE INDEX IF NOT EXISTS idx_rides_user_id ON public.rides (user_id);
CREATE INDEX IF NOT EXISTS idx_rides_driver_id ON public.rides (driver_id);
CREATE INDEX IF NOT EXISTS idx_rides_status ON public.rides (status);
CREATE INDEX IF NOT EXISTS idx_rides_created_at ON public.rides (created_at DESC);

-- WALLET_TRANSACTIONS: Table des transactions de portefeuille
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  credit NUMERIC(12,2) NOT NULL DEFAULT 0,
  debit NUMERIC(12,2) NOT NULL DEFAULT 0,
  type TEXT NOT NULL CHECK (type IN ('topup','withdrawal','payment','refund','adjustment')),
  meta JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index pour les transactions
CREATE INDEX IF NOT EXISTS idx_wallet_tx_user_id ON public.wallet_transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_type ON public.wallet_transactions (type);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_created_at ON public.wallet_transactions (created_at DESC);

-- VEHICLES: Table des véhicules des chauffeurs (optionnel)
CREATE TABLE IF NOT EXISTS public.vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER,
  color TEXT,
  plate_number TEXT UNIQUE,
  seats INTEGER NOT NULL DEFAULT 4,
  vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('eco','comfort','premium','suv','van')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id ON public.vehicles (driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_is_active ON public.vehicles (is_active);

-- RATINGS: Table des évaluations (optionnel)
CREATE TABLE IF NOT EXISTS public.ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id UUID REFERENCES public.rides(id) ON DELETE CASCADE,
  rater_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ratee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stars INTEGER NOT NULL CHECK (stars >= 1 AND stars <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ratings_ride_id ON public.ratings (ride_id);
CREATE INDEX IF NOT EXISTS idx_ratings_ratee_id ON public.ratings (ratee_id);

-- ============================================
-- 3. FUNCTIONS & TRIGGERS
-- ============================================

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rides_updated_at BEFORE UPDATE ON public.rides
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON public.vehicles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour créer automatiquement un profil lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, last_name, phone_number, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'firstName', NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'lastName', NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phoneNumber', NEW.raw_user_meta_data->>'phone_number', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'passenger')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer le profil automatiquement
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur toutes les tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. POLITIQUES RLS - PROFILES
-- ============================================

-- Permettre aux utilisateurs de lire leur propre profil
DROP POLICY IF EXISTS profiles_select_self ON public.profiles;
CREATE POLICY profiles_select_self ON public.profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

-- Permettre aux utilisateurs d'insérer leur propre profil
DROP POLICY IF EXISTS profiles_insert_self ON public.profiles;
CREATE POLICY profiles_insert_self ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- Permettre aux utilisateurs de mettre à jour leur propre profil
DROP POLICY IF EXISTS profiles_update_self ON public.profiles;
CREATE POLICY profiles_update_self ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================
-- 6. POLITIQUES RLS - RIDES
-- ============================================

-- Permettre aux utilisateurs de créer leurs propres courses
DROP POLICY IF EXISTS rides_insert_self ON public.rides;
CREATE POLICY rides_insert_self ON public.rides
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Permettre aux utilisateurs de lire leurs propres courses
DROP POLICY IF EXISTS rides_select_self ON public.rides;
CREATE POLICY rides_select_self ON public.rides
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id OR auth.uid() = driver_id);

-- Permettre aux utilisateurs de mettre à jour leurs propres courses
DROP POLICY IF EXISTS rides_update_self ON public.rides;
CREATE POLICY rides_update_self ON public.rides
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id OR auth.uid() = driver_id)
  WITH CHECK (auth.uid() = user_id OR auth.uid() = driver_id);

-- Permettre aux utilisateurs de supprimer leurs propres courses
DROP POLICY IF EXISTS rides_delete_self ON public.rides;
CREATE POLICY rides_delete_self ON public.rides
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ============================================
-- 7. POLITIQUES RLS - WALLET_TRANSACTIONS
-- ============================================

-- Permettre aux utilisateurs de créer leurs propres transactions
DROP POLICY IF EXISTS wallet_tx_insert_self ON public.wallet_transactions;
CREATE POLICY wallet_tx_insert_self ON public.wallet_transactions
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Permettre aux utilisateurs de lire leurs propres transactions
DROP POLICY IF EXISTS wallet_tx_select_self ON public.wallet_transactions;
CREATE POLICY wallet_tx_select_self ON public.wallet_transactions
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Empêcher les utilisateurs de modifier/supprimer les transactions (ledger immuable)
DROP POLICY IF EXISTS wallet_tx_block_update ON public.wallet_transactions;
CREATE POLICY wallet_tx_block_update ON public.wallet_transactions
  FOR UPDATE TO authenticated
  USING (false) WITH CHECK (false);

DROP POLICY IF EXISTS wallet_tx_block_delete ON public.wallet_transactions;
CREATE POLICY wallet_tx_block_delete ON public.wallet_transactions
  FOR DELETE TO authenticated
  USING (false);

-- ============================================
-- 8. POLITIQUES RLS - VEHICLES
-- ============================================

-- Permettre aux chauffeurs de gérer leurs propres véhicules
DROP POLICY IF EXISTS vehicles_select_self ON public.vehicles;
CREATE POLICY vehicles_select_self ON public.vehicles
  FOR SELECT TO authenticated
  USING (auth.uid() = driver_id);

DROP POLICY IF EXISTS vehicles_insert_self ON public.vehicles;
CREATE POLICY vehicles_insert_self ON public.vehicles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = driver_id);

DROP POLICY IF EXISTS vehicles_update_self ON public.vehicles;
CREATE POLICY vehicles_update_self ON public.vehicles
  FOR UPDATE TO authenticated
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

DROP POLICY IF EXISTS vehicles_delete_self ON public.vehicles;
CREATE POLICY vehicles_delete_self ON public.vehicles
  FOR DELETE TO authenticated
  USING (auth.uid() = driver_id);

-- ============================================
-- 9. POLITIQUES RLS - RATINGS
-- ============================================

-- Permettre aux utilisateurs de lire les évaluations de leurs courses
DROP POLICY IF EXISTS ratings_select_self ON public.ratings;
CREATE POLICY ratings_select_self ON public.ratings
  FOR SELECT TO authenticated
  USING (auth.uid() = rater_id OR auth.uid() = ratee_id);

-- Permettre aux utilisateurs de créer des évaluations pour leurs courses
DROP POLICY IF EXISTS ratings_insert_self ON public.ratings;
CREATE POLICY ratings_insert_self ON public.ratings
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = rater_id);

-- ============================================
-- FIN DU SCRIPT
-- ============================================
-- Vérifiez que toutes les tables et politiques ont été créées correctement
-- en allant dans Supabase Dashboard > Table Editor

