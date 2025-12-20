import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/vehicle_catalog_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleCatalogScreen extends ConsumerWidget {
  const VehicleCatalogScreen({super.key});

  String _getVehicleTypeName(VehicleType type) {
    switch (type) {
      case VehicleType.economic:
        return 'Économique';
      case VehicleType.comfort:
        return 'Confort';
      case VehicleType.premium:
        return 'Premium';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.motorcycle:
        return 'Moto';
      case VehicleType.electric:
        return 'Électrique';
      case VehicleType.hybrid:
        return 'Hybride';
      case VehicleType.utility:
        return 'Utilitaire';
      case VehicleType.business:
        return 'Entreprise';
    }
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return KoogweColors.success;
      case VehicleStatus.inactive:
        return KoogweColors.darkTextTertiary;
      case VehicleStatus.maintenance:
        return KoogweColors.accent;
      case VehicleStatus.pending:
        return KoogweColors.primary;
    }
  }

  String _getStatusText(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return 'Actif';
      case VehicleStatus.inactive:
        return 'Inactif';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.pending:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(vehicleCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Véhicules'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/driver/vehicles/add'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.vehicles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                      ),
                      const SizedBox(height: KoogweSpacing.lg),
                      Text(
                        'Aucun véhicule enregistré',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      KoogweButton(
                        text: 'Ajouter un véhicule',
                        icon: Icons.add,
                        onPressed: () => context.push('/driver/vehicles/add'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(KoogweSpacing.xl),
                  children: [
                    Text(
                      'Mes véhicules (${state.vehicles.length})',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    const SizedBox(height: KoogweSpacing.lg),
                    ...state.vehicles.map((vehicle) => _VehicleCard(
                      vehicle: vehicle,
                      vehicleTypeName: _getVehicleTypeName(vehicle.type),
                      statusColor: _getStatusColor(vehicle.status),
                      statusText: _getStatusText(vehicle.status),
                    )),
                  ],
                ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final String vehicleTypeName;
  final Color statusColor;
  final String statusText;

  const _VehicleCard({
    required this.vehicle,
    required this.vehicleTypeName,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.lg),
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
          // Photos du véhicule
          if (vehicle.photos.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: vehicle.photos.length,
                itemBuilder: (context, index) {
                  final photo = vehicle.photos[index];
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      color: KoogweColors.primary.withValues(alpha: 0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 48, color: KoogweColors.primary),
                            const SizedBox(height: KoogweSpacing.sm),
                            Text(
                              photo.type,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: KoogweColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '$vehicleTypeName • ${vehicle.year}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KoogweSpacing.md),
                Container(
                  padding: const EdgeInsets.all(KoogweSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant,
                    borderRadius: KoogweRadius.mdRadius,
                  ),
                  child: Row(
                    children: [
                      _VehicleInfo(
                        icon: Icons.people,
                        label: 'Passagers',
                        value: '${vehicle.passengerCapacity}',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                        margin: const EdgeInsets.symmetric(horizontal: KoogweSpacing.md),
                      ),
                      _VehicleInfo(
                        icon: Icons.luggage,
                        label: 'Bagages',
                        value: '${vehicle.luggageCapacity}',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                        margin: const EdgeInsets.symmetric(horizontal: KoogweSpacing.md),
                      ),
                      _VehicleInfo(
                        icon: vehicle.fuelType == 'Électrique' ? Icons.bolt : Icons.local_gas_station,
                        label: vehicle.fuelType,
                        value: vehicle.fuelConsumption > 0
                            ? '${vehicle.fuelConsumption.toStringAsFixed(1)}L/100km'
                            : '0',
                      ),
                    ],
                  ),
                ),
                if (vehicle.features.isNotEmpty) ...[
                  const SizedBox(height: KoogweSpacing.md),
                  Wrap(
                    spacing: KoogweSpacing.sm,
                    runSpacing: KoogweSpacing.sm,
                    children: vehicle.features.map((feature) => Chip(
                      label: Text(feature, style: GoogleFonts.inter(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
                const SizedBox(height: KoogweSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: KoogweButton(
                        text: 'Modifier',
                        icon: Icons.edit,
                        onPressed: () {
                          // TODO: Ouvrir modal de modification
                        },
                        variant: ButtonVariant.outline,
                        size: ButtonSize.medium,
                      ),
                    ),
                    const SizedBox(width: KoogweSpacing.md),
                    Expanded(
                      child: KoogweButton(
                        text: 'Photos',
                        icon: Icons.photo_library,
                        onPressed: () {
                          // TODO: Ouvrir galerie photos
                        },
                        variant: ButtonVariant.outline,
                        size: ButtonSize.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VehicleInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: KoogweColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

