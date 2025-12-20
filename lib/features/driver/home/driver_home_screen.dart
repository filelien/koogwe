import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/widgets/driver_dashboard_widgets.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool online = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec statut
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dashboard Chauffeur',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? KoogweColors.darkTextPrimary
                                    : KoogweColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/settings'),
                            icon: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Statut en ligne/hors ligne amélioré
                      GlassCard(
                        padding: const EdgeInsets.all(KoogweSpacing.lg),
                        borderRadius: KoogweRadius.lgRadius,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: online
                                    ? KoogweColors.statusOnline.withValues(alpha: 0.2)
                                    : KoogweColors.statusOffline.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                online ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                                color: online
                                    ? KoogweColors.statusOnline
                                    : KoogweColors.statusOffline,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    online ? 'En ligne' : 'Hors ligne',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? KoogweColors.darkTextPrimary
                                          : KoogweColors.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    online
                                        ? 'Vous recevez des courses'
                                        : 'Activez-vous pour recevoir des courses',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark
                                          ? KoogweColors.darkTextSecondary
                                          : KoogweColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: online,
                              onChanged: (v) => setState(() => online = v),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Widget de revenus dynamiques
                      DriverEarningsWidget(
                        todayEarnings: 125.50,
                        weeklyEarnings: 820.00,
                        completedRides: 42,
                        averageRating: 4.9,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Graphique de revenus
                      EarningsChartWidget().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Objectifs et bonus
                      DriverGoalsWidget(
                        weeklyGoal: 500.0,
                        currentProgress: 420.0,
                        availableBonuses: [
                          Bonus(
                            description: 'Bonus de fin de semaine',
                            amount: 50.0,
                            icon: Icons.star,
                            color: KoogweColors.accent,
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      Text(
                        'Actions rapides',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.drive_eta,
                            label: 'Mode Conduite',
                            color: KoogweColors.primary,
                            onTap: () => context.push('/driver/driving-mode'),
                          ).animate().fadeIn(delay: 550.ms).scale(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.attach_money,
                            label: 'Revenus',
                            color: KoogweColors.secondary,
                            onTap: () => context.push('/driver/earnings'),
                          ).animate().fadeIn(delay: 600.ms).scale(),
                        ),
                      ]),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.trending_up,
                            label: 'Performance',
                            color: KoogweColors.accent,
                            onTap: () => context.push('/driver/performance'),
                          ).animate().fadeIn(delay: 650.ms).scale(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.description,
                            label: 'Documents',
                            color: KoogweColors.info,
                            onTap: () => context.push('/driver/documents'),
                          ).animate().fadeIn(delay: 700.ms).scale(),
                        ),
                      ]),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.directions_car,
                            label: 'Véhicules',
                            color: KoogweColors.success,
                            onTap: () => context.push('/driver/vehicles'),
                          ).animate().fadeIn(delay: 750.ms).scale(),
                        ),
                      ]),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: KoogweRadius.lgRadius,
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
        ),
        child: Column(
          children: [Icon(icon, color: Colors.white), const SizedBox(height: 8), Text(label, style: GoogleFonts.inter(color: Colors.white))],
        ),
      ),
    );
  }
}
