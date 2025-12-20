import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:koogwe/core/constants/app_assets.dart';
import 'package:koogwe/core/widgets/intelligent_home_widgets.dart';
import 'package:koogwe/core/widgets/animated_vehicle_widget.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      // Palette claire pour l'accueil, conforme à la maquette
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomeTab(),
            RidesTab(),
            WalletTab(),
            ProfileTab(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: KoogweRadius.fullRadius,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: KoogweColors.secondaryLight,
              unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                  ? KoogweColors.darkTextTertiary
                  : KoogweColors.lightTextTertiary,
              selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Courses'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Portefeuille'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: KoogweColors.primary.withValues(alpha: 0.1),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: KoogweColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_loading)
                              Container(height: 16, width: 100, decoration: BoxDecoration(color: (isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant), borderRadius: BorderRadius.circular(8)))
                              else ...[
                                Text(
                                  'Bonjour,',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                  ),
                                ),
                                _HomeGreetingName(isDark: isDark),
                              ]
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: KoogweSpacing.xxxl),
                  if (_loading)
                    Container(height: 24, width: 200, decoration: BoxDecoration(color: (isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant), borderRadius: BorderRadius.circular(8)))
                  else
                    Text(
                      'Où allez-vous ?',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: KoogweSpacing.lg),
                  GlassCard(
                    onTap: () => context.push('/passenger/ride-booking'),
                    borderRadius: KoogweRadius.lgRadius,
                    child: Row(
                      children: [
                        Icon(Icons.search, color: KoogweColors.secondaryLight),
                        const SizedBox(width: KoogweSpacing.md),
                        Text(
                          'Entrez votre destination',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: KoogweSpacing.xxl),
                  
                  // Voiture animée interactive
                  SizedBox(
                    height: 160,
                    child: AnimatedVehicleWidget(
                      vehicleType: VehicleType.economy,
                      height: 160,
                      showRoad: true,
                    ),
                  ).animate().fadeIn(delay: 250.ms).scale(),
                  
                  const SizedBox(height: KoogweSpacing.xl),
                  
                  // Estimation tarifaire en direct
                  LivePriceEstimator(
                    vehicleType: VehicleType.economy,
                    distance: 5.2,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: KoogweSpacing.xl),
                  
                  // Carte trajet simulé interactif
                  InteractiveRideCard(
                    from: 'Votre position actuelle',
                    to: 'Destination suggérée',
                    estimatedTime: '~15 min',
                    estimatedPrice: '12,50 €',
                    onTap: () => context.push('/passenger/ride-booking'),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: KoogweSpacing.xl),
                  
                  // Statistiques personnelles
                  PersonalStatsWidget(
                    totalRides: 42,
                    totalSpent: 520.50,
                    carbonSaved: 25.3,
                    currentStreak: 7,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: KoogweSpacing.xl),
                  
                  // Recommandations intelligentes
                  SmartRecommendationsWidget(
                    recommendations: [
                      Recommendation(
                        title: 'Meilleur moment',
                        description: 'Réservez maintenant pour économiser 15%',
                        icon: Icons.access_time,
                        color: KoogweColors.primary,
                      ),
                      Recommendation(
                        title: 'Trajet éco',
                        description: 'Choisissez l\'option électrique et sauvegardez 2kg CO₂',
                        icon: Icons.eco,
                        color: KoogweColors.success,
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: KoogweSpacing.xl),
                  
                  Text(
                    'Services',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: KoogweSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _loading
                            ? _skeletonCard(isDark)
                            : ServiceCard(
                                icon: Icons.directions_car,
                                title: 'Course',
                                color: KoogweColors.primary,
                                onTap: () => context.push('/passenger/ride-booking'),
                              ).animate().fadeIn(delay: 350.ms).scale(),
                      ),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: _loading
                            ? _skeletonCard(isDark)
                            : ServiceCard(
                                icon: Icons.schedule,
                                title: 'Planifier',
                                color: KoogweColors.secondary,
                                onTap: () => context.push('/passenger/scheduled'),
                              ).animate().fadeIn(delay: 400.ms).scale(),
                      ),
                    ],
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _loading
                            ? _skeletonCard(isDark)
                              : ServiceCard(
                                icon: Icons.people,
                                title: 'Covoiturage',
                                color: KoogweColors.accent,
                                onTap: () {
                                  // TODO: Implémenter la fonctionnalité de covoiturage
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Covoiturage - Fonctionnalité à venir')),
                                  );
                                },
                              ).animate().fadeIn(delay: 450.ms).scale(),
                      ),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: _loading
                            ? _skeletonCard(isDark)
                            : ServiceCard(
                                icon: Icons.apps,
                                title: 'Services',
                                color: KoogweColors.success,
                                onTap: () => context.push('/passenger/services'),
                              ).animate().fadeIn(delay: 500.ms).scale(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonCard(bool isDark) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant,
            borderRadius: KoogweRadius.lgRadius,
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: KoogweRadius.lgRadius,
          // Subtle shadow as per flat/minimal guideline
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: KoogweSpacing.sm),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RidesTab extends StatelessWidget {
  const RidesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 48),
            const SizedBox(height: KoogweSpacing.lg),
            Text('Vos trajets', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: KoogweSpacing.lg),
            FilledButton(
              onPressed: () => context.push('/passenger/history'),
              child: const Text('Voir l\'historique'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 48),
            const SizedBox(height: KoogweSpacing.lg),
            Text('Gérez votre solde', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: KoogweSpacing.lg),
            FilledButton(
              onPressed: () => context.push('/passenger/wallet'),
              child: const Text('Ouvrir le portefeuille'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 48),
            const SizedBox(height: KoogweSpacing.lg),
            Text('Votre profil', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: KoogweSpacing.lg),
            FilledButton(
              onPressed: () => context.push('/passenger/profile'),
              child: const Text('Voir le profil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeGreetingName extends ConsumerWidget {
  final bool isDark;
  const _HomeGreetingName({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final name = (user?.fullName.isNotEmpty ?? false) ? user!.fullName : 'KOOGWE';
    return Text(
      name,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
      ),
    );
  }
}
