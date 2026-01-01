import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KoogweColors.primaryLight,
              KoogweColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final isSmallScreen = availableHeight < 700;
              
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: KoogweSpacing.xl,
                      vertical: KoogweSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
              children: [
                        SizedBox(height: isSmallScreen ? 10 : 20),
                        // Center logo (from assets/images/kol.jpg) - Réduit pour petits écrans
                Container(
                          width: isSmallScreen ? 100 : 150,
                          height: isSmallScreen ? 100 : 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: Image.asset(
                      AppAssets.appLogo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.directions_bus_filled,
                                size: isSmallScreen ? 54 : 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 450.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOutBack),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxxl),
                // Title - Réduit pour petits écrans
                Text(
                  "Let's Ride.",
                  style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                // Subtitle - Réduit
                Text(
                  AppStrings.appSlogan,
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 250.ms).slideY(begin: 0.2, end: 0, duration: 450.ms),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.lg : KoogweSpacing.xl),
                // CTA button
                KoogweButton(
                  text: 'Get started',
                  size: ButtonSize.large,
                  isFullWidth: true,
                  variant: ButtonVariant.gradient,
                  gradientColors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  borderRadius: KoogweRadius.fullRadius,
                  onPressed: () {
                    context.go('/onboarding');
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxl),
              ],
            ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
