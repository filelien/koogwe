import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour gérer le covoiturage
class CarpoolService {
  CarpoolService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  /// Créer un trajet de covoiturage
  Future<Map<String, dynamic>?> createCarpoolRide({
    required String pickup,
    required String dropoff,
    required DateTime scheduledDeparture,
    required int availableSeats,
    required double pricePerSeat,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? description,
    String? vehicleType,
    int? distanceM,
    int? durationS,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('[CarpoolService] createCarpoolRide called without user');
        return null;
      }

      final payload = {
        'driver_id': user.id,
        'pickup_text': pickup,
        'dropoff_text': dropoff,
        'scheduled_departure': scheduledDeparture.toIso8601String(),
        'available_seats': availableSeats,
        'price_per_seat': pricePerSeat,
        'status': 'open',
        if (pickupLat != null) 'pickup_lat': pickupLat,
        if (pickupLng != null) 'pickup_lng': pickupLng,
        if (dropoffLat != null) 'dropoff_lat': dropoffLat,
        if (dropoffLng != null) 'dropoff_lng': dropoffLng,
        if (description != null) 'description': description,
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (distanceM != null) 'distance_m': distanceM,
        if (durationS != null) 'duration_s': durationS,
        'created_at': DateTime.now().toIso8601String(),
      };

      final res = await _client.from('carpool_rides').insert(payload).select().maybeSingle();
      debugPrint('[CarpoolService] Carpool ride created: ${res?['id']}');
      return res;
    } on PostgrestException catch (e) {
      debugPrint('[CarpoolService] createCarpoolRide Postgrest error: ${e.message}');
      return null;
    } catch (e, st) {
      debugPrint('[CarpoolService] createCarpoolRide error: $e\n$st');
      return null;
    }
  }

  /// Réserver un siège dans un trajet de covoiturage
  Future<Map<String, dynamic>?> bookCarpoolSeat({
    required String carpoolRideId,
    required int seatsRequested,
    String? pickupText,
    String? dropoffText,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('[CarpoolService] bookCarpoolSeat called without user');
        return null;
      }

      // Vérifier que le trajet existe et a des places disponibles
      final carpool = await _client
          .from('carpool_rides')
          .select('available_seats, price_per_seat, status')
          .eq('id', carpoolRideId)
          .maybeSingle();

      if (carpool == null) {
        debugPrint('[CarpoolService] Carpool ride not found');
        return null;
      }

      final availableSeats = (carpool['available_seats'] as num?)?.toInt() ?? 0;
      final status = carpool['status'] as String? ?? '';

      if (status != 'open' || availableSeats < seatsRequested) {
        debugPrint('[CarpoolService] Not enough seats available');
        return null;
      }

      final pricePerSeat = (carpool['price_per_seat'] as num?)?.toDouble() ?? 0.0;
      final totalPrice = pricePerSeat * seatsRequested;

      final payload = {
        'carpool_ride_id': carpoolRideId,
        'passenger_id': user.id,
        'seats_requested': seatsRequested,
        'status': 'pending',
        'total_price': totalPrice,
        if (pickupText != null) 'pickup_text': pickupText,
        if (dropoffText != null) 'dropoff_text': dropoffText,
        if (pickupLat != null) 'pickup_lat': pickupLat,
        if (pickupLng != null) 'pickup_lng': pickupLng,
        if (dropoffLat != null) 'dropoff_lat': dropoffLat,
        if (dropoffLng != null) 'dropoff_lng': dropoffLng,
        'created_at': DateTime.now().toIso8601String(),
      };

      final res = await _client.from('carpool_bookings').insert(payload).select().maybeSingle();

      // Mettre à jour le nombre de places disponibles
      await _client
          .from('carpool_rides')
          .update({
            'available_seats': availableSeats - seatsRequested,
            'status': (availableSeats - seatsRequested) == 0 ? 'full' : 'open',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', carpoolRideId);

      debugPrint('[CarpoolService] Carpool seat booked: ${res?['id']}');
      return res;
    } on PostgrestException catch (e) {
      debugPrint('[CarpoolService] bookCarpoolSeat Postgrest error: ${e.message}');
      return null;
    } catch (e, st) {
      debugPrint('[CarpoolService] bookCarpoolSeat error: $e\n$st');
      return null;
    }
  }

  /// Obtenir tous les trajets de covoiturage disponibles
  Future<List<Map<String, dynamic>>> getAvailableCarpoolRides({
    DateTime? afterDate,
    int limit = 50,
  }) async {
    try {
      var query = _client
          .from('carpool_rides')
          .select('*, driver:profiles(id, first_name, last_name, avatar_url)')
          .eq('status', 'open');

      if (afterDate != null) {
        query = query.gte('scheduled_departure', afterDate.toIso8601String());
      }

      final res = await query.order('scheduled_departure', ascending: true).limit(limit);
      return (res as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      debugPrint('[CarpoolService] getAvailableCarpoolRides Postgrest error: ${e.message}');
      return [];
    } catch (e, st) {
      debugPrint('[CarpoolService] getAvailableCarpoolRides error: $e\n$st');
      return [];
    }
  }

  /// Obtenir mes trajets de covoiturage (en tant que conducteur)
  Future<List<Map<String, dynamic>>> getMyCarpoolRidesAsDriver() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final res = await _client
          .from('carpool_rides')
          .select('*, bookings:carpool_bookings(*, passenger:profiles(id, first_name, last_name, avatar_url))')
          .eq('driver_id', user.id)
          .order('scheduled_departure', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[CarpoolService] getMyCarpoolRidesAsDriver error: $e\n$st');
      return [];
    }
  }

  /// Obtenir mes réservations de covoiturage (en tant que passager)
  Future<List<Map<String, dynamic>>> getMyCarpoolBookings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final res = await _client
          .from('carpool_bookings')
          .select('*, carpool_ride:carpool_rides(*, driver:profiles(id, first_name, last_name, avatar_url))')
          .eq('passenger_id', user.id)
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[CarpoolService] getMyCarpoolBookings error: $e\n$st');
      return [];
    }
  }

  /// Annuler une réservation de covoiturage
  Future<bool> cancelCarpoolBooking(String bookingId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Récupérer la réservation pour obtenir le nombre de sièges
      final booking = await _client
          .from('carpool_bookings')
          .select('carpool_ride_id, seats_requested')
          .eq('id', bookingId)
          .eq('passenger_id', user.id)
          .maybeSingle();

      if (booking == null) return false;

      // Mettre à jour le statut de la réservation
      await _client
          .from('carpool_bookings')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Remettre les sièges disponibles dans le trajet
      final carpoolRideId = booking['carpool_ride_id'] as String;
      final seatsRequested = (booking['seats_requested'] as num?)?.toInt() ?? 0;

      final carpool = await _client
          .from('carpool_rides')
          .select('available_seats, status')
          .eq('id', carpoolRideId)
          .maybeSingle();

      if (carpool != null) {
        final currentSeats = (carpool['available_seats'] as num?)?.toInt() ?? 0;

        await _client
            .from('carpool_rides')
            .update({
              'available_seats': currentSeats + seatsRequested,
              'status': 'open', // Remettre à open si ce n'était pas full
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', carpoolRideId);
      }

      debugPrint('[CarpoolService] Carpool booking cancelled: $bookingId');
      return true;
    } catch (e, st) {
      debugPrint('[CarpoolService] cancelCarpoolBooking error: $e\n$st');
      return false;
    }
  }

  /// Annuler un trajet de covoiturage (conducteur)
  Future<bool> cancelCarpoolRide(String carpoolRideId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('carpool_rides')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', carpoolRideId)
          .eq('driver_id', user.id);

      // Annuler toutes les réservations associées
      await _client
          .from('carpool_bookings')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('carpool_ride_id', carpoolRideId)
          .eq('status', 'confirmed');

      debugPrint('[CarpoolService] Carpool ride cancelled: $carpoolRideId');
      return true;
    } catch (e, st) {
      debugPrint('[CarpoolService] cancelCarpoolRide error: $e\n$st');
      return false;
    }
  }
}

