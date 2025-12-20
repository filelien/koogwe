import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/predictive_pricing_provider.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictivePricingScreen extends ConsumerStatefulWidget {
  const PredictivePricingScreen({super.key});

  @override
  ConsumerState<PredictivePricingScreen> createState() => _PredictivePricingScreenState();
}

class _PredictivePricingScreenState extends ConsumerState<PredictivePricingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Calculer les prédictions au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pickupController.text.isNotEmpty && _dropoffController.text.isNotEmpty) {
        ref.read(predictivePricingProvider.notifier).calculatePredictions(
          pickup: _pickupController.text,
          dropoff: _dropoffController.text,
        );
      }
    });
  }

  void _calculatePredictions() {
    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir les lieux de départ et d\'arrivée')),
      );
      return;
    }

    ref.read(predictivePricingProvider.notifier).calculatePredictions(
      pickup: _pickupController.text,
      dropoff: _dropoffController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(predictivePricingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prix Prédictif'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trouvez le meilleur moment',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Comparez les prix maintenant vs plus tard et économisez',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.xxxl),

            KoogweTextField(
              controller: _pickupController,
              hint: 'Lieu de départ',
              prefixIcon: Icon(Icons.my_location, color: KoogweColors.success),
              onChanged: (_) => _calculatePredictions(),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.lg),

            KoogweTextField(
              controller: _dropoffController,
              hint: 'Destination',
              prefixIcon: Icon(Icons.location_on, color: KoogweColors.error),
              onChanged: (_) => _calculatePredictions(),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            if (state.predictions.isNotEmpty) ...[
              // Meilleur moment
              if (state.bestTime != null)
                Container(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [KoogweColors.success, KoogweColors.success.withValues(alpha: 0.8)],
                    ),
                    borderRadius: KoogweRadius.lgRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.white, size: 32),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meilleur moment',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(state.bestTime!),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(),

              const SizedBox(height: KoogweSpacing.xxxl),

              // Graphique de comparaison
              Container(
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
                    Text(
                      'Évolution du prix',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.lg),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: state.predictions.map((p) => p.price).reduce((a, b) => a > b ? a : b) * 1.2,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < state.predictions.length) {
                                    return Text(
                                      DateFormat('HH:mm').format(state.predictions[index].time),
                                      style: GoogleFonts.inter(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}€',
                                    style: GoogleFonts.inter(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: state.predictions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final prediction = entry.value;
                            final isBest = prediction.time == state.bestTime;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: prediction.price,
                                  color: isBest ? KoogweColors.success : KoogweColors.primary,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.xxxl),

              // Liste des prédictions
              Text(
                'Comparaison détaillée',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.lg),
              ...state.predictions.map((prediction) => _PredictionCard(
                prediction: prediction,
                isBest: prediction.time == state.bestTime,
                currentPrice: state.currentPrice,
              )),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_down,
                      size: 64,
                      color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                    ),
                    const SizedBox(height: KoogweSpacing.lg),
                    Text(
                      'Entrez votre itinéraire pour voir les prédictions',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PricePrediction prediction;
  final bool isBest;
  final double currentPrice;

  const _PredictionCard({
    required this.prediction,
    required this.isBest,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isBest
            ? KoogweColors.success.withValues(alpha: 0.1)
            : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isBest
              ? KoogweColors.success
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: isBest ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(KoogweSpacing.md),
            decoration: BoxDecoration(
              color: isBest
                  ? KoogweColors.success.withValues(alpha: 0.2)
                  : KoogweColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBest ? Icons.star : Icons.access_time,
              color: isBest ? KoogweColors.success : KoogweColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: KoogweSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      timeFormat.format(prediction.time),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: KoogweSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: KoogweColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Meilleur',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.traffic, size: 14, color: _getTrafficColor(prediction.trafficLevel)),
                    const SizedBox(width: 4),
                    Text(
                      'Trafic ${prediction.trafficLevel.toLowerCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: KoogweSpacing.md),
                    Icon(Icons.timer, size: 14, color: KoogweColors.darkTextSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${prediction.estimatedDuration} min',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${prediction.price.toStringAsFixed(2)}€',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: KoogweColors.primary,
                ),
              ),
              if (prediction.savings != null && prediction.savings! > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: KoogweColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${prediction.savings!.toStringAsFixed(2)}€',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: KoogweColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getTrafficColor(String level) {
    switch (level) {
      case 'Faible':
        return KoogweColors.success;
      case 'Moyen':
        return KoogweColors.accent;
      case 'Élevé':
        return KoogweColors.error;
      default:
        return KoogweColors.darkTextSecondary;
    }
  }
}

