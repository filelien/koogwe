import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/widgets/koogwe_hero_animation.dart';
import 'package:koogwe/core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.touch_app,
      title: 'Commander un trajet en 2 clics',
      description: 'Une interface claire et rapide pour réserver instantanément.',
      color: KoogweColors.primary,
    ),
    OnboardingPage(
      icon: Icons.location_searching,
      title: 'Suivre le véhicule en temps réel',
      description: 'Une carte fluide avec position et arrivée estimée.',
      color: KoogweColors.secondary,
    ),
    OnboardingPage(
      icon: Icons.directions_car,
      title: 'Choisir son type de transport',
      description: 'Éco, Confort, Premium, XL — selon vos besoins.',
      color: KoogweColors.accent,
    ),
    OnboardingPage(
      icon: Icons.account_balance_wallet,
      title: 'Payer facilement',
      description: 'Wallet, carte, mobile money — paiement sécurisé.',
      color: KoogweColors.primary,
    ),
    OnboardingPage(
      icon: Icons.share_location,
      title: 'Partager son trajet',
      description: 'Partagez votre itinéraire à vos proches en 1 geste.',
      color: KoogweColors.secondary,
    ),
    OnboardingPage(
      icon: Icons.recommend,
      title: 'Recommandations intelligentes',
      description: 'Destinations fréquentes et conseils personnalisés.',
      color: KoogweColors.accent,
    ),
    OnboardingPage(
      icon: Icons.shield,
      title: 'Voyager en toute sécurité',
      description: 'Standards élevés, assistance et notations transparentes.',
      color: KoogweColors.primary,
    ),
    OnboardingPage(
      icon: Icons.language,
      title: 'Adapter l’app à son pays',
      description: 'Pays, langue, devise — la Guyane 🇬🇫 à l’honneur.',
      color: KoogweColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/country-selection'),
                    child: const Text('Passer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KoogweSpacing.md),
            // Hero animation at top of onboarding - Réduit encore plus pour petits écrans
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxHeight < 700;
                return KoogweHeroAnimation(
                  height: isSmallScreen ? 40 : 60,
                  showVehicle: false,
                );
              },
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? KoogweColors.primary
                              : (isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.xl),
                  KoogweButton(
                    text: _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        context.go('/country-selection');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Padding(
               padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.lg : KoogweSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 700;
              final iconSize = isSmallScreen ? 60.0 : 100.0;
              final iconIconSize = isSmallScreen ? 30.0 : 50.0;
              
              return Column(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: page.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        page.icon,
                        size: iconIconSize,
                        color: page.color,
                      ),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                  Text(
                    page.title,
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.xs : KoogweSpacing.sm),
                  Text(
                    page.description,
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
