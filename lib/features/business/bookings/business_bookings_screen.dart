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

class BusinessBookingsScreen extends ConsumerStatefulWidget {
  const BusinessBookingsScreen({super.key});

  @override
  ConsumerState<BusinessBookingsScreen> createState() => _BusinessBookingsScreenState();
}

class _BusinessBookingsScreenState extends ConsumerState<BusinessBookingsScreen> {
  final _service = CompanyService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await _service.getCompanyRides();
    setState(() {
      _bookings = bookings;
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
            'Réservations',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                          const SizedBox(height: KoogweSpacing.lg),
                          Text(
                            'Aucune réservation',
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
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                          child: GlassCard(
                            padding: const EdgeInsets.all(KoogweSpacing.md),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking['pickup_text']?.toString() ?? 'N/A',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          booking['dropoff_text']?.toString() ?? 'N/A',
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
                                  Text(
                                    '€${booking['estimated_price']?.toString() ?? '0'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: KoogweColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: KoogweSpacing.sm),
                              Chip(
                                label: Text(booking['status']?.toString() ?? 'pending'),
                                backgroundColor: KoogweColors.primary.withValues(alpha: 0.2),
                              ),
                            ],
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

