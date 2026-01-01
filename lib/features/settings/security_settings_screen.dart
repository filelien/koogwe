import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _sessionTimeoutEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Sécurité',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(KoogweSpacing.md),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: const Text('Authentification biométrique'),
                        subtitle: const Text('Utiliser votre empreinte ou Face ID'),
                        trailing: Switch(
                          value: _biometricEnabled,
                          onChanged: (v) => setState(() => _biometricEnabled = v),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.verified_user),
                        title: const Text('Authentification à deux facteurs'),
                        subtitle: const Text('Ajouter une couche de sécurité supplémentaire'),
                        trailing: Switch(
                          value: _twoFactorEnabled,
                          onChanged: (v) {
                            setState(() => _twoFactorEnabled = v);
                            if (v) {
                              context.push('/2fa');
                            }
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.timer),
                        title: const Text('Déconnexion automatique'),
                        subtitle: const Text('Se déconnecter après 30 minutes d\'inactivité'),
                        trailing: Switch(
                          value: _sessionTimeoutEnabled,
                          onChanged: (v) => setState(() => _sessionTimeoutEnabled = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KoogweSpacing.lg),
                GlassCard(
                  padding: const EdgeInsets.all(KoogweSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sessions actives',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      KoogweButton(
                        text: 'Déconnecter toutes les sessions',
                        icon: Icons.logout,
                        onPressed: () async {
                          final router = GoRouter.of(context);
                          await Supabase.instance.client.auth.signOut();
                          if (!mounted) return;
                          router.go('/login');
                        },
                        variant: ButtonVariant.outline,
                        customColor: KoogweColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

