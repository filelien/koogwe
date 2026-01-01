import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/driver_service.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverStatisticsScreen extends ConsumerStatefulWidget {
  const DriverStatisticsScreen({super.key});

  @override
  ConsumerState<DriverStatisticsScreen> createState() => _DriverStatisticsScreenState();
}

class _DriverStatisticsScreenState extends ConsumerState<DriverStatisticsScreen> {
  final _service = DriverService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await _service.getStatistics();
    setState(() {
      _stats = stats;
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
            'Statistiques',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _stats == null
                  ? Center(
                      child: Text(
                        'Aucune statistique disponible',
                        style: GoogleFonts.inter(),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(KoogweSpacing.lg),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(KoogweSpacing.md),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${_stats!['total_rides'] ?? 0}',
                                              style: GoogleFonts.inter(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: KoogweColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Courses',
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
                                    ),
                                    const SizedBox(width: KoogweSpacing.md),
                                    Expanded(
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(KoogweSpacing.md),
                                        child: Column(
                                          children: [
                                            Text(
                                              '€${((_stats!['total_earnings'] ?? 0) as num).toStringAsFixed(2)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: KoogweColors.success,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Revenus',
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: KoogweSpacing.md),
                                GlassCard(
                                  padding: const EdgeInsets.all(KoogweSpacing.md),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star, color: KoogweColors.accent),
                                      const SizedBox(width: KoogweSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Note moyenne',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: isDark
                                                    ? KoogweColors.darkTextSecondary
                                                    : KoogweColors.lightTextSecondary,
                                              ),
                                            ),
                                            Text(
                                              '${((_stats!['average_rating'] ?? 0) as num).toStringAsFixed(1)}/5.0',
                                              style: GoogleFonts.inter(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? KoogweColors.darkTextPrimary
                                                    : KoogweColors.lightTextPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

