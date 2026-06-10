import '../core/network/api_client.dart';
import '../models/statement_model.dart';

class StatementService {
  static final StatementService _instance = StatementService._internal();
  factory StatementService() => _instance;
  StatementService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<StatementModel>> getStatements({String? yearMonth}) async {
    final queryParams = <String, String>{};
    if (yearMonth != null) queryParams['yearMonth'] = yearMonth;

    final response = await _apiClient.get(
      '/statements',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => StatementModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['records'] != null) {
        return (data['records'] as List)
            .map((e) => StatementModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => StatementModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取对账单列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<StatementModel> getStatementDetail(String statementId) async {
    final response = await _apiClient.get('/statements/$statementId');

    if (response.success && response.data != null) {
      return StatementModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取对账单详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmStatement(String statementId) async {
    final response = await _apiClient.post('/statements/$statementId/confirm');

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '确认对账单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> disputeStatement(String statementId, String reason) async {
    final response = await _apiClient.post(
      '/statements/$statementId/dispute?disputeReason=$reason',
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '提交对账单争议失败',
        statusCode: response.code,
      );
    }
  }
}
