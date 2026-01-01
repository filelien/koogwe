import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service complet pour la gestion des chauffeurs
class DriverService {
  DriverService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  /// Créer ou mettre à jour le profil chauffeur
  Future<Map<String, dynamic>?> createOrUpdateDriver({
    required String licenseNumber,
    DateTime? licenseExpiry,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('[DriverService] No user authenticated');
        return null;
      }

      final payload = {
        'id': user.id,
        'license_number': licenseNumber,
        if (licenseExpiry != null) 'license_expiry': licenseExpiry.toIso8601String().split('T')[0],
        'status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final res = await _client
          .from('drivers')
          .upsert(payload, onConflict: 'id')
          .select()
          .maybeSingle();

      debugPrint('[DriverService] Driver profile created/updated');
      return res;
    } catch (e, st) {
      debugPrint('[DriverService] createOrUpdateDriver error: $e\n$st');
      return null;
    }
  }

  /// Obtenir le profil chauffeur
  Future<Map<String, dynamic>?> getDriverProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client
          .from('drivers')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return res;
    } catch (e, st) {
      debugPrint('[DriverService] getDriverProfile error: $e\n$st');
      return null;
    }
  }

  /// Upload un document chauffeur
  Future<Map<String, dynamic>?> uploadDocument({
    required String documentType,
    required String filePath,
    DateTime? expiryDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Upload vers Supabase Storage
      // Note: L'upload de fichier doit être fait côté client avec le fichier réel
      // Ici on suppose que filePath est déjà uploadé ou on retourne une URL temporaire
      final fileName = '${user.id}/${documentType}_${DateTime.now().millisecondsSinceEpoch}';
      final fileUrl = 'https://storage.supabase.co/object/public/driver-documents/$fileName';

      // Enregistrer dans la table
      final res = await _client.from('driver_documents').insert({
        'driver_id': user.id,
        'document_type': documentType,
        'file_url': fileUrl,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String().split('T')[0],
        'status': 'pending',
      }).select().maybeSingle();

      debugPrint('[DriverService] Document uploaded: $documentType');
      return res;
    } catch (e, st) {
      debugPrint('[DriverService] uploadDocument error: $e\n$st');
      return null;
    }
  }

  /// Obtenir tous les documents d'un chauffeur
  Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final res = await _client
          .from('driver_documents')
          .select()
          .eq('driver_id', user.id)
          .order('uploaded_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[DriverService] getDocuments error: $e\n$st');
      return [];
    }
  }

  /// Changer le statut en ligne/hors ligne
  Future<bool> setOnlineStatus(bool isOnline) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Vérifier que le chauffeur est approuvé
      final driver = await getDriverProfile();
      if (driver == null || driver['status'] != 'approved') {
        debugPrint('[DriverService] Driver not approved, cannot go online');
        return false;
      }

      await _client
          .from('drivers')
          .update({
            'is_online': isOnline,
            'is_available': isOnline,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      debugPrint('[DriverService] Online status updated: $isOnline');
      return true;
    } catch (e, st) {
      debugPrint('[DriverService] setOnlineStatus error: $e\n$st');
      return false;
    }
  }

  /// Mettre à jour la position GPS
  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    double? accuracy,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client.from('driver_locations').insert({
        'driver_id': user.id,
        'latitude': latitude,
        'longitude': longitude,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        if (accuracy != null) 'accuracy': accuracy,
      });

      return true;
    } catch (e, st) {
      debugPrint('[DriverService] updateLocation error: $e\n$st');
      return false;
    }
  }

  /// Écouter les courses disponibles (temps réel)
  Stream<List<Map<String, dynamic>>> watchAvailableRides() {
    try {
      return _client
          .from('rides')
          .stream(primaryKey: ['id'])
          .eq('status', 'searching')
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('[DriverService] watchAvailableRides error: $e');
      return Stream.value([]);
    }
  }

  /// Accepter une course
  Future<bool> acceptRide(String rideId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Vérifier que le chauffeur est disponible
      final driver = await getDriverProfile();
      if (driver == null || !driver['is_available'] || driver['status'] != 'approved') {
        return false;
      }

      // Mettre à jour la course
      await _client
          .from('rides')
          .update({
            'driver_id': user.id,
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId)
          .eq('status', 'searching'); // Atomicité

      // Mettre à jour le statut du chauffeur
      await _client
          .from('drivers')
          .update({
            'is_available': false,
            'current_ride_id': rideId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      debugPrint('[DriverService] Ride accepted: $rideId');
      return true;
    } catch (e, st) {
      debugPrint('[DriverService] acceptRide error: $e\n$st');
      return false;
    }
  }

  /// Refuser une course
  Future<bool> rejectRide(String rideId) async {
    try {
      // La course reste en "searching" pour être proposée à d'autres chauffeurs
      debugPrint('[DriverService] Ride rejected: $rideId');
      return true;
    } catch (e, st) {
      debugPrint('[DriverService] rejectRide error: $e\n$st');
      return false;
    }
  }

  /// Mettre à jour le statut d'une course
  Future<bool> updateRideStatus(String rideId, String status) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('rides')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId)
          .eq('driver_id', user.id);

      // Si la course est terminée, libérer le chauffeur
      if (status == 'completed' || status == 'cancelled') {
        await _client
            .from('drivers')
            .update({
              'is_available': true,
              'current_ride_id': null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);
      }

      debugPrint('[DriverService] Ride status updated: $rideId -> $status');
      return true;
    } catch (e, st) {
      debugPrint('[DriverService] updateRideStatus error: $e\n$st');
      return false;
    }
  }

  /// Obtenir les statistiques du chauffeur
  Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final driver = await getDriverProfile();
      if (driver == null) return null;

      // Compter les courses
      final ridesCount = await _client
          .from('rides')
          .select('id')
          .eq('driver_id', user.id)
          .eq('status', 'completed');

      // Calculer les revenus
      final earnings = await _client
          .from('driver_transactions')
          .select('amount')
          .eq('driver_id', user.id)
          .eq('type', 'earning')
          .eq('status', 'completed');

      final totalEarnings = (earnings as List)
          .fold<double>(0, (sum, tx) => sum + ((tx['amount'] as num?)?.toDouble() ?? 0));

      return {
        'total_rides': (ridesCount as List).length,
        'total_earnings': totalEarnings,
        'average_rating': driver['average_rating'] ?? 0,
        'status': driver['status'],
        'is_online': driver['is_online'] ?? false,
      };
    } catch (e, st) {
      debugPrint('[DriverService] getStatistics error: $e\n$st');
      return null;
    }
  }

  /// Obtenir le portefeuille du chauffeur
  Future<Map<String, dynamic>?> getWallet() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final wallet = await _client
          .from('driver_wallets')
          .select()
          .eq('driver_id', user.id)
          .maybeSingle();

      if (wallet == null) {
        // Créer le portefeuille s'il n'existe pas
        await _client.from('driver_wallets').insert({
          'driver_id': user.id,
          'balance': 0,
          'pending_balance': 0,
        });
        return await getWallet();
      }

      return wallet;
    } catch (e, st) {
      debugPrint('[DriverService] getWallet error: $e\n$st');
      return null;
    }
  }

  /// Obtenir l'historique des transactions
  Future<List<Map<String, dynamic>>> getTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final res = await _client
          .from('driver_transactions')
          .select()
          .eq('driver_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[DriverService] getTransactions error: $e\n$st');
      return [];
    }
  }

  /// Obtenir des statistiques détaillées pour le dashboard
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final driver = await getDriverProfile();
      if (driver == null) return null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));

      // Courses aujourd'hui
      final todayRides = await _client
          .from('rides')
          .select('id, total_price')
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', today.toIso8601String());

      final todayEarnings = (todayRides as List).fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Courses cette semaine
      final weekRides = await _client
          .from('rides')
          .select('id, total_price, created_at')
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', weekAgo.toIso8601String());

      final weekEarnings = (weekRides as List).fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Revenus par jour (7 derniers jours)
      final earningsByDay = <Map<String, dynamic>>[];
      for (int i = 6; i >= 0; i--) {
        final dayStart = today.subtract(Duration(days: i));
        final dayEnd = dayStart.add(const Duration(days: 1));

        final dayRides = await _client
            .from('rides')
            .select('total_price')
            .eq('driver_id', user.id)
            .eq('status', 'completed')
            .gte('created_at', dayStart.toIso8601String())
            .lt('created_at', dayEnd.toIso8601String());

        final dayEarnings = (dayRides as List).fold<double>(
            0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

        earningsByDay.add({
          'date': dayStart,
          'earnings': dayEarnings,
        });
      }

      // Courses par statut
      final ridesByStatus = await _client
          .from('rides')
          .select('status')
          .eq('driver_id', user.id);

      final statusCounts = <String, int>{};
      for (var ride in (ridesByStatus as List)) {
        final status = ride['status']?.toString() ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      // Total courses
      final totalRides = (ridesByStatus as List).length;

      // Total revenus
      final allRides = await _client
          .from('rides')
          .select('total_price')
          .eq('driver_id', user.id)
          .eq('status', 'completed');

      final totalEarnings = (allRides as List).fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Note moyenne
      final rating = driver['average_rating'] ?? 0.0;

      return {
        'today_earnings': todayEarnings,
        'today_rides': (todayRides as List).length,
        'week_earnings': weekEarnings,
        'week_rides': (weekRides as List).length,
        'total_earnings': totalEarnings,
        'total_rides': totalRides,
        'average_rating': rating,
        'is_online': driver['is_online'] ?? false,
        'status': driver['status'],
        'earnings_last_7_days': earningsByDay,
        'rides_by_status': statusCounts,
      };
    } catch (e, st) {
      debugPrint('[DriverService] getDashboardStats error: $e\n$st');
      return null;
    }
  }
}

