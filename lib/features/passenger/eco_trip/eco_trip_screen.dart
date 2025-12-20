import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/eco_trip_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class EcoTripScreen extends ConsumerWidget {
  const EcoTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(ecoTripProvider);

    if (state.isLoading || state.ecoScore == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mode Éco-Trajet')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ecoScore = state.ecoScore!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Éco-Trajet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score écologique
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF66BB6A),
                  ],
                ),
                borderRadius: KoogweRadius.lgRadius,
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: ecoScore.score / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            ecoScore.score.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ecoScore.level,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _EcoStat(
                        label: 'Trajets éco',
                        value: '${ecoScore.totalEcoTrips}',
                        icon: Icons.eco,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _EcoStat(
                        label: 'CO₂ économisé',
                        value: '${ecoScore.totalCarbonSaved.toStringAsFixed(1)} kg',
                        icon: Icons.air,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().scale(duration: 600.ms, curve: Curves.easeOutBack),

            const SizedBox(height: KoogweSpacing.xxxl),

            Text(
              'Options éco disponibles',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.lg),

            ...state.availableOptions.map((option) => _EcoOptionCard(
              option: option,
              onSelect: () {
                // TODO: Sélectionner l'option éco
                context.pop();
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _EcoStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _EcoStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: KoogweSpacing.xs),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _EcoOptionCard extends StatelessWidget {
  final EcoTripOption option;
  final VoidCallback onSelect;

  const _EcoOptionCard({
    required this.option,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: option.isRecommended
            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
            : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: option.isRecommended
              ? const Color(0xFF4CAF50)
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: option.isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 28),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.type,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (option.isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Recommandé',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      option.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Expanded(
                child: _EcoBenefit(
                  icon: Icons.air,
                  label: 'CO₂',
                  value: '-${option.carbonSavings.toStringAsFixed(1)} kg',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _EcoBenefit(
                  icon: Icons.euro,
                  label: 'Économie',
                  value: '-${option.priceSavings.toStringAsFixed(2)}€',
                  color: KoogweColors.primary,
                ),
              ),
              Expanded(
                child: _EcoBenefit(
                  icon: Icons.timer,
                  label: 'Durée',
                  value: '${option.estimatedDuration} min',
                  color: KoogweColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          KoogweButton(
            text: 'Choisir cette option',
            icon: Icons.check_circle,
            onPressed: onSelect,
            isFullWidth: true,
            variant: option.isRecommended ? ButtonVariant.gradient : ButtonVariant.outline,
            gradientColors: option.isRecommended
                ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                : null,
          ),
        ],
      ),
    );
  }
}

class _EcoBenefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EcoBenefit({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: KoogweRadius.mdRadius,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
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

