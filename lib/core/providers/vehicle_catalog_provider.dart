import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VehicleType {
  economic,
  comfort,
  premium,
  suv,
  motorcycle,
  electric,
  hybrid,
  utility,
  business,
}

enum VehicleStatus { active, inactive, maintenance, pending }

class VehiclePhoto {
  final String id;
  final String url;
  final String type; // front, back, left, right, interior, dashboard, trunk, details
  final DateTime uploadDate;

  VehiclePhoto({
    required this.id,
    required this.url,
    required this.type,
    required this.uploadDate,
  });
}

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final VehicleType type;
  final VehicleStatus status;
  final int passengerCapacity;
  final int luggageCapacity;
  final String fuelType;
  final double fuelConsumption;
  final List<String> features;
  final List<VehiclePhoto> photos;
  final double basePrice;
  final String? driverId;
  final DateTime? lastMaintenance;
  final DateTime registrationDate;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.type,
    this.status = VehicleStatus.active,
    required this.passengerCapacity,
    required this.luggageCapacity,
    required this.fuelType,
    required this.fuelConsumption,
    this.features = const [],
    this.photos = const [],
    required this.basePrice,
    this.driverId,
    this.lastMaintenance,
    required this.registrationDate,
  });

  bool get hasMinimumPhotos => photos.length >= 6;
  bool get isPremium => type == VehicleType.premium || type == VehicleType.electric;
}

class VehicleCatalogState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final bool isLoading;
  final String? error;

  VehicleCatalogState({
    this.vehicles = const [],
    this.selectedVehicle,
    this.isLoading = false,
    this.error,
  });

  VehicleCatalogState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    bool? isLoading,
    String? error,
  }) {
    return VehicleCatalogState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class VehicleCatalogNotifier extends Notifier<VehicleCatalogState> {
  @override
  VehicleCatalogState build() {
    _loadVehicles();
    return VehicleCatalogState();
  }

  Future<void> _loadVehicles() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final vehicles = [
      Vehicle(
        id: '1',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2022,
        color: 'Blanc',
        licensePlate: 'GF-123-AB',
        type: VehicleType.comfort,
        status: VehicleStatus.active,
        passengerCapacity: 4,
        luggageCapacity: 2,
        fuelType: 'Essence',
        fuelConsumption: 6.5,
        features: ['Climatisation', 'Wi-Fi', 'Chargement USB'],
        photos: List.generate(6, (i) => VehiclePhoto(
          id: 'photo_$i',
          url: 'assets/vehicles/toyota_corolla_$i.jpg',
          type: ['front', 'back', 'left', 'right', 'interior', 'dashboard'][i],
          uploadDate: DateTime.now().subtract(Duration(days: 10 - i)),
        )),
        basePrice: 15.0,
        registrationDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Vehicle(
        id: '2',
        brand: 'Tesla',
        model: 'Model 3',
        year: 2023,
        color: 'Noir',
        licensePlate: 'GF-456-CD',
        type: VehicleType.electric,
        status: VehicleStatus.active,
        passengerCapacity: 5,
        luggageCapacity: 3,
        fuelType: 'Électrique',
        fuelConsumption: 0.0,
        features: ['Climatisation', 'Wi-Fi', 'Autopilot', 'Écran tactile'],
        photos: List.generate(8, (i) => VehiclePhoto(
          id: 'photo_${i + 10}',
          url: 'assets/vehicles/tesla_model3_$i.jpg',
          type: ['front', 'back', 'left', 'right', 'interior', 'dashboard', 'trunk', 'details'][i],
          uploadDate: DateTime.now().subtract(Duration(days: 5 - i)),
        )),
        basePrice: 25.0,
        registrationDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    state = state.copyWith(
      vehicles: vehicles,
      isLoading: false,
    );
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      vehicles: [...state.vehicles, vehicle],
      isLoading: false,
    );

    return true;
  }

  Future<bool> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      vehicles: state.vehicles.map((v) => v.id == vehicleId ? updatedVehicle : v).toList(),
      isLoading: false,
    );

    return true;
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      vehicles: state.vehicles.where((v) => v.id != vehicleId).toList(),
      isLoading: false,
    );

    return true;
  }

  Future<bool> addVehiclePhoto(String vehicleId, VehiclePhoto photo) async {
    final vehicles = state.vehicles.map((v) {
      if (v.id == vehicleId) {
        return Vehicle(
          id: v.id,
          brand: v.brand,
          model: v.model,
          year: v.year,
          color: v.color,
          licensePlate: v.licensePlate,
          type: v.type,
          status: v.status,
          passengerCapacity: v.passengerCapacity,
          luggageCapacity: v.luggageCapacity,
          fuelType: v.fuelType,
          fuelConsumption: v.fuelConsumption,
          features: v.features,
          photos: [...v.photos, photo],
          basePrice: v.basePrice,
          driverId: v.driverId,
          lastMaintenance: v.lastMaintenance,
          registrationDate: v.registrationDate,
        );
      }
      return v;
    }).toList();

    state = state.copyWith(vehicles: vehicles);
    return true;
  }
}

final vehicleCatalogProvider = NotifierProvider<VehicleCatalogNotifier, VehicleCatalogState>(
  VehicleCatalogNotifier.new,
);

