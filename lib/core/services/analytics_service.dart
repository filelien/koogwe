import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour les analytics et statistiques
class AnalyticsService {
  AnalyticsService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  
  final SupabaseClient _client;

  /// Obtenir les analytics d'un passager
  Future<Map<String, dynamic>> getPassengerAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return {};

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Total des courses
      final totalRidesResponse = await _client
          .from('rides')
          .select('id')
          .eq('user_id', user.id)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());
      final totalRides = (totalRidesResponse as List).length;

      // Courses complétées
      final completedRidesResponse = await _client
          .from('rides')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());
      final completedRides = (completedRidesResponse as List).length;

      // Total dépensé
      final rides = await _client
          .from('rides')
          .select('fare')
          .eq('user_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final totalSpent = rides.fold<double>(
        0.0,
        (sum, ride) => sum + ((ride['fare'] as num?)?.toDouble() ?? 0.0),
      );

      // Distance totale
      final distanceRides = await _client
          .from('rides')
          .select('distance_m')
          .eq('user_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final totalDistance = distanceRides.fold<int>(
        0,
        (sum, ride) => sum + ((ride['distance_m'] as num?)?.toInt() ?? 0),
      );

      // Type de véhicule le plus utilisé
      final vehicleTypes = await _client
          .from('rides')
          .select('vehicle_type')
          .eq('user_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final vehicleTypeCount = <String, int>{};
      for (final ride in vehicleTypes) {
        final type = ride['vehicle_type']?.toString() ?? 'unknown';
        vehicleTypeCount[type] = (vehicleTypeCount[type] ?? 0) + 1;
      }

      final mostUsedVehicle = vehicleTypeCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      return {
        'total_rides': totalRides,
        'completed_rides': completedRides,
        'total_spent': totalSpent,
        'total_distance_km': (totalDistance / 1000).toStringAsFixed(2),
        'average_ride_price': completedRides > 0 
            ? (totalSpent / completedRides).toStringAsFixed(2)
            : '0.00',
        'most_used_vehicle': mostUsedVehicle,
        'vehicle_type_distribution': vehicleTypeCount,
      };
    } catch (e, st) {
      debugPrint('[AnalyticsService] getPassengerAnalytics error: $e\n$st');
      return {};
    }
  }

  /// Obtenir les analytics d'un chauffeur
  Future<Map<String, dynamic>> getDriverAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return {};

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Total des courses
      final totalRidesResponse = await _client
          .from('rides')
          .select('id')
          .eq('driver_id', user.id)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());
      final totalRides = (totalRidesResponse as List).length;

      // Courses complétées
      final completedRidesResponse = await _client
          .from('rides')
          .select('id, fare, distance_m, duration_s')
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());
      final completedRides = (completedRidesResponse as List).length;

      // Total gagné
      final rides = await _client
          .from('rides')
          .select('fare')
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final totalEarnings = rides.fold<double>(
        0.0,
        (sum, ride) => sum + ((ride['fare'] as num?)?.toDouble() ?? 0.0),
      );

      // Distance totale
      final distanceRides = await _client
          .from('rides')
          .select('distance_m')
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final totalDistance = distanceRides.fold<int>(
        0,
        (sum, ride) => sum + ((ride['distance_m'] as num?)?.toInt() ?? 0),
      );

      // Durée totale
      final durationRides = await _client
          .from('rides')
          .select('duration_s')
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final totalDuration = durationRides.fold<int>(
        0,
        (sum, ride) => sum + ((ride['duration_s'] as num?)?.toInt() ?? 0),
      );

      // Note moyenne
      final ratings = await _client
          .from('ratings')
          .select('stars')
          .eq('ratee_id', user.id);

      final avgRating = ratings.isEmpty
          ? 0.0
          : ratings.fold<double>(
              0.0,
              (sum, r) => sum + ((r['stars'] as num?)?.toDouble() ?? 0.0),
            ) / ratings.length;

      return {
        'total_rides': totalRides,
        'completed_rides': completedRides,
        'total_earnings': totalEarnings,
        'total_distance_km': (totalDistance / 1000).toStringAsFixed(2),
        'total_duration_hours': (totalDuration / 3600).toStringAsFixed(2),
        'average_rating': avgRating.toStringAsFixed(1),
        'average_ride_earnings': completedRides > 0
            ? (totalEarnings / completedRides).toStringAsFixed(2)
            : '0.00',
      };
    } catch (e, st) {
      debugPrint('[AnalyticsService] getDriverAnalytics error: $e\n$st');
      return {};
    }
  }

  /// Obtenir les analytics d'une entreprise
  Future<Map<String, dynamic>> getBusinessAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return {};

      final company = await _client
          .from('companies')
          .select('id')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (company == null) return {};

      final companyId = company['id'];

      // Obtenir tous les employés
      final employees = await _client
          .from('company_users')
          .select('user_id')
          .eq('company_id', companyId)
          .eq('is_active', true);

      final employeeIds = (employees as List)
          .map((e) => e['user_id']?.toString())
          .where((id) => id != null)
          .cast<String>()
          .toList();

      if (employeeIds.isEmpty) {
        return {
          'total_rides': 0,
          'total_spent': 0.0,
          'active_employees': 0,
        };
      }

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Total des courses des employés
      final totalRidesResponse = await _client
          .from('rides')
          .select('id')
          .filter('user_id', 'in', '(${employeeIds.join(',')})')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());
      final totalRides = (totalRidesResponse as List).length;

      // Total dépensé
      final rides = await _client
          .from('rides')
          .select('fare')
          .filter('user_id', 'in', '(${employeeIds.join(',')})')
          .eq('status', 'completed')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final totalSpent = rides.fold<double>(
        0.0,
        (sum, ride) => sum + ((ride['fare'] as num?)?.toDouble() ?? 0.0),
      );

      return {
        'total_rides': totalRides,
        'total_spent': totalSpent,
        'active_employees': employeeIds.length,
        'average_per_employee': employeeIds.isNotEmpty
            ? (totalSpent / employeeIds.length).toStringAsFixed(2)
            : '0.00',
      };
    } catch (e, st) {
      debugPrint('[AnalyticsService] getBusinessAnalytics error: $e\n$st');
      return {};
    }
  }
}

