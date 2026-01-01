import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service complet pour la gestion des concessionnaires/propriétaires
class VehicleOwnerService {
  VehicleOwnerService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  /// Créer ou mettre à jour le profil propriétaire
  Future<Map<String, dynamic>?> createOrUpdateOwner({
    String? companyName,
    String? taxId,
    String? address,
    String? phone,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client
          .from('vehicle_owners')
          .upsert({
            'id': user.id,
            'company_name': companyName,
            'tax_id': taxId,
            'address': address,
            'phone': phone,
            'status': 'pending',
          }, onConflict: 'id')
          .select()
          .maybeSingle();

      debugPrint('[VehicleOwnerService] Owner profile created/updated');
      return res;
    } catch (e, st) {
      debugPrint('[VehicleOwnerService] createOrUpdateOwner error: $e\n$st');
      return null;
    }
  }

  /// Ajouter un véhicule à la flotte
  Future<Map<String, dynamic>?> addVehicle({
    required String make,
    required String model,
    required int year,
    required String licensePlate,
    required String vehicleType,
    String? color,
    int capacity = 4,
    Map<String, dynamic>? features,
    List<String>? photos,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client.from('vehicles').insert({
        'owner_id': user.id,
        'make': make,
        'model': model,
        'year': year,
        'license_plate': licensePlate,
        'vehicle_type': vehicleType,
        'color': color,
        'capacity': capacity,
        'features': features,
        'photos': photos,
        'status': 'available',
      }).select().maybeSingle();

      debugPrint('[VehicleOwnerService] Vehicle added: ${res?['id']}');
      return res;
    } catch (e, st) {
      debugPrint('[VehicleOwnerService] addVehicle error: $e\n$st');
      return null;
    }
  }

  /// Obtenir tous les véhicules du propriétaire
  Future<List<Map<String, dynamic>>> getMyVehicles() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final res = await _client
          .from('vehicles')
          .select('*, driver:profiles!vehicles_assigned_driver_id_fkey(*)')
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[VehicleOwnerService] getMyVehicles error: $e\n$st');
      return [];
    }
  }

  /// Assigner un véhicule à un chauffeur
  Future<bool> assignVehicleToDriver({
    required String vehicleId,
    required String driverId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Vérifier que le véhicule appartient au propriétaire
      final vehicle = await _client
          .from('vehicles')
          .select()
          .eq('id', vehicleId)
          .eq('owner_id', user.id)
          .maybeSingle();

      if (vehicle == null) return false;

      // Désassigner le véhicule actuel si assigné
      await _client
          .from('vehicle_assignments')
          .update({'is_active': false, 'unassigned_at': DateTime.now().toIso8601String()})
          .eq('vehicle_id', vehicleId)
          .eq('is_active', true);

      // Créer la nouvelle assignation
      await _client.from('vehicle_assignments').insert({
        'vehicle_id': vehicleId,
        'driver_id': driverId,
        'assigned_by': user.id,
        'is_active': true,
      });

      // Mettre à jour le véhicule
      await _client
          .from('vehicles')
          .update({
            'assigned_driver_id': driverId,
            'status': 'assigned',
          })
          .eq('id', vehicleId);

      debugPrint('[VehicleOwnerService] Vehicle assigned to driver');
      return true;
    } catch (e, st) {
      debugPrint('[VehicleOwnerService] assignVehicleToDriver error: $e\n$st');
      return false;
    }
  }

  /// Obtenir les revenus du propriétaire
  Future<Map<String, dynamic>?> getEarnings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final wallet = await _client
          .from('owner_wallets')
          .select()
          .eq('owner_id', user.id)
          .maybeSingle();

      if (wallet == null) {
        await _client.from('owner_wallets').insert({
          'owner_id': user.id,
          'balance': 0,
          'pending_balance': 0,
        });
        return await getEarnings();
      }

      return wallet;
    } catch (e, st) {
      debugPrint('[VehicleOwnerService] getEarnings error: $e\n$st');
      return null;
    }
  }

  /// Planifier une maintenance
  Future<Map<String, dynamic>?> scheduleMaintenance({
    required String vehicleId,
    required String maintenanceType,
    required String description,
    required DateTime scheduledDate,
    double? cost,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client.from('vehicle_maintenance').insert({
        'vehicle_id': vehicleId,
        'maintenance_type': maintenanceType,
        'description': description,
        'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        'cost': cost,
        'status': 'scheduled',
        'created_by': user.id,
      }).select().maybeSingle();

      // Mettre le véhicule en maintenance
      await _client
          .from('vehicles')
          .update({'status': 'maintenance'})
          .eq('id', vehicleId);

      debugPrint('[VehicleOwnerService] Maintenance scheduled');
      return res;
    } catch (e, st) {
      debugPrint('[VehicleOwnerService] scheduleMaintenance error: $e\n$st');
      return null;
    }
  }
}

