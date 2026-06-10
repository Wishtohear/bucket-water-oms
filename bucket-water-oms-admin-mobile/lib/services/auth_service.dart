import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: request.toJson(),
    );

    print('═══════════════════════════════════════════════════════════');
    print('AuthService: 登录响应解析');
    print('═══════════════════════════════════════════════════════════');
    print('response.success = ${response.success}');
    print('response.data = $response.data');
    print('response.data type = ${response.data?.runtimeType}');
    print('response.message = ${response.message}');
    print('response.code = ${response.code}');
    print('───────────────────────────────────────────────────────────');

    // 检查响应数据是否包含登录所需的字段
    if (response.data != null && response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      print('data 包含的字段: ${data.keys.toList()}');
      
      // 检查 token 相关字段
      if (data.containsKey('accessToken')) {
        print('✓ 找到 accessToken 字段');
      }
      if (data.containsKey('token')) {
        print('✓ 找到 token 字段');
      }
      if (data.containsKey('id')) {
        print('✓ 找到 id 字段: ${data['id']}');
      }
      if (data.containsKey('name')) {
        print('✓ 找到 name 字段: ${data['name']}');
      }
      if (data.containsKey('role')) {
        print('✓ 找到 role 字段: ${data['role']}');
      }
    }
    print('═══════════════════════════════════════════════════════════');

    if (response.success && response.data != null) {
      final loginResponse =
          LoginResponse.fromJson(response.data as Map<String, dynamic>);

      print('解析后的 LoginResponse:');
      print('  token = ${loginResponse.token != null ? "${loginResponse.token!.substring(0, loginResponse.token!.length > 20 ? 20 : loginResponse.token!.length)}..." : "null"}');
      print('  userId = ${loginResponse.userId}');
      print('  userName = ${loginResponse.userName}');
      print('  role = ${loginResponse.role}');

      if (loginResponse.token != null) {
        _apiClient.setAuthToken(loginResponse.token);
        await ApiConfig.saveToken(loginResponse.token!);
        print('✓ Token 已保存到 ApiConfig');
      } else {
        print('⚠ 警告: 响应中没有找到 token!');
      }

      if (loginResponse.refreshToken != null) {
        await ApiConfig.saveRefreshToken(loginResponse.refreshToken!);
        print('✓ RefreshToken 已保存');
      }

      if (loginResponse.role != null) {
        await ApiConfig.saveUserRole(loginResponse.role!);
        print('✓ UserRole 已保存');
      }

      if (loginResponse.userId != null) {
        await ApiConfig.saveUserId(loginResponse.userId!);
        print('✓ UserId 已保存');
      }

      if (loginResponse.driverId != null) {
        await ApiConfig.saveDriverId(loginResponse.driverId!);
        print('✓ DriverId 已保存: ${loginResponse.driverId}');
      }

      if (loginResponse.stationId != null) {
        await ApiConfig.saveStationId(loginResponse.stationId!);
        print('✓ StationId 已保存');
      }

      if (loginResponse.warehouseId != null) {
        await ApiConfig.saveWarehouseId(loginResponse.warehouseId!);
        print('✓ WarehouseId 已保存');
      }

      return loginResponse;
    } else {
      print('❌ 登录失败: ${response.message ?? '未知错误'}');
      throw ApiException(
        response.message ?? '登录失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      if (response.success && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data);
        _apiClient.setAuthToken(loginResponse.token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      _apiClient.setAuthToken(null);
      return true;
    } catch (e) {
      _apiClient.setAuthToken(null);
      return false;
    }
  }

  void setToken(String? token) {
    _apiClient.setAuthToken(token);
  }

  String getRoleFromIndex(int index) {
    switch (index) {
      case 0:
        return ApiConfig.roleStation;
      case 1:
        return ApiConfig.roleDriver;
      case 2:
        return ApiConfig.roleWarehouse;
      default:
        return ApiConfig.roleAdmin;
    }
  }
}
