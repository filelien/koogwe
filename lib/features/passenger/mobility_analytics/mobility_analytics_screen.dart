import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/mobility_analytics_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class MobilityAnalyticsScreen extends ConsumerWidget {
  const MobilityAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(mobilityAnalyticsProvider);

    if (state.isLoading || state.stats == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analyse de Mobilité')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stats = state.stats!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse de Mobilité'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques principales
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Distance totale',
                    value: '${stats.totalDistance.toStringAsFixed(1)} km',
                    icon: Icons.straighten,
                    color: KoogweColors.primary,
                  ).animate().fadeIn(delay: 100.ms).scale(),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Émissions CO₂',
                    value: '${stats.carbonEmissions.toStringAsFixed(1)} kg',
                    icon: Icons.eco,
                    color: KoogweColors.success,
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ),
              ],
            ),
            const SizedBox(height: KoogweSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Trajets',
                    value: '${stats.totalRides}',
                    icon: Icons.directions_car,
                    color: KoogweColors.secondary,
                  ).animate().fadeIn(delay: 300.ms).scale(),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Économies',
                    value: '${stats.moneySaved.toStringAsFixed(2)}€',
                    icon: Icons.savings,
                    color: KoogweColors.accent,
                  ).animate().fadeIn(delay: 400.ms).scale(),
                ),
              ],
            ),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Graphique distance mensuelle
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance parcourue (km)',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final months = stats.monthlyDistance.keys.toList();
                                final index = value.toInt();
                                if (index >= 0 && index < months.length) {
                                  return Text(months[index], style: GoogleFonts.inter(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: GoogleFonts.inter(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: stats.monthlyDistance.values.toList().asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value);
                            }).toList(),
                            isCurved: true,
                            color: KoogweColors.primary,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: KoogweColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                        minY: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Graphique émissions
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Émissions CO₂ (kg)',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: stats.monthlyEmissions.values.reduce((a, b) => a > b ? a : b) * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final months = stats.monthlyEmissions.keys.toList();
                                final index = value.toInt();
                                if (index >= 0 && index < months.length) {
                                  return Text(months[index], style: GoogleFonts.inter(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: GoogleFonts.inter(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: stats.monthlyEmissions.values.toList().asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                color: KoogweColors.success,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Conseils personnalisés
            Text(
              'Conseils personnalisés',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            ...state.personalizedTips.map((tip) => Container(
              margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: KoogweColors.primary.withValues(alpha: 0.1),
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(color: KoogweColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: KoogweColors.accent),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: KoogweSpacing.sm),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

