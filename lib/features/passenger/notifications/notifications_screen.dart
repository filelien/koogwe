import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/notification_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? _selectedCategory;

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.safety:
        return KoogweColors.error;
      case NotificationCategory.promotion:
        return KoogweColors.accent;
      case NotificationCategory.ride:
        return KoogweColors.primary;
      case NotificationCategory.system:
        return KoogweColors.darkTextSecondary;
      case NotificationCategory.urgent:
        return KoogweColors.error;
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.safety:
        return Icons.security;
      case NotificationCategory.promotion:
        return Icons.local_offer;
      case NotificationCategory.ride:
        return Icons.directions_car;
      case NotificationCategory.system:
        return Icons.notifications;
      case NotificationCategory.urgent:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return KoogweColors.error;
      case NotificationPriority.high:
        return KoogweColors.accent;
      case NotificationPriority.normal:
        return KoogweColors.primary;
      case NotificationPriority.low:
        return KoogweColors.darkTextTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    final filteredNotifications = _selectedCategory == null
        ? state.notifications
        : notifier.getNotificationsByCategory(_selectedCategory!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres par catégorie
                Container(
                  padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.md),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg),
                    child: Row(
                      children: [
                        _CategoryFilterChip(
                          label: 'Toutes',
                          isSelected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: KoogweSpacing.sm),
                        ...NotificationCategory.values.map((category) {
                          final icon = _getCategoryIcon(category);
                          final color = _getCategoryColor(category);
                          return Padding(
                            padding: const EdgeInsets.only(right: KoogweSpacing.sm),
                            child: _CategoryFilterChip(
                              label: category.name,
                              icon: icon,
                              isSelected: _selectedCategory == category,
                              onTap: () => setState(() => _selectedCategory = category),
                              color: color,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
                // Compteur non lues
                if (state.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KoogweSpacing.lg,
                      vertical: KoogweSpacing.sm,
                    ),
                    color: KoogweColors.primary.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: KoogweColors.primary),
                        const SizedBox(width: KoogweSpacing.sm),
                        Text(
                          '${state.unreadCount} notification${state.unreadCount > 1 ? 's' : ''} non lue${state.unreadCount > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: KoogweColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Liste des notifications
                Expanded(
                  child: filteredNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                              ),
                              const SizedBox(height: KoogweSpacing.lg),
                              Text(
                                'Aucune notification',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(KoogweSpacing.lg),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _NotificationCard(
                              notification: notification,
                              categoryColor: _getCategoryColor(notification.category),
                              categoryIcon: _getCategoryIcon(notification.category),
                              priorityColor: _getPriorityColor(notification.priority),
                              onTap: () => notifier.markAsRead(notification.id),
                              onDelete: () => notifier.deleteNotification(notification.id),
                            ).animate()
                                .fadeIn(delay: Duration(milliseconds: 100 * index))
                                .slideY(begin: 0.1, end: 0);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _CategoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? (color ?? KoogweColors.primary) : null),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: (color ?? KoogweColors.primary).withValues(alpha: 0.2),
      checkmarkColor: color ?? KoogweColors.primary,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final Color categoryColor;
  final IconData categoryIcon;
  final Color priorityColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.categoryColor,
    required this.categoryIcon,
    required this.priorityColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMM yyyy à HH:mm', 'fr_FR');

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface)
            : (isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant),
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: notification.priority == NotificationPriority.urgent
              ? KoogweColors.error
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: notification.priority == NotificationPriority.urgent ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: KoogweRadius.lgRadius,
        child: Padding(
          padding: const EdgeInsets.all(KoogweSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.md),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon ?? categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: KoogweColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(notification.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDelete,
                color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

