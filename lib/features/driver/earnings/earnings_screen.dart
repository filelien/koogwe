import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/kpi_card.dart';
import 'package:koogwe/core/widgets/chart_widgets.dart';
import 'package:koogwe/core/widgets/data_table_widget.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/services/export_service.dart';
import 'package:koogwe/core/services/report_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedPeriod = 'Semaine';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Revenus & Statistiques'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final reportService = ReportService();
                DateTime startDate;
                DateTime endDate = DateTime.now();
                
                switch (_selectedPeriod) {
                  case 'Jour':
                    startDate = DateTime.now().subtract(const Duration(days: 1));
                    break;
                  case 'Semaine':
                    startDate = DateTime.now().subtract(const Duration(days: 7));
                    break;
                  case 'Mois':
                    startDate = DateTime.now().subtract(const Duration(days: 30));
                    break;
                  case 'Année':
                    startDate = DateTime.now().subtract(const Duration(days: 365));
                    break;
                  default:
                    startDate = DateTime.now().subtract(const Duration(days: 7));
                }
                
                final pdf = await reportService.generateDriverReport(
                  startDate: startDate,
                  endDate: endDate,
                );
                
                if (pdf != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rapport PDF généré avec succès')),
                  );
                }
              },
              tooltip: 'Exporter en PDF',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => setState(() => _selectedPeriod = value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Jour', child: Text('Aujourd\'hui')),
                const PopupMenuItem(value: 'Semaine', child: Text('Cette semaine')),
                const PopupMenuItem(value: 'Mois', child: Text('Ce mois')),
                const PopupMenuItem(value: 'Année', child: Text('Cette année')),
              ],
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedPeriod,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? KoogweColors.darkTextPrimary
                            : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: KoogweSpacing.xs),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark
                          ? KoogweColors.darkTextPrimary
                          : KoogweColors.lightTextPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPIs
                      Row(
                        children: [
                          Expanded(
                            child: KPICard(
                              title: 'Revenus totaux',
                              value: '€ 820,50',
                              subtitle: '+12% vs semaine dernière',
                              icon: Icons.account_balance_wallet,
                              color: KoogweColors.success,
                              showTrend: true,
                              trendValue: 12.0,
                              trendIsPositive: true,
                            ).animate().fadeIn().scale(),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          Expanded(
                            child: KPICard(
                              title: 'Courses',
                              value: '42',
                              subtitle: 'Cette semaine',
                              icon: Icons.directions_car,
                              color: KoogweColors.primary,
                            ).animate().fadeIn(delay: 100.ms).scale(),
                          ),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: KPICard(
                              title: 'Heures actives',
                              value: '36h',
                              subtitle: 'Temps de conduite',
                              icon: Icons.access_time,
                              color: KoogweColors.info,
                            ).animate().fadeIn(delay: 200.ms).scale(),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          Expanded(
                            child: KPICard(
                              title: 'Revenu/h',
                              value: '€ 22,79',
                              subtitle: 'Moyenne horaire',
                              icon: Icons.trending_up,
                              color: KoogweColors.accent,
                            ).animate().fadeIn(delay: 300.ms).scale(),
                          ),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.xl),

                      // Graphique revenus
                      KoogweLineChart(
                        title: 'Évolution des revenus',
                        subtitle: _selectedPeriod,
                        data: const [
                          LineChartDataPoint(x: 0, y: 80),
                          LineChartDataPoint(x: 1, y: 120),
                          LineChartDataPoint(x: 2, y: 100),
                          LineChartDataPoint(x: 3, y: 160),
                          LineChartDataPoint(x: 4, y: 140),
                          LineChartDataPoint(x: 5, y: 200),
                          LineChartDataPoint(x: 6, y: 180),
                        ],
                        bottomLabels: const ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
                        leftLabelFormatter: (value) => '${value.toInt()}€',
                        lineColor: KoogweColors.success,
                        showArea: true,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: KoogweSpacing.xl),

                      // Graphique répartition
                      KoogwePieChart(
                        title: 'Répartition des revenus',
                        data: [
                          PieChartDataPoint(
                            value: 450,
                            color: KoogweColors.primary,
                            label: 'Courses normales',
                          ),
                          PieChartDataPoint(
                            value: 250,
                            color: KoogweColors.success,
                            label: 'Pourboires',
                          ),
                          PieChartDataPoint(
                            value: 120,
                            color: KoogweColors.accent,
                            label: 'Bonus',
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms).scale(),

                      const SizedBox(height: KoogweSpacing.xl),

                      // Tableau historique
                      Text(
                        'Historique des paiements',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: KoogweSpacing.md),
                      KoogweDataTable(
                        headers: const ['Date', 'Montant', 'Type', 'Statut'],
                        rows: [
                          ['15/01/2024', '€ 45,50', 'Course', 'Payé'],
                          ['14/01/2024', '€ 32,00', 'Course', 'Payé'],
                          ['14/01/2024', '€ 10,00', 'Pourboire', 'Payé'],
                          ['13/01/2024', '€ 28,75', 'Course', 'Payé'],
                          ['12/01/2024', '€ 55,00', 'Course', 'Payé'],
                        ],
                        columnConfigs: const [
                          TableColumnConfig(),
                          TableColumnConfig(
                            alignment: Alignment.centerRight,
                            textAlign: TextAlign.right,
                          ),
                          TableColumnConfig(),
                          TableColumnConfig(),
                        ],
                        striped: true,
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
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

