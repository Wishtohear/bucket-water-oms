import '../core/network/api_client.dart';
import '../models/statement_model.dart';

class StatementService {
  static final StatementService _instance = StatementService._internal();
  factory StatementService() => _instance;
  StatementService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<StatementModel>> getStatements({
    String? stationId,
    String? status,
    int page = 1,
    int size = 20,
  }) async {
    final headers = <String, String>{};
    if (stationId != null) {
      headers['X-Station-Id'] = stationId;
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/statements',
      queryParams: queryParams,
      headers: headers,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => StatementModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取对账单列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<StatementModel> getStatement(String statementId) async {
    final response = await _apiClient.get('/statements/$statementId');

    if (response.success) {
      return StatementModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取对账单详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmStatement(String statementId) async {
    final response = await _apiClient.post('/statements/$statementId/confirm');
    return response.success;
  }

  Future<Map<String, dynamic>> generateStatement(String stationId, {
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiClient.post(
      '/statements/generate',
      body: {
        'startDate': startDate,
        'endDate': endDate,
      },
      headers: {'X-Station-Id': stationId},
    );

    if (response.success) {
      return response.data ?? {};
    } else {
      throw ApiException(
        response.message ?? '生成对账单失败',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> getStatementDetails(String statementId) async {
    final response = await _apiClient.get('/statements/$statementId/details');

    if (response.success) {
      return response.data ?? {};
    } else {
      throw ApiException(
        response.message ?? '获取对账单详情失败',
        statusCode: response.code,
      );
    }
  }
}
