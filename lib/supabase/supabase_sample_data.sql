-- Helper function to insert users into auth.users and auth.identities
CREATE OR REPLACE FUNCTION insert_user_to_auth(
    email text,
    password text
) RETURNS UUID AS $$
DECLARE
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := crypt(password, gen_salt('bf'));
  
  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00', '{"provider":"email","providers":["email"]}', '{}', '2023-05-03 19:41:43.580424+00', '2023-05-03 19:41:43.585948+00', '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert sample data

-- Users and Profiles (dependent on auth.users)
-- The user koogwe@outlook.fr already exists, so we reference it.
-- Create additional users for demonstration if needed.

-- Existing user: koogwe@outlook.fr (passenger)
INSERT INTO public.users (id, email, full_name, avatar_url, role)
SELECT id, email, 'Koogwe Passenger', 'https://example.com/koogwe.jpg', 'passenger'
FROM auth.users
WHERE email = 'koogwe@outlook.fr'
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  avatar_url = EXCLUDED.avatar_url,
  role = EXCLUDED.role;

INSERT INTO public.profiles (id, username, balance, phone, country)
SELECT id, 'koogwe_passenger', 150.75, '+1234567890', 'USA'
FROM auth.users
WHERE email = 'koogwe@outlook.fr'
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  balance = EXCLUDED.balance,
  phone = EXCLUDED.phone,
  country = EXCLUDED.country;


-- New Driver User
SELECT insert_user_to_auth('driver1@example.com', 'password123');

INSERT INTO public.users (id, email, full_name, avatar_url, role)
SELECT id, email, 'Alice Driver', 'https://example.com/alice.jpg', 'driver'
FROM auth.users
WHERE email = 'driver1@example.com';

INSERT INTO public.profiles (id, username, balance, phone, country)
SELECT id, 'alice_driver', 500.00, '+1987654321', 'USA'
FROM auth.users
WHERE email = 'driver1@example.com';


-- New Passenger User
SELECT insert_user_to_auth('passenger1@example.com', 'password123');

INSERT INTO public.users (id, email, full_name, avatar_url, role)
SELECT id, email, 'Bob Passenger', 'https://example.com/bob.jpg', 'passenger'
FROM auth.users
WHERE email = 'passenger1@example.com';

INSERT INTO public.profiles (id, username, balance, phone, country)
SELECT id, 'bob_passenger', 75.20, '+1122334455', 'Canada'
FROM auth.users
WHERE email = 'passenger1@example.com';


-- Vehicles (dependent on driver_id from auth.users)
INSERT INTO public.vehicles (id, driver_id, make, model, plate, color, type)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  'Toyota',
  'Camry',
  'ABC1234',
  'Silver',
  'standard';

INSERT INTO public.vehicles (id, driver_id, make, model, plate, color, type)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  'Honda',
  'CRV',
  'XYZ5678',
  'Blue',
  'comfort';


-- Rides (dependent on user_id and driver_id from auth.users)
INSERT INTO public.rides (id, user_id, driver_id, pickup_text, dropoff_text, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, vehicle_type, status, estimated_price, distance_m, duration_s, fare)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr'),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  '123 Main St, Anytown',
  '456 Oak Ave, Anytown',
  34.0522, -118.2437,
  34.0600, -118.2500,
  'standard',
  'completed',
  25.50,
  5000,
  900,
  24.00;

INSERT INTO public.rides (id, user_id, driver_id, pickup_text, dropoff_text, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, vehicle_type, status, estimated_price, distance_m, duration_s, fare)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'passenger1@example.com'),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  '789 Pine Rd, Otherville',
  '101 Elm St, Otherville',
  33.9500, -118.4000,
  33.9600, -118.4100,
  'comfort',
  'ongoing',
  35.00,
  7000,
  1200,
  NULL;

INSERT INTO public.rides (id, user_id, driver_id, pickup_text, dropoff_text, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, vehicle_type, status, estimated_price, distance_m, duration_s, fare)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr'),
  NULL,
  '222 Maple Dr, Cityville',
  '333 Birch Ln, Cityville',
  34.1000, -118.3000,
  34.1100, -118.3100,
  'standard',
  'requested',
  18.75,
  3500,
  600,
  NULL;


-- Wallet Transactions (dependent on user_id from auth.users)
INSERT INTO public.wallet_transactions (id, user_id, credit, debit, type, description)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr'),
  100.00,
  0.00,
  'topup',
  'Initial top-up';

INSERT INTO public.wallet_transactions (id, user_id, credit, debit, type, description)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr'),
  0.00,
  24.00,
  'ride_payment',
  'Payment for ride to 456 Oak Ave';

INSERT INTO public.wallet_transactions (id, user_id, credit, debit, type, description)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  24.00,
  0.00,
  'ride_payment',
  'Earnings from ride for Koogwe';

INSERT INTO public.wallet_transactions (id, user_id, credit, debit, type, description)
SELECT
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'passenger1@example.com'),
  50.00,
  0.00,
  'topup',
  'Top-up via credit card';


-- Ratings (dependent on ride_id, rater_id, ratee_id)
INSERT INTO public.ratings (id, ride_id, rater_id, ratee_id, score, comment)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.rides WHERE pickup_text = '123 Main St, Anytown' AND user_id = (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr')),
  (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr'),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  5,
  'Excellent driver, very friendly and punctual!';

INSERT INTO public.ratings (id, ride_id, rater_id, ratee_id, score, comment)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.rides WHERE pickup_text = '123 Main St, Anytown' AND user_id = (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr')),
  (SELECT id FROM auth.users WHERE email = 'driver1@example.com'),
  (SELECT id FROM auth.users WHERE email = 'koogwe@outlook.fr'),
  4,
  'Good passenger, smooth ride.';