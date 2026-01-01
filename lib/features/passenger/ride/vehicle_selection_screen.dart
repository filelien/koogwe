import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/services/pricing_service.dart';
import 'package:koogwe/core/router/app_router.dart';

class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends ConsumerState<VehicleSelectionScreen> {
  int _selectedVehicle = 0;
  String _selectedPaymentMethod = 'CASH';
  bool _setEvent = false;
  bool _calculatingPrices = false;
  final PricingService _pricingService = PricingService();
  Map<String, double> _calculatedPrices = {};
  Map<String, int> _calculatedDurations = {};

  final List<Vehicle> _vehicles = [
    Vehicle(
      name: 'CAR',
      description: 'Économique et abordable',
      price: '4.30',
      eta: '3 min',
      icon: Icons.directions_car,
      color: KoogweColors.vehicleEconomy,
    ),
    Vehicle(
      name: 'MOTO',
      description: 'Rapide et maniable',
      price: '4.00',
      eta: '2 min',
      icon: Icons.two_wheeler,
      color: KoogweColors.vehicleComfort,
    ),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePricesForAllVehicles();
    });
  }

  Future<void> _calculatePricesForAllVehicles() async {
    final rideState = ref.read(rideProvider);
    final pickupLocation = rideState.pickupLocationDraft;
    final dropoffLocation = rideState.dropoffLocationDraft;

    if (pickupLocation == null || dropoffLocation == null) {
      // Si pas de locations, utiliser les prix par défaut
      return;
    }

    setState(() => _calculatingPrices = true);

    try {
      for (var vehicle in _vehicles) {
        final priceDetails = await _pricingService.calculatePrice(
          pickupLocation: pickupLocation,
          dropoffLocation: dropoffLocation,
          vehicleType: vehicle.name,
        );

        setState(() {
          _calculatedPrices[vehicle.name] = priceDetails['price'] as double;
          _calculatedDurations[vehicle.name] = priceDetails['duration_min'] as int;
        });
      }
    } catch (e) {
      debugPrint('[VehicleSelection] Error calculating prices: $e');
    } finally {
      setState(() => _calculatingPrices = false);
    }
  }

  String _getPriceForVehicle(Vehicle vehicle) {
    if (_calculatedPrices.containsKey(vehicle.name)) {
      return '${_calculatedPrices[vehicle.name]!.toStringAsFixed(2)}€';
    }
    return vehicle.price;
  }

  String _getEtaForVehicle(Vehicle vehicle) {
    if (_calculatedDurations.containsKey(vehicle.name)) {
      return '${_calculatedDurations[vehicle.name]} min';
    }
    return vehicle.eta;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choisir un véhicule',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(horizontalPadding),
              itemCount: _vehicles.length,
              separatorBuilder: (_, __) => SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final isSelected = _selectedVehicle == index;
                
                return InkWell(
                  onTap: () => setState(() => _selectedVehicle = index),
                  borderRadius: KoogweRadius.lgRadius,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? KoogweColors.primary.withValues(alpha: 0.1)
                          : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
                      borderRadius: KoogweRadius.lgRadius,
                      border: Border.all(
                        color: isSelected
                            ? KoogweColors.primary
                            : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 60 : 70,
                          height: isSmallScreen ? 60 : 70,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? KoogweColors.primary
                                : vehicle.color.withValues(alpha: 0.15),
                            borderRadius: KoogweRadius.mdRadius,
                          ),
                          child: Icon(
                            vehicle.icon,
                            size: isSmallScreen ? 30 : 36,
                            color: isSelected ? Colors.white : vehicle.color,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.name,
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? KoogweColors.primary
                                      : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vehicle.description,
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _calculatingPrices && !_calculatedPrices.containsKey(vehicle.name)
                                ? SizedBox(
                                    width: isSmallScreen ? 16 : 20,
                                    height: isSmallScreen ? 16 : 20,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _getPriceForVehicle(vehicle),
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 18 : 20,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? KoogweColors.primary : KoogweColors.primary,
                                    ),
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              _getEtaForVehicle(vehicle),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: KoogweSpacing.md),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: KoogweColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Section SET EVENT - Responsive
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SET EVENT',
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  Switch(
                    value: _setEvent,
                    onChanged: (value) => setState(() => _setEvent = value),
                    activeTrackColor: KoogweColors.primary.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_setEvent)
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, KoogweSpacing.md, horizontalPadding, 0),
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Ouvrir modal pour ajouter des paramètres d'événement
                },
                icon: Icon(Icons.settings, size: isSmallScreen ? 18 : 20),
                label: Text(
                  'ADD SETTINGS',
                  style: GoogleFonts.inter(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KoogweColors.primary,
                  side: BorderSide(color: KoogweColors.primary),
                  padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                ),
              ),
            ),
          
          SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
          
          // Sélection méthode de paiement - Responsive
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
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
                    'PAY WITH',
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentMethodOption(
                          label: 'CASH',
                          icon: Icons.account_balance_wallet,
                          isSelected: _selectedPaymentMethod == 'CASH',
                          onTap: () => setState(() => _selectedPaymentMethod = 'CASH'),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                      Expanded(
                        child: _PaymentMethodOption(
                          label: 'CARD',
                          icon: Icons.credit_card,
                          isSelected: _selectedPaymentMethod == 'CARD',
                          onTap: () => setState(() => _selectedPaymentMethod = 'CARD'),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
          
          Container(
            padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.xl),
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
                text: 'CONFIRM YOUR ORDER',
                onPressed: () async {
                  final vehicle = _vehicles[_selectedVehicle];
                  ref.read(rideProvider.notifier).setVehicleDraft(vehicle.name);
                  
                  // Utiliser le prix calculé si disponible, sinon extraire du prix par défaut
                  double price;
                  int duration;
                  
                  if (_calculatedPrices.containsKey(vehicle.name)) {
                    price = _calculatedPrices[vehicle.name]!;
                    duration = _calculatedDurations[vehicle.name] ?? 20;
                  } else {
                    final priceStr = vehicle.price.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
                    price = double.tryParse(priceStr) ?? 0.0;
                    duration = int.tryParse(vehicle.eta.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;
                  }
                  
                  await ref.read(rideProvider.notifier).createRideFromDraft(estimatedPrice: price);
                  if (context.mounted) {
                    final pickup = ref.read(rideProvider).pickupDraft ?? '';
                    final dropoff = ref.read(rideProvider).dropoffDraft ?? '';
                    context.push('${AppRoutes.ridePreview}?vehicleType=${Uri.encodeComponent(vehicle.name)}&pickup=${Uri.encodeComponent(pickup)}&dropoff=${Uri.encodeComponent(dropoff)}&price=$price&duration=$duration&driverName=James Smith Myers&driverRating=4.5&driverStoreAddress=Midnight transportation store&carModel=Toyota Camry&carNumber=23-10-00');
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

class _PaymentMethodOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _PaymentMethodOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.mdRadius,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? KoogweColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: KoogweRadius.mdRadius,
          border: Border.all(
            color: isSelected
                ? KoogweColors.primary
                : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? KoogweColors.primary
                  : (isDark
                      ? KoogweColors.darkTextSecondary
                      : KoogweColors.lightTextSecondary),
              size: isSmallScreen ? 18 : 20,
            ),
            SizedBox(width: isSmallScreen ? 4 : KoogweSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  color: isSelected
                      ? KoogweColors.primary
                      : (isDark
                          ? KoogweColors.darkTextPrimary
                          : KoogweColors.lightTextPrimary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
