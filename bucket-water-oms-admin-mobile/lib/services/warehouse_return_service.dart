import '../core/network/api_client.dart';
import '../models/warehouse_return_model.dart';

class WarehouseReturnService {
  static final WarehouseReturnService _instance = WarehouseReturnService._internal();
  factory WarehouseReturnService() => _instance;
  WarehouseReturnService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<ReturnCheckModel>> getReturnList(
    String warehouseId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final response = await _apiClient.get(
      '/warehouses/returns',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => ReturnCheckModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => ReturnCheckModel.fromJson(e))
            .toList();
      }
      throw ApiException('获取回仓列表失败：数据格式错误', statusCode: response.code);
    } else {
      throw ApiException(
        response.message ?? '获取回仓列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<ReturnCheckModel?> getReturnDetail(String returnId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/returns/$returnId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return ReturnCheckModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取回仓详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> checkReturn(
    String returnId, {
    required int confirmedBuckets,
    int? owedBuckets,
    String? replenishmentRequest,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/returns/$returnId/check',
      body: {
        'confirmedBuckets': confirmedBuckets,
        if (owedBuckets != null) 'owedBuckets': owedBuckets,
        if (replenishmentRequest != null)
          'replenishmentRequest': replenishmentRequest,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '核对回仓失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmReturn(
    String returnId, {
    required int actualBuckets,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/returns/$returnId/confirm',
      body: {
        'actualBuckets': actualBuckets,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '确认回仓失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> recordDiscrepancy(
    String returnId, {
    required int actualBuckets,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/returns/$returnId/discrepancy',
      body: {
        'actualBuckets': actualBuckets,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '记录差异失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> processReplenishment(
    String returnId, {
    required String replenishmentDetails,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/returns/$returnId/replenish',
      body: {
        'replenishmentDetails': replenishmentDetails,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '处理补货失败',
        statusCode: response.code,
      );
    }
  }
}
