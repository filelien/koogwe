import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour la gestion des notes et avis
class RatingService {
  RatingService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  
  final SupabaseClient _client;

  /// Créer une note
  Future<Map<String, dynamic>?> createRating({
    required String rideId,
    required String rateeId,
    required int stars,
    String? comment,
    Map<String, int>? categoryRatings, // Ex: {"cleanliness": 5, "punctuality": 4}
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Vérifier que la course est terminée
      final ride = await _client
          .from('rides')
          .select('status, user_id, driver_id')
          .eq('id', rideId)
          .maybeSingle();

      if (ride == null || ride['status'] != 'completed') {
        debugPrint('[RatingService] Ride not completed or not found');
        return null;
      }

      // Vérifier que l'utilisateur peut noter (soit passager soit chauffeur)
      final userId = user.id;
      final rideUserId = ride['user_id']?.toString();
      final rideDriverId = ride['driver_id']?.toString();

      if (userId != rideUserId && userId != rideDriverId) {
        debugPrint('[RatingService] User cannot rate this ride');
        return null;
      }

      // Vérifier qu'il n'y a pas déjà une note pour cette course
      final existing = await _client
          .from('ratings')
          .select('id')
          .eq('ride_id', rideId)
          .eq('rater_id', userId)
          .eq('ratee_id', rateeId)
          .maybeSingle();

      if (existing != null) {
        debugPrint('[RatingService] Rating already exists');
        return null;
      }

      final res = await _client.from('ratings').insert({
        'ride_id': rideId,
        'rater_id': userId,
        'ratee_id': rateeId,
        'stars': stars,
        'comment': comment,
        'category_ratings': categoryRatings,
        'is_verified': true, // Vérifié car lié à une course complétée
      }).select().maybeSingle();

      return res;
    } catch (e, st) {
      debugPrint('[RatingService] createRating error: $e\n$st');
      return null;
    }
  }

  /// Obtenir les notes d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserRatings(String userId) async {
    try {
      final res = await _client
          .from('ratings')
          .select('*, rater:profiles!ratings_rater_id_fkey(id, first_name, last_name, avatar_url)')
          .eq('ratee_id', userId)
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[RatingService] getUserRatings error: $e\n$st');
      return [];
    }
  }

  /// Obtenir la note moyenne d'un utilisateur
  Future<double> getAverageRating(String userId) async {
    try {
      final res = await _client
          .from('ratings')
          .select('stars')
          .eq('ratee_id', userId);

      if (res.isEmpty) return 0.0;

      final ratings = (res as List).cast<Map<String, dynamic>>();
      final sum = ratings.fold<double>(
        0.0,
        (acc, r) => acc + ((r['stars'] as num?)?.toDouble() ?? 0.0),
      );

      return sum / ratings.length;
    } catch (e, st) {
      debugPrint('[RatingService] getAverageRating error: $e\n$st');
      return 0.0;
    }
  }

  /// Obtenir les statistiques de notes
  Future<Map<String, dynamic>> getRatingStats(String userId) async {
    try {
      final ratings = await getUserRatings(userId);
      
      if (ratings.isEmpty) {
        return {
          'average': 0.0,
          'total': 0,
          'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      double sum = 0.0;

      for (final rating in ratings) {
        final stars = (rating['stars'] as num?)?.toInt() ?? 0;
        if (stars >= 1 && stars <= 5) {
          distribution[stars] = (distribution[stars] ?? 0) + 1;
          sum += stars;
        }
      }

      return {
        'average': sum / ratings.length,
        'total': ratings.length,
        'distribution': distribution,
      };
    } catch (e, st) {
      debugPrint('[RatingService] getRatingStats error: $e\n$st');
      return {
        'average': 0.0,
        'total': 0,
        'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }

  /// Obtenir la note d'une course spécifique
  Future<Map<String, dynamic>?> getRideRating(String rideId, String userId) async {
    try {
      final res = await _client
          .from('ratings')
          .select()
          .eq('ride_id', rideId)
          .eq('rater_id', userId)
          .maybeSingle();

      return res;
    } catch (e, st) {
      debugPrint('[RatingService] getRideRating error: $e\n$st');
      return null;
    }
  }

  /// Mettre à jour une note
  Future<bool> updateRating({
    required String ratingId,
    int? stars,
    String? comment,
    Map<String, int>? categoryRatings,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (stars != null) updates['stars'] = stars;
      if (comment != null) updates['comment'] = comment;
      if (categoryRatings != null) updates['category_ratings'] = categoryRatings;

      if (updates.isEmpty) return false;

      await _client
          .from('ratings')
          .update(updates)
          .eq('id', ratingId);

      return true;
    } catch (e, st) {
      debugPrint('[RatingService] updateRating error: $e\n$st');
      return false;
    }
  }

  /// Supprimer une note
  Future<bool> deleteRating(String ratingId) async {
    try {
      await _client
          .from('ratings')
          .delete()
          .eq('id', ratingId);

      return true;
    } catch (e, st) {
      debugPrint('[RatingService] deleteRating error: $e\n$st');
      return false;
    }
  }
}

