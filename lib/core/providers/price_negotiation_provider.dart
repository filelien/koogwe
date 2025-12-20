import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NegotiationStatus { waiting, negotiating, accepted, rejected, expired }

class PriceOffer {
  final String id;
  final double amount;
  final DateTime timestamp;
  final bool isFromPassenger;

  PriceOffer({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.isFromPassenger,
  });
}

class PriceNegotiation {
  final String id;
  final double initialPrice;
  final double suggestedPrice;
  final NegotiationStatus status;
  final List<PriceOffer> offers;
  final String? driverId;

  PriceNegotiation({
    required this.id,
    required this.initialPrice,
    required this.suggestedPrice,
    this.status = NegotiationStatus.waiting,
    this.offers = const [],
    this.driverId,
  });

  PriceNegotiation copyWith({
    String? id,
    double? initialPrice,
    double? suggestedPrice,
    NegotiationStatus? status,
    List<PriceOffer>? offers,
    String? driverId,
  }) {
    return PriceNegotiation(
      id: id ?? this.id,
      initialPrice: initialPrice ?? this.initialPrice,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      status: status ?? this.status,
      offers: offers ?? this.offers,
      driverId: driverId ?? this.driverId,
    );
  }
}

class PriceNegotiationState {
  final PriceNegotiation? currentNegotiation;
  final bool isLoading;
  final String? error;

  PriceNegotiationState({
    this.currentNegotiation,
    this.isLoading = false,
    this.error,
  });

  PriceNegotiationState copyWith({
    PriceNegotiation? currentNegotiation,
    bool? isLoading,
    String? error,
  }) {
    return PriceNegotiationState(
      currentNegotiation: currentNegotiation ?? this.currentNegotiation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PriceNegotiationNotifier extends Notifier<PriceNegotiationState> {
  @override
  PriceNegotiationState build() {
    return PriceNegotiationState();
  }

  Future<bool> startNegotiation({
    required double initialPrice,
    required double suggestedPrice,
    required String pickup,
    required String dropoff,
  }) async {
    state = state.copyWith(isLoading: true);
    
    // Simuler la création d'une négociation
    await Future.delayed(const Duration(milliseconds: 800));
    
    final negotiation = PriceNegotiation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      initialPrice: initialPrice,
      suggestedPrice: suggestedPrice,
      status: NegotiationStatus.waiting,
      offers: [
        PriceOffer(
          id: '1',
          amount: suggestedPrice,
          timestamp: DateTime.now(),
          isFromPassenger: true,
        ),
      ],
    );
    
    state = state.copyWith(
      currentNegotiation: negotiation,
      isLoading: false,
    );
    
    return true;
  }

  Future<bool> submitCounterOffer(double amount, bool isFromPassenger) async {
    if (state.currentNegotiation == null) return false;
    
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    
    final newOffer = PriceOffer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now(),
      isFromPassenger: isFromPassenger,
    );
    
    final updatedNegotiation = state.currentNegotiation!.copyWith(
      suggestedPrice: amount,
      status: NegotiationStatus.negotiating,
      offers: [...state.currentNegotiation!.offers, newOffer],
    );
    
    state = state.copyWith(
      currentNegotiation: updatedNegotiation,
      isLoading: false,
    );
    
    return true;
  }

  Future<bool> acceptOffer() async {
    if (state.currentNegotiation == null) return false;
    
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    final updatedNegotiation = state.currentNegotiation!.copyWith(
      status: NegotiationStatus.accepted,
    );
    
    state = state.copyWith(
      currentNegotiation: updatedNegotiation,
      isLoading: false,
    );
    
    return true;
  }

  Future<void> rejectNegotiation() async {
    if (state.currentNegotiation == null) return;
    
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    
    final updatedNegotiation = state.currentNegotiation!.copyWith(
      status: NegotiationStatus.rejected,
    );
    
    state = state.copyWith(
      currentNegotiation: updatedNegotiation,
      isLoading: false,
    );
  }

  void clearNegotiation() {
    state = PriceNegotiationState();
  }
}

final priceNegotiationProvider = NotifierProvider<PriceNegotiationNotifier, PriceNegotiationState>(
  PriceNegotiationNotifier.new,
);

