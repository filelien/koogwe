import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/ride_provider.dart';

class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends ConsumerState<VehicleSelectionScreen> {
  int _selectedVehicle = 0;

  final List<Vehicle> _vehicles = [
    Vehicle(
      name: 'KOOGWE Eco',
      description: 'Économique et abordable',
      price: '12 €',
      eta: '3 min',
      icon: Icons.directions_car,
      color: KoogweColors.vehicleEconomy,
    ),
    Vehicle(
      name: 'KOOGWE Confort',
      description: 'Confortable et spacieux',
      price: '18 €',
      eta: '5 min',
      icon: Icons.directions_car_filled,
      color: KoogweColors.vehicleComfort,
    ),
    Vehicle(
      name: 'KOOGWE Premium',
      description: 'Luxe et élégance',
      price: '28 €',
      eta: '7 min',
      icon: Icons.car_rental,
      color: KoogweColors.vehiclePremium,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un véhicule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              itemCount: _vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: KoogweSpacing.md),
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final isSelected = _selectedVehicle == index;
                
                return InkWell(
                  onTap: () => setState(() => _selectedVehicle = index),
                  borderRadius: KoogweRadius.lgRadius,
                  child: Container(
                    padding: const EdgeInsets.all(KoogweSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                      borderRadius: KoogweRadius.lgRadius,
                      border: Border.all(
                        color: isSelected
                            ? KoogweColors.primary
                            : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: vehicle.color.withValues(alpha: 0.1),
                            borderRadius: KoogweRadius.mdRadius,
                          ),
                          child: Icon(vehicle.icon, size: 32, color: vehicle.color),
                        ),
                        const SizedBox(width: KoogweSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                vehicle.description,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: KoogweSpacing.xs),
                              Text(
                                '${vehicle.eta} • ${vehicle.price}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: KoogweColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: KoogweColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(KoogweSpacing.xl),
            decoration: BoxDecoration(
              color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
            ),
            child: SafeArea(
              child: KoogweButton(
                text: 'Confirmer',
                onPressed: () async {
                  final vehicle = _vehicles[_selectedVehicle];
                  ref.read(rideProvider.notifier).setVehicleDraft(vehicle.name);
                  // Extract numeric price if possible
                  final price = double.tryParse(vehicle.price.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.')) ?? 0;
                  await ref.read(rideProvider.notifier).createRideFromDraft(estimatedPrice: price);
                  if (context.mounted) {
                    context.push('/passenger/ride-tracking');
                  }
                },
                isFullWidth: true,
                size: ButtonSize.large,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Vehicle {
  final String name;
  final String description;
  final String price;
  final String eta;
  final IconData icon;
  final Color color;

  Vehicle({
    required this.name,
    required this.description,
    required this.price,
    required this.eta,
    required this.icon,
    required this.color,
  });
}
