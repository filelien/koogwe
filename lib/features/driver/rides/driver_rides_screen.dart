import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/driver_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class DriverRidesScreen extends ConsumerStatefulWidget {
  const DriverRidesScreen({super.key});

  @override
  ConsumerState<DriverRidesScreen> createState() => _DriverRidesScreenState();
}

class _DriverRidesScreenState extends ConsumerState<DriverRidesScreen> {
  final _service = DriverService();
  StreamSubscription? _ridesSubscription;

  @override
  void dispose() {
    _ridesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _acceptRide(String rideId) async {
    final success = await _service.acceptRide(rideId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course acceptée !')),
        );
        context.push(AppRoutes.drivingMode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'accepter la course')),
        );
      }
    }
  }

  Future<void> _rejectRide(String rideId) async {
    await _service.rejectRide(rideId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course refusée')),
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Courses disponibles',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _service.watchAvailableRides(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur: ${snapshot.error}',
                    style: GoogleFonts.inter(),
                  ),
                );
              }

              final rides = snapshot.data ?? [];

              if (rides.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                      const SizedBox(height: KoogweSpacing.lg),
                      Text(
                        'Aucune course disponible',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.sm),
                      Text(
                        'Les nouvelles courses apparaîtront ici',
                        style: GoogleFonts.inter(
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return _RideCard(
                    ride: ride,
                    onAccept: () => _acceptRide(ride['id']),
                    onReject: () => _rejectRide(ride['id']),
                  ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2, end: 0);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RideCard({
    required this.ride,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickup = ride['pickup_text']?.toString() ?? 'N/A';
    final dropoff = ride['dropoff_text']?.toString() ?? 'N/A';
    final price = ride['estimated_price']?.toString() ?? '0';
    final distance = ride['distance_m'] != null ? '${ride['distance_m']} m' : 'Distance inconnue';

    return Padding(
      padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KoogweColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: KoogweColors.primary, size: 20),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dropoff,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '€$price',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: KoogweColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Icon(Icons.straighten, size: 16, color: KoogweColors.info),
              const SizedBox(width: 4),
              Text(
                distance,
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Expanded(
                child: KoogweButton(
                  text: 'Refuser',
                  icon: Icons.close,
                  onPressed: onReject,
                  variant: ButtonVariant.outline,
                  customColor: KoogweColors.error,
                ),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: KoogweButton(
                  text: 'Accepter',
                  icon: Icons.check,
                  onPressed: onAccept,
                  variant: ButtonVariant.gradient,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

