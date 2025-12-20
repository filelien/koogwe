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

-- Optional: prevent updates/deletes by users to keep ledger immutable.
drop policy if exists wallet_tx_block_update on public.wallet_transactions;
create policy wallet_tx_block_update on public.wallet_transactions
  for update to authenticated
  using (false) with check (false);

drop policy if exists wallet_tx_block_delete on public.wallet_transactions;
create policy wallet_tx_block_delete on public.wallet_transactions
  for delete to authenticated
  using (false);

-- NOTE: If you need admin-wide access, create additional policies for role = 'admin'.
