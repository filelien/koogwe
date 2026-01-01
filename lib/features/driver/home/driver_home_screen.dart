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
import 'package:koogwe/core/services/driver_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:intl/intl.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DriverService _driverService = DriverService();
  bool _isLoading = true;
  bool _online = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final driverProfile = await _driverService.getDriverProfile();
      final stats = await _driverService.getDashboardStats();
      
      setState(() {
        _online = driverProfile?['is_online'] ?? false;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DriverHome] Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _online = value);
    final success = await _driverService.setOnlineStatus(value);
    if (!success && mounted) {
      setState(() => _online = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la mise à jour du statut')),
      );
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
            onRefresh: _loadData,
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
                              child: Text(
                                'Dashboard Chauffeur',
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
                              onPressed: _loadData,
                              tooltip: 'Actualiser',
                            ),
                            IconButton(
                              onPressed: () => context.push(AppRoutes.settings),
                              icon: const Icon(Icons.settings_outlined),
                            ),
                            IconButton(
                              onPressed: () => context.push(AppRoutes.driverProfile),
                              icon: const Icon(Icons.person_outline),
                            ),
                          ],
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // Statut en ligne/hors ligne
                        GlassCard(
                          padding: const EdgeInsets.all(KoogweSpacing.lg),
                          borderRadius: KoogweRadius.lgRadius,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _online
                                      ? KoogweColors.success.withValues(alpha: 0.2)
                                      : KoogweColors.error.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _online ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                                  color: _online
                                      ? KoogweColors.success
                                      : KoogweColors.error,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _online ? 'En ligne' : 'Hors ligne',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? KoogweColors.darkTextPrimary
                                            : KoogweColors.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      _online
                                          ? 'Vous recevez des courses'
                                          : 'Activez-vous pour recevoir des courses',
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
                              Switch(
                                value: _online,
                                onChanged: _isLoading ? null : _toggleOnlineStatus,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_stats != null) ...[
                          // KPIs
                          Row(
                            children: [
                              Expanded(
                                child: KPICard(
                                  title: 'Aujourd\'hui',
                                  value: _formatCurrency(_stats!['today_earnings'] ?? 0.0),
                                  subtitle: '${_stats!['today_rides'] ?? 0} courses',
                                  icon: Icons.today,
                                  color: KoogweColors.primary,
                                ).animate().fadeIn(delay: 200.ms).scale(),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: KPICard(
                                  title: 'Cette semaine',
                                  value: _formatCurrency(_stats!['week_earnings'] ?? 0.0),
                                  subtitle: '${_stats!['week_rides'] ?? 0} courses',
                                  icon: Icons.calendar_today,
                                  color: KoogweColors.secondary,
                                ).animate().fadeIn(delay: 250.ms).scale(),
                              ),
                            ],
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: KPICard(
                                  title: 'Total revenus',
                                  value: _formatCurrency(_stats!['total_earnings'] ?? 0.0),
                                  subtitle: '${_stats!['total_rides'] ?? 0} courses',
                                  icon: Icons.euro,
                                  color: KoogweColors.accent,
                                ).animate().fadeIn(delay: 300.ms).scale(),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: KPICard(
                                  title: 'Note moyenne',
                                  value: '${(_stats!['average_rating'] ?? 0.0).toStringAsFixed(1)}',
                                  subtitle: '⭐',
                                  icon: Icons.star,
                                  color: KoogweColors.warning,
                                ).animate().fadeIn(delay: 350.ms).scale(),
                              ),
                            ],
                          ),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Graphique revenus (7 derniers jours)
                          _buildEarningsChart(_stats!, isDark),
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
                        
                        // Actions rapides
                        Text(
                          'Actions rapides',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                        const SizedBox(height: KoogweSpacing.md),
                        Row(children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.drive_eta,
                              label: 'Mode Conduite',
                              color: KoogweColors.primary,
                              onTap: () => context.push(AppRoutes.drivingMode),
                            ).animate().fadeIn(delay: 550.ms).scale(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.attach_money,
                              label: 'Revenus',
                              color: KoogweColors.secondary,
                              onTap: () => context.push(AppRoutes.earnings),
                            ).animate().fadeIn(delay: 600.ms).scale(),
                          ),
                        ]),
                        const SizedBox(height: KoogweSpacing.md),
                        Row(children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.trending_up,
                              label: 'Performance',
                              color: KoogweColors.accent,
                              onTap: () => context.push(AppRoutes.driverPerformance),
                            ).animate().fadeIn(delay: 650.ms).scale(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.description,
                              label: 'Documents',
                              color: KoogweColors.info,
                              onTap: () => context.push(AppRoutes.driverDocuments),
                            ).animate().fadeIn(delay: 700.ms).scale(),
                          ),
                        ]),
                        const SizedBox(height: KoogweSpacing.md),
                        Row(children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.directions_car,
                              label: 'Véhicules',
                              color: KoogweColors.success,
                              onTap: () => context.push(AppRoutes.vehicleCatalog),
                            ).animate().fadeIn(delay: 750.ms).scale(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.list_alt,
                              label: 'Courses',
                              color: KoogweColors.warning,
                              onTap: () => context.push(AppRoutes.driverRides),
                            ).animate().fadeIn(delay: 800.ms).scale(),
                          ),
                        ]),
                        const SizedBox(height: KoogweSpacing.md),
                        Row(children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.bar_chart,
                              label: 'Statistiques',
                              color: KoogweColors.info,
                              onTap: () => context.push(AppRoutes.driverStatistics),
                            ).animate().fadeIn(delay: 850.ms).scale(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.person,
                              label: 'Profil',
                              color: KoogweColors.primary,
                              onTap: () => context.push(AppRoutes.driverProfile),
                            ).animate().fadeIn(delay: 900.ms).scale(),
                          ),
                        ]),
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

  Widget _buildEarningsChart(Map<String, dynamic> stats, bool isDark) {
    final earningsData = stats['earnings_last_7_days'] as List<dynamic>? ?? [];
    
    if (earningsData.isEmpty) {
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

    final chartData = earningsData.asMap().entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      final earnings = (data['earnings'] as num?)?.toDouble() ?? 0.0;
      return LineChartDataPoint(x: entry.key.toDouble(), y: earnings);
    }).toList();

    final bottomLabels = earningsData.map((data) {
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
      leftLabelFormatter: (value) => '${value.toStringAsFixed(0)}€',
      lineColor: KoogweColors.secondary,
      showArea: true,
      height: 300,
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildRidesByStatusChart(Map<String, dynamic> stats, bool isDark) {
    final ridesByStatus = stats['rides_by_status'] as Map<String, dynamic>? ?? {};
    
    final pieData = <PieChartDataPoint>[];
    
    final statusColors = {
      'completed': KoogweColors.success,
      'in_progress': KoogweColors.info,
      'accepted': KoogweColors.primary,
      'cancelled': KoogweColors.error,
    };

    final statusLabels = {
      'completed': 'Terminées',
      'in_progress': 'En cours',
      'accepted': 'Acceptées',
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
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0);
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k€';
    }
    return '${amount.toStringAsFixed(2)}€';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: KoogweRadius.lgRadius,
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
