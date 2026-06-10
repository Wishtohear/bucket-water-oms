import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/phone_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/driver_service.dart';
import '../../services/driver_status_service.dart';
import '../../services/auth_service.dart';
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
  bool _isLoading = true;
  DriverInfoData? _driverInfo;
  final DriverService _driverService = DriverService();
  final DriverStatusService _statusService = DriverStatusService();
  bool _isStatusLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
    _initDriverStatus();
  }

  void _initDriverStatus() {
    final driverId = ApiConfig.getDriverId();
    if (driverId != null && driverId.isNotEmpty) {
      _statusService.initDriver(driverId);
    }
  }

  Future<void> _loadDriverInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverId = ApiConfig.getDriverId();

      if (driverId != null && driverId.isNotEmpty) {
        final info = await _driverService.getDriverInfo(driverId);
        setState(() {
          _driverInfo = info;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _showCustomerServiceDialog() {
    final customerServicePhone = '400-888-8888';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '联系客服',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.headset_mic,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '客服热线',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customerServicePhone,
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '工作时间: 8:00-22:00',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '取消',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          PhoneUtils.makePhoneCall(customerServicePhone,
                              context: context);
                        },
                        icon: const Icon(Icons.phone,
                            color: Colors.white, size: 20),
                        label: const Text('立即拨打'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDriverInfo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildAccountInfoCard(),
            const SizedBox(height: 16),
            _buildSettingsListCard(),
            const SizedBox(height: 16),
            _buildLogoutButton(),
            _buildVersionInfo(),
            const SizedBox(height: 100),
          ],
        ),
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
                      _driverInfo?.name ?? '司机',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '工号: ${_driverInfo?.code ?? '未设置'}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_driverInfo?.vehicle != null &&
                            _driverInfo!.vehicle!.isNotEmpty)
                          _buildBadge(_driverInfo!.vehicle!.split(' ')[0]),
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
                    '今日配送', '${_driverInfo?.todayDeliveries ?? 0} 单'),
              ),
              Expanded(
                child: _buildStatItem(
                    '累计完成', '${_driverInfo?.totalDeliveries ?? 0} 单'),
              ),
              Expanded(
                child: _buildStatItem(
                    '本月收入',
                    _driverInfo != null
                        ? '¥${_driverInfo!.monthIncome.toStringAsFixed(0)}'
                        : '未设置'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, {bool isStatus = false}) {
    Color badgeColor;
    if (isStatus) {
      final statusType = _statusService.currentStatusType;
      switch (statusType) {
        case DriverStatusType.online:
          badgeColor = AppColors.success;
          text = '在线';
          break;
        case DriverStatusType.offline:
          badgeColor = AppColors.textTertiary;
          text = '离线';
          break;
        case DriverStatusType.breakTime:
          badgeColor = AppColors.warning;
          text = '休息';
          break;
      }
    } else {
      badgeColor = Colors.white.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: _isStatusLoading ? null : () => _showStatusChangeDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isStatus ? badgeColor.withOpacity(0.15) : badgeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badgeColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isStatusLoading)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: isStatus ? badgeColor : Colors.white,
                ),
              )
            else
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTextStyles.captionSmall.copyWith(
                color: isStatus ? badgeColor : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isStatusLoading) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: isStatus ? badgeColor : Colors.white70,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '更改在线状态',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildStatusOption(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                title: '在线',
                subtitle: '可以接收新配送任务',
                isSelected: _statusService.isOnline,
                onTap: () => _changeStatus(DriverStatusType.online),
              ),
              _buildStatusOption(
                icon: Icons.pause_circle,
                iconColor: AppColors.warning,
                title: '休息中',
                subtitle: '暂停接收新任务',
                isSelected: _statusService.isOnBreak,
                onTap: () => _changeStatus(DriverStatusType.breakTime),
              ),
              _buildStatusOption(
                icon: Icons.cancel,
                iconColor: AppColors.textTertiary,
                title: '离线',
                subtitle: '不接收新配送任务',
                isSelected: _statusService.isOffline,
                onTap: () => _changeStatus(DriverStatusType.offline),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeStatus(DriverStatusType newStatus) async {
    Navigator.pop(context);

    setState(() {
      _isStatusLoading = true;
    });

    bool success = false;
    String message = '';

    switch (newStatus) {
      case DriverStatusType.online:
        success = await _statusService.goOnline();
        message = success ? '上线成功' : '上线失败';
        break;
      case DriverStatusType.offline:
        success = await _statusService.goOffline();
        message = success ? '已离线' : '离线失败';
        break;
      case DriverStatusType.breakTime:
        success = await _statusService.goOnBreak();
        message = success ? '休息模式已开启' : '操作失败';
        break;
    }

    setState(() {
      _isStatusLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    await _loadDriverInfo();
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
              value: _driverInfo?.phone ?? '未设置',
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.directions_car_outlined,
              iconColor: AppColors.success,
              label: '绑定车辆',
              value: _driverInfo?.vehicle ?? '未设置',
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.warehouse_outlined,
              iconColor: AppColors.purple,
              label: '负责仓库',
              value: _driverInfo?.warehouse ?? '未设置',
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.map_outlined,
              iconColor: AppColors.orange,
              label: '配送区域',
              value: _driverInfo?.area ?? '未设置',
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中')),
                );
              },
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中')),
                );
              },
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.print_outlined,
              iconColor: AppColors.success,
              label: '蓝牙打印',
              trailing: Text(
                '未连接',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中')),
                );
              },
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.security_outlined,
              iconColor: AppColors.orange,
              label: '账号安全',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中')),
                );
              },
            ),
            const Divider(height: 1, indent: 60),
            _buildSettingsItem(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.indigo,
              label: '联系客服',
              onTap: () {
                _showCustomerServiceDialog();
              },
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
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: '水厂订货管理系统',
                  applicationVersion: 'v2.1.0',
                  applicationLegalese: '© 2026 水厂订货管理系统',
                );
              },
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
            '2026-04-24',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
