import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationCategory { safety, promotion, ride, system, urgent }
enum NotificationPriority { low, normal, high, urgent }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final IconData? icon;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.icon,
  });
}

class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    _loadNotifications();
    return NotificationState();
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final notifications = [
      AppNotification(
        id: '1',
        title: 'Course en cours',
        message: 'Votre chauffeur arrive dans 2 minutes',
        category: NotificationCategory.ride,
        priority: NotificationPriority.high,
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        icon: Icons.directions_car,
      ),
      AppNotification(
        id: '2',
        title: 'Offre spéciale',
        message: 'Réduction de 20% sur tous les trajets vers Kourou aujourd\'hui',
        category: NotificationCategory.promotion,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        icon: Icons.local_offer,
      ),
      AppNotification(
        id: '3',
        title: 'Sécurité',
        message: 'Votre partage de position a été désactivé',
        category: NotificationCategory.safety,
        priority: NotificationPriority.high,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
        icon: Icons.security,
      ),
      AppNotification(
        id: '4',
        title: 'Trajet terminé',
        message: 'Merci d\'avoir utilisé KOOGWE. N\'oubliez pas d\'évaluer votre trajet',
        category: NotificationCategory.ride,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        icon: Icons.check_circle,
      ),
      AppNotification(
        id: '5',
        title: 'Nouveau badge',
        message: 'Félicitations ! Vous avez obtenu le badge "Éco-responsable"',
        category: NotificationCategory.system,
        priority: NotificationPriority.low,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: false,
        icon: Icons.star,
      ),
    ];

    final unreadCount = notifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
      isLoading: false,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final notifications = state.notifications.map((n) {
      if (n.id == notificationId) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          category: n.category,
          priority: n.priority,
          createdAt: n.createdAt,
          isRead: true,
          actionUrl: n.actionUrl,
          icon: n.icon,
        );
      }
      return n;
    }).toList();

    final unreadCount = notifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  Future<void> markAllAsRead() async {
    final notifications = state.notifications.map((n) {
      return AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        category: n.category,
        priority: n.priority,
        createdAt: n.createdAt,
        isRead: true,
        actionUrl: n.actionUrl,
        icon: n.icon,
      );
    }).toList();

    state = state.copyWith(
      notifications: notifications,
      unreadCount: 0,
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != notificationId).toList(),
    );
  }

  List<AppNotification> getNotificationsByCategory(NotificationCategory category) {
    return state.notifications.where((n) => n.category == category).toList();
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);

