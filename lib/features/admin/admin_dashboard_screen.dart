import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Administration — Contrôle Total',
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
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () => context.push('/settings'),
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // KPI globaux
                      Row(
                        children: [
                          Expanded(
                            child: _AdminKpiCard(
                              label: 'Utilisateurs',
                              value: '12,458',
                              icon: Icons.people,
                              color: KoogweColors.primary,
                            ).animate().fadeIn(delay: 100.ms).scale(),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          Expanded(
                            child: _AdminKpiCard(
                              label: 'Courses',
                              value: '45,230',
                              icon: Icons.directions_car,
                              color: KoogweColors.secondary,
                            ).animate().fadeIn(delay: 150.ms).scale(),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          Expanded(
                            child: _AdminKpiCard(
                              label: 'Revenus',
                              value: '€1.2M',
                              icon: Icons.euro,
                              color: KoogweColors.accent,
                            ).animate().fadeIn(delay: 200.ms).scale(),
                          ),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.xl),
                      _StatCard(
                        title: 'Revenus (7j)',
                        child: SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: KoogweColors.primary,
                                  barWidth: 3,
                                  spots: const [
                                    FlSpot(0, 3),
                                    FlSpot(1, 4.2),
                                    FlSpot(2, 3.8),
                                    FlSpot(3, 5.1),
                                    FlSpot(4, 4.8),
                                    FlSpot(5, 6.2),
                                    FlSpot(6, 6.8),
                                  ],
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: KoogweColors.primary.withValues(alpha: 0.15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      _StatCard(
                        title: 'Courses par type',
                        child: SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(value: 40, color: KoogweColors.primary, title: 'VTC'),
                                PieChartSectionData(value: 25, color: KoogweColors.secondary, title: 'Taxi'),
                                PieChartSectionData(value: 20, color: KoogweColors.accent, title: 'Covoit'),
                                PieChartSectionData(value: 15, color: KoogweColors.success, title: 'Livraison'),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Actions rapides Admin
                      Text(
                        'Actions Administratives',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: KoogweSpacing.md),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: KoogweSpacing.md,
                        mainAxisSpacing: KoogweSpacing.md,
                        childAspectRatio: 1.5,
                        children: [
                          _AdminActionCard(
                            icon: Icons.people,
                            title: 'Utilisateurs',
                            subtitle: 'Gérer tous les utilisateurs',
                            color: KoogweColors.primary,
                            onTap: () {
                              // TODO: Implémenter écran de gestion utilisateurs admin
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gestion des utilisateurs - Fonctionnalité à venir')),
                              );
                            },
                          ).animate().fadeIn(delay: 450.ms).scale(),
                          _AdminActionCard(
                            icon: Icons.directions_car,
                            title: 'Courses',
                            subtitle: 'Suivi en temps réel',
                            color: KoogweColors.secondary,
                            onTap: () {
                              // TODO: Implémenter écran de suivi courses admin
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Suivi des courses - Fonctionnalité à venir')),
                              );
                            },
                          ).animate().fadeIn(delay: 500.ms).scale(),
                          _AdminActionCard(
                            icon: Icons.euro,
                            title: 'Paiements',
                            subtitle: 'Finance & transactions',
                            color: KoogweColors.accent,
                            onTap: () {
                              // TODO: Implémenter écran de gestion paiements admin
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gestion des paiements - Fonctionnalité à venir')),
                              );
                            },
                          ).animate().fadeIn(delay: 550.ms).scale(),
                          _AdminActionCard(
                            icon: Icons.security,
                            title: 'Sécurité',
                            subtitle: 'Logs & audit',
                            color: KoogweColors.error,
                            onTap: () {
                              // TODO: Implémenter écran de sécurité et audit admin
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sécurité & Audit - Fonctionnalité à venir')),
                              );
                            },
                          ).animate().fadeIn(delay: 600.ms).scale(),
                        ],
                      ),
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

class _AdminKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(KoogweSpacing.md),
      borderRadius: KoogweRadius.mdRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: KoogweSpacing.sm),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? KoogweColors.darkTextPrimary
                  : KoogweColors.lightTextPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? KoogweColors.darkTextSecondary
                  : KoogweColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        borderRadius: KoogweRadius.lgRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: KoogweSpacing.sm),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? KoogweColors.darkTextPrimary
                    : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? KoogweColors.darkTextSecondary
                    : KoogweColors.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _StatCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: KoogweSpacing.md),
          child,
        ],
      ),
    );
  }
}
