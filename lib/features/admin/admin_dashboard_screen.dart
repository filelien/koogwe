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
import 'package:koogwe/core/services/admin_service.dart';
import 'package:koogwe/core/services/export_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _detailedStats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getDashboardStats();
      final detailedStats = await _adminService.getDetailedStats();
      setState(() {
        _stats = stats;
        _detailedStats = detailedStats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[AdminDashboard] Error loading stats: $e');
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
                        // En-tête
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isSmallScreen = constraints.maxWidth < 600;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Administration — Contrôle Total',
                                            style: GoogleFonts.inter(
                                              fontSize: isSmallScreen ? 22 : 28,
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? KoogweColors.darkTextPrimary
                                                  : KoogweColors.lightTextPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Vue d\'ensemble de la plateforme',
                                            style: GoogleFonts.inter(
                                              fontSize: isSmallScreen ? 12 : 14,
                                              color: isDark
                                                  ? KoogweColors.darkTextSecondary
                                                  : KoogweColors.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () async {
                                if (_detailedStats != null) {
                                  final exportService = ExportService();
                                  final success = await exportService.exportAdminStats(_detailedStats!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'Rapport exporté avec succès' : 'Erreur lors de l\'export'),
                                        backgroundColor: success ? KoogweColors.success : KoogweColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              tooltip: 'Exporter le rapport',
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadStats,
                              tooltip: 'Actualiser',
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () => context.push(AppRoutes.settings),
                            ),
                          ],
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // KPI principaux
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_stats != null && _detailedStats != null) ...[
                          _buildKPISection(_stats!, _detailedStats!, isDark),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Graphique revenus (7 derniers jours)
                          _buildRevenueChart(_detailedStats!, isDark),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Graphiques en ligne (responsive)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 600;
                              if (isSmallScreen) {
                                return Column(
                                  children: [
                                    _buildUsersByRoleChart(_detailedStats!, isDark),
                                    const SizedBox(height: KoogweSpacing.md),
                                    _buildRidesByStatusChart(_detailedStats!, isDark),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildUsersByRoleChart(_detailedStats!, isDark),
                                  ),
                                  const SizedBox(width: KoogweSpacing.md),
                                  Expanded(
                                    child: _buildRidesByStatusChart(_detailedStats!, isDark),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Graphique courses par type de service
                          _buildRidesByServiceChart(_detailedStats!, isDark),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Statistiques détaillées
                          _buildDetailedStatsSection(_detailedStats!, isDark),
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
                        
                        // Actions rapides Admin
                        Text(
                          'Actions Administratives',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: KoogweSpacing.md),
                        LayoutBuilder(
                          builder: (context, gridConstraints) {
                            final gridIsSmall = gridConstraints.maxWidth < 600;
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: gridIsSmall ? 1 : 2,
                              crossAxisSpacing: KoogweSpacing.md,
                              mainAxisSpacing: KoogweSpacing.md,
                              childAspectRatio: gridIsSmall ? 2.0 : 1.5,
                              children: [
                                _AdminActionCard(
                                  icon: Icons.people,
                                  title: 'Utilisateurs',
                                  subtitle: 'Gérer tous les utilisateurs',
                                  color: KoogweColors.primary,
                                  onTap: () => context.push(AppRoutes.adminUsers),
                                ).animate().fadeIn(delay: 450.ms).scale(),
                                _AdminActionCard(
                                  icon: Icons.directions_car,
                                  title: 'Courses',
                                  subtitle: 'Suivi en temps réel',
                                  color: KoogweColors.secondary,
                                  onTap: () => context.push(AppRoutes.adminRides),
                                ).animate().fadeIn(delay: 500.ms).scale(),
                                _AdminActionCard(
                                  icon: Icons.euro,
                                  title: 'Paiements',
                                  subtitle: 'Finance & transactions',
                                  color: KoogweColors.accent,
                                  onTap: () => context.push(AppRoutes.adminPayments),
                                ).animate().fadeIn(delay: 550.ms).scale(),
                                _AdminActionCard(
                                  icon: Icons.security,
                                  title: 'Sécurité',
                                  subtitle: 'Logs & audit',
                                  color: KoogweColors.error,
                                  onTap: () => context.push(AppRoutes.adminSecurity),
                                ).animate().fadeIn(delay: 600.ms).scale(),
                                _AdminActionCard(
                                  icon: Icons.attach_money,
                                  title: 'Tarification',
                                  subtitle: 'Prix par kilomètre',
                                  color: KoogweColors.accent,
                                  onTap: () => context.push(AppRoutes.adminPricing),
                                ).animate().fadeIn(delay: 650.ms).scale(),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: KoogweSpacing.xl),
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

  Widget _buildKPISection(Map<String, dynamic> stats, Map<String, dynamic> detailedStats, bool isDark) {
    final totalUsers = detailedStats['total_users'] ?? 0;
    final totalRides = detailedStats['total_rides'] ?? 0;
    final totalRevenue = detailedStats['total_revenue'] ?? 0.0;
    final todayRevenue = detailedStats['today_revenue'] ?? 0.0;
    final activeDrivers = detailedStats['active_drivers'] ?? 0;
    final todayRides = detailedStats['today_rides'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth < 900;
        
        if (isSmallScreen) {
          // Layout vertical pour petits écrans
          return Column(
            children: [
              KPICard(
                title: 'Utilisateurs',
                value: _formatNumber(totalUsers),
                subtitle: 'Total inscrits',
                icon: Icons.people,
                color: KoogweColors.primary,
                showTrend: false,
              ).animate().fadeIn(delay: 100.ms).scale(),
              const SizedBox(height: KoogweSpacing.md),
              KPICard(
                title: 'Courses',
                value: _formatNumber(totalRides),
                subtitle: '${_formatNumber(todayRides)} aujourd\'hui',
                icon: Icons.directions_car,
                color: KoogweColors.secondary,
                showTrend: false,
              ).animate().fadeIn(delay: 150.ms).scale(),
              const SizedBox(height: KoogweSpacing.md),
              KPICard(
                title: 'Revenus',
                value: _formatCurrency(totalRevenue),
                subtitle: '${_formatCurrency(todayRevenue)} aujourd\'hui',
                icon: Icons.euro,
                color: KoogweColors.accent,
                showTrend: false,
              ).animate().fadeIn(delay: 200.ms).scale(),
              const SizedBox(height: KoogweSpacing.md),
              KPICard(
                title: 'Chauffeurs actifs',
                value: _formatNumber(activeDrivers),
                subtitle: 'En ligne maintenant',
                icon: Icons.drive_eta,
                color: KoogweColors.success,
                showTrend: false,
              ).animate().fadeIn(delay: 250.ms).scale(),
              const SizedBox(height: KoogweSpacing.md),
              KPICard(
                title: 'Revenus du mois',
                value: _formatCurrency(detailedStats['month_revenue'] ?? 0.0),
                subtitle: '30 derniers jours',
                icon: Icons.trending_up,
                color: KoogweColors.info,
                showTrend: false,
              ).animate().fadeIn(delay: 300.ms).scale(),
              const SizedBox(height: KoogweSpacing.md),
              KPICard(
                title: 'Nouveaux utilisateurs',
                value: _formatNumber(detailedStats['new_users_last_7_days'] ?? 0),
                subtitle: '7 derniers jours',
                icon: Icons.person_add,
                color: KoogweColors.warning,
                showTrend: false,
              ).animate().fadeIn(delay: 350.ms).scale(),
            ],
          );
        } else if (isMediumScreen) {
          // Layout 2 colonnes pour écrans moyens
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Utilisateurs',
                      value: _formatNumber(totalUsers),
                      subtitle: 'Total inscrits',
                      icon: Icons.people,
                      color: KoogweColors.primary,
                      showTrend: false,
                    ).animate().fadeIn(delay: 100.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Courses',
                      value: _formatNumber(totalRides),
                      subtitle: '${_formatNumber(todayRides)} aujourd\'hui',
                      icon: Icons.directions_car,
                      color: KoogweColors.secondary,
                      showTrend: false,
                    ).animate().fadeIn(delay: 150.ms).scale(),
                  ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Revenus',
                      value: _formatCurrency(totalRevenue),
                      subtitle: '${_formatCurrency(todayRevenue)} aujourd\'hui',
                      icon: Icons.euro,
                      color: KoogweColors.accent,
                      showTrend: false,
                    ).animate().fadeIn(delay: 200.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Chauffeurs actifs',
                      value: _formatNumber(activeDrivers),
                      subtitle: 'En ligne maintenant',
                      icon: Icons.drive_eta,
                      color: KoogweColors.success,
                      showTrend: false,
                    ).animate().fadeIn(delay: 250.ms).scale(),
                  ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Revenus du mois',
                      value: _formatCurrency(detailedStats['month_revenue'] ?? 0.0),
                      subtitle: '30 derniers jours',
                      icon: Icons.trending_up,
                      color: KoogweColors.info,
                      showTrend: false,
                    ).animate().fadeIn(delay: 300.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Nouveaux utilisateurs',
                      value: _formatNumber(detailedStats['new_users_last_7_days'] ?? 0),
                      subtitle: '7 derniers jours',
                      icon: Icons.person_add,
                      color: KoogweColors.warning,
                      showTrend: false,
                    ).animate().fadeIn(delay: 350.ms).scale(),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Layout 3 colonnes pour grands écrans
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Utilisateurs',
                      value: _formatNumber(totalUsers),
                      subtitle: 'Total inscrits',
                      icon: Icons.people,
                      color: KoogweColors.primary,
                      showTrend: false,
                    ).animate().fadeIn(delay: 100.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Courses',
                      value: _formatNumber(totalRides),
                      subtitle: '${_formatNumber(todayRides)} aujourd\'hui',
                      icon: Icons.directions_car,
                      color: KoogweColors.secondary,
                      showTrend: false,
                    ).animate().fadeIn(delay: 150.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Revenus',
                      value: _formatCurrency(totalRevenue),
                      subtitle: '${_formatCurrency(todayRevenue)} aujourd\'hui',
                      icon: Icons.euro,
                      color: KoogweColors.accent,
                      showTrend: false,
                    ).animate().fadeIn(delay: 200.ms).scale(),
                  ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Chauffeurs actifs',
                      value: _formatNumber(activeDrivers),
                      subtitle: 'En ligne maintenant',
                      icon: Icons.drive_eta,
                      color: KoogweColors.success,
                      showTrend: false,
                    ).animate().fadeIn(delay: 250.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Revenus du mois',
                      value: _formatCurrency(detailedStats['month_revenue'] ?? 0.0),
                      subtitle: '30 derniers jours',
                      icon: Icons.trending_up,
                      color: KoogweColors.info,
                      showTrend: false,
                    ).animate().fadeIn(delay: 300.ms).scale(),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Nouveaux utilisateurs',
                      value: _formatNumber(detailedStats['new_users_last_7_days'] ?? 0),
                      subtitle: '7 derniers jours',
                      icon: Icons.person_add,
                      color: KoogweColors.warning,
                      showTrend: false,
                    ).animate().fadeIn(delay: 350.ms).scale(),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRevenueChart(Map<String, dynamic> detailedStats, bool isDark) {
    final revenueData = detailedStats['revenue_last_7_days'] as List<dynamic>? ?? [];
    
    if (revenueData.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Center(
          child: Text(
            'Aucune donnée de revenus disponible',
            style: GoogleFonts.inter(
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    final chartData = revenueData.asMap().entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      final revenue = (data['revenue'] as num?)?.toDouble() ?? 0.0;
      return LineChartDataPoint(x: entry.key.toDouble(), y: revenue);
    }).toList();

    final bottomLabels = revenueData.map((data) {
      final date = data['date'] as DateTime?;
      if (date != null) {
        return DateFormat('E', 'fr').format(date);
      }
      return '';
    }).toList();

    return KoogweLineChart(
      title: 'Revenus (7 derniers jours)',
      data: chartData,
      bottomLabels: bottomLabels.toList(),
      leftLabelFormatter: (value) => '${(value / 1000).toStringAsFixed(1)}k€',
      lineColor: KoogweColors.primary,
      showArea: true,
      height: 300,
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildUsersByRoleChart(Map<String, dynamic> detailedStats, bool isDark) {
    final usersByRole = detailedStats['users_by_role'] as Map<String, dynamic>? ?? {};
    
    final pieData = <PieChartDataPoint>[];
    if (usersByRole.containsKey('passenger')) {
      pieData.add(PieChartDataPoint(
        value: (usersByRole['passenger'] as num?)?.toDouble() ?? 0.0,
        color: KoogweColors.primary,
        label: 'Passagers',
      ));
    }
    if (usersByRole.containsKey('driver')) {
      pieData.add(PieChartDataPoint(
        value: (usersByRole['driver'] as num?)?.toDouble() ?? 0.0,
        color: KoogweColors.secondary,
        label: 'Chauffeurs',
      ));
    }
    if (usersByRole.containsKey('business')) {
      pieData.add(PieChartDataPoint(
        value: (usersByRole['business'] as num?)?.toDouble() ?? 0.0,
        color: KoogweColors.accent,
        label: 'Entreprises',
      ));
    }
    if (usersByRole.containsKey('admin')) {
      pieData.add(PieChartDataPoint(
        value: (usersByRole['admin'] as num?)?.toDouble() ?? 0.0,
        color: KoogweColors.error,
        label: 'Admins',
      ));
    }

    if (pieData.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Center(
          child: Text(
            'Aucune donnée',
            style: GoogleFonts.inter(
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return KoogwePieChart(
      title: 'Utilisateurs par rôle',
      data: pieData,
      height: 300,
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildRidesByStatusChart(Map<String, dynamic> detailedStats, bool isDark) {
    final ridesByStatus = detailedStats['rides_by_status'] as Map<String, dynamic>? ?? {};
    
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
      if (count is num && count > 0) {
        pieData.add(PieChartDataPoint(
          value: count.toDouble(),
          color: statusColors[status] ?? KoogweColors.primary,
          label: statusLabels[status] ?? status,
        ));
      }
    });

    if (pieData.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Center(
          child: Text(
            'Aucune donnée',
            style: GoogleFonts.inter(
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return KoogwePieChart(
      title: 'Courses par statut',
      data: pieData,
      height: 300,
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildRidesByServiceChart(Map<String, dynamic> detailedStats, bool isDark) {
    final ridesByService = detailedStats['rides_by_service'] as Map<String, dynamic>? ?? {};
    
    final barData = <BarChartDataPoint>[];
    final bottomLabels = <String>[];
    
    ridesByService.forEach((serviceType, count) {
      if (count is num && count > 0) {
        barData.add(BarChartDataPoint(
          y: count.toDouble(),
          color: _getServiceColor(serviceType),
        ));
        bottomLabels.add(_getServiceLabel(serviceType));
      }
    });

    if (barData.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Center(
          child: Text(
            'Aucune donnée de service disponible',
            style: GoogleFonts.inter(
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return KoogweBarChart(
      title: 'Courses par type de service',
      data: barData,
      bottomLabels: bottomLabels,
      barColor: KoogweColors.primary,
      showGrid: true,
      height: 300,
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDetailedStatsSection(Map<String, dynamic> detailedStats, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques détaillées',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          
          // Utilisateurs par rôle
          _buildStatRow(
            'Passagers',
            _formatNumber((detailedStats['users_by_role']?['passenger'] as num?)?.toInt() ?? 0),
            Icons.person,
            KoogweColors.primary,
            isDark,
          ),
          _buildStatRow(
            'Chauffeurs',
            _formatNumber((detailedStats['users_by_role']?['driver'] as num?)?.toInt() ?? 0),
            Icons.drive_eta,
            KoogweColors.secondary,
            isDark,
          ),
          _buildStatRow(
            'Entreprises',
            _formatNumber((detailedStats['users_by_role']?['business'] as num?)?.toInt() ?? 0),
            Icons.business,
            KoogweColors.accent,
            isDark,
          ),
          
          const Divider(height: KoogweSpacing.xl),
          
          // Courses par statut
          Text(
            'Courses par statut',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.sm),
          _buildStatRow(
            'Terminées',
            _formatNumber((detailedStats['rides_by_status']?['completed'] as num?)?.toInt() ?? 0),
            Icons.check_circle,
            KoogweColors.success,
            isDark,
          ),
          _buildStatRow(
            'En cours',
            _formatNumber((detailedStats['rides_by_status']?['in_progress'] as num?)?.toInt() ?? 0),
            Icons.directions_car,
            KoogweColors.info,
            isDark,
          ),
          _buildStatRow(
            'En attente',
            _formatNumber((detailedStats['rides_by_status']?['pending'] as num?)?.toInt() ?? 0),
            Icons.hourglass_empty,
            KoogweColors.warning,
            isDark,
          ),
          _buildStatRow(
            'Annulées',
            _formatNumber((detailedStats['rides_by_status']?['cancelled'] as num?)?.toInt() ?? 0),
            Icons.cancel,
            KoogweColors.error,
            isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: KoogweSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'economy':
      case 'economique':
        return KoogweColors.primary;
      case 'comfort':
      case 'confort':
        return KoogweColors.secondary;
      case 'premium':
        return KoogweColors.accent;
      case 'luxury':
      case 'luxe':
        return KoogweColors.warning;
      default:
        return KoogweColors.info;
    }
  }

  String _getServiceLabel(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'economy':
      case 'economique':
        return 'Économique';
      case 'comfort':
      case 'confort':
        return 'Confort';
      case 'premium':
        return 'Premium';
      case 'luxury':
      case 'luxe':
        return 'Luxe';
      default:
        return serviceType;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
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

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
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
      child: GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        borderRadius: KoogweRadius.lgRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: KoogweSpacing.sm),
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
                fontSize: 11,
                color: isDark
                    ? KoogweColors.darkTextSecondary
                    : KoogweColors.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
