import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/animated_vehicle_widget.dart';

/// Widget de carte avec trajet simulé interactif
class InteractiveRideCard extends StatelessWidget {
  final String from;
  final String to;
  final String estimatedTime;
  final String estimatedPrice;
  final VoidCallback? onTap;

  const InteractiveRideCard({
    super.key,
    required this.from,
    required this.to,
    required this.estimatedTime,
    required this.estimatedPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              KoogweColors.primary.withValues(alpha: 0.1),
              KoogweColors.secondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: KoogweRadius.lgRadius,
          border: Border.all(
            color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KoogweColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.route, color: KoogweColors.primary, size: 20),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        from,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        to,
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
              ],
            ),
            const SizedBox(height: KoogweSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: KoogweColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      estimatedTime,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark
                            ? KoogweColors.darkTextSecondary
                            : KoogweColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  estimatedPrice,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KoogweColors.primary,
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

/// Widget d'estimation tarifaire en direct
class LivePriceEstimator extends StatefulWidget {
  final VehicleType vehicleType;
  final double distance;
  final Function(double)? onPriceChanged;

  const LivePriceEstimator({
    super.key,
    this.vehicleType = VehicleType.economy,
    this.distance = 5.0,
    this.onPriceChanged,
  });

  @override
  State<LivePriceEstimator> createState() => _LivePriceEstimatorState();
}

class _LivePriceEstimatorState extends State<LivePriceEstimator> {
  late double _price;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  void _calculatePrice() {
    // Simulation de calcul de prix basé sur le type de véhicule et la distance
    final basePrice = 2.5;
    final pricePerKm = switch (widget.vehicleType) {
      VehicleType.economy => 1.2,
      VehicleType.comfort => 1.8,
      VehicleType.premium => 2.5,
      VehicleType.suv => 2.0,
      VehicleType.motorcycle => 1.0,
      VehicleType.taxi => 1.5,
      VehicleType.electric => 1.3,
      VehicleType.minibus => 3.0,
      VehicleType.luxury => 4.0,
    };

    setState(() {
      _price = basePrice + (widget.distance * pricePerKm);
      widget.onPriceChanged?.call(_price);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
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
          Row(
            children: [
              Icon(Icons.euro, color: KoogweColors.accent, size: 20),
              const SizedBox(width: KoogweSpacing.sm),
              Text(
                'Estimation tarifaire',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? KoogweColors.darkTextPrimary
                      : KoogweColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Text(
            '${_price.toStringAsFixed(2)} €',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: KoogweColors.primary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.xs),
          Text(
            'Pour ${widget.distance.toStringAsFixed(1)} km',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? KoogweColors.darkTextSecondary
                  : KoogweColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de statistiques personnelles animées
class PersonalStatsWidget extends StatelessWidget {
  final int totalRides;
  final double totalSpent;
  final double carbonSaved;
  final int currentStreak;

  const PersonalStatsWidget({
    super.key,
    this.totalRides = 0,
    this.totalSpent = 0.0,
    this.carbonSaved = 0.0,
    this.currentStreak = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KoogweColors.secondary.withValues(alpha: 0.1),
            KoogweColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos statistiques',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? KoogweColors.darkTextPrimary
                  : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.directions_car,
                  label: 'Courses',
                  value: totalRides.toString(),
                  color: KoogweColors.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.euro,
                  label: 'Dépensé',
                  value: '${totalSpent.toStringAsFixed(0)}€',
                  color: KoogweColors.secondary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.eco,
                  label: 'CO₂ sauvé',
                  value: '${carbonSaved.toStringAsFixed(1)}kg',
                  color: KoogweColors.success,
                ),
              ),
            ],
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: KoogweSpacing.md),
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.md),
              decoration: BoxDecoration(
                color: KoogweColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: KoogweColors.accent),
                  const SizedBox(width: KoogweSpacing.sm),
                  Text(
                    'Série de $currentStreak jours !',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KoogweColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: KoogweSpacing.xs),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? KoogweColors.darkTextPrimary
                : KoogweColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark
                ? KoogweColors.darkTextSecondary
                : KoogweColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget de recommandations intelligentes
class SmartRecommendationsWidget extends StatelessWidget {
  final List<Recommendation> recommendations;

  const SmartRecommendationsWidget({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommandations',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? KoogweColors.darkTextPrimary
                : KoogweColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: KoogweSpacing.md),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: KoogweSpacing.md),
                padding: const EdgeInsets.all(KoogweSpacing.md),
                decoration: BoxDecoration(
                  color: recommendation.color.withValues(alpha: 0.1),
                  borderRadius: KoogweRadius.mdRadius,
                  border: Border.all(
                    color: recommendation.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: recommendation.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(recommendation.icon, color: recommendation.color),
                    ),
                    const SizedBox(width: KoogweSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            recommendation.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? KoogweColors.darkTextPrimary
                                  : KoogweColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation.description,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? KoogweColors.darkTextSecondary
                                  : KoogweColors.lightTextSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Recommendation {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  Recommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

