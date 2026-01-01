import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/services/pricing_service.dart';
import 'package:koogwe/core/services/admin_service.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminPricingScreen extends ConsumerStatefulWidget {
  const AdminPricingScreen({super.key});

  @override
  ConsumerState<AdminPricingScreen> createState() => _AdminPricingScreenState();
}

class _AdminPricingScreenState extends ConsumerState<AdminPricingScreen> {
  final PricingService _pricingService = PricingService();
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _pricingSettings = [];
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadPricingSettings();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPricingSettings() async {
    setState(() => _isLoading = true);
    try {
      final isAdmin = await _adminService.isAdmin();
      if (!isAdmin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Accès refusé. Admin uniquement.')),
          );
          context.pop();
        }
        return;
      }

      final settings = await _pricingService.getAllPricingSettings();
      
      // Si aucune configuration n'existe, créer des valeurs par défaut
      if (settings.isEmpty) {
        debugPrint('[AdminPricing] No pricing settings found, using defaults');
        // Les valeurs par défaut seront créées lors de la première sauvegarde
        setState(() {
          _pricingSettings = [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _pricingSettings = settings;
          // Initialiser les controllers
          for (var setting in settings) {
            final vehicleType = setting['vehicle_type'] as String;
            _controllers['${vehicleType}_base'] ??= TextEditingController(
              text: ((setting['base_price'] as num?) ?? 2.5).toStringAsFixed(2),
            );
            _controllers['${vehicleType}_per_km'] ??= TextEditingController(
              text: ((setting['price_per_km'] as num?) ?? 1.5).toStringAsFixed(2),
            );
            _controllers['${vehicleType}_min'] ??= TextEditingController(
              text: ((setting['minimum_price'] as num?) ?? 5.0).toStringAsFixed(2),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[AdminPricing] Error loading settings: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _savePricingSetting(Map<String, dynamic> setting) async {
    try {
      final vehicleType = setting['vehicle_type'] as String;
      final basePrice = double.tryParse(
            _controllers['${vehicleType}_base']?.text.replaceAll(',', '.') ?? '0',
          ) ??
          0.0;
      final pricePerKm = double.tryParse(
            _controllers['${vehicleType}_per_km']?.text.replaceAll(',', '.') ?? '0',
          ) ??
          0.0;
      final minimumPrice = double.tryParse(
            _controllers['${vehicleType}_min']?.text.replaceAll(',', '.') ?? '0',
          ) ??
          0.0;
      final isActive = setting['is_active'] as bool? ?? true;

      if (basePrice <= 0 || pricePerKm <= 0 || minimumPrice <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez entrer des valeurs valides (> 0)')),
          );
        }
        return;
      }

      final success = await _pricingService.updatePricingSettings(
        vehicleType: vehicleType,
        basePrice: basePrice,
        pricePerKm: pricePerKm,
        minimumPrice: minimumPrice,
        isActive: isActive,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prix mis à jour pour $vehicleType'),
            backgroundColor: KoogweColors.success,
          ),
        );
        await _loadPricingSettings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    } catch (e) {
      debugPrint('[AdminPricing] Error saving: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Prix'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPricingSettings,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: KoogweSpacing.md),
                  Text(
                    'Chargement des configurations...',
                    style: GoogleFonts.inter(
                      color: isDark
                          ? KoogweColors.darkTextSecondary
                          : KoogweColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPricingSettings,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;
                  return ListView(
                    padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                    children: [
                      // En-tête
                      Text(
                        'Configuration des Prix par Kilomètre',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.sm),
                      Text(
                        'Configurez les prix de base, prix par kilomètre et prix minimum pour chaque type de véhicule',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: isDark
                              ? KoogweColors.darkTextSecondary
                              : KoogweColors.lightTextSecondary,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: KoogweSpacing.xl),

                      // Liste des paramètres de prix
                      if (_pricingSettings.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attach_money_outlined,
                                size: 64,
                                color: isDark
                                    ? KoogweColors.darkTextTertiary
                                    : KoogweColors.lightTextTertiary,
                              ),
                              const SizedBox(height: KoogweSpacing.md),
                              Text(
                                'Aucune configuration de prix',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? KoogweColors.darkTextSecondary
                                      : KoogweColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: KoogweSpacing.sm),
                              Text(
                                'Les configurations de prix seront créées automatiquement lors de la première utilisation',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark
                                      ? KoogweColors.darkTextTertiary
                                      : KoogweColors.lightTextTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._pricingSettings.map((setting) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md,
                            ),
                            child: _PricingSettingCard(
                              setting: setting,
                              controllers: _controllers,
                              onSave: () => _savePricingSetting(setting),
                              isDark: isDark,
                              isCompact: isSmallScreen,
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                          );
                        }),

                      const SizedBox(height: KoogweSpacing.xl),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class _PricingSettingCard extends StatefulWidget {
  final Map<String, dynamic> setting;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onSave;
  final bool isDark;
  final bool isCompact;

  const _PricingSettingCard({
    required this.setting,
    required this.controllers,
    required this.onSave,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  State<_PricingSettingCard> createState() => _PricingSettingCardState();
}

class _PricingSettingCardState extends State<_PricingSettingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final vehicleType = widget.setting['vehicle_type'] as String;
    final isActive = widget.setting['is_active'] as bool? ?? true;

    return GlassCard(
      padding: EdgeInsets.all(widget.isCompact ? KoogweSpacing.md : KoogweSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom du véhicule
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: KoogweSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            vehicleType,
                            style: GoogleFonts.inter(
                              fontSize: widget.isCompact ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? KoogweColors.darkTextPrimary
                                  : KoogweColors.lightTextPrimary,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isCompact ? 6 : 8,
                              vertical: widget.isCompact ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? KoogweColors.success.withValues(alpha: 0.2)
                                  : KoogweColors.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Actif' : 'Inactif',
                              style: GoogleFonts.inter(
                                fontSize: widget.isCompact ? 10 : 11,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? KoogweColors.success
                                    : KoogweColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!widget.isCompact) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Prix actuel: Base ${((widget.setting['base_price'] as num?) ?? 2.5).toStringAsFixed(2)}€ + ${((widget.setting['price_per_km'] as num?) ?? 1.5).toStringAsFixed(2)}€/km (Min: ${((widget.setting['minimum_price'] as num?) ?? 5.0).toStringAsFixed(2)}€)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: widget.isDark
                                ? KoogweColors.darkTextSecondary
                                : KoogweColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: widget.isDark
                      ? KoogweColors.darkTextSecondary
                      : KoogweColors.lightTextSecondary,
                ),
              ],
            ),
          ),

          // Formulaire (expandable)
          if (_isExpanded) ...[
            const SizedBox(height: KoogweSpacing.lg),
            const Divider(),
            const SizedBox(height: KoogweSpacing.lg),

            // Prix de base
            KoogweTextField(
              controller: widget.controllers['${vehicleType}_base'],
              label: 'Prix de base (€)',
              hint: '2.50',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.euro),
            ),
            const SizedBox(height: KoogweSpacing.md),

            // Prix par kilomètre
            KoogweTextField(
              controller: widget.controllers['${vehicleType}_per_km'],
              label: 'Prix par kilomètre (€/km)',
              hint: '1.50',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.straighten),
            ),
            const SizedBox(height: KoogweSpacing.md),

            // Prix minimum
            KoogweTextField(
              controller: widget.controllers['${vehicleType}_min'],
              label: 'Prix minimum (€)',
              hint: '5.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            const SizedBox(height: KoogweSpacing.lg),

            // Bouton sauvegarder
            KoogweButton(
              text: 'Enregistrer les modifications',
              onPressed: widget.onSave,
              icon: Icons.save,
            ),
          ],
        ],
      ),
    );
  }
}

