import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/wallet_provider.dart';
import 'package:koogwe/core/widgets/kpi_card.dart';
import 'package:koogwe/core/widgets/chart_widgets.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:koogwe/core/services/export_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  Future<void> _exportToPDF(BuildContext context, List<Map<String, dynamic>> transactions) async {
    final exportService = ExportService();
    final success = await exportService.exportWalletTransactions(transactions);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Export PDF réussi' : 'Erreur lors de l\'export PDF'),
          backgroundColor: success ? KoogweColors.success : KoogweColors.error,
        ),
      );
    }
  }

  Future<void> _exportToExcel(BuildContext context, List<Map<String, dynamic>> transactions) async {
    final exportService = ExportService();
    final headers = ['Date', 'Type', 'Crédit', 'Débit', 'Solde'];
    final rows = <List<String>>[];
    
    double balance = 0.0;
    for (final tx in transactions) {
      final credit = (tx['credit'] as num?)?.toDouble() ?? 0.0;
      final debit = (tx['debit'] as num?)?.toDouble() ?? 0.0;
      balance += credit - debit;
      
      final date = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
      
      rows.add([
        DateFormat('dd/MM/yyyy HH:mm').format(date),
        tx['type']?.toString() ?? '',
        credit > 0 ? credit.toStringAsFixed(2) : '0.00',
        debit > 0 ? debit.toStringAsFixed(2) : '0.00',
        balance.toStringAsFixed(2),
      ]);
    }
    
    final success = await exportService.exportToCSV(
      title: 'Historique des Transactions',
      headers: headers,
      rows: rows,
      fileName: 'transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
    );
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Export Excel réussi' : 'Erreur lors de l\'export Excel'),
          backgroundColor: success ? KoogweColors.success : KoogweColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(walletProvider);
    
    // Calculer les statistiques
    final totalSpent = state.transactions
        .where((t) {
          final debit = (t['debit'] as num?)?.toDouble() ?? 0;
          return debit > 0;
        })
        .fold<double>(0, (sum, t) => sum + ((t['debit'] as num?)?.toDouble() ?? 0));
    
    final totalEarned = state.transactions
        .where((t) {
          final credit = (t['credit'] as num?)?.toDouble() ?? 0;
          return credit > 0;
        })
        .fold<double>(0, (sum, t) => sum + ((t['credit'] as num?)?.toDouble() ?? 0));

    final transactions = state.transactions;
    
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Portefeuille',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            children: [
              // Solde actuel
              GlassCard(
                borderRadius: KoogweRadius.xlRadius,
                child: Container(
                  padding: const EdgeInsets.all(KoogweSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [KoogweColors.primary, KoogweColors.primaryDark],
                    ),
                    borderRadius: KoogweRadius.xlRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solde actuel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '€ ${state.balance.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: KoogweSpacing.xl),

              // KPIs
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Total dépensé',
                      value: '€${totalSpent.toStringAsFixed(2)}',
                      subtitle: 'Ce mois',
                      icon: Icons.arrow_upward,
                      color: KoogweColors.error,
                    ).animate().fadeIn(delay: 100.ms),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: KPICard(
                      title: 'Total reçu',
                      value: '€${totalEarned.toStringAsFixed(2)}',
                      subtitle: 'Ce mois',
                      icon: Icons.arrow_downward,
                      color: KoogweColors.success,
                    ).animate().fadeIn(delay: 200.ms),
                  ),
                ],
              ),

              const SizedBox(height: KoogweSpacing.xl),

              // Graphique des dépenses
              GlassCard(
                borderRadius: KoogweRadius.lgRadius,
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
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
                        height: 200,
                        child: KoogweLineChart(
                          data: [
                            LineChartDataPoint(x: 0, y: 25),
                            LineChartDataPoint(x: 1, y: 30),
                            LineChartDataPoint(x: 2, y: 22),
                            LineChartDataPoint(x: 3, y: 35),
                            LineChartDataPoint(x: 4, y: 28),
                            LineChartDataPoint(x: 5, y: 40),
                            LineChartDataPoint(x: 6, y: 32),
                          ],
                          lineColor: KoogweColors.primary,
                          bottomLabels: const ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
                          showArea: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: KoogweSpacing.xl),

              // Moyens de paiement
              Text(
                'Moyens de paiement',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),
              _PaymentTile(
                icon: Icons.credit_card, 
                title: 'Carte bancaire', 
                subtitle: 'Visa •••• 4242', 
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gestion des cartes bancaires à venir')),
                  );
                },
              ),
              _PaymentTile(
                icon: Icons.phone_iphone, 
                title: 'Mobile Money', 
                subtitle: 'Orange / MTN', 
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration Mobile Money à venir')),
                  );
                },
              ),
              _PaymentTile(
                icon: Icons.attach_money, 
                title: 'Espèces', 
                subtitle: 'Payer en cash', 
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paiement en espèces disponible')),
                  );
                },
              ),

              const SizedBox(height: KoogweSpacing.xl),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actions rapides',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  if (transactions.isNotEmpty)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf),
                          tooltip: 'Exporter en PDF',
                          onPressed: () => _exportToPDF(context, transactions),
                        ),
                        IconButton(
                          icon: const Icon(Icons.table_chart),
                          tooltip: 'Exporter en Excel',
                          onPressed: () => _exportToExcel(context, transactions),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Recharger',
                      icon: Icons.add,
                      onTap: () => _showTopUpDialog(context, ref),
                    ),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Retirer',
                      icon: Icons.remove,
                      onTap: () => _showWithdrawDialog(context, ref),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: KoogweSpacing.xl),

              // Historique des transactions
              Text(
                'Historique des transactions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),
              
              if (transactions.isEmpty)
                GlassCard(
                  borderRadius: KoogweRadius.lgRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(KoogweSpacing.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                          Text(
                            'Aucune transaction',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...transactions.take(10).map((t) {
                  final creditValue = (t['credit'] as num?)?.toDouble();
                  final debitValue = (t['debit'] as num?)?.toDouble();
                  final credit = creditValue ?? 0.0;
                  final debit = debitValue ?? 0.0;
                  final isCredit = credit > 0;
                  final amount = isCredit ? credit : debit;
                  final createdAt = DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now();
                  final type = t['type']?.toString() ?? 'transaction';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: KoogweSpacing.sm),
                    child: GlassCard(
                      borderRadius: KoogweRadius.mdRadius,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isCredit ? KoogweColors.success : KoogweColors.error)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isCredit ? KoogweColors.success : KoogweColors.error,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          type,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                        ),
                        trailing: Text(
                          '${isCredit ? '+' : '-'}€ ${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: isCredit ? KoogweColors.success : KoogweColors.error,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recharger le portefeuille'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoogweTextField(
              controller: amountController,
              hint: 'Montant (€)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.euro),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
              if (amount > 0) {
                ref.read(walletProvider.notifier).topUp(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rechargement de ${amount.toStringAsFixed(2)}€ effectué')),
                );
              }
            },
            child: const Text('Recharger'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer du portefeuille'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoogweTextField(
              controller: amountController,
              hint: 'Montant (€)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.euro),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
              if (amount > 0) {
                ref.read(walletProvider.notifier).withdraw(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Retrait de ${amount.toStringAsFixed(2)}€ effectué')),
                );
              }
            },
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PaymentTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: KoogweSpacing.sm),
      child: GlassCard(
        borderRadius: KoogweRadius.mdRadius,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KoogweColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: KoogweColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recharger le portefeuille'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoogweTextField(
              controller: amountController,
              hint: 'Montant (€)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.euro),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
              if (amount > 0) {
                ref.read(walletProvider.notifier).topUp(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rechargement de ${amount.toStringAsFixed(2)}€ effectué')),
                );
              }
            },
            child: const Text('Recharger'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer du portefeuille'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KoogweTextField(
              controller: amountController,
              hint: 'Montant (€)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.euro),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
              if (amount > 0) {
                ref.read(walletProvider.notifier).withdraw(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Retrait de ${amount.toStringAsFixed(2)}€ effectué')),
                );
              }
            },
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: KoogweColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.md),
      ),
    );
  }
}

