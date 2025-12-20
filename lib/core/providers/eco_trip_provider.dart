import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EcoTripOption {
  final String id;
  final String type;
  final double carbonSavings;
  final double priceSavings;
  final int estimatedDuration;
  final bool isRecommended;
  final String description;

  EcoTripOption({
    required this.id,
    required this.type,
    required this.carbonSavings,
    required this.priceSavings,
    required this.estimatedDuration,
    this.isRecommended = false,
    required this.description,
  });
}

class EcoScore {
  final double score;
  final String level;
  final Color levelColor;
  final int totalEcoTrips;
  final double totalCarbonSaved;

  EcoScore({
    this.score = 0.0,
    this.level = 'Débutant',
    this.levelColor = const Color(0xFF9E9E9E),
    this.totalEcoTrips = 0,
    this.totalCarbonSaved = 0.0,
  });
}

class EcoTripState {
  final EcoScore? ecoScore;
  final List<EcoTripOption> availableOptions;
  final bool isLoading;

  EcoTripState({
    this.ecoScore,
    this.availableOptions = const [],
    this.isLoading = false,
  });

  EcoTripState copyWith({
    EcoScore? ecoScore,
    List<EcoTripOption>? availableOptions,
    bool? isLoading,
  }) {
    return EcoTripState(
      ecoScore: ecoScore ?? this.ecoScore,
      availableOptions: availableOptions ?? this.availableOptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EcoTripNotifier extends Notifier<EcoTripState> {
  @override
  EcoTripState build() {
    _loadEcoData();
    return EcoTripState();
  }

  Future<void> _loadEcoData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final ecoScore = EcoScore(
      score: 85.5,
      level: 'Expert',
      levelColor: const Color(0xFF4CAF50),
      totalEcoTrips: 45,
      totalCarbonSaved: 125.8,
    );

    final options = [
      EcoTripOption(
        id: '1',
        type: 'Covoiturage',
        carbonSavings: 2.5,
        priceSavings: 5.0,
        estimatedDuration: 20,
        isRecommended: true,
        description: 'Partagez votre trajet et réduisez votre empreinte carbone',
      ),
      EcoTripOption(
        id: '2',
        type: 'Véhicule électrique',
        carbonSavings: 3.2,
        priceSavings: 3.5,
        estimatedDuration: 18,
        description: 'Véhicule 100% électrique, zéro émission',
      ),
      EcoTripOption(
        id: '3',
        type: 'Véhicule hybride',
        carbonSavings: 1.8,
        priceSavings: 2.0,
        estimatedDuration: 19,
        description: 'Combinaison essence/électrique optimisée',
      ),
    ];

    state = state.copyWith(
      ecoScore: ecoScore,
      availableOptions: options,
      isLoading: false,
    );
  }
}

final ecoTripProvider = NotifierProvider<EcoTripNotifier, EcoTripState>(
  EcoTripNotifier.new,
);

