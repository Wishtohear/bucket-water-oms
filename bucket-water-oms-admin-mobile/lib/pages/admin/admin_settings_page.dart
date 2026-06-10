import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/admin_audit_logs_service.dart';
import '../../main.dart';
import '../login/login_page.dart';
import 'admin_audit_logs_page.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final AdminAuditLogsService _auditService = AdminAuditLogsService();
  List<AuditLogModel>? _recentLogs;
  bool _isLoadingLogs = false;

  @override
  void initState() {
    super.initState();
    _loadRecentLogs();
  }

  Future<void> _loadRecentLogs() async {
    setState(() {
      _isLoadingLogs = true;
    });

    try {
      final response = await _auditService.getRecentLogs(limit: 3);

      if (mounted) {
        setState(() {
          _recentLogs = response;
          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLogs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '系统设置与维护',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildWideLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildAdminManagement(context),
                const SizedBox(height: 24),
                _buildBaseConfiguration(context),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildAuditLogs(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAdminManagement(context),
          const SizedBox(height: 16),
          _buildBaseConfiguration(context),
          const SizedBox(height: 16),
          _buildAuditLogs(context),
          const SizedBox(height: 16),
          _buildLogoutButton(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAdminManagement(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '管理员权限',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '+ 添加管理员',
                type: AppButtonType.primary,
                onPressed: () => _showComingSoon('添加管理员'),
                height: 36,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdminItem(
            context,
            name: '超级管理员 (张三)',
            role: '拥有所有系统权限',
            lastLogin: '2小时前',
            isSuperAdmin: true,
          ),
          const SizedBox(height: 12),
          _buildAdminItem(
            context,
            name: '财务主管 (李四)',
            role: '财务模块完全权限',
            lastLogin: '1天前',
            isSuperAdmin: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminItem(
    BuildContext context, {
    required String name,
    required String role,
    required String lastLogin,
    required bool isSuperAdmin,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSuperAdmin ? AppColors.primary : AppColors.purple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$role · 最后登录: $lastLogin',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
            onPressed: () => _showComingSoon('编辑管理员'),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseConfiguration(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基础业务配置',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildConfigField(
            label: '水厂名称',
            value: '清泉流响水厂总部',
            hint: '请输入水厂名称',
          ),
          const SizedBox(height: 16),
          _buildConfigField(
            label: '客服电话',
            value: '400-888-9999',
            hint: '请输入客服电话',
          ),
          const SizedBox(height: 16),
          _buildConfigFieldWithSuffix(
            label: '对账单确认期限',
            value: '3',
            suffix: '天',
            hint: '请输入天数',
            description: '水站收到对账单后，需在此期限内确认或提出争议',
          ),
          const SizedBox(height: 16),
          _buildConfigFieldWithSuffix(
            label: '库存预警阈值 (通用)',
            value: '200',
            suffix: '单位',
            hint: '请输入阈值',
            description: '当库存低于此值时发送预警通知',
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: '重置',
                type: AppButtonType.outline,
                onPressed: () {},
                height: 44,
              ),
              const SizedBox(width: 12),
              AppButton(
                text: '保存全局设置',
                type: AppButtonType.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('配置已保存'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                height: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigField({
    required String label,
    required String value,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            style: AppTextStyles.body2,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigFieldWithSuffix({
    required String label,
    required String value,
    required String suffix,
    required String hint,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  style: AppTextStyles.body2,
                  keyboardType: TextInputType.number,
                ),
              ),
              Text(
                suffix,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuditLogs(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '系统审计日志',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAuditLogsPage()),
                  );
                },
                child: Text(
                  '查看全部',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingLogs)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            )
          else if (_recentLogs == null || _recentLogs!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无操作日志',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_recentLogs ?? []).map((log) => _buildLogItemFromModel(log)),
        ],
      ),
    );
  }

  Widget _buildLogItemFromModel(AuditLogModel log) {
    Color actionColor;
    IconData actionIcon;

    switch (log.action) {
      case 'login':
        actionColor = AppColors.primary;
        actionIcon = Icons.login;
        break;
      case 'create':
        actionColor = AppColors.success;
        actionIcon = Icons.add_circle_outline;
        break;
      case 'update':
        actionColor = AppColors.warning;
        actionIcon = Icons.edit_outlined;
        break;
      case 'delete':
        actionColor = AppColors.error;
        actionIcon = Icons.delete_outline;
        break;
      case 'export':
        actionColor = AppColors.purple;
        actionIcon = Icons.download_outlined;
        break;
      default:
        actionColor = AppColors.textSecondary;
        actionIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              actionIcon,
              color: actionColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getActionText(log.action),
                        style: AppTextStyles.captionSmall.copyWith(
                          color: actionColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: log.isSuccess
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.isSuccess ? '成功' : '失败',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: log.isSuccess ? AppColors.success : AppColors.error,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.module ?? '系统',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  log.entityName ?? log.requestUrl ?? '',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatLogTime(log.createTime),
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                log.username ?? '系统',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActionText(String? action) {
    switch (action) {
      case 'login':
        return '登录';
      case 'create':
        return '创建';
      case 'update':
        return '更新';
      case 'delete':
        return '删除';
      case 'export':
        return '导出';
      case 'approve':
        return '审核通过';
      case 'reject':
        return '审核拒绝';
      case 'cancel':
        return '取消';
      default:
        return action ?? '未知';
    }
  }

  String _formatLogTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
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

  Widget _buildLogoutButton() {
    return GestureDetector(
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
    );
  }

  void _showComingSoon(String feature) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能开发中'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _showLogoutDialog() {
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
