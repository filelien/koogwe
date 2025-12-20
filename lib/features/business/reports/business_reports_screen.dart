import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class BusinessReportsScreen extends StatefulWidget {
  const BusinessReportsScreen({super.key});

  @override
  State<BusinessReportsScreen> createState() => _BusinessReportsScreenState();
}

class _BusinessReportsScreenState extends State<BusinessReportsScreen> {
  String _selectedPeriod = 'Mois';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Analyses'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Exporter le rapport
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Période de sélection
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Jour', label: Text('Jour')),
                      ButtonSegment(value: 'Semaine', label: Text('Semaine')),
                      ButtonSegment(value: 'Mois', label: Text('Mois')),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<String> selected) {
                      setState(() => _selectedPeriod = selected.first);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Résumé financier
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
                    'Dépenses totales',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.sm),
                  Text(
                    '2,450,00€',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trajets',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '156',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget restant',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '550,00€',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: KoogweSpacing.xl),

            // Graphique des dépenses
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
                    'Évolution des dépenses',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 3000,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
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
                                '${(value / 1000).toStringAsFixed(1)}k€',
                                style: GoogleFonts.inter(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(toY: 1800, color: KoogweColors.primary),
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(toY: 2100, color: KoogweColors.primary),
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(toY: 1950, color: KoogweColors.primary),
                          ]),
                          BarChartGroupData(x: 3, barRods: [
                            BarChartRodData(toY: 2300, color: KoogweColors.primary),
                          ]),
                          BarChartGroupData(x: 4, barRods: [
                            BarChartRodData(toY: 2450, color: KoogweColors.primary),
                          ]),
                          BarChartGroupData(x: 5, barRods: [
                            BarChartRodData(toY: 2200, color: KoogweColors.primary),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Alertes de dépassement
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: KoogweColors.error.withValues(alpha: 0.1),
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(color: KoogweColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: KoogweColors.error, size: 32),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dépassement de budget imminent',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: KoogweColors.error,
                          ),
                        ),
                        Text(
                          'Vous avez utilisé 82% de votre budget mensuel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Top employés
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
                    'Top employés',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  ...['Jean Dupont', 'Marie Martin', 'Luc Bernard'].map((name) => Container(
                    margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: KoogweColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            name[0],
                            style: GoogleFonts.inter(
                              color: KoogweColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: KoogweSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                '15 trajets • 245,00€',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Recommandations
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
                      Icon(Icons.insights, color: KoogweColors.secondary, size: 24),
                      const SizedBox(width: KoogweSpacing.sm),
                      Text(
                        'Recommandations',
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
                    'Optimisez vos coûts en encourageant le covoiturage et en planifiant les trajets à l\'avance. Cela pourrait réduire vos dépenses de 15%.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

