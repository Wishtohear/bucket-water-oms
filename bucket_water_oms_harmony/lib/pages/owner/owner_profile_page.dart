import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../main.dart';
import '../login/login_page.dart';
import 'owner_routes.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OwnerProfileContent();
  }
}

class _OwnerProfileContent extends StatelessWidget {
  const _OwnerProfileContent();

  final Map<String, dynamic> _userData = const {
    'name': '张记水站 - 张老板',
    'phone': '138****8888',
    'avatar': '',
    'accountBalance': 12500.00,
    'ticketCount': 156,
    'owedBarrels': 8,
  };

  final List<Map<String, dynamic>> _notifications = const [
    {
      'title': '对账单提醒',
      'content': '您2026年3月份对账单已生成，请及时确认',
      'time': '今天 09:00',
      'type': 'info',
      'icon': Icons.campaign,
      'color': AppColors.primary,
    },
    {
      'title': '欠桶预警',
      'content': '您当前欠桶8个，已接近阈值10个，请及时补缴押金',
      'time': '昨天 15:30',
      'type': 'warning',
      'icon': Icons.warning,
      'color': AppColors.error,
    },
    {
      'title': '订单完成',
      'content': '订单#202604180082已完成配送，签收照片已上传',
      'time': '04-18 14:30',
      'type': 'success',
      'icon': Icons.check_circle,
      'color': AppColors.success,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildBusinessMenu(context),
            const SizedBox(height: 16),
            _buildFinancialMenu(context),
            const SizedBox(height: 16),
            _buildSettingsMenu(context),
            const SizedBox(height: 16),
            _buildNotificationsSection(),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
            _buildVersionInfo(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 32, 24, 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['name'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _userData['phone'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAccountInfo(
                  '预存金 (元)',
                  '¥ ${(_userData['accountBalance'] as double).toStringAsFixed(2)}',
                  AppColors.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                ),
                _buildAccountInfo(
                  '可用水票 (张)',
                  '${_userData['ticketCount']}',
                  AppColors.success,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                ),
                _buildAccountInfo(
                  '欠桶 (个)',
                  '${_userData['owedBarrels']}',
                  AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        borderColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              context: context,
              icon: Icons.account_balance_wallet,
              label: '充值',
              color: AppColors.primary,
              bgColor: AppColors.primary.withOpacity(0.1),
              onTap: () => Navigator.pushNamed(context, OwnerRoutes.recharge),
            ),
            _buildQuickActionItem(
              context: context,
              icon: Icons.receipt_long,
              label: '对账',
              color: AppColors.success,
              bgColor: AppColors.success.withOpacity(0.1),
              onTap: () => Navigator.pushNamed(context, OwnerRoutes.statement),
            ),
            _buildQuickActionItem(
              context: context,
              icon: Icons.inventory_2,
              label: '空桶',
              color: AppColors.purple,
              bgColor: AppColors.purple.withOpacity(0.1),
              onTap: () =>
                  Navigator.pushNamed(context, OwnerRoutes.bucketExchange),
            ),
            _buildQuickActionItem(
              context: context,
              icon: Icons.confirmation_number,
              label: '水票',
              color: AppColors.rose,
              bgColor: AppColors.rose.withOpacity(0.1),
              onTap: () =>
                  Navigator.pushNamed(context, OwnerRoutes.ticketManage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.captionSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '业务管理',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.primary,
              label: '我的订单',
              trailing: Text(
                '全部订单',
                style: AppTextStyles.captionSmall,
              ),
              onTap: () => Navigator.pushNamed(context, OwnerRoutes.orders),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.people_outline,
              iconColor: AppColors.indigo,
              label: '客户管理',
              onTap: () =>
                  Navigator.pushNamed(context, OwnerRoutes.customerList),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.bar_chart_outlined,
              iconColor: AppColors.amber,
              label: '数据统计',
              onTap: () => Navigator.pushNamed(context, OwnerRoutes.statistics),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.confirmation_number,
              iconColor: AppColors.rose,
              label: '水票管理',
              onTap: () =>
                  Navigator.pushNamed(context, OwnerRoutes.ticketManage),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '财务管理',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.primary,
              label: '账户充值',
              trailing: Text(
                '余额 ¥12,500',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.pushNamed(context, OwnerRoutes.recharge),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.inventory_2,
              iconColor: AppColors.purple,
              label: '空桶往来',
              trailing: Text(
                '欠桶 8个',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () =>
                  Navigator.pushNamed(context, OwnerRoutes.bucketExchange),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.receipt_long,
              iconColor: AppColors.success,
              label: '对账单',
              trailing: Text(
                '待确认',
                style: AppTextStyles.captionSmall,
              ),
              onTap: () => Navigator.pushNamed(context, OwnerRoutes.statement),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '系统',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              iconColor: AppColors.textSecondary,
              label: '系统设置',
              onTap: () {},
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.security_outlined,
              iconColor: AppColors.textSecondary,
              label: '账号与安全',
              onTap: () {},
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              iconColor: AppColors.textSecondary,
              label: '帮助与反馈',
              onTap: () {},
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '消息通知',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '全部已读',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_notifications.length, (index) {
              final notification = _notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (notification['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: notification['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'] as String,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['content'] as String,
                            style: AppTextStyles.captionSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['time'] as String,
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '退出登录',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '当前版本 v2.1.0 | 今天是 2026年04月21日',
        style: AppTextStyles.captionSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AppState>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              '确定',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
