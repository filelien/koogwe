import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class DriverPerformanceScreen extends StatelessWidget {
  const DriverPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenus du jour
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [KoogweColors.primary, KoogweColors.primaryDark],
                ),
                borderRadius: KoogweRadius.lgRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenus aujourd\'hui',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.sm),
                  Text(
                    '125,50€',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '+15% vs hier',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: KoogweSpacing.xl),

            // Statistiques rapides
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Courses',
                    value: '12',
                    icon: Icons.directions_car,
                    color: KoogweColors.primary,
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Temps actif',
                    value: '6h',
                    icon: Icons.timer,
                    color: KoogweColors.secondary,
                  ).animate().fadeIn(delay: 300.ms).scale(),
                ),
              ],
            ),
            const SizedBox(height: KoogweSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Note moyenne',
                    value: '4.9',
                    icon: Icons.star,
                    color: KoogweColors.accent,
                  ).animate().fadeIn(delay: 400.ms).scale(),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Zones chaudes',
                    value: '3',
                    icon: Icons.location_on,
                    color: KoogweColors.success,
                  ).animate().fadeIn(delay: 500.ms).scale(),
                ),
              ],
            ),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Prévision revenus
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
                    'Prévision revenus',
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
                                final hours = ['8h', '10h', '12h', '14h', '16h', '18h', '20h'];
                                final index = value.toInt();
                                if (index >= 0 && index < hours.length) {
                                  return Text(hours[index], style: GoogleFonts.inter(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}€',
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
                            spots: const [
                              FlSpot(0, 20),
                              FlSpot(1, 35),
                              FlSpot(2, 45),
                              FlSpot(3, 60),
                              FlSpot(4, 75),
                              FlSpot(5, 90),
                              FlSpot(6, 110),
                            ],
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
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Zones chaudes
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Zones chaudes',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: KoogweColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Actif',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: KoogweColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  ...['Centre-ville Cayenne', 'Aéroport Félix Éboué', 'Zone Kourou'].map((zone) => Container(
                    margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
                    padding: const EdgeInsets.all(KoogweSpacing.md),
                    decoration: BoxDecoration(
                      color: KoogweColors.accent.withValues(alpha: 0.1),
                      borderRadius: KoogweRadius.mdRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: KoogweColors.accent),
                        const SizedBox(width: KoogweSpacing.sm),
                        Expanded(
                          child: Text(
                            zone,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '+25%',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: KoogweColors.success,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Suggestions intelligentes
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: KoogweColors.secondary.withValues(alpha: 0.1),
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(color: KoogweColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: KoogweColors.accent, size: 24),
                      const SizedBox(width: KoogweSpacing.sm),
                      Text(
                        'Suggestion intelligente',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: KoogweColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Text(
                    'Les heures de 18h à 20h sont généralement les plus rentables. Restez actif pendant cette période pour maximiser vos revenus.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),
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
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

