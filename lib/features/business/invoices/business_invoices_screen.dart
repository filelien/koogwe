import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/company_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BusinessInvoicesScreen extends ConsumerStatefulWidget {
  const BusinessInvoicesScreen({super.key});

  @override
  ConsumerState<BusinessInvoicesScreen> createState() => _BusinessInvoicesScreenState();
}

class _BusinessInvoicesScreenState extends ConsumerState<BusinessInvoicesScreen> {
  final _service = CompanyService();
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final invoices = await _service.getInvoices();
    setState(() {
      _invoices = invoices;
      _isLoading = false;
    });
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
            'Factures',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _invoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                          const SizedBox(height: KoogweSpacing.lg),
                          Text(
                            'Aucune facture',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(KoogweSpacing.lg),
                      itemCount: _invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = _invoices[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                          child: GlassCard(
                            padding: const EdgeInsets.all(KoogweSpacing.md),
                            child: ListTile(
                            leading: const Icon(Icons.receipt),
                            title: Text('Facture #${invoice['invoice_number'] ?? 'N/A'}'),
                            subtitle: Text(
                              invoice['created_at']?.toString().split('T')[0] ?? 'N/A',
                            ),
                            trailing: Text(
                              '€${((invoice['total_amount'] ?? 0) as num).toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: KoogweColors.primary,
                              ),
                            ),
                            onTap: () {
                              // TODO: Ouvrir détails facture
                            },
                          ),
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms);
                      },
                    ),
        ),
      ),
    );
  }
}

