import '../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class WarehouseService {
  static final WarehouseService _instance = WarehouseService._internal();
  factory WarehouseService() => _instance;
  WarehouseService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> getPendingOrders(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/orders',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取待处理订单失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<InventoryModel>> getInventory(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/inventory',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => InventoryModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取库存失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getInboundList(String warehouseId, {String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/warehouses/inbound',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取入库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> createInbound(String warehouseId, InboundRequest request, {String? operator}) async {
    final response = await _apiClient.post(
      '/warehouses/inbound',
      headers: {
        'X-Warehouse-Id': warehouseId,
        if (operator != null) 'X-Operator': operator,
      },
      body: request.toJson(),
    );

    if (response.success) {
      return Map<String, dynamic>.from(response.data ?? {});
    } else {
      throw ApiException(
        response.message ?? '创建入库单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> checkInbound(String inboundId, {required bool approved, String? remark}) async {
    final response = await _apiClient.post(
      '/warehouses/inbound/$inboundId/check',
      body: {
        'approved': approved,
        if (remark != null) 'remark': remark,
      },
    );

    return response.success;
  }

  Future<List<Map<String, dynamic>>> getOutboundList(String warehouseId, {String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/warehouses/outbound',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取出库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> createOutboundForOrder(String warehouseId, String orderId, {String? operator}) async {
    final response = await _apiClient.post(
      '/warehouses/outbound/order/$orderId',
      headers: {
        'X-Warehouse-Id': warehouseId,
        if (operator != null) 'X-Operator': operator,
      },
    );

    if (response.success) {
      return Map<String, dynamic>.from(response.data ?? {});
    } else {
      throw ApiException(
        response.message ?? '创建出库单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmOutbound(String outboundId) async {
    final response = await _apiClient.post('/warehouses/outbound/$outboundId/confirm');
    return response.success;
  }

  Future<List<Map<String, dynamic>>> getPendingReturns(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/returns',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取回仓列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> checkReturn(String returnId, {required int confirmedBarrels, String? remark}) async {
    final response = await _apiClient.post(
      '/warehouses/returns/$returnId/check',
      body: {
        'confirmedBarrels': confirmedBarrels,
        if (remark != null) 'remark': remark,
      },
    );

    return response.success;
  }

  Future<bool> acceptOrder(String orderId, String warehouseId) async {
    final response = await _apiClient.put(
      '/warehouses/orders/$orderId/accept',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    return response.success;
  }

  Future<bool> createOutbound(String warehouseId, OutboundRequest request) async {
    final response = await _apiClient.post(
      '/warehouses/outbound',
      headers: {'X-Warehouse-Id': warehouseId},
      body: request.toJson(),
    );

    return response.success;
  }
}

class InboundRequest {
  final String? supplierId;
  final String? supplierName;
  final List<InboundItem> items;
  final String? remark;

  InboundRequest({
    this.supplierId,
    this.supplierName,
    required this.items,
    this.remark,
  });

  Map<String, dynamic> toJson() => {
        if (supplierId != null) 'supplierId': supplierId,
        if (supplierName != null) 'supplierName': supplierName,
        'items': items.map((e) => e.toJson()).toList(),
        if (remark != null) 'remark': remark,
      };
}

class InboundItem {
  final String productId;
  final int quantity;
  final double? unitPrice;

  InboundItem({
    required this.productId,
    required this.quantity,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice,
      };
}

class OutboundRequest {
  final String orderId;
  final List<OutboundItem> items;
  final String? remark;

  OutboundRequest({
    required this.orderId,
    required this.items,
    this.remark,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'items': items.map((e) => e.toJson()).toList(),
        if (remark != null) 'remark': remark,
      };
}

class OutboundItem {
  final String productId;
  final int quantity;

  OutboundItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
