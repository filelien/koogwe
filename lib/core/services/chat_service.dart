import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour la gestion du chat en temps réel
class ChatService {
  ChatService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  
  final SupabaseClient _client;

  /// Envoyer un message
  Future<Map<String, dynamic>?> sendMessage({
    required String receiverId,
    required String content,
    String? rideId,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client.from('messages').insert({
        'ride_id': rideId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'content': content,
        'message_type': messageType,
        'media_url': mediaUrl,
      }).select().maybeSingle();

      // Créer une notification pour le destinataire
      await _createMessageNotification(receiverId, content, rideId);

      return res;
    } catch (e, st) {
      debugPrint('[ChatService] sendMessage error: $e\n$st');
      return null;
    }
  }

  /// Obtenir les messages d'une conversation
  Future<List<Map<String, dynamic>>> getMessages({
    required String otherUserId,
    String? rideId,
    int limit = 50,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      var query = _client
          .from('messages')
          .select()
          .or('sender_id.eq.$user.id,receiver_id.eq.$user.id')
          .or('sender_id.eq.$otherUserId,receiver_id.eq.$otherUserId');

      if (rideId != null) {
        query = query.eq('ride_id', rideId);
      }

      final res = await query.order('created_at', ascending: false).limit(limit);
      return (res as List).cast<Map<String, dynamic>>().reversed.toList();
    } catch (e, st) {
      debugPrint('[ChatService] getMessages error: $e\n$st');
      return [];
    }
  }

  /// Stream des messages en temps réel
  Stream<List<Map<String, dynamic>>> watchMessages({
    required String otherUserId,
    String? rideId,
  }) {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Stream.value([]);
      }

      var query = _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(100);

      // Note: Les filtres sur les streams doivent être appliqués différemment
      // Pour l'instant, on retourne tous les messages et on filtre côté client

      return query.map((data) {
        final messages = (data as List).cast<Map<String, dynamic>>();
        return messages.reversed.toList();
      });
    } catch (e, st) {
      debugPrint('[ChatService] watchMessages error: $e\n$st');
      return Stream.value([]);
    }
  }

  /// Marquer les messages comme lus
  Future<bool> markAsRead({
    required String senderId,
    String? rideId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      var query = _client
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('receiver_id', user.id)
          .eq('sender_id', senderId)
          .eq('is_read', false);

      if (rideId != null) {
        query = query.eq('ride_id', rideId);
      }

      await query;
      return true;
    } catch (e, st) {
      debugPrint('[ChatService] markAsRead error: $e\n$st');
      return false;
    }
  }

  /// Obtenir le nombre de messages non lus
  Future<int> getUnreadCount(String senderId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final res = await _client
          .from('messages')
          .select('id')
          .filter('receiver_id', 'eq', user.id)
          .filter('sender_id', 'eq', senderId)
          .filter('is_read', 'eq', false);
      
      return (res as List).length;
    } catch (e, st) {
      debugPrint('[ChatService] getUnreadCount error: $e\n$st');
      return 0;
    }
  }

  /// Créer une notification pour un nouveau message
  Future<void> _createMessageNotification(
    String receiverId,
    String content,
    String? rideId,
  ) async {
    try {
      await _client.from('notifications').insert({
        'user_id': receiverId,
        'type': 'message',
        'title': 'Nouveau message',
        'body': content.length > 50 ? '${content.substring(0, 50)}...' : content,
        'data': {'ride_id': rideId},
        'action_url': rideId != null ? '/passenger/chat?rideId=$rideId' : null,
      });
    } catch (e) {
      debugPrint('[ChatService] _createMessageNotification error: $e');
    }
  }
}

