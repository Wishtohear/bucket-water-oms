import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import 'notification_detail_page.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedType = '';
            break;
          case 1:
            _selectedType = 'order_status';
            break;
          case 2:
            _selectedType = 'statement_ready';
            break;
          case 3:
            _selectedType = 'bucket_warning';
            break;
          case 4:
            _selectedType = 'payment_reminder';
            break;
          case 5:
            _selectedType = 'system_notice';
            break;
        }
      });
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[NotificationListPage] 正在加载通知数据, type: $_selectedType');
      List<NotificationModel> notifications;
      if (_selectedType.isEmpty) {
        notifications = await _notificationService.getAllNotifications();
      } else {
        notifications =
            await _notificationService.getNotificationsByType(_selectedType);
      }

      print('[NotificationListPage] 获取到 ${notifications.length} 条通知');

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      print('[NotificationListPage] API异常: ${e.message}');
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[NotificationListPage] 未知错误: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载数据失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success) {
      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dateTime.month}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 0),
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildTabBar(),
              ],
            ),
          ),
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            '消息通知',
            style:
                AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: _markAllAsRead,
          child: Text(
            '全部已读',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = ['全部', '订单', '对账', '欠桶', '付款', '系统'];

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTextStyles.caption,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.label,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  Widget _buildNotificationList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: AppColors.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              '暂无消息',
              style:
                  AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isUnread = notification.isRead != true;

    return GestureDetector(
      onTap: () async {
        if (notification.id != null) {
          await _notificationService.markAsRead(notification.id!);
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetailPage(notification: notification),
          ),
        ).then((_) => _loadNotifications());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isUnread ? AppColors.primary.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeIcon(notification.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              _getTypeColor(notification.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          notification.typeText,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: _getTypeColor(notification.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notification.createTime),
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.title ?? '系统通知',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content ?? '',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String? type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'order_status':
        icon = Icons.local_shipping_outlined;
        color = AppColors.primary;
        break;
      case 'statement_ready':
        icon = Icons.description_outlined;
        color = AppColors.success;
        break;
      case 'bucket_warning':
        icon = Icons.warning_amber_outlined;
        color = AppColors.error;
        break;
      case 'payment_reminder':
        icon = Icons.account_balance_wallet_outlined;
        color = AppColors.warning;
        break;
      case 'system_notice':
        icon = Icons.campaign_outlined;
        color = AppColors.indigo;
        break;
      default:
        icon = Icons.notifications_outlined;
        color = AppColors.textSecondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'order_status':
        return AppColors.primary;
      case 'statement_ready':
        return AppColors.success;
      case 'bucket_warning':
        return AppColors.error;
      case 'payment_reminder':
        return AppColors.warning;
      case 'system_notice':
        return AppColors.indigo;
      default:
        return AppColors.textSecondary;
    }
  }
}
