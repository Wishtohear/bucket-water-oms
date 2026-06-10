import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';
import 'pages/login/login_page.dart';
import 'pages/admin/admin_routes.dart';
import 'pages/splash/splash_page.dart';
import 'stores/sse_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.init();
  await initStorage();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SseStore()),
      ],
      child: const WaterOMSApp(),
    ),
  );
}

Future<void> initStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(ApiConfig.tokenKey);
  final refreshToken = prefs.getString(ApiConfig.refreshTokenKey);
  final userRole = prefs.getString(ApiConfig.userRoleKey);
  final userId = prefs.getString(ApiConfig.userIdKey);
  final userName = prefs.getString('user_name');
  final stationName = prefs.getString('station_name');

  if (token != null) {
    await ApiConfig.saveToken(token);
  }
  if (refreshToken != null) {
    await ApiConfig.saveRefreshToken(refreshToken);
  }
  if (userRole != null) {
    await ApiConfig.saveUserRole(userRole);
  }
  if (userId != null) {
    await ApiConfig.saveUserId(userId);
  }

  if (userName != null) {
    AppState.currentUserNameStatic = userName;
  }
  if (stationName != null) {
    AppState.currentStationNameStatic = stationName;
  }
}

class AppState extends ChangeNotifier {
  static String currentUserNameStatic = '';
  static String currentStationNameStatic = '';

  int _selectedRoleIndex = 0;
  String _currentUserName = '';
  String _currentStationName = '';
  String? _userId;
  String? _token;
  String? _role;
  String? _stationId;
  String? _warehouseId;
  String? _driverId;

  int get selectedRoleIndex => _selectedRoleIndex;
  String get currentUserName => _currentUserName;
  String get currentStationName => _currentStationName;
  String? get userId => _userId;
  String? get token => _token;
  String? get role => _role;
  String? get stationId => _stationId;
  String? get warehouseId => _warehouseId;
  String? get driverId => _driverId;

  AppState() {
    _currentUserName = currentUserNameStatic;
    _currentStationName = currentStationNameStatic;
  }

  Future<void> setRoleIndex(int index) async {
    _selectedRoleIndex = index;
    notifyListeners();
  }

  Future<void> setUserInfo({
    required String name,
    required String station,
    String? userId,
    String? token,
    String? role,
  }) async {
    _currentUserName = name;
    _currentStationName = station;
    _userId = userId;
    _token = token;
    _role = role;

    currentUserNameStatic = name;
    currentStationNameStatic = station;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('station_name', station);
    if (userId != null) {
      await prefs.setString(ApiConfig.userIdKey, userId);
    }
    if (token != null) {
      await prefs.setString(ApiConfig.tokenKey, token);
      ApiConfig.saveToken(token);
    }
    if (role != null) {
      await prefs.setString(ApiConfig.userRoleKey, role);
    }

    notifyListeners();
  }

  Future<void> restoreUserInfo({
    String? userId,
    String? token,
    String? role,
    String? userName,
    String? stationName,
    String? stationId,
    String? warehouseId,
    String? driverId,
  }) async {
    _userId = userId;
    _token = token;
    _role = role;
    _currentUserName = userName ?? '';
    _currentStationName = stationName ?? '';
    _stationId = stationId;
    _warehouseId = warehouseId;
    _driverId = driverId;

    if (userName != null) {
      currentUserNameStatic = userName;
    }
    if (stationName != null) {
      currentStationNameStatic = stationName;
    }

    if (role != null) {
      final roleIndex = _getRoleIndex(role);
      _selectedRoleIndex = roleIndex;
    }

    print('═══════════════════════════════════════════════════════════');
    print('AppState: 用户信息已恢复');
    print('═══════════════════════════════════════════════════════════');
    print('userId: $userId');
    print('role: $role (index: $_selectedRoleIndex)');
    print('userName: $userName');
    print('stationName: $stationName');
    print('stationId: $stationId');
    print('warehouseId: $warehouseId');
    print('driverId: $driverId');
    print(
        'token: ${token != null ? "${token.substring(0, token.length > 20 ? 20 : token.length)}..." : "null"}');
    print('═══════════════════════════════════════════════════════════');

    notifyListeners();
  }

  int _getRoleIndex(String role) {
    switch (role) {
      case 'station':
        return 0;
      case 'driver':
        return 1;
      case 'warehouse':
        return 2;
      case 'admin':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> logout() async {
    _selectedRoleIndex = 0;
    _currentUserName = '';
    _currentStationName = '';
    _userId = null;
    _token = null;
    _role = null;
    _stationId = null;
    _warehouseId = null;
    _driverId = null;

    currentUserNameStatic = '';
    currentStationNameStatic = '';

    await ApiConfig.clearTokens();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('station_name');
    await prefs.remove(ApiConfig.userIdKey);
    await prefs.remove(ApiConfig.userRoleKey);
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.refreshTokenKey);
    await prefs.remove(ApiConfig.stationIdKey);
    await prefs.remove(ApiConfig.warehouseIdKey);
    await prefs.remove(ApiConfig.driverIdKey);

    notifyListeners();
  }
}

class WaterOMSApp extends StatelessWidget {
  const WaterOMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '水厂订货管理系统',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const SplashPage());
        }
        if (settings.name?.startsWith('/admin') ?? false) {
          return AdminRoutes.generateRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      },
      home: const SplashPage(),
    );
  }
}
