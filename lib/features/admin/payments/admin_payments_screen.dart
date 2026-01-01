import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/kpi_card.dart';
import 'package:koogwe/core/widgets/data_table_widget.dart';
import 'package:koogwe/core/services/export_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  double _totalRevenue = 0;
  double _todayRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      // Utiliser une requête simple pour éviter les erreurs
      final response = await Supabase.instance.client
          .from('wallet_transactions')
          .select('id, user_id, credit, debit, type, created_at')
          .order('created_at', ascending: false)
          .limit(200);
      
      final transactions = List<Map<String, dynamic>>.from(response);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      double total = 0;
      double todayTotal = 0;
      
      for (var tx in transactions) {
        final amount = (tx['credit'] as num?)?.toDouble() ?? 0.0;
        total += amount;
        
        final createdAt = DateTime.tryParse(tx['created_at']?.toString() ?? '');
        if (createdAt != null && createdAt.isAfter(today)) {
          todayTotal += amount;
        }
      }
      
      setState(() {
        _transactions = transactions;
        _totalRevenue = total;
        _todayRevenue = todayTotal;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[AdminPayments] Error loading transactions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMsg = e.toString().contains('infinite recursion') 
            ? 'Erreur de configuration RLS. Veuillez appliquer les politiques Supabase (voir lib/supabase/APPLY_POLICIES.md)'
            : 'Erreur lors du chargement: ${e.toString().length > 100 ? e.toString().substring(0, 100) + "..." : e}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: KoogweColors.error,
            duration: const Duration(seconds: 5),
          ),
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
            'Gestion des Paiements',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.download),
              tooltip: 'Exporter',
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 8),
                      Text('Exporter en PDF'),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    final exportService = ExportService();
                    final headers = ['Date', 'Utilisateur', 'Type', 'Crédit', 'Débit', 'Statut'];
                    final rows = _transactions.map((tx) {
                      final date = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
                      return [
                        DateFormat('dd/MM/yyyy HH:mm').format(date),
                        tx['user_id']?.toString() ?? '',
                        tx['type']?.toString() ?? '',
                        (tx['credit'] as num?)?.toStringAsFixed(2) ?? '0.00',
                        (tx['debit'] as num?)?.toStringAsFixed(2) ?? '0.00',
                        tx['status']?.toString() ?? 'completed',
                      ];
                    }).toList();
                    final pdfSuccess = await exportService.exportToPDF(
                      title: 'Gestion des Paiements',
                      headers: headers,
                      rows: rows,
                      fileName: 'payments_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
                    );
                    final excelSuccess = await exportService.exportToCSV(
                      title: 'Gestion des Paiements',
                      headers: headers,
                      rows: rows,
                      fileName: 'payments_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            pdfSuccess && excelSuccess
                                ? 'Exports PDF et Excel générés avec succès'
                                : pdfSuccess
                                    ? 'Export PDF généré'
                                    : excelSuccess
                                        ? 'Export Excel généré'
                                        : 'Erreur lors de l\'export',
                          ),
                          backgroundColor: (pdfSuccess || excelSuccess) ? KoogweColors.success : KoogweColors.error,
                        ),
                      );
                    }
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.table_chart, size: 20),
                      SizedBox(width: 8),
                      Text('Exporter en Excel'),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    final exportService = ExportService();
                    final headers = ['Date', 'Utilisateur', 'Type', 'Crédit', 'Débit', 'Statut'];
                    final rows = _transactions.map((tx) {
                      final date = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
                      return [
                        DateFormat('dd/MM/yyyy HH:mm').format(date),
                        tx['user_id']?.toString() ?? '',
                        tx['type']?.toString() ?? '',
                        (tx['credit'] as num?)?.toStringAsFixed(2) ?? '0.00',
                        (tx['debit'] as num?)?.toStringAsFixed(2) ?? '0.00',
                        tx['status']?.toString() ?? 'completed',
                      ];
                    }).toList();
                    final success = await exportService.exportToCSV(
                      title: 'Gestion des Paiements',
                      headers: headers,
                      rows: rows,
                      fileName: 'payments_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Export Excel généré avec succès' : 'Erreur lors de l\'export'),
                          backgroundColor: success ? KoogweColors.success : KoogweColors.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;
                  return Padding(
                    padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                    child: isSmallScreen
                        ? Column(
                            children: [
                              KPICard(
                                title: 'Revenus totaux',
                                value: '€${_totalRevenue.toStringAsFixed(2)}',
                                subtitle: 'Toutes transactions',
                                icon: Icons.account_balance_wallet,
                                color: KoogweColors.primary,
                              ).animate().fadeIn().scale(),
                              const SizedBox(height: KoogweSpacing.md),
                              KPICard(
                                title: 'Aujourd\'hui',
                                value: '€${_todayRevenue.toStringAsFixed(2)}',
                                subtitle: 'Revenus du jour',
                                icon: Icons.today,
                                color: KoogweColors.success,
                              ).animate().fadeIn(delay: 100.ms).scale(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: KPICard(
                                  title: 'Revenus totaux',
                                  value: '€${_totalRevenue.toStringAsFixed(2)}',
                                  subtitle: 'Toutes transactions',
                                  icon: Icons.account_balance_wallet,
                                  color: KoogweColors.primary,
                                ).animate().fadeIn().scale(),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: KPICard(
                                  title: 'Aujourd\'hui',
                                  value: '€${_todayRevenue.toStringAsFixed(2)}',
                                  subtitle: 'Revenus du jour',
                                  icon: Icons.today,
                                  color: KoogweColors.success,
                                ).animate().fadeIn(delay: 100.ms).scale(),
                              ),
                            ],
                          ),
                  );
                },
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: KoogweSpacing.md),
                            Text(
                              'Chargement des transactions...',
                              style: GoogleFonts.inter(
                                color: isDark
                                    ? KoogweColors.darkTextSecondary
                                    : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 64,
                                  color: isDark
                                      ? KoogweColors.darkTextTertiary
                                      : KoogweColors.lightTextTertiary,
                                ),
                                const SizedBox(height: KoogweSpacing.md),
                                Text(
                                  'Aucune transaction',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? KoogweColors.darkTextSecondary
                                        : KoogweColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: KoogweSpacing.sm),
                                Text(
                                  'Les transactions apparaîtront ici une fois effectuées',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark
                                        ? KoogweColors.darkTextTertiary
                                        : KoogweColors.lightTextTertiary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 600;
                              return SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg,
                                ),
                                child: isSmallScreen
                                    ? Column(
                                        children: _transactions.take(50).map((tx) {
                                          final credit = (tx['credit'] as num?)?.toDouble() ?? 0.0;
                                          final debit = (tx['debit'] as num?)?.toDouble() ?? 0.0;
                                          final amount = credit > 0 ? credit : debit;
                                          final type = tx['type']?.toString() ?? 'unknown';
                                          final createdAt = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
                                          
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: KoogweSpacing.sm),
                                            child: GlassCard(
                                              padding: const EdgeInsets.all(KoogweSpacing.md),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        type,
                                                        style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w600,
                                                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                                        ),
                                                      ),
                                                      Text(
                                                        '€${amount.toStringAsFixed(2)}',
                                                        style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w700,
                                                          color: credit > 0 ? KoogweColors.success : KoogweColors.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    DateFormat('dd/MM/yyyy à HH:mm').format(createdAt),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : KoogweDataTable(
                                        headers: const ['Date', 'Type', 'Montant', 'Utilisateur', 'Statut'],
                                        rows: _transactions.take(50).map((tx) {
                                          final credit = (tx['credit'] as num?)?.toDouble() ?? 0.0;
                                          final debit = (tx['debit'] as num?)?.toDouble() ?? 0.0;
                                          final amount = credit > 0 ? credit : debit;
                                          final type = tx['type']?.toString() ?? 'unknown';
                                          final createdAt = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
                                          final userIdStr = tx['user_id']?.toString() ?? '';
                                          final userId = userIdStr.length > 8 
                                              ? userIdStr.substring(0, 8) 
                                              : (userIdStr.isEmpty ? 'N/A' : userIdStr);
                                          
                                          return [
                                            DateFormat('dd/MM/yy HH:mm').format(createdAt),
                                            type,
                                            '€${amount.toStringAsFixed(2)}',
                                            userId,
                                            credit > 0 ? 'Crédit' : 'Débit',
                                          ];
                                        }).toList(),
                                        columnConfigs: const [
                                          TableColumnConfig(),
                                          TableColumnConfig(),
                                          TableColumnConfig(alignment: Alignment.centerRight, textAlign: TextAlign.right),
                                          TableColumnConfig(),
                                          TableColumnConfig(),
                                        ],
                                        striped: true,
                                        paginated: false,
                                      ),
                              ).animate().fadeIn(delay: 200.ms);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

