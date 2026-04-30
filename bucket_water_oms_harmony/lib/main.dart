import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';
import 'pages/login/login_page.dart';
import 'pages/admin/admin_routes.dart';

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

  int get selectedRoleIndex => _selectedRoleIndex;
  String get currentUserName => _currentUserName;
  String get currentStationName => _currentStationName;
  String? get userId => _userId;
  String? get token => _token;
  String? get role => _role;
  String? get stationId => _stationId;

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

  Future<void> logout() async {
    _selectedRoleIndex = 0;
    _currentUserName = '';
    _currentStationName = '';
    _userId = null;
    _token = null;
    _role = null;

    currentUserNameStatic = '';
    currentStationNameStatic = '';

    await ApiConfig.clearTokens();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('station_name');

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
        if (settings.name?.startsWith('/admin') ?? false) {
          return AdminRoutes.generateRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      },
      home: const LoginPage(),
    );
  }
}
