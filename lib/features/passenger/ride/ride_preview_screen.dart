import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/router/app_router.dart';
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
  final String? driverStoreAddress;
  final String? carModel;
  final String? carNumber;

  const RidePreviewScreen({
    super.key,
    required this.vehicleType,
    required this.pickup,
    required this.dropoff,
    required this.estimatedPrice,
    required this.estimatedDuration,
    this.driverName,
    this.driverRating,
    this.driverStoreAddress,
    this.carModel,
    this.carNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aperçu de la course',
          style: GoogleFonts.inter(fontSize: isSmallScreen ? 18 : 20),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du trajet - Responsive
            Container(
              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),
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
                      Icon(
                        Icons.my_location,
                        color: KoogweColors.success,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                      Expanded(
                        child: Text(
                          pickup,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: isSmallScreen ? 10 : 12),
                    child: Container(
                      width: 2,
                      height: isSmallScreen ? 16 : 20,
                      color: KoogweColors.darkTextTertiary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: KoogweColors.error,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                      Expanded(
                        child: Text(
                          dropoff,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),

            // Informations du véhicule - Responsive
            Container(
              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),
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
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? KoogweColors.darkTextPrimary
                          : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 60 : 80,
                        height: isSmallScreen ? 60 : 80,
                        decoration: BoxDecoration(
                          color: KoogweColors.primary.withValues(alpha: 0.1),
                          borderRadius: KoogweRadius.mdRadius,
                        ),
                        child: Center(
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: isSmallScreen ? 45 : 60,
                            height: isSmallScreen ? 45 : 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.directions_car,
                              size: isSmallScreen ? 30 : 40,
                              color: KoogweColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleType,
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? KoogweColors.darkTextPrimary
                                    : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            if (driverName != null) ...[
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                'Chauffeur : $driverName',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: isDark
                                      ? KoogweColors.darkTextSecondary
                                      : KoogweColors.lightTextSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (driverRating != null) ...[
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: isSmallScreen ? 14 : 16,
                                    color: KoogweColors.accent,
                                  ),
                                  Text(
                                    ' ${driverRating!.toStringAsFixed(1)}',
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 12 : 14,
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

            SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),

            // Détails du trajet - Responsive
            Container(
              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),
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
                    isSmallScreen: isSmallScreen,
                  ),
                  Divider(height: isSmallScreen ? 16 : 24),
                  _DetailRow(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '12.5 km', // Simulé
                    isSmallScreen: isSmallScreen,
                  ),
                  Divider(height: isSmallScreen ? 16 : 24),
                  _DetailRow(
                    icon: Icons.euro,
                    label: 'Prix estimé',
                    value: '${estimatedPrice.toStringAsFixed(2)}€',
                    isPrice: true,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),

            // Options activées - Responsive
            Container(
              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),
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
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: KoogweColors.primary,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                  Wrap(
                    spacing: isSmallScreen ? 6 : KoogweSpacing.sm,
                    runSpacing: isSmallScreen ? 6 : KoogweSpacing.sm,
                    children: [
                      _OptionChip(icon: Icons.air, label: 'Climatisation', isSmallScreen: isSmallScreen),
                      _OptionChip(icon: Icons.wifi, label: 'Wi-Fi', isSmallScreen: isSmallScreen),
                      _OptionChip(icon: Icons.usb, label: 'USB', isSmallScreen: isSmallScreen),
                      _OptionChip(icon: Icons.music_note, label: 'Musique', isSmallScreen: isSmallScreen),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxxl),

            KoogweButton(
              text: 'Confirmer la réservation',
              icon: Icons.check_circle,
              onPressed: () {
                context.go(AppRoutes.rideTracking);
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
  final bool isSmallScreen;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isPrice = false,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          color: isPrice
              ? KoogweColors.primary
              : KoogweColors.darkTextSecondary,
          size: isSmallScreen ? 20 : 24,
        ),
        SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 14 : 16,
              color: isDark
                  ? KoogweColors.darkTextSecondary
                  : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: isPrice
                ? KoogweColors.primary
                : (isDark
                    ? KoogweColors.darkTextPrimary
                    : KoogweColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSmallScreen;

  const _OptionChip({
    required this.icon,
    required this.label,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 14 : 16, color: KoogweColors.primary),
          SizedBox(width: isSmallScreen ? 3 : 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 11 : 12,
              color: KoogweColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

