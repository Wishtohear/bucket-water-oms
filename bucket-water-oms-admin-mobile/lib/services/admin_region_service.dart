import '../core/network/api_client.dart';
import '../models/admin_models.dart';

class AdminRegionService {
  static final AdminRegionService _instance = AdminRegionService._internal();
  factory AdminRegionService() => _instance;
  AdminRegionService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<RegionModel>> getRegionTree() async {
    final response = await _apiClient.get('/admin/regions/tree');

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => RegionModel.fromJson(e)).toList();
      }
    }
    throw ApiException(
      response.message ?? '获取区域树失败',
      statusCode: response.code,
    );
  }

  Future<RegionModel> createRegion(RegionModel region) async {
    final response = await _apiClient.post(
      '/admin/regions',
      body: region.toJson(),
    );

    if (response.success && response.data != null) {
      return RegionModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建区域失败',
        statusCode: response.code,
      );
    }
  }

  Future<RegionModel> updateRegion(String regionId, RegionModel region) async {
    final response = await _apiClient.put(
      '/admin/regions/$regionId',
      body: region.toJson(),
    );

    if (response.success && response.data != null) {
      return RegionModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新区域失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> deleteRegion(String regionId) async {
    final response = await _apiClient.delete('/admin/regions/$regionId');

    if (!response.success) {
      throw ApiException(
        response.message ?? '删除区域失败',
        statusCode: response.code,
      );
    }
    return true;
  }
}
