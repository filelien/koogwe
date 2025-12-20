import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/comfort_preferences_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ComfortPreferencesScreen extends ConsumerWidget {
  const ComfortPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preferences = ref.watch(comfortPreferencesProvider);
    final notifier = ref.read(comfortPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences de confort'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              notifier.updatePreferences(preferences);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Préférences sauvegardées')),
                );
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personnalisez votre trajet',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Indiquez vos préférences pour un trajet plus agréable',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.xxxl),
            
            _PreferenceCard(
              icon: Icons.volume_off,
              title: 'Mode silencieux',
              description: 'Pas de musique ni de conversation',
              isActive: preferences.silence,
              onTap: () => notifier.toggleSilence(),
              color: KoogweColors.primary,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _PreferenceCard(
              icon: Icons.music_note,
              title: 'Musique',
              description: 'Souhaitez-vous de la musique pendant le trajet',
              isActive: preferences.music,
              onTap: () => notifier.toggleMusic(),
              color: KoogweColors.secondary,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _PreferenceCard(
              icon: Icons.ac_unit,
              title: 'Climatisation',
              description: 'Aération et température confortable',
              isActive: preferences.airConditioning,
              onTap: () => notifier.toggleAirConditioning(),
              color: KoogweColors.accent,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _PreferenceCard(
              icon: Icons.directions_car_outlined,
              title: 'Conduite douce',
              description: 'Accélération et freinage en douceur',
              isActive: preferences.gentleDriving,
              onTap: () => notifier.toggleGentleDriving(),
              color: KoogweColors.success,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _PreferenceCard(
              icon: Icons.chat_bubble_outline,
              title: 'Conversation',
              description: 'Ouvert à la conversation avec le chauffeur',
              isActive: preferences.conversation,
              onTap: () => notifier.toggleConversation(),
              color: KoogweColors.secondaryDark,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Sélecteur de température
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thermostat, color: KoogweColors.primary),
                      const SizedBox(width: KoogweSpacing.md),
                      Text(
                        'Température',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Wrap(
                    spacing: KoogweSpacing.md,
                    children: ['18°C', '20°C', '22°C', '24°C', '26°C'].map((temp) {
                      final isSelected = preferences.temperature == temp;
                      return FilterChip(
                        label: Text(temp),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            notifier.setTemperature(temp);
                          }
                        },
                        selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: KoogweColors.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            KoogweButton(
              text: 'Appliquer les préférences',
              icon: Icons.check_circle,
              onPressed: () {
                notifier.updatePreferences(preferences);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Préférences appliquées')),
                  );
                  context.pop();
                }
              },
              isFullWidth: true,
              size: ButtonSize.large,
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _PreferenceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.15)
              : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
          borderRadius: KoogweRadius.lgRadius,
          border: Border.all(
            color: isActive
                ? color
                : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.md),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? color : (isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
                size: 28,
              ),
            ),
            const SizedBox(width: KoogweSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (_) => onTap(),
              activeThumbColor: color,
            ),
          ],
        ),
      ),
    );
  }
}

