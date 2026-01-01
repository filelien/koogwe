import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:koogwe/core/services/supabase_service.dart';

/// Service pour optimiser les performances de l'application
/// Gère le cache, la mise en mémoire, et les optimisations réseau
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _defaultCacheDuration = const Duration(minutes: 5);

  /// Obtenir une valeur du cache si elle existe et n'est pas expirée
  T? getCached<T>(String key) {
    if (!_cache.containsKey(key)) return null;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      _cache.remove(key);
      return null;
    }
    
    if (DateTime.now().difference(timestamp) > _defaultCacheDuration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key] as T?;
  }

  /// Mettre en cache une valeur
  void setCached(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Nettoyer le cache expiré
  void clearExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _defaultCacheDuration) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Nettoyer tout le cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Vérifier la connexion Supabase et retourner le statut
  Future<Map<String, dynamic>> checkSupabaseConnection() async {
    try {
      return await SupabaseService.testConnection();
    } catch (e, st) {
      debugPrint('[PerformanceService] Erreur vérification Supabase: $e\n$st');
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }

  /// Mesurer la performance d'une fonction
  Future<T> measurePerformance<T>(
    Future<T> Function() function,
    String operationName,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      
      if (kDebugMode) {
        debugPrint('[PerformanceService] $operationName: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('[PerformanceService] $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  /// Débouncer une fonction pour éviter les appels trop fréquents
  Timer? _debounceTimer;
  
  void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle une fonction pour limiter la fréquence d'exécution
  DateTime? _lastThrottleCall;
  
  bool throttle(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    if (_lastThrottleCall == null || 
        now.difference(_lastThrottleCall!) >= delay) {
      _lastThrottleCall = now;
      callback();
      return true;
    }
    return false;
  }

  /// Nettoyer les ressources
  void dispose() {
    _debounceTimer?.cancel();
    clearCache();
  }
}

