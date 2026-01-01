import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koogwe/core/services/supabase_service.dart';

/// Service centralisé pour la gestion des notifications
class NotificationService {
  NotificationService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  
  final SupabaseClient _client;

  /// Créer une notification
  Future<String?> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      final res = await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'data': data,
        'action_url': actionUrl,
      }).select('id').maybeSingle();
      
      return res?['id']?.toString();
    } catch (e, st) {
      debugPrint('[NotificationService] createNotification error: $e\n$st');
      return null;
    }
  }

  /// Obtenir les notifications d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      var query = _client
          .from('notifications')
          .select()
          .eq('user_id', user.id);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final res = await query.order('created_at', ascending: false).limit(limit);
      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[NotificationService] getUserNotifications error: $e\n$st');
      return [];
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      
      return true;
    } catch (e, st) {
      debugPrint('[NotificationService] markAsRead error: $e\n$st');
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('is_read', false);
      
      return true;
    } catch (e, st) {
      debugPrint('[NotificationService] markAllAsRead error: $e\n$st');
      return false;
    }
  }

  /// Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final res = await _client
          .from('notifications')
          .select('id')
          .filter('user_id', 'eq', user.id)
          .filter('is_read', 'eq', false);
      
      return (res as List).length;
    } catch (e, st) {
      debugPrint('[NotificationService] getUnreadCount error: $e\n$st');
      return 0;
    }
  }

  /// Stream des notifications en temps réel
  Stream<List<Map<String, dynamic>>> watchNotifications() {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Stream.value([]);
      }

      return _client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50)
          .map((data) => (data as List).cast<Map<String, dynamic>>());
    } catch (e, st) {
      debugPrint('[NotificationService] watchNotifications error: $e\n$st');
      return Stream.value([]);
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      
      return true;
    } catch (e, st) {
      debugPrint('[NotificationService] deleteNotification error: $e\n$st');
      return false;
    }
  }

  /// Créer une notification pour un changement de statut de course
  Future<void> notifyRideStatusChange({
    required String rideId,
    required String userId,
    required String status,
    String? driverName,
  }) async {
    String title;
    String body;
    String type;

    switch (status) {
      case 'accepted':
        title = 'Course acceptée';
        body = driverName != null 
            ? '$driverName a accepté votre course'
            : 'Votre course a été acceptée';
        type = 'ride_accepted';
        break;
      case 'in_progress':
        title = 'Course en cours';
        body = driverName != null
            ? '$driverName est en route'
            : 'Votre chauffeur est en route';
        type = 'ride_started';
        break;
      case 'completed':
        title = 'Course terminée';
        body = 'Votre course est terminée. Merci d\'avoir utilisé KOOGWE!';
        type = 'ride_completed';
        break;
      case 'cancelled':
        title = 'Course annulée';
        body = 'Votre course a été annulée';
        type = 'ride_cancelled';
        break;
      default:
        return;
    }

    await createNotification(
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: {'ride_id': rideId, 'status': status},
      actionUrl: '/passenger/ride-tracking?rideId=$rideId',
    );
  }
}

