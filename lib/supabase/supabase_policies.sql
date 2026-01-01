-- KOOGWE Supabase RLS Policies (canonical source)

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.rides enable row level security;
alter table public.wallet_transactions enable row level security;

-- PROFILES
-- Allow authenticated users to insert/update their own profile row
drop policy if exists profiles_insert_self on public.profiles;
create policy profiles_insert_self on public.profiles
  for insert to authenticated
  with check (auth.uid() = id);

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Allow each user to read only their own profile
drop policy if exists profiles_select_self on public.profiles;
create policy profiles_select_self on public.profiles
  for select to authenticated
  using (auth.uid() = id);

-- IMPORTANT: Allow admins to read all profiles (using SECURITY DEFINER function to avoid recursion)
-- This function bypasses RLS to check if user is admin
create or replace function public.is_admin()
returns boolean as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$ language sql security definer stable;

-- Admin can read all profiles
drop policy if exists profiles_select_admin on public.profiles;
create policy profiles_select_admin on public.profiles
  for select to authenticated
  using (public.is_admin());

-- Admin can update all profiles
drop policy if exists profiles_update_admin on public.profiles;
create policy profiles_update_admin on public.profiles
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Fonction SQL pour obtenir le rôle d'un utilisateur (bypass RLS pour éviter la récursion)
create or replace function public.get_user_role(user_uuid uuid)
returns text as $$
  select role from public.profiles where id = user_uuid;
$$ language sql security definer;

-- RIDES
-- Insert rides for yourself
drop policy if exists rides_insert_self on public.rides;
create policy rides_insert_self on public.rides
  for insert to authenticated
  with check (auth.uid() = user_id);

-- Select only your rides
drop policy if exists rides_select_self on public.rides;
create policy rides_select_self on public.rides
  for select to authenticated
  using (auth.uid() = user_id);

-- Admin can read all rides
drop policy if exists rides_select_admin on public.rides;
create policy rides_select_admin on public.rides
  for select to authenticated
  using (public.is_admin());

-- Update/Delete only your rides (e.g., cancel)
drop policy if exists rides_update_self on public.rides;
create policy rides_update_self on public.rides
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists rides_delete_self on public.rides;
create policy rides_delete_self on public.rides
  for delete to authenticated
  using (auth.uid() = user_id);

-- WALLET TRANSACTIONS
-- Insert own transactions (topup/withdrawal)
drop policy if exists wallet_tx_insert_self on public.wallet_transactions;
create policy wallet_tx_insert_self on public.wallet_transactions
  for insert to authenticated
  with check (auth.uid() = user_id);

-- Read only your transactions
drop policy if exists wallet_tx_select_self on public.wallet_transactions;
create policy wallet_tx_select_self on public.wallet_transactions
  for select to authenticated
  using (auth.uid() = user_id);

-- Admin can read all transactions
drop policy if exists wallet_tx_select_admin on public.wallet_transactions;
create policy wallet_tx_select_admin on public.wallet_transactions
  for select to authenticated
  using (public.is_admin());

-- Optional: prevent updates/deletes by users to keep ledger immutable.
drop policy if exists wallet_tx_block_update on public.wallet_transactions;
create policy wallet_tx_block_update on public.wallet_transactions
  for update to authenticated
  using (false) with check (false);

drop policy if exists wallet_tx_block_delete on public.wallet_transactions;
create policy wallet_tx_block_delete on public.wallet_transactions
  for delete to authenticated
  using (false);

-- DRIVER LOCATIONS
alter table public.driver_locations enable row level security;

-- Drivers can update their own location
drop policy if exists driver_locations_upsert_self on public.driver_locations;
create policy driver_locations_upsert_self on public.driver_locations
  for all to authenticated
  using (auth.uid() = driver_id)
  with check (auth.uid() = driver_id);

-- Passengers can read driver locations for active rides
drop policy if exists driver_locations_select_ride on public.driver_locations;
create policy driver_locations_select_ride on public.driver_locations
  for select to authenticated
  using (
    exists (
      select 1 from public.rides
      where rides.driver_id = driver_locations.driver_id
        and rides.user_id = auth.uid()
        and rides.status in ('accepted', 'in_progress')
    )
  );

-- FAMILY MEMBERS
alter table public.family_members enable row level security;
alter table public.family_settings enable row level security;

-- Family owner can manage their family members
drop policy if exists family_members_all_owner on public.family_members;
create policy family_members_all_owner on public.family_members
  for all to authenticated
  using (auth.uid() = family_owner_id)
  with check (auth.uid() = family_owner_id);

-- Family members can read their own membership
drop policy if exists family_members_select_member on public.family_members;
create policy family_members_select_member on public.family_members
  for select to authenticated
  using (auth.uid() = member_user_id);

-- Family settings: owner only
drop policy if exists family_settings_all_owner on public.family_settings;
create policy family_settings_all_owner on public.family_settings
  for all to authenticated
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- PRICING SETTINGS: Allow admins to read/write all
alter table public.pricing_settings enable row level security;

drop policy if exists pricing_settings_admin_all on public.pricing_settings;
create policy pricing_settings_admin_all on public.pricing_settings
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Allow all authenticated users to read pricing (for ride booking)
drop policy if exists pricing_settings_select_all on public.pricing_settings;
create policy pricing_settings_select_all on public.pricing_settings
  for select to authenticated
  using (true);

-- CARPOOL RIDES: Allow all authenticated users to read, drivers to manage their own
alter table public.carpool_rides enable row level security;

drop policy if exists carpool_rides_select_all on public.carpool_rides;
create policy carpool_rides_select_all on public.carpool_rides
  for select to authenticated
  using (true);

drop policy if exists carpool_rides_insert_driver on public.carpool_rides;
create policy carpool_rides_insert_driver on public.carpool_rides
  for insert to authenticated
  with check (auth.uid() = driver_id);

drop policy if exists carpool_rides_update_driver on public.carpool_rides;
create policy carpool_rides_update_driver on public.carpool_rides
  for update to authenticated
  using (auth.uid() = driver_id)
  with check (auth.uid() = driver_id);

-- CARPOOL BOOKINGS: Allow passengers to manage their own bookings
alter table public.carpool_bookings enable row level security;

drop policy if exists carpool_bookings_select_all on public.carpool_bookings;
create policy carpool_bookings_select_all on public.carpool_bookings
  for select to authenticated
  using (true);

drop policy if exists carpool_bookings_insert_passenger on public.carpool_bookings;
create policy carpool_bookings_insert_passenger on public.carpool_bookings
  for insert to authenticated
  with check (auth.uid() = passenger_id);

drop policy if exists carpool_bookings_update_passenger on public.carpool_bookings;
create policy carpool_bookings_update_passenger on public.carpool_bookings
  for update to authenticated
  using (auth.uid() = passenger_id)
  with check (auth.uid() = passenger_id);
