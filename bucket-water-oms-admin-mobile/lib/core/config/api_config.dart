import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.31.72:8080/api';
  static const Duration timeout = Duration(seconds: 30);
  static const Duration refreshTimeout = Duration(minutes: 5);

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String stationIdKey = 'station_id';
  static const String warehouseIdKey = 'warehouse_id';
  static const String driverIdKey = 'driver_id';

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

  static String getStationId() {
    return _prefs?.getString(stationIdKey) ?? '';
  }

  static Future<void> saveStationId(String stationId) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(stationIdKey, stationId);
  }

  static String getWarehouseId() {
    return _prefs?.getString(warehouseIdKey) ?? '';
  }

  static Future<void> saveWarehouseId(String warehouseId) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(warehouseIdKey, warehouseId);
  }

  static String getDriverId() {
    return _prefs?.getString(driverIdKey) ?? '';
  }

  static Future<void> saveDriverId(String driverId) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.setString(driverIdKey, driverId);
  }

  static Future<void> clearTokens() async {
    if (_prefs == null) {
      await init();
    }
    await _prefs?.remove(tokenKey);
    await _prefs?.remove(refreshTokenKey);
    await _prefs?.remove(userRoleKey);
    await _prefs?.remove(userIdKey);
    await _prefs?.remove(stationIdKey);
    await _prefs?.remove(warehouseIdKey);
    await _prefs?.remove(driverIdKey);
  }
}
