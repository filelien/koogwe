import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReputationScore {
  final double overallScore;
  final int totalRides;
  final double punctualityScore;
  final double cancellationRate;
  final double ratingAverage;
  final int badgesCount;
  final List<String> badges;

  ReputationScore({
    this.overallScore = 0.0,
    this.totalRides = 0,
    this.punctualityScore = 0.0,
    this.cancellationRate = 0.0,
    this.ratingAverage = 0.0,
    this.badgesCount = 0,
    this.badges = const [],
  });
}

class ReputationState {
  final ReputationScore? score;
  final bool isLoading;
  final String? error;

  ReputationState({
    this.score,
    this.isLoading = false,
    this.error,
  });

  ReputationState copyWith({
    ReputationScore? score,
    bool? isLoading,
    String? error,
  }) {
    return ReputationState(
      score: score ?? this.score,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReputationNotifier extends Notifier<ReputationState> {
  @override
  ReputationState build() {
    _loadReputation();
    return ReputationState();
  }

  Future<void> _loadReputation() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    
    // Données simulées réalistes
    state = state.copyWith(
      score: ReputationScore(
        overallScore: 4.8,
        totalRides: 147,
        punctualityScore: 96.5,
        cancellationRate: 2.1,
        ratingAverage: 4.8,
        badgesCount: 5,
        badges: [
          'Ponctuel',
          'Fiable',
          'Super hôte',
          'Rapide',
          'Éco-responsable',
        ],
      ),
      isLoading: false,
    );
  }
}

final reputationProvider = NotifierProvider<ReputationNotifier, ReputationState>(
  ReputationNotifier.new,
);

