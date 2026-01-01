import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _shareLocation = true;
  bool _shareProfile = false;
  bool _analyticsEnabled = true;
  bool _marketingEmails = false;

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
            'Confidentialité',
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
                        leading: const Icon(Icons.location_on),
                        title: const Text('Partager ma localisation'),
                        subtitle: const Text('Permettre l\'accès à votre position pour les courses'),
                        trailing: Switch(
                          value: _shareLocation,
                          onChanged: (v) => setState(() => _shareLocation = v),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Partager mon profil'),
                        subtitle: const Text('Permettre aux chauffeurs de voir votre profil'),
                        trailing: Switch(
                          value: _shareProfile,
                          onChanged: (v) => setState(() => _shareProfile = v),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.analytics),
                        title: const Text('Analytics et amélioration'),
                        subtitle: const Text('Partager des données anonymes pour améliorer l\'app'),
                        trailing: Switch(
                          value: _analyticsEnabled,
                          onChanged: (v) => setState(() => _analyticsEnabled = v),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Emails marketing'),
                        subtitle: const Text('Recevoir des offres et promotions'),
                        trailing: Switch(
                          value: _marketingEmails,
                          onChanged: (v) => setState(() => _marketingEmails = v),
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
                        'Données personnelles',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Télécharger mes données'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Téléchargement en cours...')),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: KoogweColors.error),
                        title: Text(
                          'Supprimer mon compte',
                          style: TextStyle(color: KoogweColors.error),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer mon compte'),
                              content: const Text(
                                'Cette action est irréversible. Toutes vos données seront supprimées.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Fonctionnalité à venir')),
                                    );
                                  },
                                  child: Text(
                                    'Supprimer',
                                    style: TextStyle(color: KoogweColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

