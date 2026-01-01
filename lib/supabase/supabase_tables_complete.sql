-- =====================================================
-- KOOGWE - SCHÉMA COMPLET DE BASE DE DONNÉES
-- Version: 2.0.0
-- Date: $(date)
-- =====================================================
-- Ce fichier contient TOUTES les tables nécessaires
-- pour une application de production complète
-- =====================================================

-- Extensions
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- =====================================================
-- 1. PROFILES (Utilisateurs)
-- =====================================================
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
  is_verified boolean not null default false,
  is_active boolean not null default true,
  two_factor_enabled boolean not null default false,
  two_factor_secret text,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_email on public.profiles (email);
create index if not exists idx_profiles_username on public.profiles (username);
create index if not exists idx_profiles_role on public.profiles (role);
create index if not exists idx_profiles_is_active on public.profiles (is_active);

-- =====================================================
-- 2. DRIVERS (Chauffeurs)
-- =====================================================
create table if not exists public.drivers (
  id uuid primary key references auth.users(id) on delete cascade,
  license_number text not null,
  license_expiry date,
  status text not null default 'pending' check (status in ('pending','approved','rejected','suspended')),
  is_online boolean not null default false,
  is_available boolean not null default true,
  total_rides integer not null default 0,
  total_earnings numeric(12,2) not null default 0,
  average_rating numeric(3,2) default 0.0,
  verification_status text not null default 'pending' check (verification_status in ('pending','verified','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_drivers_status on public.drivers (status);
create index if not exists idx_drivers_is_online on public.drivers (is_online);
create index if not exists idx_drivers_is_available on public.drivers (is_available);

-- =====================================================
-- 3. VEHICLES (Véhicules)
-- =====================================================
create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references auth.users(id) on delete cascade,
  make text not null,
  model text not null,
  year integer not null,
  color text not null,
  plate_number text not null,
  vehicle_type text not null check (vehicle_type in ('economy','comfort','premium','luxury','suv','motorcycle','electric','hybrid','utility')),
  seats integer not null default 4,
  status text not null default 'active' check (status in ('active','inactive','maintenance','rejected')),
  insurance_expiry date,
  registration_expiry date,
  photos text[], -- Array of photo URLs
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(driver_id, plate_number)
);

create index if not exists idx_vehicles_driver_id on public.vehicles (driver_id);
create index if not exists idx_vehicles_status on public.vehicles (status);
create index if not exists idx_vehicles_vehicle_type on public.vehicles (vehicle_type);

-- =====================================================
-- 4. DRIVER DOCUMENTS (Documents Chauffeurs)
-- =====================================================
create table if not exists public.driver_documents (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references auth.users(id) on delete cascade,
  document_type text not null check (document_type in ('identity','license','insurance','registration','medical','background','other')),
  file_url text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected','expired')),
  expiry_date date,
  rejection_reason text,
  uploaded_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_driver_documents_driver_id on public.driver_documents (driver_id);
create index if not exists idx_driver_documents_status on public.driver_documents (status);
create index if not exists idx_driver_documents_type on public.driver_documents (document_type);

-- =====================================================
-- 5. RIDES (Courses)
-- =====================================================
create table if not exists public.rides (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  driver_id uuid references auth.users(id),
  vehicle_id uuid references public.vehicles(id),
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
  payment_method text,
  payment_status text not null default 'pending' check (payment_status in ('pending','paid','refunded','failed')),
  scheduled_at timestamptz, -- Pour les trajets programmés
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,
  cancelled_by uuid references auth.users(id),
  route_polyline text, -- Encoded polyline pour l'itinéraire
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_rides_user_id on public.rides (user_id);
create index if not exists idx_rides_driver_id on public.rides (driver_id);
create index if not exists idx_rides_status on public.rides (status);
create index if not exists idx_rides_created_at on public.rides (created_at desc);
create index if not exists idx_rides_scheduled_at on public.rides (scheduled_at);
create index if not exists idx_rides_payment_status on public.rides (payment_status);
create index if not exists idx_rides_user_status on public.rides (user_id, status);
create index if not exists idx_rides_driver_status on public.rides (driver_id, status);

-- =====================================================
-- 6. RATINGS (Notes et Avis)
-- =====================================================
create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null references public.rides(id) on delete cascade,
  rater_id uuid not null references auth.users(id) on delete cascade,
  ratee_id uuid not null references auth.users(id) on delete cascade,
  stars integer not null check (stars >= 1 and stars <= 5),
  comment text,
  category_ratings jsonb, -- Ex: {"cleanliness": 5, "punctuality": 4, "courtesy": 5}
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(ride_id, rater_id, ratee_id)
);

create index if not exists idx_ratings_ride_id on public.ratings (ride_id);
create index if not exists idx_ratings_ratee_id on public.ratings (ratee_id);
create index if not exists idx_ratings_rater_id on public.ratings (rater_id);
create index if not exists idx_ratings_stars on public.ratings (stars);

-- =====================================================
-- 7. DRIVER LOCATIONS (Positions Chauffeurs)
-- =====================================================
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

-- =====================================================
-- 8. WALLET TRANSACTIONS (Transactions Portefeuille)
-- =====================================================
create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  credit numeric(12,2) not null default 0 check (credit >= 0),
  debit numeric(12,2) not null default 0 check (debit >= 0),
  type text not null check (type in ('topup','withdrawal','payment','refund','adjustment','bonus','commission')),
  status text not null default 'pending' check (status in ('pending','completed','failed','cancelled')),
  payment_method text,
  payment_reference text,
  meta jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (credit = 0 or debit = 0) -- Soit crédit soit débit, pas les deux
);

create index if not exists idx_wallet_tx_user_id on public.wallet_transactions (user_id);
create index if not exists idx_wallet_tx_type on public.wallet_transactions (type);
create index if not exists idx_wallet_tx_status on public.wallet_transactions (status);
create index if not exists idx_wallet_tx_created_at on public.wallet_transactions (created_at desc);
create index if not exists idx_wallet_tx_user_type on public.wallet_transactions (user_id, type);

-- =====================================================
-- 9. PRICING SETTINGS (Paramètres de Tarification)
-- =====================================================
create table if not exists public.pricing_settings (
  id uuid primary key default gen_random_uuid(),
  vehicle_type text not null unique,
  base_fare numeric(12,2) not null default 2.5 check (base_fare >= 0),
  price_per_km numeric(12,2) not null default 1.5 check (price_per_km >= 0),
  min_fare numeric(12,2) not null default 5.0 check (min_fare >= 0),
  price_per_minute numeric(12,2) default 0.0 check (price_per_minute >= 0),
  surge_multiplier numeric(4,2) default 1.0 check (surge_multiplier >= 1.0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_pricing_settings_vehicle_type on public.pricing_settings (vehicle_type);
create index if not exists idx_pricing_settings_active on public.pricing_settings (is_active);

-- =====================================================
-- 10. CARPOOL RIDES (Covoiturage)
-- =====================================================
create table if not exists public.carpool_rides (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references auth.users(id) on delete cascade,
  vehicle_id uuid references public.vehicles(id),
  pickup_text text not null,
  dropoff_text text not null,
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  route_polyline text,
  scheduled_at timestamptz not null,
  available_seats integer not null default 1 check (available_seats > 0),
  total_seats integer not null default 1 check (total_seats > 0),
  price_per_seat numeric(12,2) not null check (price_per_seat >= 0),
  status text not null default 'pending' check (status in ('pending','active','full','in_progress','completed','cancelled')),
  description text,
  vehicle_type text,
  distance_m integer,
  duration_s integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (available_seats <= total_seats)
);

create index if not exists idx_carpool_rides_driver_id on public.carpool_rides (driver_id);
create index if not exists idx_carpool_rides_status on public.carpool_rides (status);
create index if not exists idx_carpool_rides_scheduled_at on public.carpool_rides (scheduled_at);
create index if not exists idx_carpool_rides_created_at on public.carpool_rides (created_at desc);

-- =====================================================
-- 11. CARPOOL BOOKINGS (Réservations Covoiturage)
-- =====================================================
create table if not exists public.carpool_bookings (
  id uuid primary key default gen_random_uuid(),
  carpool_ride_id uuid not null references public.carpool_rides(id) on delete cascade,
  passenger_id uuid not null references auth.users(id) on delete cascade,
  seats_booked integer not null default 1 check (seats_booked > 0),
  status text not null default 'pending' check (status in ('pending','confirmed','cancelled','rejected')),
  pickup_text text,
  dropoff_text text,
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  total_price numeric(12,2) not null check (total_price >= 0),
  payment_status text not null default 'pending' check (payment_status in ('pending','paid','refunded')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(carpool_ride_id, passenger_id)
);

create index if not exists idx_carpool_bookings_carpool_ride_id on public.carpool_bookings (carpool_ride_id);
create index if not exists idx_carpool_bookings_passenger_id on public.carpool_bookings (passenger_id);
create index if not exists idx_carpool_bookings_status on public.carpool_bookings (status);

-- =====================================================
-- 12. COMPANIES (Entreprises)
-- =====================================================
create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  phone text,
  address text,
  tax_id text,
  registration_number text,
  monthly_budget numeric(12,2) not null default 0 check (monthly_budget >= 0),
  current_spent numeric(12,2) not null default 0 check (current_spent >= 0),
  status text not null default 'pending' check (status in ('pending','approved','rejected','suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_companies_owner_id on public.companies (owner_id);
create index if not exists idx_companies_status on public.companies (status);

-- =====================================================
-- 13. COMPANY USERS (Employés Entreprises)
-- =====================================================
create table if not exists public.company_users (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'employee' check (role in ('admin','manager','employee')),
  department text,
  monthly_limit numeric(12,2),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, user_id)
);

create index if not exists idx_company_users_company_id on public.company_users (company_id);
create index if not exists idx_company_users_user_id on public.company_users (user_id);
create index if not exists idx_company_users_is_active on public.company_users (is_active);

-- =====================================================
-- 14. NOTIFICATIONS (Notifications)
-- =====================================================
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('ride_request','ride_accepted','ride_started','ride_completed','ride_cancelled','payment','message','system','promotion','reminder')),
  title text not null,
  body text not null,
  data jsonb, -- Données supplémentaires
  is_read boolean not null default false,
  read_at timestamptz,
  action_url text, -- URL de redirection
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user_id on public.notifications (user_id);
create index if not exists idx_notifications_is_read on public.notifications (is_read);
create index if not exists idx_notifications_created_at on public.notifications (created_at desc);
create index if not exists idx_notifications_user_read on public.notifications (user_id, is_read);

-- =====================================================
-- 15. MESSAGES (Chat)
-- =====================================================
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid references public.rides(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  message_type text not null default 'text' check (message_type in ('text','image','location','system')),
  media_url text,
  is_read boolean not null default false,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_messages_ride_id on public.messages (ride_id);
create index if not exists idx_messages_sender_id on public.messages (sender_id);
create index if not exists idx_messages_receiver_id on public.messages (receiver_id);
create index if not exists idx_messages_created_at on public.messages (created_at desc);
create index if not exists idx_messages_ride_created on public.messages (ride_id, created_at desc);

-- =====================================================
-- 16. SOS ALERTS (Alertes SOS)
-- =====================================================
create table if not exists public.sos_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  ride_id uuid references public.rides(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  address text,
  status text not null default 'active' check (status in ('active','resolved','false_alarm')),
  resolved_at timestamptz,
  resolved_by uuid references auth.users(id),
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists idx_sos_alerts_user_id on public.sos_alerts (user_id);
create index if not exists idx_sos_alerts_status on public.sos_alerts (status);
create index if not exists idx_sos_alerts_created_at on public.sos_alerts (created_at desc);

-- =====================================================
-- 17. AUDIT LOGS (Logs d'Audit)
-- =====================================================
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  old_values jsonb,
  new_values jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

create index if not exists idx_audit_logs_user_id on public.audit_logs (user_id);
create index if not exists idx_audit_logs_entity on public.audit_logs (entity_type, entity_id);
create index if not exists idx_audit_logs_created_at on public.audit_logs (created_at desc);
create index if not exists idx_audit_logs_action on public.audit_logs (action);

-- =====================================================
-- 18. FAMILY MEMBERS (Membres Famille)
-- =====================================================
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
  monthly_budget_limit numeric(12,2) check (monthly_budget_limit >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_family_members_owner on public.family_members (family_owner_id);
create index if not exists idx_family_members_member on public.family_members (member_user_id);
create index if not exists idx_family_members_status on public.family_members (status);

-- =====================================================
-- 19. FAMILY SETTINGS (Paramètres Famille)
-- =====================================================
create table if not exists public.family_settings (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  is_active boolean not null default false,
  monthly_budget numeric(12,2) not null default 0 check (monthly_budget >= 0),
  current_spent numeric(12,2) not null default 0 check (current_spent >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =====================================================
-- 20. FAVORITES (Destinations Favorites)
-- =====================================================
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  address text not null,
  latitude double precision,
  longitude double precision,
  icon text, -- Nom de l'icône
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_favorites_user_id on public.favorites (user_id);

-- =====================================================
-- 21. SEARCH HISTORY (Historique de Recherche)
-- =====================================================
create table if not exists public.search_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  query text not null,
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now()
);

create index if not exists idx_search_history_user_id on public.search_history (user_id);
create index if not exists idx_search_history_created_at on public.search_history (created_at desc);

-- =====================================================
-- 22. DISPUTES (Litiges)
-- =====================================================
create table if not exists public.disputes (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid references public.rides(id) on delete set null,
  user_id uuid not null references auth.users(id) on delete cascade,
  driver_id uuid references auth.users(id),
  type text not null check (type in ('payment','service','safety','other')),
  subject text not null,
  description text not null,
  status text not null default 'open' check (status in ('open','in_progress','resolved','closed')),
  resolution text,
  resolved_by uuid references auth.users(id),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_disputes_user_id on public.disputes (user_id);
create index if not exists idx_disputes_driver_id on public.disputes (driver_id);
create index if not exists idx_disputes_status on public.disputes (status);
create index if not exists idx_disputes_ride_id on public.disputes (ride_id);

-- =====================================================
-- 23. SUBSCRIPTIONS (Abonnements)
-- =====================================================
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_type text not null check (plan_type in ('weekly','monthly','yearly')),
  status text not null default 'active' check (status in ('active','expired','cancelled','pending')),
  start_date timestamptz not null,
  end_date timestamptz not null,
  price numeric(12,2) not null check (price >= 0),
  discount_percentage numeric(5,2) default 0.0,
  rides_used integer not null default 0,
  rides_limit integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_subscriptions_user_id on public.subscriptions (user_id);
create index if not exists idx_subscriptions_status on public.subscriptions (status);
create index if not exists idx_subscriptions_end_date on public.subscriptions (end_date);

-- =====================================================
-- 24. PROMOTIONS (Promotions)
-- =====================================================
create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  description text,
  discount_type text not null check (discount_type in ('percentage','fixed','free_ride')),
  discount_value numeric(12,2) not null check (discount_value >= 0),
  min_amount numeric(12,2) default 0,
  max_discount numeric(12,2),
  max_uses integer,
  used_count integer not null default 0,
  valid_from timestamptz not null,
  valid_until timestamptz not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_promotions_code on public.promotions (code);
create index if not exists idx_promotions_is_active on public.promotions (is_active);
create index if not exists idx_promotions_valid_until on public.promotions (valid_until);

-- =====================================================
-- 25. PROMOTION USAGES (Utilisations de Promotions)
-- =====================================================
create table if not exists public.promotion_usages (
  id uuid primary key default gen_random_uuid(),
  promotion_id uuid not null references public.promotions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  ride_id uuid references public.rides(id) on delete set null,
  discount_amount numeric(12,2) not null check (discount_amount >= 0),
  created_at timestamptz not null default now(),
  unique(promotion_id, user_id, ride_id)
);

create index if not exists idx_promotion_usages_promotion_id on public.promotion_usages (promotion_id);
create index if not exists idx_promotion_usages_user_id on public.promotion_usages (user_id);

-- =====================================================
-- 26. INVOICES (Factures)
-- =====================================================
create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_number text not null unique,
  ride_id uuid references public.rides(id) on delete set null,
  user_id uuid not null references auth.users(id) on delete cascade,
  company_id uuid references public.companies(id) on delete set null,
  amount numeric(12,2) not null check (amount >= 0),
  tax_amount numeric(12,2) default 0 check (tax_amount >= 0),
  total_amount numeric(12,2) not null check (total_amount >= 0),
  payment_status text not null default 'pending' check (payment_status in ('pending','paid','overdue','cancelled')),
  issued_at timestamptz not null default now(),
  due_at timestamptz,
  paid_at timestamptz,
  pdf_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_invoices_user_id on public.invoices (user_id);
create index if not exists idx_invoices_company_id on public.invoices (company_id);
create index if not exists idx_invoices_payment_status on public.invoices (payment_status);
create index if not exists idx_invoices_invoice_number on public.invoices (invoice_number);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger pour mettre à jour updated_at automatiquement
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Appliquer le trigger à toutes les tables avec updated_at
create trigger update_profiles_updated_at before update on public.profiles
  for each row execute function update_updated_at_column();

create trigger update_drivers_updated_at before update on public.drivers
  for each row execute function update_updated_at_column();

create trigger update_vehicles_updated_at before update on public.vehicles
  for each row execute function update_updated_at_column();

create trigger update_rides_updated_at before update on public.rides
  for each row execute function update_updated_at_column();

create trigger update_ratings_updated_at before update on public.ratings
  for each row execute function update_updated_at_column();

create trigger update_wallet_tx_updated_at before update on public.wallet_transactions
  for each row execute function update_updated_at_column();

create trigger update_pricing_settings_updated_at before update on public.pricing_settings
  for each row execute function update_updated_at_column();

create trigger update_carpool_rides_updated_at before update on public.carpool_rides
  for each row execute function update_updated_at_column();

create trigger update_carpool_bookings_updated_at before update on public.carpool_bookings
  for each row execute function update_updated_at_column();

create trigger update_companies_updated_at before update on public.companies
  for each row execute function update_updated_at_column();

create trigger update_company_users_updated_at before update on public.company_users
  for each row execute function update_updated_at_column();

create trigger update_family_members_updated_at before update on public.family_members
  for each row execute function update_updated_at_column();

create trigger update_family_settings_updated_at before update on public.family_settings
  for each row execute function update_updated_at_column();

create trigger update_favorites_updated_at before update on public.favorites
  for each row execute function update_updated_at_column();

create trigger update_disputes_updated_at before update on public.disputes
  for each row execute function update_updated_at_column();

create trigger update_subscriptions_updated_at before update on public.subscriptions
  for each row execute function update_updated_at_column();

create trigger update_promotions_updated_at before update on public.promotions
  for each row execute function update_updated_at_column();

create trigger update_invoices_updated_at before update on public.invoices
  for each row execute function update_updated_at_column();

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

-- Fonction pour calculer le solde à partir des transactions
create or replace function calculate_balance(user_uuid uuid)
returns numeric as $$
  select coalesce(sum(credit - debit), 0)
  from public.wallet_transactions
  where user_id = user_uuid and status = 'completed';
$$ language sql stable;

-- Fonction pour mettre à jour le solde dans profiles
create or replace function update_profile_balance()
returns trigger as $$
begin
  update public.profiles
  set balance = calculate_balance(new.user_id)
  where id = new.user_id;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger pour mettre à jour le solde automatiquement
create trigger update_balance_after_transaction
after insert or update on public.wallet_transactions
for each row
when (new.status = 'completed')
execute function update_profile_balance();

-- Fonction pour mettre à jour la note moyenne d'un chauffeur
create or replace function update_driver_rating()
returns trigger as $$
begin
  update public.drivers
  set average_rating = (
    select coalesce(avg(stars), 0.0)
    from public.ratings
    where ratee_id = new.ratee_id
  )
  where id = new.ratee_id;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger pour mettre à jour la note moyenne
create trigger update_driver_rating_trigger
after insert or update on public.ratings
for each row
execute function update_driver_rating();

-- =====================================================
-- VALEURS PAR DÉFAUT
-- =====================================================

-- Insertion des valeurs par défaut pour pricing_settings
insert into public.pricing_settings (vehicle_type, base_fare, price_per_km, min_fare, is_active)
values
  ('economy', 2.5, 1.2, 5.0, true),
  ('comfort', 4.0, 2.0, 8.0, true),
  ('premium', 6.0, 3.0, 12.0, true),
  ('luxury', 8.0, 4.0, 15.0, true),
  ('suv', 7.0, 3.5, 14.0, true),
  ('motorcycle', 2.0, 1.0, 4.0, true),
  ('electric', 3.0, 1.5, 6.0, true),
  ('hybrid', 3.5, 1.8, 7.0, true),
  ('utility', 5.0, 2.5, 10.0, true)
on conflict (vehicle_type) do nothing;

