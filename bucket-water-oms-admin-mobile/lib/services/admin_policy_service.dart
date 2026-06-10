import '../core/network/api_client.dart';
import '../models/admin_models.dart';
import '../models/policy_models.dart';

class AdminPolicyService {
  static final AdminPolicyService _instance = AdminPolicyService._internal();
  factory AdminPolicyService() => _instance;
  AdminPolicyService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<PolicyListResponse> getPolicyTemplates({
    String? keyword,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/admin/policies/templates',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<PolicyModel> policies = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          policies = data.map((e) => PolicyModel.fromJson(e)).toList();
          total = policies.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            policies = (data['list'] as List)
                .map((e) => PolicyModel.fromJson(e))
                .toList();
          }
          total = data['total'] ?? policies.length;
        }
      }

      return PolicyListResponse(
        policies: policies,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '获取政策模板列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<PolicyModel> getPolicyTemplateDetail(String templateId) async {
    final response =
        await _apiClient.get('/admin/policies/templates/$templateId');

    if (response.success && response.data != null) {
      return PolicyModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取政策模板详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<PolicyModel> createPolicyTemplate(PolicyModel policy) async {
    final response = await _apiClient.post(
      '/admin/policies/templates',
      body: policy.toJson(),
    );

    if (response.success && response.data != null) {
      return PolicyModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建政策模板失败',
        statusCode: response.code,
      );
    }
  }

  Future<PolicyModel> updatePolicyTemplate(
      String templateId, PolicyModel policy) async {
    final response = await _apiClient.put(
      '/admin/policies/templates/$templateId',
      body: policy.toJson(),
    );

    if (response.success && response.data != null) {
      return PolicyModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新政策模板失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> deletePolicyTemplate(String templateId) async {
    final response =
        await _apiClient.delete('/admin/policies/templates/$templateId');

    if (!response.success) {
      throw ApiException(
        response.message ?? '删除政策模板失败',
        statusCode: response.code,
      );
    }
    return true;
  }
}
