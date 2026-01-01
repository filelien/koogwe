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
import 'package:koogwe/core/services/rides_service.dart';
import 'package:koogwe/core/router/app_router.dart';

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
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final ridesService = RidesService();
      final stats = await ridesService.getPassengerStats();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[PassengerHome] Error loading stats: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl;
    
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: KoogweSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Photo de profil en rectangle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: KoogweColors.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: KoogweColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: KoogweColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_loading)
                              Container(
                                height: 16,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? KoogweColors.darkSurfaceVariant
                                      : KoogweColors.lightSurfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                            else ...[
                              Text(
                                'Bonjour,',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark
                                      ? KoogweColors.darkTextSecondary
                                      : KoogweColors.lightTextSecondary,
                                ),
                              ),
                              _HomeGreetingName(isDark: isDark),
                            ]
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(AppRoutes.settings),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxxl),
                  if (_loading)
                    Container(
                      height: 24,
                      width: 200,
                      decoration: BoxDecoration(
                        color: isDark
                            ? KoogweColors.darkSurfaceVariant
                            : KoogweColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                  else
                    Text(
                      'Où allez-vous ?',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? KoogweColors.darkTextPrimary
                            : KoogweColors.lightTextPrimary,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: KoogweSpacing.lg),
                  GlassCard(
                    onTap: () => context.push(AppRoutes.rideBooking),
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
                  
                  // Voiture animée interactive - Responsive
                  SizedBox(
                    height: isSmallScreen ? 120 : 160,
                    child: AnimatedVehicleWidget(
                      vehicleType: VehicleType.economy,
                      height: isSmallScreen ? 120 : 160,
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
                    onTap: () => context.push(AppRoutes.rideBooking),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: KoogweSpacing.xl),
                  
                  // Statistiques personnelles
                  if (_stats != null)
                    PersonalStatsWidget(
                      totalRides: _stats!['total_rides'] ?? 0,
                      totalSpent: (_stats!['total_spent'] ?? 0.0).toDouble(),
                      carbonSaved: (_stats!['carbon_saved'] ?? 0.0).toDouble(),
                      currentStreak: _stats!['current_streak'] ?? 0,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0)
                  else
                    PersonalStatsWidget(
                      totalRides: 0,
                      totalSpent: 0.0,
                      carbonSaved: 0.0,
                      currentStreak: 0,
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
                  // Grille de services responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 400 ? 2 : 2;
                      final childAspectRatio = isSmallScreen ? 1.1 : 1.0;
                      
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: KoogweSpacing.md,
                        mainAxisSpacing: KoogweSpacing.md,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _loading
                              ? _skeletonCard(isDark)
                              : ServiceCard(
                                  icon: Icons.directions_car,
                                  title: 'Course',
                                  color: KoogweColors.primary,
                                  onTap: () => context.push(AppRoutes.rideBooking),
                                ).animate().fadeIn(delay: 350.ms).scale(),
                          _loading
                              ? _skeletonCard(isDark)
                              : ServiceCard(
                                  icon: Icons.schedule,
                                  title: 'Planifier',
                                  color: KoogweColors.secondary,
                                  onTap: () => context.push(AppRoutes.scheduledRide),
                                ).animate().fadeIn(delay: 400.ms).scale(),
                          _loading
                              ? _skeletonCard(isDark)
                              : ServiceCard(
                                  icon: Icons.people,
                                  title: 'Covoiturage',
                                  color: KoogweColors.accent,
                                  onTap: () {
                                    context.push(AppRoutes.carpool);
                                  },
                                ).animate().fadeIn(delay: 450.ms).scale(),
                          _loading
                              ? _skeletonCard(isDark)
                              : ServiceCard(
                                  icon: Icons.apps,
                                  title: 'Services',
                                  color: KoogweColors.success,
                                  onTap: () => context.push(AppRoutes.serviceSelection),
                                ).animate().fadeIn(delay: 500.ms).scale(),
                        ],
                      );
                    },
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final iconSize = isSmallScreen ? 28.0 : 32.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: KoogweRadius.lgRadius,
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
            Icon(icon, size: iconSize, color: Colors.white),
            SizedBox(height: isSmallScreen ? 4 : KoogweSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              onPressed: () => context.push(AppRoutes.rideHistory),
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
              onPressed: () => context.push(AppRoutes.wallet),
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
              onPressed: () => context.push(AppRoutes.passengerProfile),
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
