-- KOOGWE Supabase Schema (canonical source)
-- This schema matches the current Flutter services:
--  - RidesService uses table: rides
--  - WalletService uses tables: profiles (optional balance), wallet_transactions
--  - Auth flow upserts into: profiles

-- Extensions (for gen_random_uuid)
create extension if not exists pgcrypto;

-- PROFILES: 1:1 with auth.users
-- Acts as our application-level "users" table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  username text unique,
  first_name text,
  last_name text,
  phone_number text,
  role text not null default 'passenger' check (role in ('passenger','driver','admin','business')),
  avatar_url text,
  balance numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_email on public.profiles (email);
create index if not exists idx_profiles_username on public.profiles (username);

-- RIDES
create table if not exists public.rides (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  driver_id uuid references auth.users(id),
  pickup_text text not null,
  dropoff_text text not null,
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  vehicle_type text not null,
  status text not null default 'requested' check (status in ('requested','accepted','in_progress','completed','cancelled')),
  estimated_price numeric(12,2),
  distance_m integer,
  duration_s integer,
  fare numeric(12,2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_rides_user_id on public.rides (user_id);
create index if not exists idx_rides_created_at on public.rides (created_at desc);

-- DRIVER LOCATIONS: Positions des chauffeurs en temps réel
create table if not exists public.driver_locations (
  driver_id uuid primary key references auth.users(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  heading double precision,
  speed double precision,
  accuracy double precision,
  updated_at timestamptz not null default now()
);

create index if not exists idx_driver_locations_updated_at on public.driver_locations (updated_at desc);

-- FAMILY MEMBERS: Gestion des membres de famille
create table if not exists public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_owner_id uuid not null references auth.users(id) on delete cascade,
  member_user_id uuid references auth.users(id),
  name text not null,
  email text not null,
  phone text,
  role text not null default 'child' check (role in ('parent', 'child')),
  status text not null default 'pending' check (status in ('active', 'pending', 'blocked')),
  can_request_rides boolean not null default true,
  can_receive_rides boolean not null default true,
  monthly_budget_limit numeric(12,2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_family_members_owner on public.family_members (family_owner_id);
create index if not exists idx_family_members_member on public.family_members (member_user_id);

-- FAMILY SETTINGS: Paramètres du mode famille
create table if not exists public.family_settings (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  is_active boolean not null default false,
  monthly_budget numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- WALLET TRANSACTIONS
create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  credit numeric(12,2) not null default 0,
  debit numeric(12,2) not null default 0,
  type text not null check (type in ('topup','withdrawal','payment','refund')),
  meta jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_wallet_tx_user_id on public.wallet_transactions (user_id);
create index if not exists idx_wallet_tx_created_at on public.wallet_transactions (created_at desc);

-- PRICING SETTINGS: Configuration des prix par kilomètre par type de véhicule
create table if not exists public.pricing_settings (
  id uuid primary key default gen_random_uuid(),
  vehicle_type text not null unique,
  base_price numeric(12,2) not null default 2.5,
  price_per_km numeric(12,2) not null default 1.5,
  minimum_price numeric(12,2) not null default 5.0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_pricing_settings_vehicle_type on public.pricing_settings (vehicle_type);
create index if not exists idx_pricing_settings_active on public.pricing_settings (is_active);

-- Insertion des valeurs par défaut pour les types de véhicules
insert into public.pricing_settings (vehicle_type, base_price, price_per_km, minimum_price, is_active)
values
  ('CAR', 2.5, 1.2, 5.0, true),
  ('MOTO', 2.0, 1.0, 4.0, true),
  ('KOOGWE Eco', 3.0, 1.5, 6.0, true),
  ('KOOGWE Confort', 4.0, 2.0, 8.0, true),
  ('KOOGWE Premium', 6.0, 3.0, 12.0, true),
  ('economy', 2.5, 1.2, 5.0, true),
  ('comfort', 4.0, 2.0, 8.0, true),
  ('premium', 6.0, 3.0, 12.0, true),
  ('luxury', 8.0, 4.0, 15.0, true)
on conflict (vehicle_type) do nothing;

-- CARPOOL RIDES: Covoiturage - Trajets partagés
create table if not exists public.carpool_rides (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references auth.users(id) on delete cascade,
  pickup_text text not null,
  dropoff_text text not null,
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  scheduled_departure timestamptz not null,
  available_seats integer not null default 4,
  price_per_seat numeric(12,2) not null,
  status text not null default 'open' check (status in ('open', 'full', 'in_progress', 'completed', 'cancelled')),
  description text,
  vehicle_type text,
  distance_m integer,
  duration_s integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_carpool_driver_id on public.carpool_rides (driver_id);
create index if not exists idx_carpool_status on public.carpool_rides (status);
create index if not exists idx_carpool_departure on public.carpool_rides (scheduled_departure);
create index if not exists idx_carpool_created_at on public.carpool_rides (created_at desc);

-- CARPOOL BOOKINGS: Réservations de covoiturage
create table if not exists public.carpool_bookings (
  id uuid primary key default gen_random_uuid(),
  carpool_ride_id uuid not null references public.carpool_rides(id) on delete cascade,
  passenger_id uuid not null references auth.users(id) on delete cascade,
  seats_requested integer not null default 1,
  status text not null default 'pending' check (status in ('pending', 'confirmed', 'cancelled', 'rejected')),
  pickup_text text,
  dropoff_text text,
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  total_price numeric(12,2) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(carpool_ride_id, passenger_id)
);

create index if not exists idx_carpool_booking_ride_id on public.carpool_bookings (carpool_ride_id);
create index if not exists idx_carpool_booking_passenger_id on public.carpool_bookings (passenger_id);
create index if not exists idx_carpool_booking_status on public.carpool_bookings (status);

-- NOTE ABOUT LEGACY public.users TABLE
-- If a previous migration created public.users with columns like full_name,
-- prefer using public.profiles instead going forward. Seeds inserting into
-- public.users should be removed or migrated to profiles.
