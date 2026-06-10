import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../stores/sse_store.dart';
import '../../shared/widgets/sse_status_widget.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PushNotificationDemoPage extends StatefulWidget {
  const PushNotificationDemoPage({super.key});

  @override
  State<PushNotificationDemoPage> createState() =>
      _PushNotificationDemoPageState();
}

class _PushNotificationDemoPageState extends State<PushNotificationDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息推送演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SseStore>().connect(
                    '1',
                    'station',
                  );
            },
            tooltip: '重新连接',
          ),
        ],
      ),
      body: Consumer<SseStore>(
        builder: (context, sseStore, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '连接状态',
                        ),
                        const Spacer(),
                        SseStatusIndicator(showLabel: true),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusChip(
                          '已接收',
                          '${sseStore.notifications.length}',
                          AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          '未读',
                          '${sseStore.unreadCount}',
                          AppColors.error,
                        ),
                        const Spacer(),
                        if (sseStore.unreadCount > 0)
                          TextButton(
                            onPressed: sseStore.markAllAsRead,
                            child: const Text('全部已读'),
                          ),
                      ],
                    ),
                    if (sseStore.lastError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sseStore.lastError!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                              size: 80,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无消息',
                              style: AppTextStyles.subtitle1.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '当有订单状态变更时，\n消息会实时推送到这里',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                sseStore.connect('1', 'station');
                              },
                              icon: const Icon(Icons.wifi),
                              label: const Text('模拟连接'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: sseStore.notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = sseStore.notifications[index];
                          return _buildNotificationCard(notification, sseStore);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<SseStore>(
        builder: (context, sseStore, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              NotificationListSheet.show(context);
            },
            icon: const Icon(Icons.notifications),
            label: Text(
                '通知 ${sseStore.unreadCount > 0 ? "(${sseStore.unreadCount})" : ""}'),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification, SseStore sseStore) {
    final isUnread = sseStore.unreadNotifications.contains(notification);
    final isDelivered = notification.isDeliveryTask;

    return Card(
      elevation: isUnread ? 2 : 0,
      color: isUnread ? Colors.white : AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread
            ? const BorderSide(color: AppColors.primary, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isUnread) {
            sseStore.markAsRead(notification);
          }
          _showNotificationDetail(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _getEventColor(notification.event).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getEventIcon(notification.event),
                      color: _getEventColor(notification.event),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.eventDisplayName,
                          style: AppTextStyles.caption.copyWith(
                            color: _getEventColor(notification.event),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.content,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (notification.orderNo != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '订单号: ${notification.orderNo}',
                    style: AppTextStyles.captionSmall,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(notification.timestamp),
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (isDelivered) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '新任务',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(dynamic notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.content),
              const Divider(),
              _buildDetailRow('事件类型', notification.eventDisplayName),
              if (notification.orderNo != null)
                _buildDetailRow('订单号', notification.orderNo),
              if (notification.stationName != null)
                _buildDetailRow('水站', notification.stationName),
              if (notification.warehouseName != null)
                _buildDetailRow('仓库', notification.warehouseName),
              if (notification.driverName != null)
                _buildDetailRow('司机', notification.driverName),
              if (notification.actualQty != null)
                _buildDetailRow('实收数量', '${notification.actualQty}'),
              if (notification.bucketReturned != null)
                _buildDetailRow('回桶数量', '${notification.bucketReturned}'),
              if (notification.reason != null)
                _buildDetailRow('原因', notification.reason),
              _buildDetailRow('时间', notification.timestamp.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          if (notification.orderId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('查看订单'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String event) {
    switch (event) {
      case 'order_created':
        return Icons.add_shopping_cart;
      case 'order_reviewed':
        return Icons.check_circle;
      case 'order_rejected':
        return Icons.cancel;
      case 'order_dispatched':
        return Icons.local_shipping;
      case 'order_delivering':
        return Icons.delivery_dining;
      case 'order_completed':
        return Icons.done_all;
      case 'order_cancelled':
        return Icons.block;
      case 'new_delivery_task':
        return Icons.notification_important;
      default:
        return Icons.notifications;
    }
  }

  Color _getEventColor(String event) {
    switch (event) {
      case 'order_created':
        return AppColors.primary;
      case 'order_reviewed':
      case 'order_completed':
        return AppColors.success;
      case 'order_rejected':
      case 'order_cancelled':
        return AppColors.error;
      case 'order_dispatched':
      case 'order_delivering':
        return AppColors.warning;
      case 'new_delivery_task':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
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
      return '${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
