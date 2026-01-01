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
      
      // Vérifier que les valeurs ne sont pas vides
      if (url.isEmpty || key.isEmpty) {
        debugPrint('[Supabase] ❌ ERREUR: URL ou clé Supabase manquante!');
        debugPrint('[Supabase] URL: ${url.isEmpty ? "VIDE" : url}');
        debugPrint('[Supabase] Key: ${key.isEmpty ? "VIDE" : "${key.substring(0, key.length > 20 ? 20 : key.length)}..."}');
        debugPrint('[Supabase] 💡 Solution: Configurez SUPABASE_URL et SUPABASE_ANON_KEY');
        throw Exception('Supabase URL ou clé manquante. Vérifiez votre configuration.');
      }
      
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
        debugPrint('[Supabase] 💡 Vérifiez:');
        debugPrint('[Supabase]   1. Que l\'URL Supabase est correcte');
        debugPrint('[Supabase]   2. Que la clé anon est correcte');
        debugPrint('[Supabase]   3. Que les tables existent dans Supabase');
        debugPrint('[Supabase]   4. Que les politiques RLS sont configurées');
      }
    } catch (e, st) {
      debugPrint('[Supabase] ❌ Init error: $e');
      debugPrint('[Supabase] Stack: $st');
      debugPrint('[Supabase] 💡 Vérifiez votre configuration Supabase dans lib/core/config/env.dart');
      // Ne pas rethrow pour permettre à l'app de démarrer même si Supabase échoue
      // L'utilisateur pourra voir l'erreur dans l'écran de test
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
      
      // Vérifier si l'utilisateur est authentifié
      final currentUser = client.auth.currentUser;
      final isAuthenticated = currentUser != null;
      
      // Test de l'authentification
      results['auth'] = {
        'initialized': true,
        'authenticated': isAuthenticated,
        'currentUser': currentUser?.id ?? 'none',
      };
      debugPrint('[Supabase] ✅ Auth service initialized');
      debugPrint('[Supabase] User authenticated: $isAuthenticated');
      
      // Si l'utilisateur n'est pas authentifié, les erreurs de permission sont normales
      // Les politiques RLS nécessitent une authentification
      if (!isAuthenticated) {
        debugPrint('[Supabase] ⚠️  User not authenticated - RLS policies require auth');
        debugPrint('[Supabase] ⚠️  Table access will fail (this is expected)');
      }
      
      // Test 1: Vérifier l'accès à la table profiles
      try {
        await client.from('profiles').select('count').limit(1);
        results['tables']!['profiles'] = true;
        debugPrint('[Supabase] ✅ Table "profiles" accessible');
      } catch (e) {
        results['tables']!['profiles'] = false;
        final errorMsg = e.toString();
        // Si l'utilisateur n'est pas authentifié, les erreurs de permission sont attendues
        if (isAuthenticated || !errorMsg.contains('permission denied')) {
          results['errors']!.add('profiles: $errorMsg');
          debugPrint('[Supabase] ❌ Table "profiles" error: $errorMsg');
        } else {
          debugPrint('[Supabase] ⚠️  Table "profiles" requires authentication (normal)');
        }
      }

      // Test 2: Vérifier l'accès à la table rides
      try {
        await client.from('rides').select('count').limit(1);
        results['tables']!['rides'] = true;
        debugPrint('[Supabase] ✅ Table "rides" accessible');
      } catch (e) {
        results['tables']!['rides'] = false;
        final errorMsg = e.toString();
        if (isAuthenticated || !errorMsg.contains('permission denied')) {
          results['errors']!.add('rides: $errorMsg');
          debugPrint('[Supabase] ❌ Table "rides" error: $errorMsg');
        } else {
          debugPrint('[Supabase] ⚠️  Table "rides" requires authentication (normal)');
        }
      }

      // Test 3: Vérifier l'accès à la table wallet_transactions
      try {
        await client.from('wallet_transactions').select('count').limit(1);
        results['tables']!['wallet_transactions'] = true;
        debugPrint('[Supabase] ✅ Table "wallet_transactions" accessible');
      } catch (e) {
        results['tables']!['wallet_transactions'] = false;
        final errorMsg = e.toString();
        if (isAuthenticated || !errorMsg.contains('permission denied')) {
          results['errors']!.add('wallet_transactions: $errorMsg');
          debugPrint('[Supabase] ❌ Table "wallet_transactions" error: $errorMsg');
        } else {
          debugPrint('[Supabase] ⚠️  Table "wallet_transactions" requires authentication (normal)');
        }
      }

      // La connexion est considérée comme réussie si:
      // 1. L'authentification fonctionne, OU
      // 2. Au moins une table est accessible (même si les autres échouent à cause de RLS)
      // 3. Les erreurs ne sont pas des erreurs critiques (juste des permissions RLS attendues)
      final hasRealErrors = results['errors']!.any((e) => 
        !e.toString().contains('permission denied') && 
        !e.toString().contains('42501')
      );
      
      if (isAuthenticated && results['tables']!.values.any((v) => v == true)) {
        results['connected'] = true;
        debugPrint('[Supabase] ✅ Connection test PASSED (authenticated user)');
      } else if (!hasRealErrors) {
        // Pas d'erreurs critiques, juste des permissions RLS (normal quand non authentifié)
        results['connected'] = true;
        debugPrint('[Supabase] ✅ Connection test PASSED (RLS working as expected)');
      } else {
        results['connected'] = false;
        debugPrint('[Supabase] ⚠️  Connection test has errors (check configuration)');
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
