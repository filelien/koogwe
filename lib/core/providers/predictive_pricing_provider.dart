import 'package:flutter_riverpod/flutter_riverpod.dart';

class PricePrediction {
  final DateTime time;
  final double price;
  final double? savings;
  final String trafficLevel;
  final int estimatedDuration;

  PricePrediction({
    required this.time,
    required this.price,
    this.savings,
    required this.trafficLevel,
    required this.estimatedDuration,
  });
}

class PredictivePricingState {
  final double currentPrice;
  final List<PricePrediction> predictions;
  final DateTime? bestTime;
  final bool isLoading;

  PredictivePricingState({
    this.currentPrice = 0.0,
    this.predictions = const [],
    this.bestTime,
    this.isLoading = false,
  });

  PredictivePricingState copyWith({
    double? currentPrice,
    List<PricePrediction>? predictions,
    DateTime? bestTime,
    bool? isLoading,
  }) {
    return PredictivePricingState(
      currentPrice: currentPrice ?? this.currentPrice,
      predictions: predictions ?? this.predictions,
      bestTime: bestTime ?? this.bestTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PredictivePricingNotifier extends Notifier<PredictivePricingState> {
  @override
  PredictivePricingState build() {
    return PredictivePricingState();
  }

  Future<void> calculatePredictions({
    required String pickup,
    required String dropoff,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final predictions = [
      PricePrediction(
        time: now.add(const Duration(minutes: 0)),
        price: 25.50,
        savings: null,
        trafficLevel: 'Élevé',
        estimatedDuration: 25,
      ),
      PricePrediction(
        time: now.add(const Duration(minutes: 30)),
        price: 22.00,
        savings: 3.50,
        trafficLevel: 'Moyen',
        estimatedDuration: 20,
      ),
      PricePrediction(
        time: now.add(const Duration(hours: 1)),
        price: 18.50,
        savings: 7.00,
        trafficLevel: 'Faible',
        estimatedDuration: 18,
      ),
      PricePrediction(
        time: now.add(const Duration(hours: 2)),
        price: 20.00,
        savings: 5.50,
        trafficLevel: 'Moyen',
        estimatedDuration: 19,
      ),
    ];

    final bestPrediction = predictions.reduce((a, b) =>
        (b.savings ?? 0) > (a.savings ?? 0) ? b : a);

    state = state.copyWith(
      currentPrice: predictions.first.price,
      predictions: predictions,
      bestTime: bestPrediction.time,
      isLoading: false,
    );
  }
}

final predictivePricingProvider = NotifierProvider<PredictivePricingNotifier, PredictivePricingState>(
  PredictivePricingNotifier.new,
);

