import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/company_service.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessBudgetScreen extends ConsumerStatefulWidget {
  const BusinessBudgetScreen({super.key});

  @override
  ConsumerState<BusinessBudgetScreen> createState() => _BusinessBudgetScreenState();
}

class _BusinessBudgetScreenState extends ConsumerState<BusinessBudgetScreen> {
  final _service = CompanyService();
  Map<String, dynamic>? _budget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final budget = await _service.getBudget();
    setState(() {
      _budget = budget;
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
            'Budget',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _budget == null
                  ? Center(
                      child: Text(
                        'Aucune information de budget',
                        style: GoogleFonts.inter(),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(KoogweSpacing.lg),
                      child: Column(
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.all(KoogweSpacing.lg),
                            child: Column(
                              children: [
                                Text(
                                  'Budget mensuel',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: isDark
                                        ? KoogweColors.darkTextSecondary
                                        : KoogweColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: KoogweSpacing.sm),
                                Text(
                                  '€${((_budget!['monthly_budget'] ?? 0) as num).toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: KoogweColors.primary,
                                  ),
                                ),
                                const SizedBox(height: KoogweSpacing.lg),
                                LinearProgressIndicator(
                                  value: ((_budget!['current_spent'] ?? 0) as num).toDouble() /
                                      ((_budget!['monthly_budget'] ?? 1) as num).toDouble(),
                                  backgroundColor: KoogweColors.darkBackground,
                                  valueColor: AlwaysStoppedAnimation<Color>(KoogweColors.primary),
                                ),
                                const SizedBox(height: KoogweSpacing.sm),
                                Text(
                                  'Dépensé: €${((_budget!['current_spent'] ?? 0) as num).toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark
                                        ? KoogweColors.darkTextSecondary
                                        : KoogweColors.lightTextSecondary,
                                  ),
                                ),
                              ],
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

