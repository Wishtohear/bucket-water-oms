import '../core/network/api_client.dart';
import '../models/statement_model.dart';

class DriverStatementService {
  static final DriverStatementService _instance =
      DriverStatementService._internal();
  factory DriverStatementService() => _instance;
  DriverStatementService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<StatementModel>> getStatements(
    String driverId, {
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/driver-statements',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success && response.data != null) {
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

  Future<StatementModel> getStatementDetail(
    String driverId,
    String statementId,
  ) async {
    final response = await _apiClient.get(
      '/driver-statements/$statementId',
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success && response.data != null) {
      return StatementModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取对账单详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmStatement(
    String driverId,
    String statementId,
  ) async {
    final response = await _apiClient.post(
      '/driver-statements/$statementId/confirm',
      headers: {'X-Driver-Id': driverId},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '确认对账单失败',
        statusCode: response.code,
      );
    }
    return response.success;
  }

  Future<bool> disputeStatement(
    String driverId,
    String statementId, {
    String? reason,
  }) async {
    final response = await _apiClient.post(
      '/driver-statements/$statementId/dispute',
      body: {
        if (reason != null) 'reason': reason,
      },
      headers: {'X-Driver-Id': driverId},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '提交对账争议失败',
        statusCode: response.code,
      );
    }
    return response.success;
  }

  Future<Map<String, dynamic>> getStatementStats(String driverId) async {
    final response = await _apiClient.get(
      '/driver-statements/stats',
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success && response.data != null) {
      return response.data ?? {};
    } else {
      throw ApiException(
        response.message ?? '获取对账统计失败',
        statusCode: response.code,
      );
    }
  }
}
