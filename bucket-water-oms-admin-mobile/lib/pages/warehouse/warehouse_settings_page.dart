import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/warehouse_service.dart';
import '../../main.dart';
import '../login/login_page.dart';
import 'warehouse_operation_logs_page.dart';

class WarehouseSettingsPage extends StatefulWidget {
  const WarehouseSettingsPage({super.key});

  @override
  State<WarehouseSettingsPage> createState() => _WarehouseSettingsPageState();
}

class _WarehouseSettingsPageState extends State<WarehouseSettingsPage> {
  bool _isLoading = true;

  Map<String, dynamic>? _warehouseInfo;
  Map<String, dynamic>? _profileInfo;
  Map<String, dynamic>? _notificationSettings;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final warehouseService = WarehouseService();
      final warehouseId = ApiConfig.getWarehouseId();

      debugPrint('[WarehouseSettings] warehouseId: $warehouseId');

      if (warehouseId.isNotEmpty) {
        try {
          final warehouseInfo =
              await warehouseService.getWarehouseInfo(warehouseId);
          debugPrint('[WarehouseSettings] warehouseInfo: $warehouseInfo');

          Map<String, dynamic>? profileInfo;
          Map<String, dynamic>? notificationSettings;

          try {
            profileInfo = await warehouseService.getProfile(warehouseId);
            debugPrint('[WarehouseSettings] profileInfo: $profileInfo');
          } catch (e) {
            debugPrint('[WarehouseSettings] 获取个人信息失败: $e');
          }

          try {
            notificationSettings =
                await warehouseService.getNotificationSettings(warehouseId);
            debugPrint(
                '[WarehouseSettings] notificationSettings: $notificationSettings');
          } catch (e) {
            debugPrint('[WarehouseSettings] 获取通知设置失败: $e');
          }

          if (mounted) {
            setState(() {
              _warehouseInfo = warehouseInfo;
              _profileInfo = profileInfo;
              _notificationSettings = notificationSettings;
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint('[WarehouseSettings] 获取仓库信息失败: $e');
          if (mounted) {
            setState(() {
              _errorMessage = '获取仓库信息失败: $e';
              _isLoading = false;
            });
          }
        }
      } else {
        debugPrint('[WarehouseSettings] warehouseId 为空');
        if (mounted) {
          setState(() {
            _errorMessage = '未登录仓库账号';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[WarehouseSettings] 加载数据失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载数据失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _warehouseInfo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWarehouseInfo(),
          const SizedBox(height: 16),
          _buildProfileInfo(),
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

    final String displayName;
    if (_warehouseInfo?['name'] != null &&
        (_warehouseInfo?['name'] as String).isNotEmpty) {
      displayName = _warehouseInfo?['name'] as String;
    } else if (_profileInfo?['name'] != null &&
        (_profileInfo?['name'] as String).isNotEmpty) {
      displayName = _profileInfo?['name'] as String;
    } else if (appState.currentUserName.isNotEmpty) {
      displayName = appState.currentUserName;
    } else {
      displayName = '仓库管理员';
    }

    final String displayPhone;
    if (_profileInfo?['phone'] != null &&
        (_profileInfo?['phone'] as String).isNotEmpty) {
      displayPhone = _profileInfo?['phone'] as String;
    } else {
      displayPhone = '未设置';
    }

    final String displayCode;
    if (_profileInfo?['code'] != null &&
        (_profileInfo?['code'] as String).isNotEmpty) {
      displayCode = _profileInfo?['code'] as String;
    } else if (_warehouseInfo?['code'] != null &&
        (_warehouseInfo?['code'] as String).isNotEmpty) {
      displayCode = _warehouseInfo?['code'] as String;
    } else if (appState.userId != null && appState.userId!.isNotEmpty) {
      displayCode = appState.userId!;
    } else {
      displayCode = '未知';
    }

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
                      Icons.warehouse,
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
                  displayName,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '工号: $displayCode',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '手机: $displayPhone',
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
              '仓库管理员',
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
    final warehouseName = _warehouseInfo?['name'] ?? '未设置';
    final warehouseAddress =
        _warehouseInfo?['address'] ?? _warehouseInfo?['region'] ?? '暂无地址';

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
              label: '仓库名称',
              value: warehouseName,
              showArrow: false,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.location_on,
              iconColor: AppColors.purple,
              iconBgColor: AppColors.purple.withOpacity(0.1),
              label: '仓库地址',
              value: warehouseAddress,
              showArrow: false,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.inventory_2,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              label: '库位管理',
              value: '查看库位信息',
              showArrow: true,
              onTap: () => _showLocationManagement(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    final profileName = _profileInfo?['name'] ?? '未设置';
    final profilePhone =
        _profileInfo?['phone'] ?? _profileInfo?['mobile'] ?? '未设置';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '个人信息',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.person,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withOpacity(0.1),
              label: '姓名',
              value: profileName,
              showArrow: true,
              onTap: () => _showEditProfile('name'),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.phone,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              label: '手机号',
              value: profilePhone,
              showArrow: true,
              onTap: () => _showEditProfile('phone'),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.lock,
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withOpacity(0.1),
              label: '修改密码',
              value: '点击修改',
              showArrow: true,
              onTap: () => _showChangePassword(),
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
    final newOrderEnabled = _notificationSettings?['newOrder'] ?? true;
    final lowStockEnabled = _notificationSettings?['lowStock'] ?? true;
    final driverReturnEnabled = _notificationSettings?['driverReturn'] ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          children: [
            _buildNotificationItem(
              icon: Icons.shopping_cart,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withOpacity(0.1),
              label: '新订单提醒',
              value: newOrderEnabled,
              onChanged: (value) =>
                  _updateNotificationSetting('newOrder', value),
            ),
            _buildDivider(),
            _buildNotificationItem(
              icon: Icons.warning_amber,
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withOpacity(0.1),
              label: '库存预警提醒',
              value: lowStockEnabled,
              onChanged: (value) =>
                  _updateNotificationSetting('lowStock', value),
            ),
            _buildDivider(),
            _buildNotificationItem(
              icon: Icons.local_shipping,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              label: '司机回仓提醒',
              value: driverReturnEnabled,
              onChanged: (value) =>
                  _updateNotificationSetting('driverReturn', value),
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

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
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
          '数据最后同步: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    try {
      final warehouseService = WarehouseService();
      final warehouseId = ApiConfig.getWarehouseId();

      if (warehouseId.isEmpty) return;

      final newSettings =
          Map<String, dynamic>.from(_notificationSettings ?? {});
      newSettings[key] = value;

      await warehouseService.updateNotificationSettings(
        warehouseId,
        newOrder: newSettings['newOrder'] ?? true,
        lowStock: newSettings['lowStock'] ?? true,
        driverReturn: newSettings['driverReturn'] ?? true,
      );

      if (mounted) {
        setState(() {
          _notificationSettings = newSettings;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLocationManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('库位管理功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showEditProfile(String field) {
    String initialValue = '';
    String fieldKey = '';
    if (field == 'name') {
      initialValue = (_profileInfo?['name'] ?? '').toString();
      fieldKey = 'name';
    } else {
      initialValue =
          (_profileInfo?['phone'] ?? _profileInfo?['mobile'] ?? '').toString();
      fieldKey = 'phone';
    }
    final controller = TextEditingController(text: initialValue);
    final fieldKeyFinal = fieldKey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(field == 'name' ? '修改姓名' : '修改手机号'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field == 'name' ? '请输入姓名' : '请输入手机号',
          ),
          keyboardType:
              field == 'phone' ? TextInputType.phone : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitProfile(fieldKeyFinal, controller.text);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfile(String field, String value) async {
    if (value.isEmpty) return;

    try {
      final warehouseService = WarehouseService();
      final warehouseId = ApiConfig.getWarehouseId();

      if (warehouseId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('未登录仓库账号'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      await warehouseService.updateProfile(
        warehouseId,
        name: field == 'name' ? value : null,
        phone: field == 'phone' ? value : null,
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('修改成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('修改失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showChangePassword() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '旧密码',
                hintText: '请输入旧密码',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密码',
                hintText: '请输入新密码',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认密码',
                hintText: '请再次输入新密码',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('两次输入的密码不一致'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('密码长度不能少于6位'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _submitPassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPassword(String oldPassword, String newPassword) async {
    try {
      final warehouseService = WarehouseService();
      final warehouseId = ApiConfig.getWarehouseId();

      if (warehouseId.isEmpty) return;

      await warehouseService.changePassword(
        warehouseId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('密码修改成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('修改失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showOperationLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WarehouseOperationLogsPage()),
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
