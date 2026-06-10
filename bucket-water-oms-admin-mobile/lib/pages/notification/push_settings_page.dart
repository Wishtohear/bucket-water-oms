import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../stores/sse_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PushSettingsPage extends StatelessWidget {
  const PushSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息推送设置'),
      ),
      body: Consumer<SseStore>(
        builder: (context, sseStore, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('推送提醒'),
              const SizedBox(height: 8),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: '声音提醒',
                subtitle: '收到推送时播放提示音',
                value: sseStore.soundEnabled,
                onChanged: (value) {
                  sseStore.setSoundEnabled(value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: '震动提醒',
                subtitle: '收到推送时震动手机',
                value: sseStore.vibrationEnabled,
                onChanged: (value) {
                  sseStore.setVibrationEnabled(value);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('连接状态'),
              const SizedBox(height: 8),
              _buildConnectionStatus(sseStore),
              const SizedBox(height: 24),
              _buildSectionTitle('测试'),
              const SizedBox(height: 8),
              _buildTestButtons(context, sseStore),
              const SizedBox(height: 24),
              _buildSectionTitle('通知权限'),
              const SizedBox(height: 8),
              _buildPermissionSection(context, sseStore),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.body2.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.body2),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(SseStore sseStore) {
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
      statusText = '未连接';
      statusIcon = Icons.wifi_off;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '实时推送连接',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
            if (sseStore.isConnected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '在线',
                      style: AppTextStyles.captionSmall.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context, SseStore sseStore) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final granted = await sseStore.requestNotificationPermissions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(granted ? '权限申请成功' : '权限申请失败，请手动开启'),
                    backgroundColor: granted ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications),
            label: const Text('申请权限'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await sseStore.testNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('测试通知已发送'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('发送测试'),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionSection(BuildContext context, SseStore sseStore) {
    return FutureBuilder<bool>(
      future: sseStore.isNotificationPermissionGranted(),
      builder: (context, snapshot) {
        final isGranted = snapshot.data ?? false;

        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isGranted ? AppColors.success : AppColors.warning).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isGranted ? Icons.check_circle : Icons.warning,
                    color: isGranted ? AppColors.success : AppColors.warning,
                  ),
                ),
                title: const Text('通知权限状态'),
                subtitle: Text(
                  isGranted ? '已授权' : '未授权',
                  style: AppTextStyles.caption.copyWith(
                    color: isGranted ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
              if (!isGranted)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        '通知权限未开启，将无法收到消息推送。\n请在系统设置中开启通知权限。',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await sseStore.requestNotificationPermissions();
                        },
                        child: const Text('前往授权'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
