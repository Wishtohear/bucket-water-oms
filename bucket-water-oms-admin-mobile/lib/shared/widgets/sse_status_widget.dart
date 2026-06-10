import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../stores/sse_store.dart';
import '../../models/push_notification_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SseStatusIndicator extends StatelessWidget {
  final bool showLabel;

  const SseStatusIndicator({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<SseStore>(
      builder: (context, sseStore, child) {
        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (sseStore.isConnected) {
          statusColor = AppColors.success;
          statusText = '已连接';
          statusIcon = Icons.wifi;
        } else if (sseStore.isConnecting) {
          statusColor = AppColors.warning;
          statusText = '连接中...';
          statusIcon = Icons.sync;
        } else {
          statusColor = AppColors.textTertiary;
          statusText = '推送离线';
          statusIcon = Icons.wifi_off;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sseStore.isConnecting)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              )
            else
              Icon(
                statusIcon,
                size: 14,
                color: statusColor,
              ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                statusText,
                style: AppTextStyles.captionSmall.copyWith(
                  color: statusColor,
                ),
              ),
            ],
            if (sseStore.unreadCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${sseStore.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class PushNotificationBadge extends StatelessWidget {
  final Widget child;
  final int? badgeCount;

  const PushNotificationBadge({
    super.key,
    required this.child,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SseStore>(
      builder: (context, sseStore, child) {
        final count = badgeCount ?? sseStore.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child ?? const SizedBox(),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class NotificationListTile extends StatelessWidget {
  final PushNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationListTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${notification.event}_${notification.timestamp.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: _getNotificationIcon(),
        title: Text(
          notification.title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.content,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _getNotificationIcon() {
    IconData icon;
    Color color;

    switch (notification.event) {
      case PushNotification.eventOrderCreated:
        icon = Icons.add_shopping_cart;
        color = AppColors.primary;
        break;
      case PushNotification.eventOrderReviewed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case PushNotification.eventOrderRejected:
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      case PushNotification.eventOrderDispatched:
        icon = Icons.local_shipping;
        color = AppColors.primary;
        break;
      case PushNotification.eventOrderDelivering:
        icon = Icons.delivery_dining;
        color = AppColors.warning;
        break;
      case PushNotification.eventOrderCompleted:
        icon = Icons.done_all;
        color = AppColors.success;
        break;
      case PushNotification.eventOrderCancelled:
        icon = Icons.block;
        color = AppColors.textTertiary;
        break;
      case PushNotification.eventNewDeliveryTask:
        icon = Icons.notification_important;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.primary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${dateTime.month}-${dateTime.day}';
    }
  }
}

class NotificationListSheet extends StatelessWidget {
  const NotificationListSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationListSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SseStore>(
      builder: (context, sseStore, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '消息通知',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    SseStatusIndicator(showLabel: true),
                    const SizedBox(width: 8),
                    if (sseStore.unreadCount > 0)
                      TextButton(
                        onPressed: sseStore.markAllAsRead,
                        child: const Text('全部已读'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: sseStore.notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无消息通知',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '订单状态变更会自动推送',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: sseStore.notifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = sseStore.notifications[index];
                          return NotificationListTile(
                            notification: notification,
                            onTap: () {
                              sseStore.markAsRead(notification);
                              Navigator.pop(context);
                            },
                            onDismiss: () {
                              sseStore.markAsRead(notification);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
