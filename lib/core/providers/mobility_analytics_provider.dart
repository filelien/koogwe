import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobilityStats {
  final double totalDistance;
  final double carbonEmissions;
  final double moneySaved;
  final int totalRides;
  final double averageRideDistance;
  final Map<String, double> monthlyDistance;
  final Map<String, double> monthlyEmissions;
  final Map<String, double> monthlySpending;

  MobilityStats({
    this.totalDistance = 0.0,
    this.carbonEmissions = 0.0,
    this.moneySaved = 0.0,
    this.totalRides = 0,
    this.averageRideDistance = 0.0,
    this.monthlyDistance = const {},
    this.monthlyEmissions = const {},
    this.monthlySpending = const {},
  });
}

class MobilityAnalyticsState {
  final MobilityStats? stats;
  final List<String> personalizedTips;
  final bool isLoading;

  MobilityAnalyticsState({
    this.stats,
    this.personalizedTips = const [],
    this.isLoading = false,
  });

  MobilityAnalyticsState copyWith({
    MobilityStats? stats,
    List<String>? personalizedTips,
    bool? isLoading,
  }) {
    return MobilityAnalyticsState(
      stats: stats ?? this.stats,
      personalizedTips: personalizedTips ?? this.personalizedTips,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MobilityAnalyticsNotifier extends Notifier<MobilityAnalyticsState> {
  @override
  MobilityAnalyticsState build() {
    _loadAnalytics();
    return MobilityAnalyticsState();
  }

  Future<void> _loadAnalytics() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final stats = MobilityStats(
      totalDistance: 1250.5,
      carbonEmissions: 245.8,
      moneySaved: 180.50,
      totalRides: 87,
      averageRideDistance: 14.4,
      monthlyDistance: {
        'Jan': 120.5,
        'Fév': 145.2,
        'Mar': 180.8,
        'Avr': 165.3,
        'Mai': 195.6,
        'Juin': 210.4,
      },
      monthlyEmissions: {
        'Jan': 24.1,
        'Fév': 29.0,
        'Mar': 36.2,
        'Avr': 33.1,
        'Mai': 39.1,
        'Juin': 42.1,
      },
      monthlySpending: {
        'Jan': 180.5,
        'Fév': 210.2,
        'Mar': 245.8,
        'Avr': 230.3,
        'Mai': 265.6,
        'Juin': 280.4,
      },
    );

    final tips = [
      'Vous avez économisé 180,50€ en utilisant le covoiturage ce mois-ci',
      'Vos trajets sont 15% plus écologiques que la moyenne',
      'Pensez à planifier vos trajets pour économiser encore plus',
      'Votre score écologique est excellent ! 🌱',
    ];

    state = state.copyWith(
      stats: stats,
      personalizedTips: tips,
      isLoading: false,
    );
  }
}

final mobilityAnalyticsProvider = NotifierProvider<MobilityAnalyticsNotifier, MobilityAnalyticsState>(
  MobilityAnalyticsNotifier.new,
);

