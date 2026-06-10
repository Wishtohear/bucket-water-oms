import '../core/network/api_client.dart';
import '../models/warehouse_models.dart';

class WarehouseInboundService {
  static final WarehouseInboundService _instance = WarehouseInboundService._internal();
  factory WarehouseInboundService() => _instance;
  WarehouseInboundService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<InboundModel>> getInboundList(
    String warehouseId, {
    String? status,
    String? type,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };

    final response = await _apiClient.get(
      '/warehouses/inbound',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => InboundModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => InboundModel.fromJson(e))
            .toList();
      }
      throw ApiException('获取入库列表失败：数据格式错误', statusCode: response.code);
    } else {
      throw ApiException(
        response.message ?? '获取入库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<InboundModel?> getInboundDetail(String inboundId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/inbound/$inboundId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      return InboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取入库详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<InboundModel?> createInbound(
    String warehouseId,
    CreateInboundRequest request, {
    String? operator,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/inbound',
      headers: {
        'X-Warehouse-Id': warehouseId,
        if (operator != null) 'X-Operator': operator,
      },
      body: request.toJson(),
    );

    if (response.success) {
      return InboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建入库单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> checkInbound(
    String inboundId, {
    required bool approved,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/inbound/$inboundId/check',
      body: {
        'approved': approved,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '审核入库失败',
        statusCode: response.code,
      );
    }
  }
}
