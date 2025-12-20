import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

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
                              'Dashboard Entreprise',
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
                            icon: const Icon(Icons.assessment),
                            onPressed: () => context.push('/business/reports'),
                            tooltip: 'Rapports',
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () => context.push('/settings'),
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      _KpiRow().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      _BarRevenue().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      GlassCard(
                        onTap: () => context.push('/business/reports'),
                        borderRadius: KoogweRadius.lgRadius,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: KoogweColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.assessment, color: KoogweColors.primary, size: 32),
                            ),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rapports & Analyses',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? KoogweColors.darkTextPrimary
                                          : KoogweColors.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Voir les rapports détaillés et analytics',
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
                            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Actions rapides entreprise
                      Text(
                        'Actions rapides',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _BusinessActionCard(
                              icon: Icons.people,
                              title: 'Employés',
                              subtitle: 'Gérer les équipes',
                              color: KoogweColors.primary,
                              onTap: () {
                                // TODO: Créer l'écran de gestion des employés
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gestion des employés - Bientôt disponible')),
                                );
                              },
                            ).animate().fadeIn(delay: 450.ms).scale(),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          Expanded(
                            child: _BusinessActionCard(
                              icon: Icons.directions_car,
                              title: 'Flotte',
                              subtitle: 'Véhicules & catalogues',
                              color: KoogweColors.secondary,
                              onTap: () {
                                context.go('/driver/vehicles');
                              },
                            ).animate().fadeIn(delay: 500.ms).scale(),
                          ),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _BusinessActionCard(
                              icon: Icons.receipt_long,
                              title: 'Facturation',
                              subtitle: 'Gérer les paiements',
                              color: KoogweColors.accent,
                              onTap: () {
                                context.go('/business/reports');
                              },
                            ).animate().fadeIn(delay: 550.ms).scale(),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          Expanded(
                            child: _BusinessActionCard(
                              icon: Icons.bar_chart,
                              title: 'Analytics',
                              subtitle: 'Analyses détaillées',
                              color: KoogweColors.info,
                              onTap: () => context.push('/business/reports'),
                            ).animate().fadeIn(delay: 600.ms).scale(),
                          ),
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

class _BusinessActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BusinessActionCard({
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
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: KoogweRadius.lgRadius,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: KoogweSpacing.md),
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
                fontSize: 12,
                color: isDark
                    ? KoogweColors.darkTextSecondary
                    : KoogweColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _KpiCard(label: 'Courses', value: '1 284')),
        SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Revenus', value: '€ 23 540')),
        SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Satisfaction', value: '4.8 ★')),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  const _KpiCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
        borderRadius: KoogweRadius.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _BarRevenue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                  const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(labels[value.toInt() % 7]),
                  );
                }),
              ),
            ),
            barGroups: List.generate(7, (i) {
              final double val = [12.0, 8.0, 10.0, 14.0, 11.0, 6.0, 9.0][i];
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: val, color: KoogweColors.primary, width: 16, borderRadius: BorderRadius.circular(6)),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}
