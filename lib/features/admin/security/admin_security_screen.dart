import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/kpi_card.dart';
import 'package:koogwe/core/services/admin_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AdminSecurityScreen extends StatefulWidget {
  const AdminSecurityScreen({super.key});

  @override
  State<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends State<AdminSecurityScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _auditLogs = [];
  int _totalLogs = 0;
  int _failedLogins = 0;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _adminService.getAuditLogs(limit: 100);
      
      // Compter les tentatives échouées (exemple: on peut filtrer par type d'action)
      final failedCount = logs.where((log) {
        final action = log['action']?.toString().toLowerCase() ?? '';
        return action.contains('failed') || action.contains('denied');
      }).length;

      setState(() {
        _auditLogs = logs;
        _totalLogs = logs.length;
        _failedLogins = failedCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[AdminSecurity] Error loading data: $e');
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Sécurité & Audit',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSecurityData,
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadSecurityData,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(KoogweSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistiques de sécurité
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: KPICard(
                                  title: 'Logs d\'audit',
                                  value: _totalLogs.toString(),
                                  subtitle: 'Total enregistré',
                                  icon: Icons.security,
                                  color: KoogweColors.primary,
                                ).animate().fadeIn().scale(),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: KPICard(
                                  title: 'Tentatives échouées',
                                  value: _failedLogins.toString(),
                                  subtitle: 'Dernières 24h',
                                  icon: Icons.warning,
                                  color: KoogweColors.warning,
                                ).animate().fadeIn(delay: 100.ms).scale(),
                              ),
                            ],
                          ),
                          const SizedBox(height: KoogweSpacing.xl),
                          
                          // Liste des logs d'audit
                          Text(
                            'Logs d\'audit récents',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? KoogweColors.darkTextPrimary
                                  : KoogweColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                          
                          if (_auditLogs.isEmpty)
                            GlassCard(
                              padding: const EdgeInsets.all(KoogweSpacing.xl),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.security_outlined,
                                    size: 64,
                                    color: isDark
                                        ? KoogweColors.darkTextTertiary
                                        : KoogweColors.lightTextTertiary,
                                  ),
                                  const SizedBox(height: KoogweSpacing.md),
                                  Text(
                                    'Aucun log d\'audit disponible',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: isDark
                                          ? KoogweColors.darkTextSecondary
                                          : KoogweColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._auditLogs.take(20).map((log) => _AuditLogCard(
                              log: log,
                              isDark: isDark,
                            )),
                        ],
                        
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // Actions de sécurité
                        Text(
                          'Actions de sécurité',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: KoogweSpacing.md),
                        _SecurityActionCard(
                          icon: Icons.security,
                          title: 'Logs d\'audit',
                          description: 'Consulter les logs de sécurité',
                          color: KoogweColors.primary,
                          onTap: () {
                            // Navigate to full audit logs if needed
                          },
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: KoogweSpacing.md),
                        _SecurityActionCard(
                          icon: Icons.shield,
                          title: 'Politiques de sécurité',
                          description: 'Gérer les règles de sécurité',
                          color: KoogweColors.secondary,
                          onTap: () {
                            // TODO: Navigate to security policies
                          },
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        _SecurityActionCard(
                          icon: Icons.warning,
                          title: 'Alertes de sécurité',
                          description: 'Voir les alertes et incidents',
                          color: KoogweColors.error,
                          onTap: () {
                            // TODO: Navigate to security alerts
                          },
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: KoogweSpacing.md),
                        _SecurityActionCard(
                          icon: Icons.backup,
                          title: 'Sauvegardes',
                          description: 'Gérer les sauvegardes système',
                          color: KoogweColors.info,
                          onTap: () {
                            // TODO: Navigate to backups
                          },
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
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
}

class _AuditLogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final bool isDark;

  const _AuditLogCard({
    required this.log,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final action = log['action']?.toString() ?? 'Action inconnue';
    final createdAt = DateTime.tryParse(log['created_at']?.toString() ?? '') ?? DateTime.now();
    final user = log['user'] as Map<String, dynamic>?;
    final userName = user != null
        ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()
        : 'Utilisateur inconnu';
    final userEmail = user?['email']?.toString() ?? '';

    Color actionColor = KoogweColors.info;
    IconData actionIcon = Icons.info_outline;
    
    if (action.toLowerCase().contains('failed') || action.toLowerCase().contains('denied')) {
      actionColor = KoogweColors.error;
      actionIcon = Icons.error_outline;
    } else if (action.toLowerCase().contains('login') || action.toLowerCase().contains('access')) {
      actionColor = KoogweColors.success;
      actionIcon = Icons.check_circle_outline;
    } else if (action.toLowerCase().contains('delete') || action.toLowerCase().contains('remove')) {
      actionColor = KoogweColors.warning;
      actionIcon = Icons.delete_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, color: actionColor, size: 20),
            ),
            const SizedBox(width: KoogweSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
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

class _SecurityActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _SecurityActionCard({
    required this.icon,
    required this.title,
    required this.description,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: KoogweSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? KoogweColors.darkTextPrimary
                          : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
