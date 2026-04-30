import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../core/network/api_client.dart';
import '../owner/owner_home_page.dart';
import '../driver/driver_tasks_page.dart';
import '../warehouse/warehouse_home_page.dart';
import '../admin/admin_home_page.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController(text: '13800138000');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(int roleIndex) async {
    if (_isLoading) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      _showError('请输入手机号');
      return;
    }
    if (password.isEmpty) {
      _showError('请输入密码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final role = authService.getRoleFromIndex(roleIndex);
      final request = LoginRequest(
        phone: phone,
        password: password,
        role: role,
      );

      final response = await authService.login(request);
      final appState = context.read<AppState>();

      String userName = response.userName ?? '用户';
      String stationName = '';

      switch (roleIndex) {
        case 0:
          stationName = response.stationName ?? '水站';
          await appState.setUserInfo(
            name: userName,
            station: stationName,
            userId: response.id,
            token: response.token,
            role: role,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OwnerHomePage()),
            );
          }
          break;
        case 1:
          stationName = '司机';
          await appState.setUserInfo(
            name: userName,
            station: stationName,
            userId: response.id,
            token: response.token,
            role: role,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DriverTasksPage()),
            );
          }
          break;
        case 2:
          stationName = response.stationName ?? '仓库';
          await appState.setUserInfo(
            name: userName,
            station: stationName,
            userId: response.id,
            token: response.token,
            role: role,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WarehouseHomePage()),
            );
          }
          break;
        case 3:
          stationName = '水厂管理';
          await appState.setUserInfo(
            name: userName,
            station: stationName,
            userId: response.id,
            token: response.token,
            role: role,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
            );
          }
          break;
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('登录失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleDemoLogin(int roleIndex) {
    final appState = context.read<AppState>();
    appState.setRoleIndex(roleIndex);

    switch (roleIndex) {
      case 0:
        appState.setUserInfo(name: '张老板', station: '张记旗舰水站');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerHomePage()),
        );
        break;
      case 1:
        appState.setUserInfo(name: '王力师傅', station: '豫A·88888');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverTasksPage()),
        );
        break;
      case 2:
        appState.setUserInfo(name: '仓库管理员', station: '中心仓库 A库区');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WarehouseHomePage()),
        );
        break;
      case 3:
        appState.setUserInfo(name: '系统管理员', station: '水厂总部');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 48),
              _buildForm(),
              const SizedBox(height: 32),
              _buildRoleSelection(),
              const SizedBox(height: 24),
              _buildLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop,
            color: AppColors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '水厂订货管理系统',
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '智慧水务 · 快捷订货',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppTextField(
          controller: _phoneController,
          hintText: '请输入手机号',
          prefixIcon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _passwordController,
          hintText: '请输入密码',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLoading ? '登录中...' : '选择登录身份',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: _isLoading ? '请稍候' : '水站老板端',
                type: AppButtonType.primary,
                onPressed: _isLoading ? () {} : () => _handleLogin(0),
                height: 56,
                icon: Icons.store,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: _isLoading ? '请稍候' : '司机配送端',
                type: AppButtonType.secondary,
                onPressed: _isLoading ? () {} : () => _handleLogin(1),
                height: 56,
                icon: Icons.local_shipping,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: _isLoading ? '请稍候' : '仓库管理端',
                type: AppButtonType.outline,
                onPressed: _isLoading ? () {} : () => _handleLogin(2),
                height: 56,
                icon: Icons.warehouse,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: _isLoading ? '请稍候' : '管理员端',
                type: AppButtonType.primary,
                onPressed: _isLoading ? () {} : () => _handleLogin(3),
                height: 56,
                icon: Icons.admin_panel_settings,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    _showDemoLoginDialog();
                  },
            child: Text(
              '演示模式登录',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDemoLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('演示模式'),
        content: const Text('是否使用演示数据登录？\n\n演示数据将使用模拟的用户信息，不会连接真实后端。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDemoLogin(0);
            },
            child: const Text('水站老板'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDemoLogin(1);
            },
            child: const Text('司机'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDemoLogin(2);
            },
            child: const Text('仓库管理员'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDemoLogin(3);
            },
            child: const Text('系统管理员'),
          ),
        ],
      ),
    );
  }

  Widget _buildLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('忘记密码功能开发中')),
            );
          },
          child: Text(
            '忘记密码？',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('注册功能开发中')),
            );
          },
          child: Text(
            '新用户注册',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
