import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service centralisé pour la gestion de la géolocalisation
/// Gère les permissions, le suivi en temps réel, et le cache de position
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  LatLng? _lastKnownLocation;
  Position? _lastPosition;
  final _locationController = StreamController<LatLng>.broadcast();
  
  /// Stream de la position actuelle en temps réel
  Stream<LatLng> get locationStream => _locationController.stream;
  
  /// Dernière position connue
  LatLng? get lastKnownLocation => _lastKnownLocation;
  Position? get lastPosition => _lastPosition;

  /// Vérifier et demander les permissions de localisation
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Les services de localisation sont désactivés');
        return false;
      }

      // Vérifier les permissions avec permission_handler
      PermissionStatus status = await Permission.location.status;
      
      if (status.isDenied) {
        status = await Permission.location.request();
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('[LocationService] Permissions définitivement refusées');
        return false;
      }

      if (status.isGranted || status.isLimited) {
        // Vérifier aussi avec Geolocator pour compatibilité
        LocationPermission geolocatorPermission = await Geolocator.checkPermission();
        if (geolocatorPermission == LocationPermission.denied) {
          geolocatorPermission = await Geolocator.requestPermission();
        }
        
        if (geolocatorPermission == LocationPermission.deniedForever) {
          debugPrint('[LocationService] Permissions définitivement refusées (Geolocator)');
          return false;
        }
        
        return geolocatorPermission != LocationPermission.denied;
      }

      return false;
    } catch (e, st) {
      debugPrint('[LocationService] Erreur vérification permissions: $e\n$st');
      return false;
    }
  }

  /// Obtenir la position actuelle une seule fois
  Future<LatLng?> getCurrentLocation({bool highAccuracy = true}) async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('[LocationService] Pas de permission pour obtenir la position');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: highAccuracy 
              ? LocationAccuracy.high 
              : LocationAccuracy.medium,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      _lastKnownLocation = location;
      _lastPosition = position;
      
      debugPrint('[LocationService] Position obtenue: ${location.latitude}, ${location.longitude}');
      return location;
    } catch (e, st) {
      debugPrint('[LocationService] Erreur obtention position: $e\n$st');
      return _lastKnownLocation; // Retourner la dernière position connue en cas d'erreur
    }
  }

  /// Démarrer le suivi de position en temps réel
  Future<bool> startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Mètres
  }) async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('[LocationService] Pas de permission pour le suivi');
        return false;
      }

      // Arrêter le suivi précédent s'il existe
      await stopLocationTracking();

      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
          timeLimit: const Duration(seconds: 30),
        ),
      ).listen(
        (Position position) {
          final location = LatLng(position.latitude, position.longitude);
          _lastKnownLocation = location;
          _lastPosition = position;
          _locationController.add(location);
          debugPrint('[LocationService] Position mise à jour: ${location.latitude}, ${location.longitude}');
        },
        onError: (error) {
          debugPrint('[LocationService] Erreur stream position: $error');
        },
      );

      debugPrint('[LocationService] Suivi de position démarré');
      return true;
    } catch (e, st) {
      debugPrint('[LocationService] Erreur démarrage suivi: $e\n$st');
      return false;
    }
  }

  /// Arrêter le suivi de position
  Future<void> stopLocationTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    debugPrint('[LocationService] Suivi de position arrêté');
  }

  /// Calculer la distance entre deux points (en mètres)
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Calculer le bearing (direction) entre deux points (en degrés)
  double calculateBearing(LatLng from, LatLng to) {
    return Geolocator.bearingBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Nettoyer les ressources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}

