import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/services/rides_service.dart';
import 'package:latlong2/latlong.dart';

class RideModel {
  final String id;
  final String pickup;
  final String dropoff;
  final String vehicleType;
  final String status;
  final double? estimatedPrice;
  final DateTime createdAt;
  final String? driverId;
  final String? passengerId;
  final String? driverPhone;
  final String? passengerPhone;
  final String? pickupAddress;
  final String? dropoffAddress;
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;

  RideModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
    required this.status,
    required this.createdAt,
    this.estimatedPrice,
    this.driverId,
    this.passengerId,
    this.driverPhone,
    this.passengerPhone,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLocation,
    this.dropoffLocation,
  });

  factory RideModel.fromMap(Map<String, dynamic> m) {
    final driver = m['driver'] as Map<String, dynamic>?;
    final passenger = m['passenger'] as Map<String, dynamic>?;
    
    LatLng? pickupLocation;
    if (m['pickup_lat'] != null && m['pickup_lng'] != null) {
      pickupLocation = LatLng(
        (m['pickup_lat'] as num).toDouble(),
        (m['pickup_lng'] as num).toDouble(),
      );
    }
    
    LatLng? dropoffLocation;
    if (m['dropoff_lat'] != null && m['dropoff_lng'] != null) {
      dropoffLocation = LatLng(
        (m['dropoff_lat'] as num).toDouble(),
        (m['dropoff_lng'] as num).toDouble(),
      );
    }
    
    return RideModel(
      id: (m['id'] ?? '').toString(),
      pickup: (m['pickup_text'] ?? m['pickup_address'] ?? '').toString(),
      dropoff: (m['dropoff_text'] ?? m['dropoff_address'] ?? '').toString(),
      vehicleType: (m['vehicle_type'] ?? 'unknown').toString(),
      status: (m['status'] ?? 'requested').toString(),
      estimatedPrice: (m['estimated_price'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse((m['created_at'] ?? '').toString()) ?? DateTime.now(),
      driverId: (m['driver_id'] ?? driver?['id'] ?? '').toString(),
      passengerId: (m['user_id'] ?? m['passenger_id'] ?? passenger?['id'] ?? '').toString(),
      driverPhone: driver?['phone_number']?.toString(),
      passengerPhone: passenger?['phone_number']?.toString(),
      pickupAddress: (m['pickup_text'] ?? m['pickup_address'] ?? '').toString(),
      dropoffAddress: (m['dropoff_text'] ?? m['dropoff_address'] ?? '').toString(),
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
    );
  }
}

class RideState {
  final List<RideModel> history;
  final RideModel? current;
  final String? pickupDraft;
  final String? dropoffDraft;
  final String? vehicleDraft;
  final LatLng? pickupLocationDraft;
  final LatLng? dropoffLocationDraft;
  final bool isLoading;
  final String? error;

  RideState({
    this.history = const [],
    this.current,
    this.pickupDraft,
    this.dropoffDraft,
    this.vehicleDraft,
    this.pickupLocationDraft,
    this.dropoffLocationDraft,
    this.isLoading = false,
    this.error,
  });

  RideState copyWith({
    List<RideModel>? history,
    RideModel? current,
    String? pickupDraft,
    String? dropoffDraft,
    String? vehicleDraft,
    LatLng? pickupLocationDraft,
    LatLng? dropoffLocationDraft,
    bool? isLoading,
    String? error,
  }) => RideState(
        history: history ?? this.history,
        current: current ?? this.current,
        pickupDraft: pickupDraft ?? this.pickupDraft,
        dropoffDraft: dropoffDraft ?? this.dropoffDraft,
        vehicleDraft: vehicleDraft ?? this.vehicleDraft,
        pickupLocationDraft: pickupLocationDraft ?? this.pickupLocationDraft,
        dropoffLocationDraft: dropoffLocationDraft ?? this.dropoffLocationDraft,
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

  void setDraft({
    String? pickup,
    String? dropoff,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
  }) {
    state = state.copyWith(
      pickupDraft: pickup ?? state.pickupDraft,
      dropoffDraft: dropoff ?? state.dropoffDraft,
      pickupLocationDraft: pickupLocation ?? state.pickupLocationDraft,
      dropoffLocationDraft: dropoffLocation ?? state.dropoffLocationDraft,
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
      pickupLat: state.pickupLocationDraft?.latitude,
      pickupLng: state.pickupLocationDraft?.longitude,
      dropoffLat: state.dropoffLocationDraft?.latitude,
      dropoffLng: state.dropoffLocationDraft?.longitude,
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
        pickupLocation: state.pickupLocationDraft,
        dropoffLocation: state.dropoffLocationDraft,
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
  RideModel copyWith({
    String? status,
    String? driverId,
    String? passengerId,
    String? driverPhone,
    String? passengerPhone,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
  }) => RideModel(
        id: id,
        pickup: pickup,
        dropoff: dropoff,
        vehicleType: vehicleType,
        status: status ?? this.status,
        createdAt: createdAt,
        estimatedPrice: estimatedPrice,
        driverId: driverId ?? this.driverId,
        passengerId: passengerId ?? this.passengerId,
        driverPhone: driverPhone ?? this.driverPhone,
        passengerPhone: passengerPhone ?? this.passengerPhone,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      );
}

final rideProvider = NotifierProvider<RideNotifier, RideState>(RideNotifier.new);
