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
  // This screen is a marketing/entry hero inspired by the provided mockup.
  // We intentionally removed the route input fields to keep it clean and focused.

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              // Header row with small circular logo and menu
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: KoogweColors.accent,
                      child: ClipOval(
                        child: Image.asset(
                          AppAssets.appLogo,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_bus, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.go(AppRoutes.settings),
                      icon: Icon(Icons.settings,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Animation principale du véhicule (10 secondes)
              const KoogweHeroAnimation(
                height: 280,
                showVehicle: true,
                durationSeconds: 10,
                loop: true,
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 32),

              // Logo Koogwe
              Center(
                child: Image.asset(
                  AppAssets.appLogo,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.directions_bus,
                    size: 80,
                    color: KoogweColors.primary,
                  ),
                ).animate().scale(duration: 500.ms, delay: 200.ms, curve: Curves.easeOutBack),
              ),

              const SizedBox(height: 24),

              // Slogan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      AppStrings.appSlogan,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    Text(
                      'Réservez, suivez et payez vos trajets en toute simplicité, partout dans le monde.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bouton CTA principal "Commencer"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: KoogweButton(
                  text: 'Commencer',
                  icon: Icons.arrow_forward_rounded,
                  size: ButtonSize.large,
                  variant: ButtonVariant.gradient,
                  gradientColors: [
                    KoogweColors.primary,
                    KoogweColors.primaryDark,
                  ],
                  borderRadius: KoogweRadius.fullRadius,
                  isFullWidth: true,
                  onPressed: () => context.go(AppRoutes.roleSelection),
                ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms, duration: 400.ms, begin: const Offset(0.95, 0.95)),
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
