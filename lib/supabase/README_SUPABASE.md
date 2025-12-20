# KOOGWE - Supabase Client Code Documentation

## 📋 Overview

This document provides a complete reference for the Supabase integration in the KOOGWE application. The app uses Supabase for authentication, database operations, and real-time features.

## 🏗️ Architecture

### Core Files

1. **lib/supabase/supabase_config.dart** - Generic Supabase configuration and CRUD helpers
2. **lib/core/services/supabase_service.dart** - Supabase initialization and OAuth helpers
3. **lib/core/config/env.dart** - Environment configuration
4. **lib/core/providers/auth_provider.dart** - Authentication state management with Riverpod

### Service Layer

- **lib/core/services/rides_service.dart** - Ride management operations
- **lib/core/services/wallet_service.dart** - Wallet and transaction operations

## 🔧 Configuration

### Environment Variables

The app reads Supabase credentials from `lib/core/config/env.dart`:

```dart
static const supabaseUrl = String.fromEnvironment(
  'EXPO_PUBLIC_SUPABASE_URL',
  defaultValue: 'https://orwdpmuswbozrhxrjhya.supabase.co',
);
static const supabaseAnonKey = String.fromEnvironment(
  'EXPO_PUBLIC_SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGci...',
);
```

### Initialization

Supabase is initialized before the app runs in `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init(); // Initialize Supabase with PKCE flow
  await EasyLocalization.ensureInitialized();
  runApp(const KoogweApp());
}
```

## 🗄️ Database Schema

### Tables

#### 1. **users** (Primary user table)
- Maps 1:1 to auth.users
- Contains: email, username, first_name, last_name, phone_number, role, avatar_url, balance
- Roles: passenger, driver, admin, business

#### 2. **profiles** (Backward compatibility)
- Duplicate of users table for backward compatibility
- Same structure as users table

#### 3. **rides**
- Ride requests and assignments
- Contains: user_id, driver_id, pickup/dropoff locations, vehicle_type, status, pricing
- Statuses: requested, accepted, enroute, completed, cancelled
- Vehicle types: eco, comfort, premium, suv, van

#### 4. **wallet_transactions**
- Ledger of credits/debits per user
- Types: topup, payment, refund, withdrawal, adjustment

#### 5. **vehicles**
- Registered vehicles for drivers
- Contains: driver_id, make, model, color, plate, seats

#### 6. **ratings**
- Feedback after completed rides
- Contains: ride_id, rater_id, ratee_id, stars (1-5), comment

### SQL Migrations

**Location**: `lib/supabase/`

- **supabase_tables.sql** - Complete database schema
- **supabase_policies.sql** - Row-Level Security (RLS) policies

**To deploy**: Use the Supabase panel in the left sidebar of Dreamflow.

## 🔐 Authentication

### AuthProvider (Riverpod)

The `AuthNotifier` class manages authentication state:

```dart
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
```

### Auth Methods

#### 1. Email/Password Login
```dart
await ref.read(authProvider.notifier).login(email, password);
```

#### 2. Email/Password Registration
```dart
await ref.read(authProvider.notifier).register(
  email: email,
  password: password,
  firstName: firstName,
  lastName: lastName,
  phoneNumber: phoneNumber,
  role: UserRole.passenger,
);
```

#### 3. Google OAuth
```dart
await ref.read(authProvider.notifier).signInWithGoogle();
```

**Note**: Google OAuth requires:
- Supabase project to have Google provider enabled
- Mobile: Deep-link configuration (`koogwe://login-callback`)
- Web: Redirect URL matches project origin

#### 4. Logout
```dart
await ref.read(authProvider.notifier).logout();
```

### User Roles

```dart
enum UserRole { passenger, driver, admin, business }
```

### Auth State

```dart
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
}
```

## 📊 Database Operations

### Generic CRUD Service

The `SupabaseService` class provides generic database operations:

#### Select Multiple Records
```dart
final rides = await SupabaseService.select(
  'rides',
  filters: {'user_id': userId},
  orderBy: 'created_at',
  ascending: false,
  limit: 10,
);
```

#### Select Single Record
```dart
final user = await SupabaseService.selectSingle(
  'users',
  filters: {'id': userId},
);
```

#### Insert Record
```dart
final result = await SupabaseService.insert(
  'rides',
  {
    'user_id': userId,
    'pickup_text': 'Location A',
    'dropoff_text': 'Location B',
    'vehicle_type': 'eco',
    'status': 'requested',
  },
);
```

#### Update Record
```dart
await SupabaseService.update(
  'rides',
  {'status': 'completed'},
  filters: {'id': rideId},
);
```

#### Delete Record
```dart
await SupabaseService.delete(
  'rides',
  filters: {'id': rideId},
);
```

### Complex Queries

For complex queries, use the direct client:

