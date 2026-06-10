import '../core/network/api_client.dart';
import '../models/outbound_model.dart';

class WarehouseOutboundService {
  static final WarehouseOutboundService _instance = WarehouseOutboundService._internal();
  factory WarehouseOutboundService() => _instance;
  WarehouseOutboundService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<OutboundModel>> getOutboundList(
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
      '/warehouses/outbound',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OutboundModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => OutboundModel.fromJson(e))
            .toList();
      }
      throw ApiException('获取出库列表失败：数据格式错误', statusCode: response.code);
    } else {
      throw ApiException(
        response.message ?? '获取出库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<OutboundModel?> getOutboundDetail(String outboundId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/outbound/$outboundId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      return OutboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取出库详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<OutboundModel?> createOutbound(
    String warehouseId,
    OutboundRequest request, {
    String? operator,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/outbound',
      headers: {
        'X-Warehouse-Id': warehouseId,
        if (operator != null) 'X-Operator': operator,
      },
      body: request.toJson(),
    );

    if (response.success) {
      return OutboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建出库单失败',
        statusCode: response.code,
      );
    }
  }

  Future<OutboundModel?> createOutboundForOrder(
    String warehouseId,
    String orderId, {
    String? operator,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/outbound/order/$orderId',
      headers: {
        'X-Warehouse-Id': warehouseId,
        if (operator != null) 'X-Operator': operator,
      },
    );

    if (response.success) {
      return OutboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建订单出库失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmOutbound(String outboundId, {String? remark}) async {
    final response = await _apiClient.post(
      '/warehouses/outbound/$outboundId/confirm',
      body: {
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '确认出库失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> startPicking(String outboundId, {String? operator}) async {
    final response = await _apiClient.put(
      '/warehouses/outbound/$outboundId/pick',
      headers: {
        if (operator != null) 'X-Operator': operator,
      },
      body: {'status': 'picking'},
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '开始拣货失败',
        statusCode: response.code,
      );
    }
  }
}
