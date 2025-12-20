import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:koogwe/core/providers/theme_provider.dart';
import 'package:koogwe/core/theme/koogwe_theme_data.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:koogwe/core/services/supabase_service.dart';
import 'package:koogwe/core/config/env.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  // Initialize bindings first to establish the zone
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure Supabase is ready for auth and deep-link handling
  await SupabaseService.init();
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Build the app widget
  final app = EasyLocalization(
    supportedLocales: const [
      Locale('fr'),
      Locale('en'),
      Locale('pt'),
      Locale('es'),
      Locale('ht'), // Haitian Creole
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('fr'),
    child: const ProviderScope(child: KoogweApp()),
  );
  
  // Initialize Sentry only if a DSN is provided. Never crash on init errors.
  final dsn = Env.sentryDsn;
  if (dsn.isNotEmpty && dsn != 'your_firebase_web_push_key') {
    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.tracesSampleRate = 0.2; // light sampling by default
          options.enablePrintBreadcrumbs = true;
        },
        appRunner: () => runApp(app),
      );
      return; // App already started by Sentry
    } catch (e) {
      // Fall back to normal runApp if Sentry failed for any reason
      debugPrint('Sentry init failed: $e');
    }
  }
  
  // Run app normally if Sentry is not configured or failed
  runApp(app);
}

class KoogweApp extends ConsumerWidget {
  const KoogweApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final materialTheme = themeState.materialTheme;
    
    // Écouter les changements de mode système
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).listenToSystemMode();
    });
    
    return MaterialApp.router(
      title: 'KOOGWE',
      debugShowCheckedModeBanner: false,
      theme: materialTheme,
      darkTheme: materialTheme,
      themeMode: themeState.isSystemMode
          ? ThemeMode.system
          : (themeState.mode == KoogweThemeMode.dark ? ThemeMode.dark : ThemeMode.light),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: appRouter,
    );
  }
}
