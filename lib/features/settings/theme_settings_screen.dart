import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/theme_provider.dart';
import 'package:koogwe/core/theme/koogwe_theme_data.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentThemeData = themeState.themeData;
    final isDark = themeState.mode == KoogweThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thèmes & Apparence'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aperçu du thème actuel
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                gradient: currentThemeData.gradientBackground ?? LinearGradient(
                  colors: [currentThemeData.primary, currentThemeData.primaryDark],
                ),
                borderRadius: KoogweRadius.lgRadius,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentThemeData.name,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (currentThemeData.description != null)
                            Text(
                              currentThemeData.description!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                        ],
                      ),
                      if (currentThemeData.icon != null)
                        Icon(
                          currentThemeData.icon,
                          size: 48,
                          color: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _ColorPreview(
                          label: 'Primaire',
                          color: currentThemeData.primary,
                        ),
                      ),
                      const SizedBox(width: KoogweSpacing.sm),
                      Expanded(
                        child: _ColorPreview(
                          label: 'Secondaire',
                          color: currentThemeData.secondary,
                        ),
                      ),
                      const SizedBox(width: KoogweSpacing.sm),
                      Expanded(
                        child: _ColorPreview(
                          label: 'Accent',
                          color: currentThemeData.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Sélection du mode (Light/Dark/System)
            Text(
              'Mode d\'affichage',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.lg),
            
            Container(
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _ModeOption(
                    icon: Icons.light_mode,
                    label: 'Clair',
                    isSelected: !themeState.isSystemMode && themeState.mode == KoogweThemeMode.light,
                    onTap: () => themeNotifier.setMode(KoogweThemeMode.light),
                  ),
                  Divider(height: 1, color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                  _ModeOption(
                    icon: Icons.dark_mode,
                    label: 'Sombre',
                    isSelected: !themeState.isSystemMode && themeState.mode == KoogweThemeMode.dark,
                    onTap: () => themeNotifier.setMode(KoogweThemeMode.dark),
                  ),
                  Divider(height: 1, color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                  _ModeOption(
                    icon: Icons.brightness_auto,
                    label: 'Système',
                    description: 'Suivre les paramètres système',
                    isSelected: themeState.isSystemMode,
                    onTap: () => themeNotifier.setSystemMode(true),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Liste des thèmes
            Text(
              'Choisir un thème',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.lg),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: KoogweSpacing.md,
                mainAxisSpacing: KoogweSpacing.md,
                childAspectRatio: 1.2,
              ),
              itemCount: KoogweTheme.values.length,
              itemBuilder: (context, index) {
                final theme = KoogweTheme.values[index];
                final themeData = KoogweThemeData.getTheme(theme, themeState.mode);
                final isSelected = themeState.currentTheme == theme;

                return _ThemeCard(
                  theme: theme,
                  themeData: themeData,
                  isSelected: isSelected,
                  onTap: () => themeNotifier.setTheme(theme),
                ).animate()
                    .fadeIn(delay: Duration(milliseconds: 500 + (index * 50)))
                    .scale(delay: Duration(milliseconds: 500 + (index * 50)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorPreview({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: KoogweRadius.mdRadius,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
          ),
          const SizedBox(height: KoogweSpacing.xs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.label,
    this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeData = KoogweColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? themeData.primary : (isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(width: KoogweSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? themeData.primary : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: themeData.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final KoogweTheme theme;
  final KoogweThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.themeData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        decoration: BoxDecoration(
          gradient: themeData.gradientBackground ?? LinearGradient(
            colors: [themeData.primary, themeData.primaryDark],
          ),
          borderRadius: KoogweRadius.lgRadius,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeData.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(KoogweSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (themeData.icon != null)
                    Icon(
                      themeData.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        themeData.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (themeData.description != null)
                        Text(
                          themeData.description!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: KoogweSpacing.sm,
                right: KoogweSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: themeData.primary,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

