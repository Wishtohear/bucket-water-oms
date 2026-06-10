import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../main.dart';
import '../login/login_page.dart';
import '../owner/owner_home_page.dart';
import '../driver/driver_tasks_page.dart';
import '../warehouse/warehouse_home_page.dart';
import '../admin/admin_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final token = ApiConfig.getToken();
    final role = ApiConfig.getUserRole();

    print('═══════════════════════════════════════════════════════════');
    print('SplashPage: 检查登录状态');
    print('═══════════════════════════════════════════════════════════');
    print('token: ${token.isNotEmpty ? "${token.substring(0, token.length > 20 ? 20 : token.length)}..." : "empty"}');
    print('role: $role');
    print('═══════════════════════════════════════════════════════════');

    if (token.isNotEmpty && role.isNotEmpty) {
      await _restoreUserSession();
      _navigateToHome(role);
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _restoreUserSession() async {
    final appState = context.read<AppState>();

    final userId = ApiConfig.getUserId();
    final token = ApiConfig.getToken();
    final role = ApiConfig.getUserRole();
    final userName = await _getUserName();
    final stationName = await _getStationName();

    await appState.restoreUserInfo(
      userId: userId.isNotEmpty ? userId : null,
      token: token.isNotEmpty ? token : null,
      role: role.isNotEmpty ? role : null,
      userName: userName.isNotEmpty ? userName : null,
      stationName: stationName.isNotEmpty ? stationName : null,
      stationId: ApiConfig.getStationId().isNotEmpty ? ApiConfig.getStationId() : null,
      warehouseId: ApiConfig.getWarehouseId().isNotEmpty ? ApiConfig.getWarehouseId() : null,
      driverId: ApiConfig.getDriverId().isNotEmpty ? ApiConfig.getDriverId() : null,
    );
  }

  Future<String> _getUserName() async {
    return '';
  }

  Future<String> _getStationName() async {
    return '';
  }

  void _navigateToHome(String role) {
    if (!mounted) return;

    Widget homePage;
    switch (role) {
      case 'station':
        homePage = const OwnerHomePage();
        break;
      case 'driver':
        homePage = const DriverTasksPage();
        break;
      case 'warehouse':
        homePage = const WarehouseHomePage();
        break;
      case 'admin':
        homePage = const AdminHomePage();
        break;
      default:
        _navigateToLogin();
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => homePage),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '水厂订货管理系统',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '智慧水务 · 快捷订货',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
