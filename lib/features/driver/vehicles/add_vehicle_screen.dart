import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/providers/vehicle_catalog_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  VehicleType _selectedType = VehicleType.economic;
  int _seats = 4;
  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        brand: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
        color: _colorController.text.trim(),
        licensePlate: _plateController.text.trim(),
        type: _selectedType,
        passengerCapacity: _seats,
        luggageCapacity: 2,
        fuelType: 'Essence',
        fuelConsumption: 7.0,
        basePrice: 15.0,
        registrationDate: DateTime.now(),
      );
      
      await ref.read(vehicleCatalogProvider.notifier).addVehicle(vehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Véhicule ajouté avec succès')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg;

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
            'Ajouter un véhicule',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: isSmallScreen ? 18 : 20,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                  
                  // Type de véhicule
                  GlassCard(
                    padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                    borderRadius: KoogweRadius.lgRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type de véhicule',
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                        Wrap(
                          spacing: KoogweSpacing.sm,
                          runSpacing: KoogweSpacing.sm,
                          children: VehicleType.values.map((type) {
                            final isSelected = _selectedType == type;
                            return ChoiceChip(
                              label: Text(_getVehicleTypeName(type)),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedType = type);
                                }
                              },
                              selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: KoogweColors.primary,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  
                  SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                  
                  // Informations du véhicule
                  GlassCard(
                    padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                    borderRadius: KoogweRadius.lgRadius,
                    child: Column(
                      children: [
                        KoogweTextField(
                          controller: _makeController,
                          hint: 'Marque (ex: Toyota)',
                          prefixIcon: const Icon(Icons.directions_car),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la marque';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                        KoogweTextField(
                          controller: _modelController,
                          hint: 'Modèle (ex: Camry)',
                          prefixIcon: const Icon(Icons.car_rental),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le modèle';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: KoogweTextField(
                                controller: _yearController,
                                hint: 'Année',
                                prefixIcon: const Icon(Icons.calendar_today),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Année requise';
                                  }
                                  final year = int.tryParse(value);
                                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                                    return 'Année invalide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                            Expanded(
                              child: KoogweTextField(
                                controller: _colorController,
                                hint: 'Couleur',
                                prefixIcon: const Icon(Icons.color_lens),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Couleur requise';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                        KoogweTextField(
                          controller: _plateController,
                          hint: 'Plaque d\'immatriculation',
                          prefixIcon: const Icon(Icons.confirmation_number),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Plaque requise';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                        Row(
                          children: [
                            Text(
                              'Nombre de places: ',
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_seats > 1) {
                                  setState(() => _seats--);
                                }
                              },
                            ),
                            Text(
                              '$_seats',
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: KoogweColors.primary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (_seats < 8) {
                                  setState(() => _seats++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  
                  SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxl),
                  
                  KoogweButton(
                    text: 'Ajouter le véhicule',
                    icon: Icons.check,
                    onPressed: _isLoading ? null : _submit,
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  SizedBox(height: isSmallScreen ? KoogweSpacing.xl : KoogweSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
      default:
        return 'Autre';
    }
  }
}

