import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/env_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? code;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? true,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      code: json['code'],
    );
  }
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final http.Client _client = http.Client();
  String? _authToken;

  ApiClient._internal() {
    _authToken = ApiConfig.getToken();
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders({String? additionalHeader}) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (additionalHeader != null) {
      headers['X-Additional-Header'] = additionalHeader;
    }
    return headers;
  }

  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );

      if (EnvConfig.enableLogging) {
        print('API GET: $uri');
      }

      final response = await _client
          .get(
            uri,
            headers: _getHeaders(
              additionalHeader: headers?['X-Additional-Header'],
            ),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (EnvConfig.enableLogging) {
        print('API POST: $uri');
        print('Body: ${jsonEncode(body)}');
      }

      final response = await _client
          .post(
            uri,
            headers: _getHeaders(
              additionalHeader: headers?['X-Additional-Header'],
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (EnvConfig.enableLogging) {
        print('API PUT: $uri');
        print('Body: ${jsonEncode(body)}');
      }

      final response = await _client
          .put(
            uri,
            headers: _getHeaders(
              additionalHeader: headers?['X-Additional-Header'],
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (EnvConfig.enableLogging) {
        print('API DELETE: $uri');
      }

      final response = await _client
          .delete(
            uri,
            headers: _getHeaders(
              additionalHeader: headers?['X-Additional-Header'],
            ),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('未知错误: $e');
    }
  }

  ApiResponse<dynamic> _handleResponse(http.Response response) {
    if (EnvConfig.enableLogging) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse(success: true, data: null);
      }

      try {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: jsonData['success'] == true,
          data: jsonData['data'],
          message: jsonData['message']?.toString(),
          code: int.tryParse(jsonData['code']?.toString() ?? ''),
        );
      } catch (e) {
        return ApiResponse(success: true, data: null);
      }
    } else if (response.statusCode == 401) {
      throw ApiException('登录已过期，请重新登录', statusCode: 401);
    } else if (response.statusCode == 403) {
      throw ApiException('没有权限访问', statusCode: 403);
    } else if (response.statusCode == 404) {
      throw ApiException('资源不存在', statusCode: 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('服务器错误，请稍后重试', statusCode: response.statusCode);
    } else {
      try {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? '请求失败';
        throw ApiException(message,
            statusCode: response.statusCode, data: data);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('请求失败', statusCode: response.statusCode);
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
