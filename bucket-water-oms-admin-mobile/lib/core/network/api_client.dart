import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/env_config.dart';
import 'api_models.dart';

export 'api_models.dart';

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

  Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );

      if (EnvConfig.enableLogging) {
        print('═══════════════════════════════════════════════════════════');
        print('[$timestamp] 📤 API GET 请求');
        print('Endpoint: $endpoint');
        print('Full URL: $uri');
        if (queryParams != null && queryParams.isNotEmpty) {
          print('Query Params: $queryParams');
        }
        if (headers != null && headers.isNotEmpty) {
          print('Headers: $headers');
        }
        if (_authToken != null && _authToken!.isNotEmpty) {
          print(
              'Authorization: Bearer ${_authToken!.substring(0, _authToken!.length > 20 ? 20 : _authToken!.length)}...');
        }
        print('───────────────────────────────────────────────────────────');
      }

      final stopwatch = Stopwatch()..start();
      final response = await _client
          .get(
            uri,
            headers: _getHeaders(customHeaders: headers),
          )
          .timeout(ApiConfig.timeout);
      stopwatch.stop();

      if (EnvConfig.enableLogging) {
        print('[$timestamp] ✅ API GET 响应');
        print('Status: ${response.statusCode}');
        print('Duration: ${stopwatch.elapsedMilliseconds}ms');
        print(
            'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
        print('═══════════════════════════════════════════════════════════');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('[$timestamp] ❌ 网络连接失败: ${e.message}');
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      print('[$timestamp] ❌ HTTP请求失败: ${e.message}');
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('[$timestamp] ❌ 未知错误: $e');
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (EnvConfig.enableLogging) {
        print('═══════════════════════════════════════════════════════════');
        print('[$timestamp] 📤 API POST 请求');
        print('Endpoint: $endpoint');
        print('Full URL: $uri');
        if (body != null) {
          print('Body: ${jsonEncode(body)}');
        }
        if (headers != null && headers.isNotEmpty) {
          print('Headers: $headers');
        }
        if (_authToken != null && _authToken!.isNotEmpty) {
          print(
              'Authorization: Bearer ${_authToken!.substring(0, _authToken!.length > 20 ? 20 : _authToken!.length)}...');
        }
        print('───────────────────────────────────────────────────────────');
      }

      final stopwatch = Stopwatch()..start();
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(customHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      stopwatch.stop();

      if (EnvConfig.enableLogging) {
        print('[$timestamp] ✅ API POST 响应');
        print('Status: ${response.statusCode}');
        print('Duration: ${stopwatch.elapsedMilliseconds}ms');
        print(
            'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
        print('═══════════════════════════════════════════════════════════');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('[$timestamp] ❌ 网络连接失败: ${e.message}');
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      print('[$timestamp] ❌ HTTP请求失败: ${e.message}');
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('[$timestamp] ❌ 未知错误: $e');
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );

      if (EnvConfig.enableLogging) {
        print('═══════════════════════════════════════════════════════════');
        print('[$timestamp] 📤 API PUT 请求');
        print('Endpoint: $endpoint');
        print('Full URL: $uri');
        if (body != null) {
          print('Body: ${jsonEncode(body)}');
        }
        if (queryParams != null && queryParams.isNotEmpty) {
          print('Query Params: $queryParams');
        }
        if (headers != null && headers.isNotEmpty) {
          print('Headers: $headers');
        }
        if (_authToken != null && _authToken!.isNotEmpty) {
          print(
              'Authorization: Bearer ${_authToken!.substring(0, _authToken!.length > 20 ? 20 : _authToken!.length)}...');
        }
        print('───────────────────────────────────────────────────────────');
      }

      final stopwatch = Stopwatch()..start();
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(customHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      stopwatch.stop();

      if (EnvConfig.enableLogging) {
        print('[$timestamp] ✅ API PUT 响应');
        print('Status: ${response.statusCode}');
        print('Duration: ${stopwatch.elapsedMilliseconds}ms');
        print(
            'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
        print('═══════════════════════════════════════════════════════════');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('[$timestamp] ❌ 网络连接失败: ${e.message}');
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      print('[$timestamp] ❌ HTTP请求失败: ${e.message}');
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('[$timestamp] ❌ 未知错误: $e');
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (EnvConfig.enableLogging) {
        print('═══════════════════════════════════════════════════════════');
        print('[$timestamp] 📤 API DELETE 请求');
        print('Endpoint: $endpoint');
        print('Full URL: $uri');
        if (headers != null && headers.isNotEmpty) {
          print('Headers: $headers');
        }
        if (_authToken != null && _authToken!.isNotEmpty) {
          print(
              'Authorization: Bearer ${_authToken!.substring(0, _authToken!.length > 20 ? 20 : _authToken!.length)}...');
        }
        print('───────────────────────────────────────────────────────────');
      }

      final stopwatch = Stopwatch()..start();
      final response = await _client
          .delete(
            uri,
            headers: _getHeaders(customHeaders: headers),
          )
          .timeout(ApiConfig.timeout);
      stopwatch.stop();

      if (EnvConfig.enableLogging) {
        print('[$timestamp] ✅ API DELETE 响应');
        print('Status: ${response.statusCode}');
        print('Duration: ${stopwatch.elapsedMilliseconds}ms');
        print(
            'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
        print('═══════════════════════════════════════════════════════════');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('[$timestamp] ❌ 网络连接失败: ${e.message}');
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      print('[$timestamp] ❌ HTTP请求失败: ${e.message}');
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('[$timestamp] ❌ 未知错误: $e');
      throw ApiException('未知错误: $e');
    }
  }

  Future<ApiResponse<dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (EnvConfig.enableLogging) {
        print('═══════════════════════════════════════════════════════════');
        print('[$timestamp] 📤 API PATCH 请求');
        print('Endpoint: $endpoint');
        print('Full URL: $uri');
        if (body != null) {
          print('Body: ${jsonEncode(body)}');
        }
        if (headers != null && headers.isNotEmpty) {
          print('Headers: $headers');
        }
        if (_authToken != null && _authToken!.isNotEmpty) {
          print(
              'Authorization: Bearer ${_authToken!.substring(0, _authToken!.length > 20 ? 20 : _authToken!.length)}...');
        }
        print('───────────────────────────────────────────────────────────');
      }

      final stopwatch = Stopwatch()..start();
      final httpRequest = http.Request('PATCH', uri);
      httpRequest.headers.addAll(_getHeaders(customHeaders: headers));
      if (body != null) {
        httpRequest.body = jsonEncode(body);
      }

      final streamedResponse = await _client.send(httpRequest).timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      if (EnvConfig.enableLogging) {
        print('[$timestamp] ✅ API PATCH 响应');
        print('Status: ${response.statusCode}');
        print('Duration: ${stopwatch.elapsedMilliseconds}ms');
        print(
            'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
        print('═══════════════════════════════════════════════════════════');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('[$timestamp] ❌ 网络连接失败: ${e.message}');
      throw ApiException('网络连接失败，请检查网络');
    } on http.ClientException catch (e) {
      print('[$timestamp] ❌ HTTP请求失败: ${e.message}');
      throw ApiException('请求失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('[$timestamp] ❌ 未知错误: $e');
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
        final success = jsonData['success'] == true ||
            jsonData['code'] == 200 ||
            jsonData['code'] == 0;

        // 返回完整的响应数据，保留所有字段（与PC端axios行为一致）
        // 不再只提取data字段，让上层服务自己解析
        return ApiResponse(
          success: success,
          data: jsonData['data'] ?? jsonData, // 如果没有data字段，返回整个响应
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
