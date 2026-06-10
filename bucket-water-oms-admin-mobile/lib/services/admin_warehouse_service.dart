import '../core/network/api_client.dart';
import '../models/admin_models.dart';

class AdminWarehouseService {
  static final AdminWarehouseService _instance = AdminWarehouseService._internal();
  factory AdminWarehouseService() => _instance;
  AdminWarehouseService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<WarehouseListResponse> getWarehouses({
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
      '/admin/warehouses',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<WarehouseModel> warehouses = [];
      int total = 0;
      WarehouseStats? stats;

      if (data != null) {
        if (data is List) {
          warehouses = data.map((e) => WarehouseModel.fromJson(e as Map<String, dynamic>)).toList();
          total = warehouses.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            warehouses = (data['list'] as List)
                .map((e) => WarehouseModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? warehouses.length;
          if (data['stats'] != null) {
            stats = WarehouseStats.fromJson(data['stats'] as Map<String, dynamic>);
          }
        }
      }

      return WarehouseListResponse(
        warehouses: warehouses,
        total: total,
        page: page,
        pageSize: pageSize,
        stats: stats,
      );
    } else {
      throw ApiException(
        response.message ?? '获取仓库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<WarehouseModel> getWarehouseDetail(String warehouseId) async {
    final response = await _apiClient.get('/admin/warehouses/$warehouseId');

    if (response.success && response.data != null) {
      return WarehouseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取仓库详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<WarehouseModel> createWarehouse(WarehouseModel warehouse, {String? password}) async {
    final body = warehouse.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    } else {
      body['password'] = '123456';
    }

    final response = await _apiClient.post(
      '/admin/warehouses',
      body: body,
    );

    if (response.success && response.data != null) {
      return WarehouseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建仓库失败',
        statusCode: response.code,
      );
    }
  }

  Future<WarehouseModel> updateWarehouse(String warehouseId, WarehouseModel warehouse, {String? password}) async {
    final body = warehouse.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await _apiClient.put(
      '/admin/warehouses/$warehouseId',
      body: body,
    );

    if (response.success && response.data != null) {
      return WarehouseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新仓库失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateWarehouseStatus(String warehouseId, String status) async {
    final response = await _apiClient.put(
      '/admin/warehouses/$warehouseId/status',
      body: {'status': status},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '更新仓库状态失败',
        statusCode: response.code,
      );
    }
    return true;
  }
}

class WarehouseListResponse {
  final List<WarehouseModel> warehouses;
  final int total;
  final int page;
  final int pageSize;
  final WarehouseStats? stats;

  WarehouseListResponse({
    required this.warehouses,
    required this.total,
    required this.page,
    required this.pageSize,
    this.stats,
  });

  bool get hasMore => (page * pageSize) < total;
}

class WarehouseStats {
  final int totalWarehouses;
  final int totalStock;
  final int warningWarehouses;
  final int pendingOrders;

  WarehouseStats({
    required this.totalWarehouses,
    required this.totalStock,
    required this.warningWarehouses,
    required this.pendingOrders,
  });

  factory WarehouseStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseStats(
        totalWarehouses: 0,
        totalStock: 0,
        warningWarehouses: 0,
        pendingOrders: 0,
      );
    }
    return WarehouseStats(
      totalWarehouses: json['totalWarehouses'] ?? json['total_warehouses'] ?? 0,
      totalStock: json['totalStock'] ?? json['total_stock'] ?? 0,
      warningWarehouses: json['warningWarehouses'] ?? json['warning_warehouses'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? json['pending_orders'] ?? 0,
    );
  }
}
