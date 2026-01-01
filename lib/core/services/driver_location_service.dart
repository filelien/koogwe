import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:koogwe/core/services/location_service.dart';

/// Service pour synchroniser la position du chauffeur avec Supabase
class DriverLocationService {
  static final DriverLocationService _instance = DriverLocationService._internal();
  factory DriverLocationService() => _instance;
  DriverLocationService._internal();

  final _locationService = LocationService();
  StreamSubscription<LatLng>? _locationSubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;
  String? _driverId;

  /// Démarrer la synchronisation de la position du chauffeur
  Future<bool> startLocationSync(String driverId) async {
    try {
      _driverId = driverId;
      
      // Démarrer le suivi de position
      final trackingStarted = await _locationService.startLocationTracking();
      if (!trackingStarted) {
        debugPrint('[DriverLocationService] Impossible de démarrer le suivi de position');
        return false;
      }

      // Synchroniser immédiatement la position actuelle
      final currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation != null) {
        await _syncLocationToSupabase(currentLocation);
      }

      // Écouter les mises à jour de position
      _locationSubscription = _locationService.locationStream.listen(
        (location) {
          _syncLocationToSupabase(location);
        },
        onError: (error) {
          debugPrint('[DriverLocationService] Erreur stream position: $error');
        },
      );

      // Synchroniser périodiquement (toutes les 10 secondes) pour garantir la mise à jour
      _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final location = _locationService.lastKnownLocation;
        if (location != null) {
          await _syncLocationToSupabase(location);
        }
      });

      debugPrint('[DriverLocationService] Synchronisation démarrée pour chauffeur: $driverId');
      return true;
    } catch (e, st) {
      debugPrint('[DriverLocationService] Erreur démarrage synchronisation: $e\n$st');
      return false;
    }
  }

  /// Arrêter la synchronisation
  Future<void> stopLocationSync() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _syncTimer?.cancel();
    _syncTimer = null;
    _isSyncing = false;
    _driverId = null;
    await _locationService.stopLocationTracking();
    debugPrint('[DriverLocationService] Synchronisation arrêtée');
  }

  /// Synchroniser la position avec Supabase
  Future<void> _syncLocationToSupabase(LatLng location) async {
    if (_isSyncing || _driverId == null) return;

    _isSyncing = true;
    try {
      await Supabase.instance.client.from('driver_locations').upsert({
        'driver_id': _driverId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('[DriverLocationService] Position synchronisée: ${location.latitude}, ${location.longitude}');
    } catch (e, st) {
      debugPrint('[DriverLocationService] Erreur synchronisation position: $e\n$st');
    } finally {
      _isSyncing = false;
    }
  }

  /// Obtenir la position d'un chauffeur depuis Supabase
  Future<LatLng?> getDriverLocation(String driverId) async {
    try {
      final response = await Supabase.instance.client
          .from('driver_locations')
          .select('latitude, longitude')
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response != null) {
        final lat = response['latitude'] as num?;
        final lon = response['longitude'] as num?;
        if (lat != null && lon != null) {
          return LatLng(lat.toDouble(), lon.toDouble());
        }
      }
      return null;
    } catch (e, st) {
      debugPrint('[DriverLocationService] Erreur récupération position chauffeur: $e\n$st');
      return null;
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    stopLocationSync();
  }
}