```dart
final client = SupabaseConfig.client;
final rides = await client
  .from('rides')
  .select('*, users!inner(*)')
  .eq('status', 'requested')
  .order('created_at', ascending: false);
```

## 🚗 Rides Service

Location: `lib/core/services/rides_service.dart`

### Create Ride
```dart
final ridesService = RidesService();
final ride = await ridesService.createRide(
  pickup: 'Location A',
  dropoff: 'Location B',
  vehicleType: 'eco',
  estimatedPrice: 25.50,
);
```

### Cancel Ride
```dart
await ridesService.cancelRide(rideId);
```

### List My Rides
```dart
final myRides = await ridesService.listMyRides();
```

## 💰 Wallet Service

Location: `lib/core/services/wallet_service.dart`

### Get Balance
```dart
final walletService = WalletService();
final balance = await walletService.getBalance();
```

### Top Up
```dart
await walletService.topUp(50.0);
```

### Withdraw
```dart
await walletService.withdraw(20.0);
```

### List Transactions
```dart
final transactions = await walletService.listTransactions(limit: 50);
```

## 🔒 Row-Level Security (RLS)

All tables have RLS enabled with permissive policies for authenticated users:

```sql
create policy "Users authenticated full access"
  on public.users
  for all
  to authenticated
  using (true)
  with check (true);
```

**Note**: These policies allow any authenticated user full access. For production, implement more granular policies (e.g., users can only access their own data).

## 🚀 Usage Examples

### Complete Login Flow

```dart
// In a login screen
final emailController = TextEditingController();
final passwordController = TextEditingController();

// When user presses login
await ref.read(authProvider.notifier).login(
  emailController.text,
  passwordController.text,
);

// Check auth state
final authState = ref.watch(authProvider);
if (authState.isAuthenticated) {
  context.go('/passenger-home');
} else if (authState.error != null) {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authState.error!)),
  );
}
```

### Complete Ride Booking Flow

```dart
// Create a ride request
final ridesService = RidesService();
final ride = await ridesService.createRide(
  pickup: pickupLocation,
  dropoff: dropoffLocation,
  vehicleType: selectedVehicle,
  estimatedPrice: calculatedPrice,
);

if (ride != null) {
  // Ride created successfully
  final rideId = ride['id'];
  context.push('/ride-tracking/$rideId');
} else {
  // Handle error
  debugPrint('Failed to create ride');
}
```

### Wallet Top-Up Flow

```dart
// Top up wallet
final walletService = WalletService();
final success = await walletService.topUp(100.0);

if (success) {
  // Refresh balance
  final newBalance = await walletService.getBalance();
  setState(() => balance = newBalance);
}
```

## 🔧 Troubleshooting

### Google OAuth Not Working

**Error**: `"Unsupported provider: provider is not enabled"`

**Solution**:
1. Open Supabase Dashboard
2. Go to Authentication → Providers
3. Enable Google provider
4. Add OAuth credentials (Client ID & Secret)
5. Add authorized redirect URLs:
   - Web: `https://your-app-url.com`
   - Mobile: `koogwe://login-callback`

### Deep Links Not Working (Mobile)

**Android**: Check `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="koogwe" android:host="login-callback" />
</intent-filter>
```

**iOS**: Check `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>koogwe</string>
    </array>
  </dict>
</array>
```

### Email Confirmation Issues

Supabase projects have email confirmation enabled by default. For testing:

**Option 1**: Disable email confirmation
1. Go to Supabase Dashboard
2. Authentication → Email Auth
3. Disable "Confirm email"

**Option 2**: Use real email addresses for testing

### Database Connection Errors

1. Verify Supabase URL and anon key in `lib/core/config/env.dart`
2. Check if tables exist in Supabase Dashboard
3. Deploy SQL migrations using Supabase panel in Dreamflow
4. Verify RLS policies are applied

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [supabase_flutter Package](https://pub.dev/packages/supabase_flutter)
- [Riverpod Documentation](https://riverpod.dev)

## 🎯 Next Steps

1. **Deploy Migrations**: Use Supabase panel in Dreamflow to deploy SQL migrations
2. **Enable Google OAuth**: Configure Google provider in Supabase Dashboard
3. **Test Authentication**: Try login, registration, and Google OAuth
4. **Generate Sample Data**: Use Supabase panel to add sample data for testing
5. **Customize RLS Policies**: Implement granular security policies for production

## ✅ Checklist

- [x] Supabase initialized in main.dart
- [x] Authentication with email/password
- [x] Google OAuth integration
- [x] User profile management
- [x] Rides service (create, cancel, list)
- [x] Wallet service (balance, top-up, withdraw, transactions)
- [x] Database schema with RLS policies
- [x] Deep-link configuration for mobile OAuth
- [x] Error handling and logging
- [x] Multi-language support (FR, EN, PT, ES, HT)

---

**KOOGWE — Allons-y, en toute confiance** 🚗✨
