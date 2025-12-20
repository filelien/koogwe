import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DisputeStatus { pending, inReview, resolved, rejected }
enum DisputeCategory { price, route, driver, vehicle, other }

class Dispute {
  final String id;
  final DisputeCategory category;
  final String title;
  final String description;
  final DisputeStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final double? refundAmount;
  final String rideId;

  Dispute({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.status = DisputeStatus.pending,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
    this.refundAmount,
    required this.rideId,
  });
}

class DisputeState {
  final List<Dispute> disputes;
  final bool isLoading;
  final String? error;

  DisputeState({
    this.disputes = const [],
    this.isLoading = false,
    this.error,
  });

  DisputeState copyWith({
    List<Dispute>? disputes,
    bool? isLoading,
    String? error,
  }) {
    return DisputeState(
      disputes: disputes ?? this.disputes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DisputeNotifier extends Notifier<DisputeState> {
  @override
  DisputeState build() {
    _loadDisputes();
    return DisputeState();
  }

  Future<void> _loadDisputes() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    state = state.copyWith(
      disputes: [
        Dispute(
          id: '1',
          category: DisputeCategory.price,
          title: 'Prix incorrect',
          description: 'Le prix facturé ne correspond pas au tarif affiché lors de la réservation.',
          status: DisputeStatus.inReview,
          createdAt: now.subtract(const Duration(days: 2)),
          rideId: 'ride_123',
        ),
        Dispute(
          id: '2',
          category: DisputeCategory.route,
          title: 'Itinéraire plus long',
          description: 'Le chauffeur a pris un itinéraire beaucoup plus long que prévu.',
          status: DisputeStatus.resolved,
          createdAt: now.subtract(const Duration(days: 5)),
          resolvedAt: now.subtract(const Duration(days: 4)),
          resolution: 'Remboursement de 5€ effectué',
          refundAmount: 5.0,
          rideId: 'ride_456',
        ),
      ],
      isLoading: false,
    );
  }

  Future<bool> createDispute({
    required DisputeCategory category,
    required String title,
    required String description,
    required String rideId,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final dispute = Dispute(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      rideId: rideId,
    );
    
    state = state.copyWith(
      disputes: [dispute, ...state.disputes],
      isLoading: false,
    );
    
    return true;
  }
}

final disputeProvider = NotifierProvider<DisputeNotifier, DisputeState>(
  DisputeNotifier.new,
);

