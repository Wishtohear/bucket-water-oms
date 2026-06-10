import '../core/network/api_client.dart';
import '../models/warehouse_dashboard_model.dart';

class WarehouseDashboardService {
  static final WarehouseDashboardService _instance = WarehouseDashboardService._internal();
  factory WarehouseDashboardService() => _instance;
  WarehouseDashboardService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<WarehouseDashboardModel> getDashboard(String warehouseId) async {
    try {
      final response = await _apiClient.get(
        '/warehouses/dashboard',
        headers: {'X-Warehouse-Id': warehouseId},
      );

      if (response.success && response.data != null) {
        return WarehouseDashboardModel.fromJson(response.data);
      } else {
        throw ApiException(
          response.message ?? '获取仓库仪表盘失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取仓库仪表盘失败：$e');
    }
  }

  Future<WarehouseStats> getStats(String warehouseId) async {
    try {
      final response = await _apiClient.get(
        '/warehouses/dashboard/stats',
        headers: {'X-Warehouse-Id': warehouseId},
      );

      if (response.success && response.data != null) {
        return WarehouseStats.fromJson(response.data);
      } else {
        throw ApiException(
          response.message ?? '获取仓库统计失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取仓库统计失败：$e');
    }
  }

  Future<List<WarehouseTask>> getTodayTasks(String warehouseId) async {
    try {
      final response = await _apiClient.get(
        '/warehouses/dashboard/tasks',
        headers: {'X-Warehouse-Id': warehouseId},
      );

      if (response.success && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => WarehouseTask.fromJson(e))
              .toList();
        }
        throw ApiException('获取今日任务失败：数据格式错误', statusCode: response.code);
      } else {
        throw ApiException(
          response.message ?? '获取今日任务失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取今日任务失败：$e');
    }
  }

  Future<List<WarehouseAlert>> getAlerts(String warehouseId) async {
    try {
      final response = await _apiClient.get(
        '/warehouses/dashboard/alerts',
        headers: {'X-Warehouse-Id': warehouseId},
      );

      if (response.success && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => WarehouseAlert.fromJson(e))
              .toList();
        }
        throw ApiException('获取仓库告警失败：数据格式错误', statusCode: response.code);
      } else {
        throw ApiException(
          response.message ?? '获取仓库告警失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取仓库告警失败：$e');
    }
  }
}
