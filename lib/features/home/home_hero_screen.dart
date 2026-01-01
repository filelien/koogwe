import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_hero_animation.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:koogwe/core/constants/app_assets.dart';
import 'package:koogwe/core/constants/app_strings.dart';

class HomeHeroScreen extends StatefulWidget {
  const HomeHeroScreen({super.key});

  @override
  State<HomeHeroScreen> createState() => _HomeHeroScreenState();
}

class _HomeHeroScreenState extends State<HomeHeroScreen> {
  // Écran d'accueil marketing de KOOGWE

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 360;
            
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        (isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              // Header row with rectangular logo and menu - Responsive
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 16 : 20,
                  16,
                  isSmallScreen ? 16 : 20,
                  0,
                ),
                child: Row(
                  children: [
                    // Logo en rectangle
                    Container(
                      width: isSmallScreen ? 40 : 48,
                      height: isSmallScreen ? 40 : 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: KoogweColors.accent,
                        border: Border.all(
                          color: KoogweColors.accent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          AppAssets.appLogo,
                          width: isSmallScreen ? 40 : 48,
                          height: isSmallScreen ? 40 : 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.directions_bus,
                            size: isSmallScreen ? 20 : 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.go(AppRoutes.settings),
                      icon: Icon(
                        Icons.settings,
                        color: isDark
                            ? KoogweColors.darkTextPrimary
                            : KoogweColors.lightTextPrimary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 24),

              // Animation principale du véhicule (10 secondes) - Responsive
              KoogweHeroAnimation(
                height: isSmallScreen ? 200 : 280,
                showVehicle: true,
                durationSeconds: 10,
                loop: true,
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOut),

              SizedBox(height: isSmallScreen ? 20 : 32),

              // Logo Koogwe - Responsive
              Center(
                child: Image.asset(
                  AppAssets.appLogo,
                  width: isSmallScreen ? 80 : 120,
                  height: isSmallScreen ? 80 : 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.directions_bus,
                    size: isSmallScreen ? 60 : 80,
                    color: KoogweColors.primary,
                  ),
                ).animate().scale(duration: 500.ms, delay: 200.ms, curve: Curves.easeOutBack),
              ),

              SizedBox(height: isSmallScreen ? 16 : 24),

              // Slogan - Responsive
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                child: Column(
                  children: [
                    Text(
                      AppStrings.appSlogan,
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? KoogweColors.darkTextPrimary
                            : KoogweColors.lightTextPrimary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text(
                      'Réservez, suivez et payez vos trajets en toute simplicité, partout dans le monde.',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? KoogweColors.darkTextSecondary
                            : KoogweColors.lightTextSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 24 : 40),

              // Bouton CTA principal "Commencer" - Responsive
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                child: KoogweButton(
                  text: 'Commencer',
                  icon: Icons.arrow_forward_rounded,
                  size: isSmallScreen ? ButtonSize.medium : ButtonSize.large,
                  variant: ButtonVariant.gradient,
                  gradientColors: [
                    KoogweColors.primary,
                    KoogweColors.primaryDark,
                  ],
                  borderRadius: KoogweRadius.fullRadius,
                  isFullWidth: true,
                  onPressed: () => context.go(AppRoutes.roleSelection),
                ).animate().fadeIn(delay: 800.ms).scale(
                      delay: 800.ms,
                      duration: 400.ms,
                      begin: const Offset(0.95, 0.95),
                    ),
              ),

              const SizedBox(height: 16),

              // Indicateurs visuels élégants (points de progression)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 0
                            ? KoogweColors.primary
                            : (isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 32),

              // Options rapides (chips de rôles)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    KoogweButton(
                      text: 'Passager',
                      icon: Icons.person_outline,
                      size: ButtonSize.small,
                      variant: ButtonVariant.outline,
                      borderRadius: KoogweRadius.fullRadius,
                      onPressed: () => context.go(AppRoutes.passengerHome),
                    ),
                    KoogweButton(
                      text: 'Chauffeur',
                      icon: Icons.drive_eta,
                      size: ButtonSize.small,
                      variant: ButtonVariant.outline,
                      borderRadius: KoogweRadius.fullRadius,
                      onPressed: () => context.go(AppRoutes.driverHome),
                    ),
                    KoogweButton(
                      text: 'Entreprise',
                      icon: Icons.business_center_outlined,
                      size: ButtonSize.small,
                      variant: ButtonVariant.outline,
                      borderRadius: KoogweRadius.fullRadius,
                      onPressed: () => context.go(AppRoutes.businessDashboard),
                    ),
                    KoogweButton(
                      text: 'Paramètres',
                      icon: Icons.settings_outlined,
                      size: ButtonSize.small,
                      variant: ButtonVariant.outline,
                      borderRadius: KoogweRadius.fullRadius,
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Removed the old _RouteCard list to match the simplified hero mockup.
