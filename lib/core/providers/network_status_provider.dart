import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

enum NetworkStatus { online, offline, weak, loading }

// Note: connectivity_plus package required for full functionality
// For now, using simulated network status

class NetworkStatusState {
  final NetworkStatus status;
  final bool isCached;
  final String? cacheMessage;

  NetworkStatusState({
    this.status = NetworkStatus.loading,
    this.isCached = false,
    this.cacheMessage,
  });

  NetworkStatusState copyWith({
    NetworkStatus? status,
    bool? isCached,
    String? cacheMessage,
  }) {
    return NetworkStatusState(
      status: status ?? this.status,
      isCached: isCached ?? this.isCached,
      cacheMessage: cacheMessage ?? this.cacheMessage,
    );
  }
}

class NetworkStatusNotifier extends Notifier<NetworkStatusState> {

  @override
  NetworkStatusState build() {
    _initNetworkMonitoring();
    return NetworkStatusState(status: NetworkStatus.online);
  }

  void _initNetworkMonitoring() {
    // Simuler la vérification du statut réseau
    // TODO: Intégrer avec connectivity_plus une fois le package installé
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // Simulation: Par défaut en ligne, peut être modifié pour tester
      if (state.status == NetworkStatus.online) {
        // Simulation d'un réseau faible occasionnellement
        // En production, cela utiliserait connectivity_plus
      }
    });
  }

  void setNetworkStatus(NetworkStatus status) {
    String? message;
    bool isCached = false;

    if (status == NetworkStatus.offline) {
      message = 'Mode hors ligne activé. Vos données seront synchronisées lors de la reconnexion.';
      isCached = true;
    } else if (status == NetworkStatus.weak) {
      message = 'Connexion mobile détectée. Mode cache activé pour améliorer les performances.';
      isCached = true;
    }

    state = state.copyWith(
      status: status,
      isCached: isCached,
      cacheMessage: message,
    );
  }

  Future<bool> saveToCache(String key, dynamic data) async {
    // Simuler la sauvegarde en cache
    if (state.status == NetworkStatus.offline || state.status == NetworkStatus.weak) {
      // TODO: Implémenter le stockage local réel
      return true;
    }
    return false;
  }

}

final networkStatusProvider = NotifierProvider<NetworkStatusNotifier, NetworkStatusState>(
  NetworkStatusNotifier.new,
);

