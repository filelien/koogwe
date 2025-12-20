import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
