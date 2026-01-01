-- Migration: Ajouter les colonnes de coordonnées GPS aux courses
-- Date: 2024
-- Description: Ajoute pickup_lat, pickup_lng, dropoff_lat, dropoff_lng à la table rides

-- Ajouter les colonnes si elles n'existent pas déjà
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'rides' 
    AND column_name = 'pickup_lat'
  ) THEN
    ALTER TABLE public.rides ADD COLUMN pickup_lat double precision;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'rides' 
    AND column_name = 'pickup_lng'
  ) THEN
    ALTER TABLE public.rides ADD COLUMN pickup_lng double precision;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'rides' 
    AND column_name = 'dropoff_lat'
  ) THEN
    ALTER TABLE public.rides ADD COLUMN dropoff_lat double precision;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'rides' 
    AND column_name = 'dropoff_lng'
  ) THEN
    ALTER TABLE public.rides ADD COLUMN dropoff_lng double precision;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'rides' 
    AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.rides ADD COLUMN updated_at timestamptz not null default now();
  END IF;
END $$;

-- Créer un index sur les coordonnées pour les requêtes géospatiales
CREATE INDEX IF NOT EXISTS idx_rides_pickup_location ON public.rides USING GIST (point(pickup_lng, pickup_lat)) WHERE pickup_lat IS NOT NULL AND pickup_lng IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_rides_dropoff_location ON public.rides USING GIST (point(dropoff_lng, dropoff_lat)) WHERE dropoff_lat IS NOT NULL AND dropoff_lng IS NOT NULL;

