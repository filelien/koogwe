import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduledRide {
  final String id;
  final DateTime scheduledDateTime;
  final String pickup;
  final String dropoff;
  final String vehicleType;
  final double estimatedPrice;
  final bool isActive;
  final DateTime? reminderTime;

  ScheduledRide({
    required this.id,
    required this.scheduledDateTime,
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
    required this.estimatedPrice,
    this.isActive = true,
    this.reminderTime,
  });
}

class ScheduledRideState {
  final List<ScheduledRide> rides;
  final bool isLoading;
  final String? error;

  ScheduledRideState({
    this.rides = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduledRideState copyWith({
    List<ScheduledRide>? rides,
    bool? isLoading,
    String? error,
  }) {
    return ScheduledRideState(
      rides: rides ?? this.rides,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ScheduledRideNotifier extends Notifier<ScheduledRideState> {
  @override
  ScheduledRideState build() {
    _loadScheduledRides();
    return ScheduledRideState();
  }

  Future<void> _loadScheduledRides() async {
    state = state.copyWith(isLoading: true);
    // Simuler un chargement
    await Future.delayed(const Duration(seconds: 1));
    
    // Données simulées réalistes
    final now = DateTime.now();
    state = state.copyWith(
      rides: [
        ScheduledRide(
          id: '1',
          scheduledDateTime: now.add(const Duration(days: 1, hours: 2)),
          pickup: 'Aéroport Félix Éboué, Cayenne',
          dropoff: 'Centre-ville, Cayenne',
          vehicleType: 'Confort',
          estimatedPrice: 25.50,
          reminderTime: now.add(const Duration(days: 1)),
        ),
        ScheduledRide(
          id: '2',
          scheduledDateTime: now.add(const Duration(days: 3)),
          pickup: 'Kourou',
          dropoff: 'Sinnamary',
          vehicleType: 'Éco',
          estimatedPrice: 35.00,
          reminderTime: now.add(const Duration(days: 3, hours: -1)),
        ),
      ],
      isLoading: false,
    );
  }

  Future<bool> scheduleRide({
    required DateTime scheduledDateTime,
    required String pickup,
    required String dropoff,
    required String vehicleType,
    required double estimatedPrice,
    DateTime? reminderTime,
  }) async {
    state = state.copyWith(isLoading: true);
    
    // Simuler l'ajout
    await Future.delayed(const Duration(seconds: 1));
    
    final newRide = ScheduledRide(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scheduledDateTime: scheduledDateTime,
      pickup: pickup,
      dropoff: dropoff,
      vehicleType: vehicleType,
      estimatedPrice: estimatedPrice,
      reminderTime: reminderTime,
    );
    
    state = state.copyWith(
      rides: [newRide, ...state.rides],
      isLoading: false,
    );
    
    return true;
  }

  Future<bool> cancelScheduledRide(String rideId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    state = state.copyWith(
      rides: state.rides.where((r) => r.id != rideId).toList(),
      isLoading: false,
    );
    
    return true;
  }

  Future<bool> modifyScheduledRide(
    String rideId, {
    DateTime? scheduledDateTime,
    String? pickup,
    String? dropoff,
    String? vehicleType,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    final rides = state.rides.map((ride) {
      if (ride.id == rideId) {
        return ScheduledRide(
          id: ride.id,
          scheduledDateTime: scheduledDateTime ?? ride.scheduledDateTime,
          pickup: pickup ?? ride.pickup,
          dropoff: dropoff ?? ride.dropoff,
          vehicleType: vehicleType ?? ride.vehicleType,
          estimatedPrice: ride.estimatedPrice,
          reminderTime: ride.reminderTime,
        );
      }
      return ride;
    }).toList();
    
    state = state.copyWith(
      rides: rides,
      isLoading: false,
    );
    
    return true;
  }
}

final scheduledRideProvider = NotifierProvider<ScheduledRideNotifier, ScheduledRideState>(
  ScheduledRideNotifier.new,
);

