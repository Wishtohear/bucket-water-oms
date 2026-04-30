import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../main.dart';
import '../login/login_page.dart';

class WarehouseSettingsPage extends StatefulWidget {
  const WarehouseSettingsPage({super.key});

  @override
  State<WarehouseSettingsPage> createState() => _WarehouseSettingsPageState();
}

class _WarehouseSettingsPageState extends State<WarehouseSettingsPage> {
  final int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWarehouseInfo(),
          const SizedBox(height: 16),
          _buildSettingsList(),
          const SizedBox(height: 24),
          _buildVersionInfo(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final appState = context.watch<AppState>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Row(
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
              child: Image.network(
                'https://modao.cc/agent-py/media/generated_images/2026-04-19/ccffcecb3a5c481d86feb6258243b7e8.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.currentUserName.isNotEmpty
                      ? appState.currentUserName
                      : '王管理',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '工号: ${appState.userId ?? 'WMS-2026-001'}',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '高级管理员',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          children: [
            _buildInfoItem(
              icon: Icons.business,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withOpacity(0.1),
              label: '所属机构',
              value: '水务科技中心仓库',
              showArrow: false,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.location_on,
              iconColor: AppColors.purple,
              iconBgColor: AppColors.purple.withOpacity(0.1),
              label: '库位管理',
              value: 'A区、B区、成品库',
              showArrow: true,
              onTap: () {
                _showLocationManagement();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required bool showArrow,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.shield,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              label: '权限设置',
              onTap: () => _showPermissionSettings(),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.history,
              iconColor: AppColors.orange,
              iconBgColor: AppColors.orange.withOpacity(0.1),
              label: '操作日志',
              onTap: () => _showOperationLogs(),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.notifications,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withOpacity(0.1),
              label: '消息提醒',
              onTap: () => _showNotificationSettings(),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.logout,
              iconColor: AppColors.error,
              iconBgColor: AppColors.error.withOpacity(0.1),
              label: '退出登录',
              labelColor: AppColors.error,
              showArrow: false,
              onTap: () => _showLogoutConfirmation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    Color? labelColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  color: labelColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 60,
      color: AppColors.borderLight,
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          '水厂订货管理系统 V4.2.0',
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '数据最后同步: 2026-04-19 14:30',
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  void _showLocationManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('库位管理功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPermissionSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('权限设置功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showOperationLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('操作日志功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('消息提醒功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
