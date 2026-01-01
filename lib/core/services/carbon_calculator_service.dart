import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

/// Service pour calculer l'empreinte carbone et les économies CO₂
/// Basé sur les données réelles des courses
class CarbonCalculatorService {
  CarbonCalculatorService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  // Facteurs d'émission CO₂ par type de véhicule (en kg CO₂/km)
  static const Map<String, double> _emissionFactors = {
    'eco': 0.12,        // Véhicule économique (petite voiture)
    'comfort': 0.15,    // Véhicule confort (voiture moyenne)
    'premium': 0.18,    // Véhicule premium (grosse voiture)
    'xl': 0.22,         // Véhicule XL (SUV)
    'electric': 0.0,    // Véhicule électrique (0 émission directe)
    'hybrid': 0.08,     // Véhicule hybride
    'motorcycle': 0.06, // Moto
  };

  // Facteur d'émission moyen d'une voiture personnelle (pour comparaison)
  static const double _averageCarEmission = 0.15; // kg CO₂/km

  /// Calculer la distance entre deux points GPS (en km)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  /// Calculer le CO₂ économisé pour une course
  /// Retourne la différence entre l'émission d'une voiture personnelle et le véhicule utilisé
  double calculateCarbonSaved({
    required double distanceKm,
    required String vehicleType,
  }) {
    final vehicleEmission = _emissionFactors[vehicleType.toLowerCase()] ?? _averageCarEmission;
    final personalCarEmission = distanceKm * _averageCarEmission;
    final rideEmission = distanceKm * vehicleEmission;
    
    // CO₂ économisé = émission voiture personnelle - émission course
    // Si le véhicule est plus économe, on économise du CO₂
    final carbonSaved = personalCarEmission - rideEmission;
    return carbonSaved > 0 ? carbonSaved : 0.0;
  }

  /// Calculer le CO₂ total économisé par un utilisateur
  Future<double> getTotalCarbonSaved(String userId) async {
    try {
      final rides = await _client
          .from('rides')
          .select('pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, vehicle_type, distance_m, status')
          .eq('user_id', userId)
          .eq('status', 'completed');

      double totalCarbonSaved = 0.0;

      for (final ride in rides) {
        final pickupLat = ride['pickup_lat'] as num?;
        final pickupLng = ride['pickup_lng'] as num?;
        final dropoffLat = ride['dropoff_lat'] as num?;
        final dropoffLng = ride['dropoff_lng'] as num?;
        final vehicleType = (ride['vehicle_type'] ?? 'comfort').toString();
        final distanceM = ride['distance_m'] as num?;

        double distanceKm = 0.0;

        // Utiliser la distance en mètres si disponible
        if (distanceM != null) {
          distanceKm = distanceM.toDouble() / 1000.0;
        } 
        // Sinon calculer depuis les coordonnées GPS
        else if (pickupLat != null && pickupLng != null && 
                 dropoffLat != null && dropoffLng != null) {
          final pickup = LatLng(pickupLat.toDouble(), pickupLng.toDouble());
          final dropoff = LatLng(dropoffLat.toDouble(), dropoffLng.toDouble());
          distanceKm = _calculateDistance(pickup, dropoff);
        }

        if (distanceKm > 0) {
          totalCarbonSaved += calculateCarbonSaved(
            distanceKm: distanceKm,
            vehicleType: vehicleType,
          );
        }
      }

      return totalCarbonSaved;
    } catch (e, st) {
      debugPrint('[CarbonCalculatorService] Erreur calcul CO₂: $e\n$st');
      return 0.0;
    }
  }

  /// Calculer le streak (série de jours consécutifs avec au moins une course)
  Future<int> getCurrentStreak(String userId) async {
    try {
      final rides = await _client
          .from('rides')
          .select('created_at, status')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      if (rides.isEmpty) return 0;

      // Grouper les courses par jour
      final ridesByDay = <String>{};
      for (final ride in rides) {
        final createdAt = DateTime.tryParse(ride['created_at']?.toString() ?? '');
        if (createdAt != null) {
          final dayKey = '${createdAt.year}-${createdAt.month}-${createdAt.day}';
          ridesByDay.add(dayKey);
        }
      }

      if (ridesByDay.isEmpty) return 0;

      // Calculer le streak en partant d'aujourd'hui
      final today = DateTime.now();
      int streak = 0;
      DateTime currentDate = DateTime(today.year, today.month, today.day);

      while (true) {
        final dayKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
        if (ridesByDay.contains(dayKey)) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          // Si c'est aujourd'hui et qu'il n'y a pas de course, on ne compte pas
          if (currentDate.year == today.year && 
              currentDate.month == today.month && 
              currentDate.day == today.day) {
            // Pas de course aujourd'hui, on vérifie hier
            currentDate = currentDate.subtract(const Duration(days: 1));
            continue;
          }
          break;
        }
      }

      return streak;
    } catch (e, st) {
      debugPrint('[CarbonCalculatorService] Erreur calcul streak: $e\n$st');
      return 0;
    }
  }

  /// Obtenir les statistiques carbone complètes
  Future<Map<String, dynamic>> getCarbonStats(String userId) async {
    try {
      final totalCarbonSaved = await getTotalCarbonSaved(userId);
      final currentStreak = await getCurrentStreak(userId);

      return {
        'total_carbon_saved': totalCarbonSaved,
        'current_streak': currentStreak,
      };
    } catch (e, st) {
      debugPrint('[CarbonCalculatorService] Erreur stats carbone: $e\n$st');
      return {
        'total_carbon_saved': 0.0,
        'current_streak': 0,
      };
    }
  }
}

