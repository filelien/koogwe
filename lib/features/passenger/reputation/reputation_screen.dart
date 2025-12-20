import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/reputation_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class ReputationScreen extends ConsumerWidget {
  const ReputationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(reputationProvider);
    
    if (state.isLoading || state.score == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Score & Réputation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final score = state.score!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score & Réputation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score global
            Center(
              child: Container(
                padding: const EdgeInsets.all(KoogweSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [KoogweColors.primary, KoogweColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    Text(
                      score.overallScore.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/ 5.0',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Statistiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  label: 'Trajets',
                  value: score.totalRides.toString(),
                  icon: Icons.directions_car,
                  color: KoogweColors.primary,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                _StatCard(
                  label: 'Ponctualité',
                  value: '${score.punctualityScore.toStringAsFixed(0)}%',
                  icon: Icons.schedule,
                  color: KoogweColors.success,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                _StatCard(
                  label: 'Annulations',
                  value: '${score.cancellationRate.toStringAsFixed(1)}%',
                  icon: Icons.cancel_outlined,
                  color: KoogweColors.error,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Graphique de progression
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
                    'Évolution des évaluations',
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
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 4.5),
                              const FlSpot(1, 4.7),
                              const FlSpot(2, 4.6),
                              const FlSpot(3, 4.8),
                              const FlSpot(4, 4.9),
                              const FlSpot(5, 4.8),
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
                        minY: 4.0,
                        maxY: 5.0,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Badges
            Text(
              'Badges',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            Wrap(
              spacing: KoogweSpacing.md,
              runSpacing: KoogweSpacing.md,
              children: score.badges.map((badge) => Chip(
                avatar: Icon(Icons.star, size: 16, color: KoogweColors.accent),
                label: Text(badge),
                backgroundColor: KoogweColors.accent.withValues(alpha: 0.1),
              )).toList(),
            ).animate().fadeIn(delay: 600.ms),
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
          const SizedBox(height: 4),
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

