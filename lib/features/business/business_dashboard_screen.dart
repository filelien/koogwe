import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/kpi_card.dart';
import 'package:koogwe/core/widgets/chart_widgets.dart';
import 'package:koogwe/core/services/company_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:intl/intl.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  final CompanyService _companyService = CompanyService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _companyService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[BusinessDashboard] Error loading stats: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStats,
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
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadStats,
                              tooltip: 'Actualiser',
                            ),
                            IconButton(
                              icon: const Icon(Icons.assessment),
                              onPressed: () => context.push(AppRoutes.businessReports),
                              tooltip: 'Rapports',
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () => context.push(AppRoutes.settings),
                            ),
                          ],
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_stats != null) ...[
                          // KPIs
                          Row(
                            children: [
                              Expanded(
                                child: KPICard(
                                  title: 'Courses',
                                  value: '${_stats!['total_rides'] ?? 0}',
                                  subtitle: '${_stats!['completed_rides'] ?? 0} terminées',
                                  icon: Icons.directions_car,
                                  color: KoogweColors.primary,
                                ).animate().fadeIn(delay: 100.ms).scale(),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: KPICard(
                                  title: 'Dépenses',
                                  value: _formatCurrency(_stats!['total_spent'] ?? 0.0),
                                  subtitle: '${_formatCurrency(_stats!['month_spent'] ?? 0.0)} ce mois',
                                  icon: Icons.euro,
                                  color: KoogweColors.secondary,
                                ).animate().fadeIn(delay: 150.ms).scale(),
                              ),
                            ],
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: KPICard(
                                  title: 'Budget',
                                  value: _formatCurrency(_stats!['remaining_budget'] ?? 0.0),
                                  subtitle: 'Restant ce mois',
                                  icon: Icons.account_balance_wallet,
                                  color: KoogweColors.accent,
                                ).animate().fadeIn(delay: 200.ms).scale(),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: KPICard(
                                  title: 'Employés',
                                  value: '${_stats!['employees_count'] ?? 0}',
                                  subtitle: 'Actifs',
                                  icon: Icons.people,
                                  color: KoogweColors.info,
                                ).animate().fadeIn(delay: 250.ms).scale(),
                              ),
                            ],
                          ),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Graphique dépenses (7 derniers jours)
                          _buildSpendingChart(_stats!, isDark),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Courses par statut
                          _buildRidesByStatusChart(_stats!, isDark),
                          const SizedBox(height: KoogweSpacing.xl),
                        ] else
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: KoogweColors.error,
                                ),
                                const SizedBox(height: KoogweSpacing.md),
                                Text(
                                  'Erreur de chargement des données',
                                  style: GoogleFonts.inter(
                                    color: KoogweColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // Carte rapports
                        GlassCard(
                          onTap: () => context.push(AppRoutes.businessReports),
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
                                  context.push(AppRoutes.businessEmployees);
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
                                  context.push(AppRoutes.vehicleCatalog);
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
                                  context.push(AppRoutes.businessInvoices);
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
                                onTap: () => context.push(AppRoutes.businessReports),
                              ).animate().fadeIn(delay: 600.ms).scale(),
                            ),
                          ],
                        ),
                        const SizedBox(height: KoogweSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _BusinessActionCard(
                                icon: Icons.event,
                                title: 'Réservations',
                                subtitle: 'Voir les trajets',
                                color: KoogweColors.success,
                                onTap: () {
                                  context.push(AppRoutes.businessBookings);
                                },
                              ).animate().fadeIn(delay: 650.ms).scale(),
                            ),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: _BusinessActionCard(
                                icon: Icons.account_balance_wallet,
                                title: 'Budget',
                                subtitle: 'Gérer le budget',
                                color: KoogweColors.warning,
                                onTap: () {
                                  context.push(AppRoutes.businessBudget);
                                },
                              ).animate().fadeIn(delay: 700.ms).scale(),
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
      ),
    );
  }

  Widget _buildSpendingChart(Map<String, dynamic> stats, bool isDark) {
    final spendingData = stats['spending_last_7_days'] as List<dynamic>? ?? [];
    
    if (spendingData.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Center(
          child: Text(
            'Aucune donnée de dépenses disponible',
            style: GoogleFonts.inter(
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    final chartData = spendingData.asMap().entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      final spent = (data['spent'] as num?)?.toDouble() ?? 0.0;
      return LineChartDataPoint(x: entry.key.toDouble(), y: spent);
    }).toList();

    final bottomLabels = spendingData.map((data) {
      final date = data['date'] as DateTime?;
      if (date != null) {
        return DateFormat('E', 'fr').format(date);
      }
      return '';
    }).toList();

    return KoogweLineChart(
      title: 'Dépenses (7 derniers jours)',
      data: chartData,
      bottomLabels: bottomLabels.toList(),
      leftLabelFormatter: (value) => '${(value / 1000).toStringAsFixed(1)}k€',
      lineColor: KoogweColors.secondary,
      showArea: true,
      height: 300,
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildRidesByStatusChart(Map<String, dynamic> stats, bool isDark) {
    final ridesByStatus = stats['rides_by_status'] as Map<String, dynamic>? ?? {};
    
    final pieData = <PieChartDataPoint>[];
    
    final statusColors = {
      'completed': KoogweColors.success,
      'in_progress': KoogweColors.info,
      'pending': KoogweColors.warning,
      'cancelled': KoogweColors.error,
    };

    final statusLabels = {
      'completed': 'Terminées',
      'in_progress': 'En cours',
      'pending': 'En attente',
      'cancelled': 'Annulées',
    };

    ridesByStatus.forEach((status, count) {
      if (count is num && count > 0 && statusColors.containsKey(status)) {
        pieData.add(PieChartDataPoint(
          value: count.toDouble(),
          color: statusColors[status]!,
          label: statusLabels[status] ?? status,
        ));
      }
    });

    if (pieData.isEmpty) {
      return const SizedBox.shrink();
    }

    return KoogwePieChart(
      title: 'Répartition des courses',
      data: pieData,
      height: 300,
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0);
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M€';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k€';
    }
    return '${amount.toStringAsFixed(2)}€';
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
