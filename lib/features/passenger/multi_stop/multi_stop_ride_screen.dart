import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MultiStopRideScreen extends ConsumerStatefulWidget {
  const MultiStopRideScreen({super.key});

  @override
  ConsumerState<MultiStopRideScreen> createState() => _MultiStopRideScreenState();
}

class _MultiStopRideScreenState extends ConsumerState<MultiStopRideScreen> {
  final List<StopLocation> _stops = [
    StopLocation(
      id: '1',
      address: 'Adresse de départ',
      isPickup: true,
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
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Trajet avec arrêts',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  children: [
                    // Instructions
                    GlassCard(
                      borderRadius: KoogweRadius.lgRadius,
                      child: Padding(
                        padding: const EdgeInsets.all(KoogweSpacing.md),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: KoogweColors.primary, size: 24),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: Text(
                                'Ajoutez jusqu\'à 3 arrêts supplémentaires à votre trajet',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),

                    const SizedBox(height: KoogweSpacing.xl),

                    // Liste des arrêts
                    ..._stops.asMap().entries.map((entry) {
                      final index = entry.key;
                      final stop = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                        child: GlassCard(
                          borderRadius: KoogweRadius.lgRadius,
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: stop.isPickup
                                    ? KoogweColors.success.withValues(alpha: 0.15)
                                    : KoogweColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                stop.isPickup ? Icons.my_location : Icons.location_on,
                                color: stop.isPickup ? KoogweColors.success : KoogweColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              stop.isPickup ? 'Départ' : 'Arrêt $index',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            subtitle: Text(
                              stop.address,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                            trailing: stop.isPickup
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      setState(() {
                                        _stops.removeAt(index);
                                      });
                                    },
                                    color: KoogweColors.error,
                                  ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1, end: 0);
                    }),

                    // Bouton ajouter arrêt
                    if (_stops.length < 4)
                      OutlinedButton.icon(
                        onPressed: () => _addStop(),
                        icon: const Icon(Icons.add_location),
                        label: const Text('Ajouter un arrêt'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: KoogweColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.md),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                  ],
                ),
              ),

              // Bouton de confirmation
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
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
                    text: 'Confirmer le trajet',
                    icon: Icons.check_circle,
                    onPressed: () {
                      // TODO: Créer le trajet avec arrêts multiples
                      context.pop();
                    },
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addStop() {
    setState(() {
      _stops.add(StopLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        address: 'Nouvel arrêt ${_stops.length}',
        isPickup: false,
      ));
    });
  }
}

class StopLocation {
  final String id;
  final String address;
  final bool isPickup;

  StopLocation({
    required this.id,
    required this.address,
    required this.isPickup,
  });
}

