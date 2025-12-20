import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_assets.dart';

class RidePreviewScreen extends StatelessWidget {
  final String vehicleType;
  final String pickup;
  final String dropoff;
  final double estimatedPrice;
  final int estimatedDuration;
  final String? driverName;
  final double? driverRating;

  const RidePreviewScreen({
    super.key,
    required this.vehicleType,
    required this.pickup,
    required this.dropoff,
    required this.estimatedPrice,
    required this.estimatedDuration,
    this.driverName,
    this.driverRating,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu de la course'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du trajet
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.my_location, color: KoogweColors.success, size: 24),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Text(
                          pickup,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                      width: 2,
                      height: 20,
                      color: KoogweColors.darkTextTertiary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: KoogweColors.error, size: 24),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Text(
                          dropoff,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Informations du véhicule
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Véhicule',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: KoogweColors.primary.withValues(alpha: 0.1),
                          borderRadius: KoogweRadius.mdRadius,
                        ),
                        child: Center(
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.directions_car,
                              size: 40,
                              color: KoogweColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleType,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            if (driverName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Chauffeur : $driverName',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                              ),
                            ],
                            if (driverRating != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 16, color: KoogweColors.accent),
                                  Text(
                                    ' ${driverRating!.toStringAsFixed(1)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Détails du trajet
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.timer,
                    label: 'Durée estimée',
                    value: '$estimatedDuration min',
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '12.5 km', // Simulé
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.euro,
                    label: 'Prix estimé',
                    value: '${estimatedPrice.toStringAsFixed(2)}€',
                    isPrice: true,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Options activées
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                color: KoogweColors.primary.withValues(alpha: 0.1),
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(color: KoogweColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Options incluses',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: KoogweColors.primary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Wrap(
                    spacing: KoogweSpacing.sm,
                    runSpacing: KoogweSpacing.sm,
                    children: [
                      _OptionChip(icon: Icons.air, label: 'Climatisation'),
                      _OptionChip(icon: Icons.wifi, label: 'Wi-Fi'),
                      _OptionChip(icon: Icons.usb, label: 'Chargement USB'),
                      _OptionChip(icon: Icons.music_note, label: 'Musique'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xxxl),

            KoogweButton(
              text: 'Confirmer la réservation',
              icon: Icons.check_circle,
              onPressed: () {
                context.go('/passenger/ride-tracking');
              },
              isFullWidth: true,
              size: ButtonSize.large,
              variant: ButtonVariant.gradient,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPrice;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: isPrice ? KoogweColors.primary : KoogweColors.darkTextSecondary, size: 24),
        const SizedBox(width: KoogweSpacing.md),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isPrice ? KoogweColors.primary : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OptionChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: KoogweColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: KoogweColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

