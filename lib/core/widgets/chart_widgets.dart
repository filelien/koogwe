import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/glass_card.dart';

/// Widget pour graphique en barres
class KoogweBarChart extends StatelessWidget {
  final List<BarChartDataPoint> data;
  final String? title;
  final String? subtitle;
  final double? maxY;
  final List<String>? bottomLabels;
  final String Function(double)? leftLabelFormatter;
  final Color? barColor;
  final bool showGrid;
  final double? height;

  const KoogweBarChart({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.maxY,
    this.bottomLabels,
    this.leftLabelFormatter,
    this.barColor,
    this.showGrid = false,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColorValue = barColor ?? KoogweColors.primary;
    final maxYValue = maxY ?? (data.map((d) => d.y).reduce((a, b) => a > b ? a : b) * 1.2);

    return GlassCard(
      borderRadius: KoogweRadius.lgRadius,
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: KoogweSpacing.xs),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark 
                        ? KoogweColors.darkTextSecondary 
                        : KoogweColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: KoogweSpacing.lg),
            ],
            SizedBox(
              height: height,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxYValue,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (bottomLabels != null && value.toInt() < bottomLabels!.length) {
                            return Text(
                              bottomLabels![value.toInt()],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark 
                                    ? KoogweColors.darkTextSecondary 
                                    : KoogweColors.lightTextSecondary,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (leftLabelFormatter != null) {
                            return Text(
                              leftLabelFormatter!(value),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark 
                                    ? KoogweColors.darkTextSecondary 
                                    : KoogweColors.lightTextSecondary,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDark 
                                  ? KoogweColors.darkTextSecondary 
                                  : KoogweColors.lightTextSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: showGrid),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.y,
                          color: entry.value.color ?? barColorValue,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour graphique linéaire
class KoogweLineChart extends StatelessWidget {
  final List<LineChartDataPoint> data;
  final String? title;
  final String? subtitle;
  final double? maxY;
  final double? minY;
  final List<String>? bottomLabels;
  final String Function(double)? leftLabelFormatter;
  final Color? lineColor;
  final bool showGrid;
  final bool showPoints;
  final double? height;
  final bool showArea;

  const KoogweLineChart({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.maxY,
    this.minY,
    this.bottomLabels,
    this.leftLabelFormatter,
    this.lineColor,
    this.showGrid = true,
    this.showPoints = true,
    this.height = 250,
    this.showArea = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColorValue = lineColor ?? KoogweColors.primary;
    final maxYValue = maxY ?? 
        (data.map((d) => d.y).reduce((a, b) => a > b ? a : b) * 1.1);
    final minYValue = minY ?? 0;

    return GlassCard(
      borderRadius: KoogweRadius.lgRadius,
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: KoogweSpacing.xs),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark 
                        ? KoogweColors.darkTextSecondary 
                        : KoogweColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: KoogweSpacing.lg),
            ],
            SizedBox(
              height: height,
              child: LineChart(
                LineChartData(
                  minY: minYValue,
                  maxY: maxYValue,
                  gridData: FlGridData(
                    show: showGrid,
                    drawVerticalLine: false,
                    horizontalInterval: (maxYValue - minYValue) / 5,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (bottomLabels != null && value.toInt() < bottomLabels!.length) {
                            return Text(
                              bottomLabels![value.toInt()],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark 
                                    ? KoogweColors.darkTextSecondary 
                                    : KoogweColors.lightTextSecondary,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (leftLabelFormatter != null) {
                            return Text(
                              leftLabelFormatter!(value),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark 
                                    ? KoogweColors.darkTextSecondary 
                                    : KoogweColors.lightTextSecondary,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDark 
                                  ? KoogweColors.darkTextSecondary 
                                  : KoogweColors.lightTextSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.map((point) => FlSpot(point.x, point.y)).toList(),
                      isCurved: true,
                      color: lineColorValue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: showPoints,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: lineColorValue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: showArea
                          ? BarAreaData(
                              show: true,
                              color: lineColorValue.withValues(alpha: 0.1),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour graphique en secteurs (Pie Chart)
class KoogwePieChart extends StatelessWidget {
  final List<PieChartDataPoint> data;
  final String? title;
  final String? subtitle;
  final double? height;
  final bool showPercentage;
  final double? radius;

  const KoogwePieChart({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.height = 250,
    this.showPercentage = true,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    final radiusValue = radius ?? 80.0;

    return GlassCard(
      borderRadius: KoogweRadius.lgRadius,
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: KoogweSpacing.xs),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark 
                        ? KoogweColors.darkTextSecondary 
                        : KoogweColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: KoogweSpacing.lg),
            ],
            SizedBox(
              height: height,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: radiusValue / 2,
                        sections: data.asMap().entries.map((entry) {
                          final item = entry.value;
                          final percentage = (item.value / total) * 100;
                          return PieChartSectionData(
                            value: item.value,
                            color: item.color,
                            title: showPercentage 
                                ? '${percentage.toStringAsFixed(1)}%'
                                : '',
                            radius: radiusValue,
                            titleStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: KoogweSpacing.lg),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.map((item) {
                        final percentage = (item.value / total) * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: KoogweSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.label,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark 
                                                  ? KoogweColors.darkTextPrimary 
                                                  : KoogweColors.lightTextPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: item.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${item.value.toStringAsFixed(0)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: isDark 
                                            ? KoogweColors.darkTextSecondary 
                                            : KoogweColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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

/// Point de données pour graphique en barres
class BarChartDataPoint {
  final double y;
  final Color? color;

  const BarChartDataPoint({
    required this.y,
    this.color,
  });
}

/// Point de données pour graphique linéaire
class LineChartDataPoint {
  final double x;
  final double y;

  const LineChartDataPoint({
    required this.x,
    required this.y,
  });
}

/// Point de données pour graphique en secteurs
class PieChartDataPoint {
  final double value;
  final Color color;
  final String label;

  const PieChartDataPoint({
    required this.value,
    required this.color,
    required this.label,
  });
}

