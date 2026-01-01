import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PriceComparisonScreen extends StatefulWidget {
  final String pickup;
  final String dropoff;

  const PriceComparisonScreen({
    super.key,
    required this.pickup,
    required this.dropoff,
  });

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final List<VehicleOption> _vehicles = [
    VehicleOption(
      name: 'KOOGWE Eco',
      price: 12.50,
      eta: '3 min',
      features: ['Climatisation', 'Wi-Fi'],
      color: KoogweColors.vehicleEconomy,
    ),
    VehicleOption(
      name: 'KOOGWE Confort',
      price: 18.00,
      eta: '5 min',
      features: ['Climatisation', 'Wi-Fi', 'Espace supplémentaire'],
      color: KoogweColors.vehicleComfort,
    ),
    VehicleOption(
      name: 'KOOGWE Premium',
      price: 28.00,
      eta: '7 min',
      features: ['Climatisation', 'Wi-Fi', 'Espace supplémentaire', 'Service premium'],
      color: KoogweColors.vehiclePremium,
    ),
  ];

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
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Comparaison de prix',
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
              // Informations du trajet
              GlassCard(
                borderRadius: KoogweRadius.lgRadius,
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.my_location, color: KoogweColors.success, size: 20),
                          const SizedBox(width: KoogweSpacing.sm),
                          Expanded(
                            child: Text(
                              widget.pickup,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          width: 2,
                          height: 20,
                          color: KoogweColors.darkTextTertiary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: KoogweColors.error, size: 20),
                          const SizedBox(width: KoogweSpacing.sm),
                          Expanded(
                            child: Text(
                              widget.dropoff,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.xl),

              // Options de véhicules
              Text(
                'Options disponibles',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),

              ..._vehicles.map((vehicle) {
                final index = _vehicles.indexOf(vehicle);
                return Padding(
                  padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                  child: GlassCard(
                    borderRadius: KoogweRadius.lgRadius,
                    child: Padding(
                      padding: const EdgeInsets.all(KoogweSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: vehicle.color.withValues(alpha: 0.15),
                                  borderRadius: KoogweRadius.mdRadius,
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  color: vehicle.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: KoogweSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicle.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${vehicle.eta} • ${vehicle.features.length} avantages',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '€${vehicle.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: vehicle.color,
                                    ),
                                  ),
                                  Text(
                                    'Prix estimé',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                          Wrap(
                            spacing: KoogweSpacing.sm,
                            runSpacing: KoogweSpacing.xs,
                            children: vehicle.features.map((feature) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: vehicle.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  feature,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: vehicle.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleOption {
  final String name;
  final double price;
  final String eta;
  final List<String> features;
  final Color color;

  VehicleOption({
    required this.name,
    required this.price,
    required this.eta,
    required this.features,
    required this.color,
  });
}

