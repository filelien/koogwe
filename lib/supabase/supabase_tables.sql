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
  vehicle_type text not null,
  status text not null default 'requested' check (status in ('requested','accepted','in_progress','completed','cancelled')),
  estimated_price numeric(12,2),
  distance_m integer,
  duration_s integer,
  fare numeric(12,2),
  created_at timestamptz not null default now()
);

create index if not exists idx_rides_user_id on public.rides (user_id);
create index if not exists idx_rides_created_at on public.rides (created_at desc);

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

-- NOTE ABOUT LEGACY public.users TABLE
-- If a previous migration created public.users with columns like full_name,
-- prefer using public.profiles instead going forward. Seeds inserting into
-- public.users should be removed or migrated to profiles.
