import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/animated_vehicle_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleTypeSelector extends StatefulWidget {
  final VehicleType selectedType;
  final ValueChanged<VehicleType>? onTypeChanged;

  const VehicleTypeSelector({
    super.key,
    this.selectedType = VehicleType.economy,
    this.onTypeChanged,
  });

  @override
  State<VehicleTypeSelector> createState() => _VehicleTypeSelectorState();
}

class _VehicleTypeSelectorState extends State<VehicleTypeSelector> {
  late VehicleType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  final Map<VehicleType, Map<String, dynamic>> _vehicleTypes = {
    VehicleType.economy: {
      'name': 'Économique',
      'icon': Icons.directions_car,
      'color': KoogweColors.success,
      'emoji': '🚗',
    },
    VehicleType.comfort: {
      'name': 'Confort',
      'icon': Icons.directions_car,
      'color': KoogweColors.secondary,
      'emoji': '🚘',
    },
    VehicleType.premium: {
      'name': 'Premium',
      'icon': Icons.directions_car,
      'color': KoogweColors.primary,
      'emoji': '⭐',
    },
    VehicleType.suv: {
      'name': 'SUV',
      'icon': Icons.airport_shuttle,
      'color': KoogweColors.accent,
      'emoji': '🚙',
    },
    VehicleType.motorcycle: {
      'name': 'Moto',
      'icon': Icons.two_wheeler,
      'color': KoogweColors.warning,
      'emoji': '🏍️',
    },
    VehicleType.taxi: {
      'name': 'Taxi',
      'icon': Icons.local_taxi,
      'color': Colors.yellow.shade700,
      'emoji': '🚕',
    },
    VehicleType.electric: {
      'name': 'Électrique',
      'icon': Icons.electric_car,
      'color': Colors.green.shade400,
      'emoji': '⚡',
    },
    VehicleType.minibus: {
      'name': 'Minibus',
      'icon': Icons.directions_bus,
      'color': KoogweColors.info,
      'emoji': '🚐',
    },
    VehicleType.luxury: {
      'name': 'Luxe',
      'icon': Icons.sports_motorsports,
      'color': Colors.purple.shade300,
      'emoji': '🏎️',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated vehicle preview
        AnimatedVehicleWidget(
          vehicleType: _selectedType,
          height: 180,
          showRoad: true,
        ).animate().fadeIn().scale(),

        const SizedBox(height: KoogweSpacing.lg),

        // Vehicle type chips
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _vehicleTypes.length,
            itemBuilder: (context, index) {
              final type = _vehicleTypes.keys.elementAt(index);
              final data = _vehicleTypes[type]!;
              final isSelected = _selectedType == type;

              return Padding(
                padding: const EdgeInsets.only(right: KoogweSpacing.md),
                child: _VehicleTypeChip(
                  emoji: data['emoji'] as String,
                  name: data['name'] as String,
                  color: data['color'] as Color,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                    widget.onTypeChanged?.call(type);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VehicleTypeChip extends StatelessWidget {
  final String emoji;
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleTypeChip({
    required this.emoji,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.mdRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.symmetric(
          horizontal: KoogweSpacing.md,
          vertical: KoogweSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
          borderRadius: KoogweRadius.mdRadius,
          border: Border.all(
            color: isSelected ? color : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: KoogweSpacing.xs),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? color
                    : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

