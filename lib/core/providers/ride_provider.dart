import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/services/rides_service.dart';

class RideModel {
  final String id;
  final String pickup;
  final String dropoff;
  final String vehicleType;
  final String status;
  final double? estimatedPrice;
  final DateTime createdAt;

  RideModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
    required this.status,
    required this.createdAt,
    this.estimatedPrice,
  });

  factory RideModel.fromMap(Map<String, dynamic> m) => RideModel(
        id: (m['id'] ?? '').toString(),
        pickup: (m['pickup_text'] ?? '').toString(),
        dropoff: (m['dropoff_text'] ?? '').toString(),
        vehicleType: (m['vehicle_type'] ?? 'unknown').toString(),
        status: (m['status'] ?? 'requested').toString(),
        estimatedPrice: (m['estimated_price'] as num?)?.toDouble(),
        createdAt: DateTime.tryParse((m['created_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

class RideState {
  final List<RideModel> history;
  final RideModel? current;
  final String? pickupDraft;
  final String? dropoffDraft;
  final String? vehicleDraft;
  final bool isLoading;
  final String? error;

  RideState({
    this.history = const [],
    this.current,
    this.pickupDraft,
    this.dropoffDraft,
    this.vehicleDraft,
    this.isLoading = false,
    this.error,
  });

  RideState copyWith({
    List<RideModel>? history,
    RideModel? current,
    String? pickupDraft,
    String? dropoffDraft,
    String? vehicleDraft,
    bool? isLoading,
    String? error,
  }) => RideState(
        history: history ?? this.history,
        current: current ?? this.current,
        pickupDraft: pickupDraft ?? this.pickupDraft,
        dropoffDraft: dropoffDraft ?? this.dropoffDraft,
        vehicleDraft: vehicleDraft ?? this.vehicleDraft,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

class RideNotifier extends Notifier<RideState> {
  final _svc = RidesService();

  @override
  RideState build() {
    return RideState();
  }

  void setDraft({String? pickup, String? dropoff}) {
    state = state.copyWith(
      pickupDraft: pickup ?? state.pickupDraft,
      dropoffDraft: dropoff ?? state.dropoffDraft,
    );
  }

  void setVehicleDraft(String vehicle) {
    state = state.copyWith(vehicleDraft: vehicle);
  }

  Future<void> createRideFromDraft({double estimatedPrice = 0}) async {
    final pickup = state.pickupDraft ?? '';
    final dropoff = state.dropoffDraft ?? '';
    final vehicle = state.vehicleDraft ?? 'eco';
    if (pickup.isEmpty || dropoff.isEmpty) {
      state = state.copyWith(error: 'Adresse manquante');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    final res = await _svc.createRide(
      pickup: pickup,
      dropoff: dropoff,
      vehicleType: vehicle,
      estimatedPrice: estimatedPrice,
    );
    if (res != null) {
      final model = RideModel.fromMap(res);
      state = state.copyWith(current: model, history: [model, ...state.history], isLoading: false);
    } else {
      debugPrint('[RideNotifier] createRideFromDraft failed; keeping local-only');
      final model = RideModel(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        pickup: pickup,
        dropoff: dropoff,
        vehicleType: vehicle,
        status: 'requested',
        estimatedPrice: estimatedPrice,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(current: model, history: [model, ...state.history], isLoading: false);
    }
  }

  Future<void> cancelCurrentRide() async {
    final current = state.current;
    if (current == null) return;
    state = state.copyWith(isLoading: true);
    final ok = await _svc.cancelRide(current.id);
    if (ok) {
      final updated = current.copyWith(status: 'cancelled');
      final hist = state.history.map((r) => r.id == current.id ? updated : r).toList();
      state = state.copyWith(current: updated, history: hist, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    final list = await _svc.listMyRides();
    final mapped = list.map(RideModel.fromMap).toList();
    state = state.copyWith(history: mapped, isLoading: false);
  }
}

extension on RideModel {
  RideModel copyWith({String? status}) => RideModel(
        id: id,
        pickup: pickup,
        dropoff: dropoff,
        vehicleType: vehicleType,
        status: status ?? this.status,
        createdAt: createdAt,
        estimatedPrice: estimatedPrice,
      );
}

final rideProvider = NotifierProvider<RideNotifier, RideState>(RideNotifier.new);
