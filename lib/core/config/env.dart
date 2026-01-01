/// Centralized environment configuration for KOOGWE.
///
/// Reads from --dart-define when available. Primary keys are the standard
/// SUPABASE_URL and SUPABASE_ANON_KEY.
/// We also accept EXPO_PUBLIC_* as fallback for compatibility. If none are
/// provided, we use a safe default so the app can boot, but auth will fail
/// until real values are injected.
class Env {
  // --- Supabase ---
  // Primary names for Supabase integration
  static const _supabaseUrlPrimary = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const _supabaseAnonPrimary = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  // Fallback (legacy/expo style)
  static const _supabaseUrlExpo = String.fromEnvironment('EXPO_PUBLIC_SUPABASE_URL', defaultValue: '');
  static const _supabaseAnonExpo = String.fromEnvironment('EXPO_PUBLIC_SUPABASE_ANON_KEY', defaultValue: '');

  static String get supabaseUrl {
    final v = _supabaseUrlPrimary.isNotEmpty
        ? _supabaseUrlPrimary
        : (_supabaseUrlExpo.isNotEmpty
            ? _supabaseUrlExpo
            : 'https://oesykhvutfleamrplvxt.supabase.co');
    return v;
  }

  static String get supabaseAnonKey {
    final v = _supabaseAnonPrimary.isNotEmpty
        ? _supabaseAnonPrimary
        : (_supabaseAnonExpo.isNotEmpty
            ? _supabaseAnonExpo
            : 'sb_publishable_FgO03dfjtXgwF3Wldvx9Sw_fwUF1gUy');
    return v;
  }

  // Maps & Routing
  static const mapboxToken = String.fromEnvironment(
    'EXPO_PUBLIC_MAPBOX_TOKEN',
    defaultValue:
        'pk.eyJ1Ijoibm9saWxpbm8iLCJhIjoiY21pcjhza21uMGIwcDV0c2l2emllaXpleCJ9.Tk-6mzoTa6ggVzBbMThKww',
  );
  static const googleMapsKey = String.fromEnvironment(
    'EXPO_PUBLIC_GOOGLE_MAPS_KEY',
    defaultValue: 'AIzaSyAal0KaPwOgAhS0NX4ph5D_0NRVmo66dfE',
  );
  static const osrmEndpoint = String.fromEnvironment(
    'EXPO_PUBLIC_OSRM_ENDPOINT',
    defaultValue: 'https://router.project-osrm.org',
  );

  // Traffic / Weather (for dynamic pricing demos)
  static const trafficApiKey = String.fromEnvironment(
    'EXPO_PUBLIC_TRAFFIC_API_KEY',
    defaultValue: 'a15a5e4138981f6c61e45e15f608e9ed',
  );

  // Payments
  static const stripePublishableKey = String.fromEnvironment(
    'EXPO_PUBLIC_STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51SaaupC1qK84HmzO8yW1gSwJkMkn668DLDwDsKHIHhNkR6xg0Ko71xIsdQaqics9078liY18SSv1fPgllDkJ3Vop00x7khx36H',
  );
  static const mobileMoneyProvider = String.fromEnvironment(
    'EXPO_PUBLIC_MOBILE_MONEY_PROVIDER',
    defaultValue: 'orange_money',
  );

  // Push Notifications (Firebase web key placeholder)
  static const firebaseWebPushKey = String.fromEnvironment(
    'EXPO_PUBLIC_FIREBASE_WEB_PUSH_KEY',
    defaultValue: 'your_firebase_web_push_key',
  );

  // OTP / SMS (Twilio)
  static const twilioSid = String.fromEnvironment(
    'EXPO_PUBLIC_TWILIO_SID',
    defaultValue: '',
  );
  static const twilioAuthToken = String.fromEnvironment(
    'EXPO_PUBLIC_TWILIO_AUTH_TOKEN',
    defaultValue: '',
  );

  // OCR
  static const ocrApiKey = String.fromEnvironment(
    'EXPO_PUBLIC_OCR_API_KEY',
    defaultValue: 'K84347997388957',
  );

  // Monitoring
  static const sentryDsn = String.fromEnvironment(
    'EXPO_PUBLIC_SENTRY_DSN',
    defaultValue:
        'https://7ccf675f708fa970e6d33252ebfc94c6@o4510476663652352.ingest.us.sentry.io/4510476665290752',
  );
}
