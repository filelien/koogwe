import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenus & Statistiques')),
      body: ListView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        children: [
          Text('Cette semaine', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: KoogweSpacing.md),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [KoogweColors.auroraStart, KoogweColors.auroraMid],
              ),
              borderRadius: KoogweRadius.lgRadius,
            ),
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: KoogweColors.secondaryLight,
                    barWidth: 3,
                    spots: const [
                      FlSpot(0, 80),
                      FlSpot(1, 120),
                      FlSpot(2, 100),
                      FlSpot(3, 160),
                      FlSpot(4, 140),
                      FlSpot(5, 200),
                      FlSpot(6, 180),
                    ],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: KoogweColors.secondary.withValues(alpha: 0.20)),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: KoogweSpacing.xl),
          Row(
            children: const [
              Expanded(child: _Metric(title: 'Revenus', value: '€ 820')),
              SizedBox(width: 12),
              Expanded(child: _Metric(title: 'Courses', value: '42')),
              SizedBox(width: 12),
              Expanded(child: _Metric(title: 'Heures', value: '36h')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  const _Metric({required this.title, required this.value});

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
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
