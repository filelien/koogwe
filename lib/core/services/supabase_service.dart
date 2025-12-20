import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koogwe/core/config/env.dart';

/// Supabase bootstrap and helpers.
///
/// Call SupabaseService.init() before runApp to ensure OAuth deep-links work.
class SupabaseService {
  static Future<void> init() async {
    try {
      final url = Env.supabaseUrl;
      final key = Env.supabaseAnonKey;
      
      // Log configuration for debugging
      debugPrint('[Supabase] Initializing...');
      debugPrint('[Supabase] URL: $url');
      debugPrint('[Supabase] Anon Key: ${key.substring(0, key.length > 20 ? 20 : key.length)}...');
      
      // Use a custom scheme for mobile deep links: koogwe://auth-callback
      await Supabase.initialize(
        url: url,
        anonKey: key,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: true,
      );
      debugPrint('[Supabase] ✅ Initialized successfully');
      
      // Test connection immediately after initialization
      final testResult = await testConnection();
      if (testResult['connected'] == true) {
        debugPrint('[Supabase] ✅ Connection test passed');
      } else {
        debugPrint('[Supabase] ⚠️ Connection test failed: ${testResult['errors']}');
      }
    } catch (e, st) {
      debugPrint('[Supabase] ❌ Init error: $e');
      debugPrint('[Supabase] Stack: $st');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? oauthRedirectUrl() {
    if (kIsWeb) return null; // Web handles callback automatically
    // NOTE: Ensure mobile deep links are configured:
    // Android: AndroidManifest.xml -> intent-filter with scheme "koogwe" and host "login-callback".
    // iOS: Info.plist -> CFBundleURLTypes with URL scheme "koogwe".
    return 'koogwe://login-callback';
  }

  /// Test la connexion à Supabase en vérifiant l'accès aux tables
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{
      'connected': false,
      'url': Env.supabaseUrl,
      'anonKey': '${Env.supabaseAnonKey.substring(0, 20)}...',
      'tables': <String, bool>{},
      'errors': <String>[],
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final client = Supabase.instance.client;
      
      // Test de connexion basique - vérifier que le client est initialisé
      final supabaseUrl = Env.supabaseUrl;
      if (supabaseUrl.isEmpty) {
        results['errors']!.add('Supabase URL not configured');
        return results;
      }
      
      debugPrint('[Supabase] Testing connection to: $supabaseUrl');
      
      // Test 1: Vérifier l'accès à la table profiles
      try {
        await client.from('profiles').select('count').limit(1);
        results['tables']!['profiles'] = true;
        debugPrint('[Supabase] ✅ Table "profiles" accessible');
      } catch (e) {
        results['tables']!['profiles'] = false;
        final errorMsg = e.toString();
        results['errors']!.add('profiles: $errorMsg');
        debugPrint('[Supabase] ❌ Table "profiles" error: $errorMsg');
      }

      // Test 2: Vérifier l'accès à la table rides
      try {
        await client.from('rides').select('count').limit(1);
        results['tables']!['rides'] = true;
        debugPrint('[Supabase] ✅ Table "rides" accessible');
      } catch (e) {
        results['tables']!['rides'] = false;
        final errorMsg = e.toString();
        results['errors']!.add('rides: $errorMsg');
        debugPrint('[Supabase] ❌ Table "rides" error: $errorMsg');
      }

      // Test 3: Vérifier l'accès à la table wallet_transactions
      try {
        await client.from('wallet_transactions').select('count').limit(1);
        results['tables']!['wallet_transactions'] = true;
        debugPrint('[Supabase] ✅ Table "wallet_transactions" accessible');
      } catch (e) {
        results['tables']!['wallet_transactions'] = false;
        final errorMsg = e.toString();
        results['errors']!.add('wallet_transactions: $errorMsg');
        debugPrint('[Supabase] ❌ Table "wallet_transactions" error: $errorMsg');
      }

      // Test 4: Vérifier l'authentification (sans se connecter)
      try {
        final currentUser = client.auth.currentUser;
        results['auth'] = {
          'initialized': true,
          'currentUser': currentUser?.id ?? 'none',
        };
        debugPrint('[Supabase] ✅ Auth service initialized');
      } catch (e) {
        results['auth'] = {'initialized': false, 'error': e.toString()};
        results['errors']!.add('auth: $e');
        debugPrint('[Supabase] ❌ Auth service error: $e');
      }

      // Si au moins une table est accessible, la connexion fonctionne
      results['connected'] = results['tables']!.values.any((v) => v == true);
      
      if (results['connected'] == true) {
        debugPrint('[Supabase] ✅ Connection test PASSED');
      } else {
        debugPrint('[Supabase] ❌ Connection test FAILED');
        if (results['errors']!.isNotEmpty) {
          debugPrint('[Supabase] Errors: ${results['errors']}');
        }
      }
    } catch (e, st) {
      results['connected'] = false;
      results['errors']!.add('Connection test failed: $e');
      debugPrint('[Supabase] ❌ Connection test exception: $e');
      debugPrint('[Supabase] Stack trace: $st');
    }

    return results;
  }
}
