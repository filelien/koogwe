import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServiceType {
  passengerTransport,
  packageDelivery,
  quickDelivery,
  businessTransport,
}

class ServiceTypeState {
  final ServiceType selectedService;
  final bool isLoading;

  ServiceTypeState({
    this.selectedService = ServiceType.passengerTransport,
    this.isLoading = false,
  });

  ServiceTypeState copyWith({
    ServiceType? selectedService,
    bool? isLoading,
  }) {
    return ServiceTypeState(
      selectedService: selectedService ?? this.selectedService,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ServiceTypeNotifier extends Notifier<ServiceTypeState> {
  @override
  ServiceTypeState build() {
    return ServiceTypeState();
  }

  void setServiceType(ServiceType type) {
    state = state.copyWith(selectedService: type);
  }
}

final serviceTypeProvider = NotifierProvider<ServiceTypeNotifier, ServiceTypeState>(
  ServiceTypeNotifier.new,
);

