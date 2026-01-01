import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koogwe/core/services/carbon_calculator_service.dart';

/// Service to interact with rides data in Supabase.
/// All methods fail gracefully and log errors; UI should remain responsive.
class RidesService {
  RidesService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  Future<Map<String, dynamic>?> createRide({
    required String pickup,
    required String dropoff,
    required String vehicleType,
    required double estimatedPrice,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('[RidesService] createRide called without user');
        return null;
      }
      final payload = {
        'user_id': user.id,
        'pickup_text': pickup,
        'dropoff_text': dropoff,
        'vehicle_type': vehicleType,
        'status': 'requested',
        'estimated_price': estimatedPrice,
        'created_at': DateTime.now().toIso8601String(),
        if (pickupLat != null) 'pickup_lat': pickupLat,
        if (pickupLng != null) 'pickup_lng': pickupLng,
        if (dropoffLat != null) 'dropoff_lat': dropoffLat,
        if (dropoffLng != null) 'dropoff_lng': dropoffLng,
      };
      final res = await _client.from('rides').insert(payload).select().maybeSingle();
      debugPrint('[RidesService] Ride created: ${res?['id']}');
      return res;
    } on PostgrestException catch (e) {
      debugPrint('[RidesService] createRide Postgrest error: ${e.message}');
      return null;
    } catch (e, st) {
      debugPrint('[RidesService] createRide error: $e\n$st');
      return null;
    }
  }

  Future<bool> cancelRide(String rideId) async {
    try {
      await _client.from('rides').update({'status': 'cancelled'}).eq('id', rideId);
      debugPrint('[RidesService] Ride cancelled: $rideId');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('[RidesService] cancelRide Postgrest error: ${e.message}');
      return false;
    } catch (e, st) {
      debugPrint('[RidesService] cancelRide error: $e\n$st');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listMyRides() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const [];
      final res = await _client
          .from('rides')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return (res as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      debugPrint('[RidesService] listMyRides Postgrest error: ${e.message}');
      return const [];
    } catch (e, st) {
      debugPrint('[RidesService] listMyRides error: $e\n$st');
      return const [];
    }
  }

  /// Obtenir les statistiques du passager
  Future<Map<String, dynamic>?> getPassengerStats() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthAgo = today.subtract(const Duration(days: 30));

      // Total courses
      final allRides = await _client
          .from('rides')
          .select('id, total_price, status, created_at')
          .eq('user_id', user.id);

      // Courses terminées
      final completedRides = (allRides as List)
          .where((ride) => ride['status'] == 'completed')
          .toList();

      // Total dépensé
      final totalSpent = completedRides.fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Courses ce mois
      final monthRides = completedRides.where((ride) {
        final createdAt = DateTime.tryParse(ride['created_at']?.toString() ?? '');
        return createdAt != null && createdAt.isAfter(monthAgo);
      }).toList();

      final monthSpent = monthRides.fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Courses par statut
      final statusCounts = <String, int>{};
      for (var ride in (allRides as List)) {
        final status = ride['status']?.toString() ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      // Portefeuille
      final wallet = await _client
          .from('wallets')
          .select('balance')
          .eq('user_id', user.id)
          .maybeSingle();

      final balance = (wallet?['balance'] as num?)?.toDouble() ?? 0.0;

      // Calculer CO₂ économisé et streak
      try {
        final carbonService = CarbonCalculatorService();
        final carbonStats = await carbonService.getCarbonStats(user.id);
        
        return {
          'total_rides': completedRides.length,
          'total_spent': totalSpent,
          'month_rides': monthRides.length,
          'month_spent': monthSpent,
          'wallet_balance': balance,
          'rides_by_status': statusCounts,
          'carbon_saved': carbonStats['total_carbon_saved'] ?? 0.0,
          'current_streak': carbonStats['current_streak'] ?? 0,
        };
      } catch (e) {
        debugPrint('[RidesService] Erreur calcul carbone/streak: $e');
        return {
          'total_rides': completedRides.length,
          'total_spent': totalSpent,
          'month_rides': monthRides.length,
          'month_spent': monthSpent,
          'wallet_balance': balance,
          'rides_by_status': statusCounts,
          'carbon_saved': 0.0,
          'current_streak': 0,
        };
      }
    } catch (e, st) {
      debugPrint('[RidesService] getPassengerStats error: $e\n$st');
      return null;
    }
  }
}
