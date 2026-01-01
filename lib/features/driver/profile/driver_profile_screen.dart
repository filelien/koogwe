import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/driver_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_assets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final DriverService _driverService = DriverService();
  Map<String, dynamic>? _driverProfile;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _driverService.getDriverProfile();
      final stats = await _driverService.getDashboardStats();
      setState(() {
        _driverProfile = profile;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DriverProfile] Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg;

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
            'Mon Profil',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: isSmallScreen ? 18 : 20,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          children: [
                            const SizedBox(height: KoogweSpacing.lg),
                            
                            // En-tête avec photo et infos
                            GlassCard(
                              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                              borderRadius: KoogweRadius.lgRadius,
                              child: Column(
                                children: [
                                  // Photo de profil en rectangle
                                  Container(
                                    width: isSmallScreen ? 80 : 100,
                                    height: isSmallScreen ? 80 : 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: KoogweColors.primary.withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: KoogweColors.primary.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: user?.profileImageUrl != null
                                          ? Image.network(
                                              user!.profileImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(
                                                Icons.person,
                                                size: isSmallScreen ? 40 : 50,
                                                color: KoogweColors.primary,
                                              ),
                                            )
                                          : Image.asset(
                                              AppAssets.appLogo,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(
                                                Icons.person,
                                                size: isSmallScreen ? 40 : 50,
                                                color: KoogweColors.primary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                                  Text(
                                    user?.fullName ?? 'Chauffeur',
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? KoogweColors.darkTextPrimary
                                          : KoogweColors.lightTextPrimary,
                                    ),
                                  ),
                                  if (user?.phoneNumber != null) ...[
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: isSmallScreen ? 14 : 16,
                                          color: isDark
                                              ? KoogweColors.darkTextSecondary
                                              : KoogweColors.lightTextSecondary,
                                        ),
                                        SizedBox(width: isSmallScreen ? 4 : 8),
                                        Text(
                                          user!.phoneNumber!,
                                          style: GoogleFonts.inter(
                                            fontSize: isSmallScreen ? 12 : 14,
                                            color: isDark
                                                ? KoogweColors.darkTextSecondary
                                                : KoogweColors.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (_stats != null) ...[
                                    SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _StatItem(
                                          value: '${_stats!['total_rides'] ?? 0}',
                                          label: 'Courses',
                                          icon: Icons.directions_car,
                                          isSmallScreen: isSmallScreen,
                                        ),
                                        _StatItem(
                                          value: '${(_stats!['average_rating'] ?? 0.0).toStringAsFixed(1)}',
                                          label: 'Note',
                                          icon: Icons.star,
                                          isSmallScreen: isSmallScreen,
                                        ),
                                        _StatItem(
                                          value: '${(_stats!['total_earnings'] ?? 0.0).toStringAsFixed(0)}€',
                                          label: 'Revenus',
                                          icon: Icons.euro,
                                          isSmallScreen: isSmallScreen,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                            
                            SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                            
                            // Section Fonctionnalités
                            _ProfileSection(
                              title: 'Fonctionnalités',
                              isSmallScreen: isSmallScreen,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.drive_eta, color: KoogweColors.primary, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Mode Conduite',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.drivingMode),
                                ),
                                ListTile(
                                  leading: Icon(Icons.attach_money, color: KoogweColors.secondary, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Revenus',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.earnings),
                                ),
                                ListTile(
                                  leading: Icon(Icons.trending_up, color: KoogweColors.accent, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Performance',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.driverPerformance),
                                ),
                                ListTile(
                                  leading: Icon(Icons.bar_chart, color: KoogweColors.info, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Statistiques',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.driverStatistics),
                                ),
                                ListTile(
                                  leading: Icon(Icons.directions_car, color: KoogweColors.success, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Mes Courses',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.driverRides),
                                ),
                                ListTile(
                                  leading: Icon(Icons.local_taxi, color: KoogweColors.warning, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Véhicules',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.vehicleCatalog),
                                ),
                                ListTile(
                                  leading: Icon(Icons.description, color: KoogweColors.primary, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Documents',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.driverDocuments),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                            
                            // Section Compte
                            _ProfileSection(
                              title: 'Compte',
                              isSmallScreen: isSmallScreen,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.edit, color: KoogweColors.primary, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Modifier le profil',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    // TODO: Écran d'édition de profil
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.settings, color: KoogweColors.secondary, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Paramètres',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.settings),
                                ),
                                ListTile(
                                  leading: Icon(Icons.help_outline, color: KoogweColors.info, size: isSmallScreen ? 20 : 24),
                                  title: Text(
                                    'Aide & Support',
                                    style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => context.push(AppRoutes.helpCenter),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSmallScreen;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: KoogweColors.primary, size: isSmallScreen ? 20 : 24),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 10 : 12,
            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isSmallScreen;

  const _ProfileSection({
    required this.title,
    required this.children,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: KoogweRadius.lgRadius,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
