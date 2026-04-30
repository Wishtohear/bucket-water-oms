import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../main.dart';
import '../login/login_page.dart';

class DriverSettingsPage extends StatelessWidget {
  const DriverSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DriverSettingsContent();
  }
}

class _DriverSettingsContent extends StatefulWidget {
  const _DriverSettingsContent();

  @override
  State<_DriverSettingsContent> createState() => _DriverSettingsContentState();
}

class _DriverSettingsContentState extends State<_DriverSettingsContent> {
  bool _isOnline = true;

  final Map<String, dynamic> _driverData = {
    'name': '王力师傅',
    'code': 'DRV-2024-001',
    'phone': '138****8888',
    'vehicle': '豫A·88888 蓝色货车',
    'warehouse': '中心仓库 A库区',
    'area': '桂林市全城',
    'todayDeliveries': 8,
    'totalDeliveries': 1258,
    'monthIncome': '¥8.5k',
  };

  void _showOnlineStatusDialog(bool isOnline) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isOnline ? '已上线' : '已离线'),
        content: Text(
          isOnline ? '您已上线，现在可以接收新配送任务' : '您已离线，将不会接收新配送任务\n当前配送任务不受影响',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？\n\n退出后将无法接收新的配送任务。'),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildAccountInfoCard(),
          const SizedBox(height: 16),
          _buildSettingsListCard(),
          const SizedBox(height: 16),
          _buildOnlineToggleCard(),
          const SizedBox(height: 16),
          _buildLogoutButton(),
          _buildVersionInfo(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 40, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
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
                      _driverData['name'] as String,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '工号: ${_driverData['code']}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge(
                            _driverData['vehicle'].toString().split(' ')[0]),
                        const SizedBox(width: 8),
                        _buildBadge('在线', isStatus: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    '今日配送', '${_driverData['todayDeliveries']} 单'),
              ),
              Expanded(
                child: _buildStatItem(
                    '累计完成', '${_driverData['totalDeliveries']} 单'),
              ),
              Expanded(
                child: _buildStatItem(
                    '本月收入', _driverData['monthIncome'] as String),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, {bool isStatus = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isStatus ? AppColors.success : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionSmall.copyWith(
          color: isStatus ? AppColors.success : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          children: [
            _buildInfoItem(
              icon: Icons.phone_outlined,
              iconColor: AppColors.primary,
              label: '联系电话',
              value: _driverData['phone'] as String,
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.directions_car_outlined,
              iconColor: AppColors.success,
              label: '绑定车辆',
              value: _driverData['vehicle'] as String,
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.warehouse_outlined,
              iconColor: AppColors.purple,
              label: '负责仓库',
              value: _driverData['warehouse'] as String,
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.map_outlined,
              iconColor: AppColors.orange,
              label: '配送区域',
              value: _driverData['area'] as String,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
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
                style: AppTextStyles.caption.copyWith(
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
        const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildSettingsListCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.primary,
              label: '消息通知',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '已开启',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.navigation_outlined,
              iconColor: AppColors.purple,
              label: '导航设置',
              trailing: Text(
                '高德地图',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.print_outlined,
              iconColor: AppColors.success,
              label: '蓝牙打印',
              trailing: Text(
                '已连接',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.security_outlined,
              iconColor: AppColors.orange,
              label: '账号安全',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.indigo,
              label: '联系客服',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.info_outline,
              iconColor: AppColors.textSecondary,
              label: '关于我们',
              trailing: Text(
                'v2.1.0',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    Widget? trailing,
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineToggleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time_filled,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '在线接单',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '开启后将接收新配送任务',
                        style: AppTextStyles.captionSmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (value) {
                    setState(() {
                      _isOnline = value;
                    });
                    _showOnlineStatusDialog(value);
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '切换为离线后，当前配送任务不受影响，但不会接收新订单。',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _showLogoutDialog,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.error.withOpacity(0.1),
            ),
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
      child: Column(
        children: [
          Text(
            '水厂订货管理系统 · 司机端 v2.1.0',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '2026-04-21',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
