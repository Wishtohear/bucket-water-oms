import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.31.72:8080/api';
  static const Duration timeout = Duration(seconds: 30);
  static const Duration refreshTimeout = Duration(minutes: 5);

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';

  static const String roleStation = 'station';
  static const String roleDriver = 'driver';
  static const String roleWarehouse = 'warehouse';
  static const String roleAdmin = 'admin';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getToken() {
    return _prefs?.getString(tokenKey) ?? '';
  }

  static Future<void> saveToken(String token) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(tokenKey, token);
  }

  static String getRefreshToken() {
    return _prefs?.getString(refreshTokenKey) ?? '';
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(refreshTokenKey, refreshToken);
  }

  static String getUserRole() {
    return _prefs?.getString(userRoleKey) ?? '';
  }

  static Future<void> saveUserRole(String role) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(userRoleKey, role);
  }

  static String getUserId() {
    return _prefs?.getString(userIdKey) ?? '';
  }

  static Future<void> saveUserId(String userId) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(userIdKey, userId);
  }

  static Future<void> clearTokens() async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.remove(tokenKey);
    await _prefs?.remove(refreshTokenKey);
    await _prefs?.remove(userRoleKey);
    await _prefs?.remove(userIdKey);
  }
}
