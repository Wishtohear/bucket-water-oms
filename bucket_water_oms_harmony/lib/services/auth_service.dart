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

    print('AuthService: response.success = ${response.success}');
    print('AuthService: response.data = ${response.data}');
    print('AuthService: response.data type = ${response.data.runtimeType}');
    print('AuthService: response.message = ${response.message}');
    print('AuthService: response.code = ${response.code}');

    if (response.success && response.data != null) {
      final loginResponse =
          LoginResponse.fromJson(response.data as Map<String, dynamic>);

      print('AuthService: loginResponse.token = ${loginResponse.token}');
      print('AuthService: loginResponse.userId = ${loginResponse.userId}');
      print('AuthService: loginResponse.userName = ${loginResponse.userName}');
      print('AuthService: loginResponse.role = ${loginResponse.role}');

      if (loginResponse.token != null) {
        _apiClient.setAuthToken(loginResponse.token);
        await ApiConfig.saveToken(loginResponse.token!);
      }

      if (loginResponse.refreshToken != null) {
        await ApiConfig.saveRefreshToken(loginResponse.refreshToken!);
      }

      if (loginResponse.role != null) {
        await ApiConfig.saveUserRole(loginResponse.role!);
      }

      if (loginResponse.userId != null) {
        await ApiConfig.saveUserId(loginResponse.userId!);
      }

      return loginResponse;
    } else {
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
