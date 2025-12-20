import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget de revenus dynamiques pour chauffeur
class DriverEarningsWidget extends StatelessWidget {
  final double todayEarnings;
  final double weeklyEarnings;
  final int completedRides;
  final double averageRating;

  const DriverEarningsWidget({
    super.key,
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.completedRides = 0,
    this.averageRating = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KoogweColors.secondary.withValues(alpha: 0.2),
            KoogweColors.accent.withValues(alpha: 0.1),
          ],
        ),
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
                'Revenus aujourd\'hui',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? KoogweColors.darkTextPrimary
                      : KoogweColors.lightTextPrimary,
                ),
              ),
              Icon(Icons.trending_up, color: KoogweColors.success, size: 20),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Text(
            '${todayEarnings.toStringAsFixed(2)} €',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: KoogweColors.secondary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Expanded(
                child: _EarningMetric(
                  label: 'Cette semaine',
                  value: '${weeklyEarnings.toStringAsFixed(2)} €',
                  icon: Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _EarningMetric(
                  label: 'Courses',
                  value: completedRides.toString(),
                  icon: Icons.directions_car,
                ),
              ),
              Expanded(
                child: _EarningMetric(
                  label: 'Note',
                  value: averageRating.toStringAsFixed(1),
                  icon: Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _EarningMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, size: 20, color: KoogweColors.accent),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? KoogweColors.darkTextPrimary
                : KoogweColors.lightTextPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark
                ? KoogweColors.darkTextSecondary
                : KoogweColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget d'objectifs et bonus animés
class DriverGoalsWidget extends StatelessWidget {
  final double weeklyGoal;
  final double currentProgress;
  final List<Bonus> availableBonuses;

  const DriverGoalsWidget({
    super.key,
    this.weeklyGoal = 500.0,
    this.currentProgress = 0.0,
    this.availableBonuses = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressPercent = (currentProgress / weeklyGoal).clamp(0.0, 1.0);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objectif hebdomadaire',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? KoogweColors.darkTextPrimary
                  : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: isDark
                      ? KoogweColors.darkSurfaceVariant
                      : KoogweColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressPercent,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [KoogweColors.primary, KoogweColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentProgress.toStringAsFixed(2)} € / ${weeklyGoal.toStringAsFixed(2)} €',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? KoogweColors.darkTextSecondary
                      : KoogweColors.lightTextSecondary,
                ),
              ),
              Text(
                '${(progressPercent * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: KoogweColors.primary,
                ),
              ),
            ],
          ),
          if (availableBonuses.isNotEmpty) ...[
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Bonus disponibles',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? KoogweColors.darkTextPrimary
                    : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.sm),
            ...availableBonuses.map((bonus) => Container(
                  margin: const EdgeInsets.only(bottom: KoogweSpacing.xs),
                  padding: const EdgeInsets.all(KoogweSpacing.md),
                  decoration: BoxDecoration(
                    color: bonus.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: bonus.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(bonus.icon, color: bonus.color, size: 20),
                      const SizedBox(width: KoogweSpacing.sm),
                      Expanded(
                        child: Text(
                          bonus.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '+${bonus.amount.toStringAsFixed(0)}€',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: bonus.color,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class Bonus {
  final String description;
  final double amount;
  final IconData icon;
  final Color color;

  Bonus({
    required this.description,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

/// Widget de graphique de revenus animé
class EarningsChartWidget extends StatelessWidget {
  final List<double> weeklyData;

  const EarningsChartWidget({
    super.key,
    this.weeklyData = const [80, 120, 100, 160, 140, 200, 180],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
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
            'Évolution des revenus',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? KoogweColors.darkTextPrimary
                  : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? KoogweColors.darkBorder
                          : KoogweColors.lightBorder,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: KoogweColors.secondary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: KoogweColors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

