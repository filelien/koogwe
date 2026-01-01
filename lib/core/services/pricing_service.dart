import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koogwe/core/services/osrm_service.dart';
import 'package:latlong2/latlong.dart';

/// Service pour calculer les prix des courses basé sur la distance et les paramètres admin
class PricingService {
  PricingService({
    SupabaseClient? client,
    OsrmService? osrmService,
  })  : _client = client ?? Supabase.instance.client,
        _osrmService = osrmService ?? OsrmService();

  final SupabaseClient _client;
  final OsrmService _osrmService;

  /// Obtenir les paramètres de prix pour un type de véhicule
  Future<Map<String, dynamic>?> getPricingSettings(String vehicleType) async {
    try {
      final res = await _client
          .from('pricing_settings')
          .select()
          .eq('vehicle_type', vehicleType)
          .eq('is_active', true)
          .maybeSingle();

      if (res != null) {
        return {
          'base_price': (res['base_price'] as num?)?.toDouble() ?? 2.5,
          'price_per_km': (res['price_per_km'] as num?)?.toDouble() ?? 1.5,
          'minimum_price': (res['minimum_price'] as num?)?.toDouble() ?? 5.0,
        };
      }

      // Valeurs par défaut si pas de configuration
      return _getDefaultPricing(vehicleType);
    } catch (e, st) {
      debugPrint('[PricingService] getPricingSettings error: $e\n$st');
      return _getDefaultPricing(vehicleType);
    }
  }

  /// Obtenir tous les paramètres de prix (pour l'admin)
  Future<List<Map<String, dynamic>>> getAllPricingSettings() async {
    try {
      final res = await _client
          .from('pricing_settings')
          .select()
          .order('vehicle_type');

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[PricingService] getAllPricingSettings error: $e\n$st');
      return [];
    }
  }

  /// Mettre à jour les paramètres de prix (admin seulement)
  Future<bool> updatePricingSettings({
    required String vehicleType,
    required double basePrice,
    required double pricePerKm,
    required double minimumPrice,
    bool isActive = true,
  }) async {
    try {
      // Utiliser upsert pour créer ou mettre à jour
      // Note: Le schéma SQL utilise base_price, price_per_km, minimum_price
      await _client.from('pricing_settings').upsert({
        'vehicle_type': vehicleType,
        'base_price': basePrice,
        'price_per_km': pricePerKm,
        'minimum_price': minimumPrice,
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'vehicle_type');

      debugPrint('[PricingService] Pricing settings updated for $vehicleType');
      return true;
    } catch (e, st) {
      debugPrint('[PricingService] updatePricingSettings error: $e\n$st');
      return false;
    }
  }

  /// Calculer le prix d'une course basé sur la distance réelle
  Future<Map<String, dynamic>> calculatePrice({
    required LatLng pickupLocation,
    required LatLng dropoffLocation,
    required String vehicleType,
  }) async {
    try {
      // Obtenir l'itinéraire avec distance et durée
      final routeDetails = await _osrmService.routeWithDetails(
        startLat: pickupLocation.latitude,
        startLon: pickupLocation.longitude,
        endLat: dropoffLocation.latitude,
        endLon: dropoffLocation.longitude,
      );

      final distanceM = routeDetails['distance_m'] as int;
      final durationS = routeDetails['duration_s'] as int;
      final distanceKm = distanceM / 1000.0;

      // Obtenir les paramètres de prix
      final pricing = await getPricingSettings(vehicleType);
      if (pricing == null) {
        return {
          'price': 0.0,
          'distance_m': distanceM,
          'distance_km': distanceKm,
          'duration_s': durationS,
          'polyline': routeDetails['polyline'] as List<List<double>>,
        };
      }

      final basePrice = pricing['base_price'] as double;
      final pricePerKm = pricing['price_per_km'] as double;
      final minimumPrice = pricing['minimum_price'] as double;

      // Calcul: prix de base + (distance en km * prix par km)
      double calculatedPrice = basePrice + (distanceKm * pricePerKm);

      // Appliquer le prix minimum
      if (calculatedPrice < minimumPrice) {
        calculatedPrice = minimumPrice;
      }

      return {
        'price': calculatedPrice,
        'distance_m': distanceM,
        'distance_km': distanceKm,
        'duration_s': durationS,
        'duration_min': (durationS / 60).round(),
        'polyline': routeDetails['polyline'] as List<List<double>>,
      };
    } catch (e, st) {
      debugPrint('[PricingService] calculatePrice error: $e\n$st');
      // Retourner un prix par défaut en cas d'erreur
      return {
        'price': 10.0,
        'distance_m': 0,
        'distance_km': 0.0,
        'duration_s': 0,
        'duration_min': 0,
        'polyline': <List<double>>[],
      };
    }
  }

  /// Calculer le prix avec distance fournie (sans appel OSRM)
  Future<double> calculatePriceFromDistance({
    required double distanceKm,
    required String vehicleType,
  }) async {
    try {
      final pricing = await getPricingSettings(vehicleType);
      if (pricing == null) return 10.0;

      final basePrice = pricing['base_price'] as double;
      final pricePerKm = pricing['price_per_km'] as double;
      final minimumPrice = pricing['minimum_price'] as double;

      double calculatedPrice = basePrice + (distanceKm * pricePerKm);

      if (calculatedPrice < minimumPrice) {
        calculatedPrice = minimumPrice;
      }

      return calculatedPrice;
    } catch (e, st) {
      debugPrint('[PricingService] calculatePriceFromDistance error: $e\n$st');
      return 10.0;
    }
  }

  /// Valeurs par défaut si pas de configuration en base
  Map<String, dynamic>? _getDefaultPricing(String vehicleType) {
    final defaults = {
      'CAR': {'base_price': 2.5, 'price_per_km': 1.2, 'minimum_price': 5.0},
      'MOTO': {'base_price': 2.0, 'price_per_km': 1.0, 'minimum_price': 4.0},
      'KOOGWE Eco': {'base_price': 3.0, 'price_per_km': 1.5, 'minimum_price': 6.0},
      'KOOGWE Confort': {'base_price': 4.0, 'price_per_km': 2.0, 'minimum_price': 8.0},
      'KOOGWE Premium': {'base_price': 6.0, 'price_per_km': 3.0, 'minimum_price': 12.0},
      'economy': {'base_price': 2.5, 'price_per_km': 1.2, 'minimum_price': 5.0},
      'comfort': {'base_price': 4.0, 'price_per_km': 2.0, 'minimum_price': 8.0},
      'premium': {'base_price': 6.0, 'price_per_km': 3.0, 'minimum_price': 12.0},
      'luxury': {'base_price': 8.0, 'price_per_km': 4.0, 'minimum_price': 15.0},
    };

    final defaultPricing = defaults[vehicleType];
    if (defaultPricing != null) {
      return {
        'base_price': defaultPricing['base_price'] as double,
        'price_per_km': defaultPricing['price_per_km'] as double,
        'minimum_price': defaultPricing['minimum_price'] as double,
      };
    }

    // Valeur par défaut générique
    return {
      'base_price': 2.5,
      'price_per_km': 1.5,
      'minimum_price': 5.0,
    };
  }
}

