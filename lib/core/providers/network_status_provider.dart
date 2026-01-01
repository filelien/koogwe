import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum NetworkStatus { online, offline, weak, loading }

class NetworkStatusState {
  final NetworkStatus status;
  final bool isCached;
  final String? cacheMessage;
  final ConnectivityResult? connectivityResult;

  NetworkStatusState({
    this.status = NetworkStatus.loading,
    this.isCached = false,
    this.cacheMessage,
    this.connectivityResult,
  });

  NetworkStatusState copyWith({
    NetworkStatus? status,
    bool? isCached,
    String? cacheMessage,
    ConnectivityResult? connectivityResult,
  }) {
    return NetworkStatusState(
      status: status ?? this.status,
      isCached: isCached ?? this.isCached,
      cacheMessage: cacheMessage ?? this.cacheMessage,
      connectivityResult: connectivityResult ?? this.connectivityResult,
    );
  }
}

class NetworkStatusNotifier extends Notifier<NetworkStatusState> {
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  @override
  NetworkStatusState build() {
    _initNetworkMonitoring();
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });
    return NetworkStatusState(status: NetworkStatus.loading);
  }

  void _initNetworkMonitoring() async {
    // Vérifier le statut initial
    await _checkConnectivity();

    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateNetworkStatus(result);
      },
      onError: (error) {
        debugPrint('[NetworkStatus] Erreur monitoring: $error');
        state = state.copyWith(status: NetworkStatus.offline);
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateNetworkStatus(result);
    } catch (e) {
      debugPrint('[NetworkStatus] Erreur vérification: $e');
      state = state.copyWith(status: NetworkStatus.offline);
    }
  }

  void _updateNetworkStatus(ConnectivityResult result) {
    
    NetworkStatus newStatus;
    String? message;
    bool isCached = false;

    switch (result) {
      case ConnectivityResult.wifi:
        newStatus = NetworkStatus.online;
        message = null;
        isCached = false;
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        newStatus = NetworkStatus.online;
        message = 'Connexion mobile détectée. Mode cache activé pour améliorer les performances.';
        isCached = true;
        break;
      case ConnectivityResult.none:
        newStatus = NetworkStatus.offline;
        message = 'Mode hors ligne activé. Vos données seront synchronisées lors de la reconnexion.';
        isCached = true;
        break;
      default:
        newStatus = NetworkStatus.weak;
        message = 'Connexion instable détectée.';
        isCached = true;
    }

    state = state.copyWith(
      status: newStatus,
      isCached: isCached,
      cacheMessage: message,
      connectivityResult: result,
    );
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
    try {
      if (state.status == NetworkStatus.offline || state.status == NetworkStatus.weak) {
        final prefs = await SharedPreferences.getInstance();
        final jsonData = jsonEncode(data);
        return await prefs.setString('cache_$key', jsonData);
      }
      return false;
    } catch (e) {
      debugPrint('[NetworkStatus] Erreur sauvegarde cache: $e');
      return false;
    }
  }

  Future<dynamic> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('cache_$key');
      if (jsonData != null) {
        return jsonDecode(jsonData);
      }
      return null;
    } catch (e) {
      debugPrint('[NetworkStatus] Erreur récupération cache: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('[NetworkStatus] Erreur nettoyage cache: $e');
    }
  }
}

final networkStatusProvider = NotifierProvider<NetworkStatusNotifier, NetworkStatusState>(
  NetworkStatusNotifier.new,
);

