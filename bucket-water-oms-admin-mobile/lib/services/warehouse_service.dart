import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/warehouse_dashboard_model.dart';
import '../models/warehouse_models.dart';
import '../models/inventory_models.dart';

class WarehouseService {
  static final WarehouseService _instance = WarehouseService._internal();
  factory WarehouseService() => _instance;
  WarehouseService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<WarehouseDashboardModel> getDashboard(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/dashboard',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return WarehouseDashboardModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取仓库Dashboard失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OrderModel>> getOrders(
    String warehouseId, {
    String? status,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (status != null) 'status': status,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };

    final response = await _apiClient.get(
      '/warehouses/orders',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取订单列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OrderModel>> getAllOrders(
    String warehouseId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (status != null) 'status': status,
    };

    final response = await _apiClient.get(
      '/warehouses/orders/all',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取订单列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OrderModel>> getPreparingOrders(
    String warehouseId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (status != null) 'status': status,
    };

    final response = await _apiClient.get(
      '/warehouses/orders/preparing',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取备货订单列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<OrderModel?> getOrderDetail(String orderId, String warehouseId) async {
    final response = await _apiClient.get(
      '/orders/$orderId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return OrderModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取订单详情失败',
        statusCode: response.code,
      );
    }
  }

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

  Future<bool> calibrateInventory(
    String inventoryId, {
    required int quantity,
    String? reason,
  }) async {
    final response = await _apiClient.put(
      '/warehouses/inventory/$inventoryId/calibrate',
      body: {
        'quantity': quantity,
        if (reason != null) 'reason': reason,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '库存校准失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<InboundModel>> getInboundList(
    String warehouseId, {
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/warehouses/bucket-inbound',
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
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取入库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<InboundModel?> getInboundDetail(
      String inboundId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/bucket-inbound/$inboundId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return InboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取入库详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<InboundModel?> createInbound(
    String warehouseId, {
    required String type,
    required List<Map<String, dynamic>> items,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/bucket-inbound',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        'type': type,
        'items': items,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success && response.data != null) {
      return InboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建入库单失败',
        statusCode: response.code,
      );
    }
  }

  Future<InboundModel?> confirmInbound(
    String inboundId, {
    int? actualQuantity,
    String? checker,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/bucket-inbound/$inboundId/confirm',
      body: {
        if (actualQuantity != null) 'actualQuantity': actualQuantity,
        if (checker != null) 'checker': checker,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success && response.data != null) {
      return InboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '确认入库失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> rejectInbound(
    String inboundId, {
    required String reason,
    String? operator,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/bucket-inbound/$inboundId/reject',
      body: {
        'reason': reason,
        if (operator != null) 'operator': operator,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '拒绝入库失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OutboundModel>> getOutboundList(
    String warehouseId, {
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/warehouses/bucket-outbound',
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
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取出库列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<OutboundModel?> getOutboundDetail(
      String outboundId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/bucket-outbound/$outboundId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return OutboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取出库详情失败',
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
      '/warehouses/bucket-outbound/order/$orderId',
      headers: {
        'X-Warehouse-Id': warehouseId,
        if (operator != null) 'X-Operator': operator,
      },
    );

    if (response.success && response.data != null) {
      return OutboundModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建出库单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmOutbound(String outboundId) async {
    final response = await _apiClient.post(
      '/warehouses/bucket-outbound/$outboundId/confirm',
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

  Future<List<ReturnModel>> getPendingReturns(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/returns',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => ReturnModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取回仓列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<ReturnModel?> getReturnCheckDetail(
      String returnId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/returns/$returnId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return ReturnModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取回仓详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmReturnCheck(
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

  Future<bool> acceptOrder(String orderId, String warehouseId) async {
    final response = await _apiClient.post(
      '/orders/$orderId/review',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {'action': 'accept'},
    );

    return response.success;
  }

  Future<bool> rejectOrder(
    String orderId,
    String warehouseId, {
    required String reason,
    List<Map<String, dynamic>>? stockDetails,
  }) async {
    final response = await _apiClient.post(
      '/orders/$orderId/reject',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        'reason': reason,
        if (stockDetails != null) 'stockDetails': stockDetails,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '拒单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> dispatchOrder(
    String orderId,
    String warehouseId, {
    required String driverId,
    String? remark,
    bool autoOutbound = true,
  }) async {
    final response = await _apiClient.post(
      '/orders/$orderId/dispatch',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        'driverId': driverId,
        if (remark != null) 'remark': remark,
        'autoOutbound': autoOutbound,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '派单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> dispatchAndAutoOutbound(
    String orderId,
    String warehouseId, {
    required String driverId,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/orders/$orderId/dispatch',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        'driverId': driverId,
        if (remark != null) 'remark': remark,
        'autoOutbound': true,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '派单失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<AfterSalesModel>> getAfterSalesList(
    String warehouseId, {
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/after-sales/warehouse',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => AfterSalesModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取售后列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<AfterSalesModel?> getAfterSalesDetail(
      String afterSalesId, String warehouseId) async {
    final response = await _apiClient.get(
      '/after-sales/$afterSalesId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return AfterSalesModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取售后详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> processAfterSales(
    String afterSalesId, {
    required String action,
    String? remark,
    bool? approved,
    String? type,
    String? reason,
    String? newOrderId,
  }) async {
    final response = await _apiClient.post(
      '/after-sales/$afterSalesId/process',
      body: {
        'action': action,
        if (remark != null) 'remark': remark,
        if (approved != null) 'approved': approved,
        if (type != null) 'type': type,
        if (reason != null) 'reason': reason,
        if (newOrderId != null) 'newOrderId': newOrderId,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '处理售后失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<DriverModel>> getAvailableDrivers(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/drivers',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => DriverModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取司机列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<DriverModel>> getRecommendedDrivers(
    String warehouseId, {
    String? orderId,
  }) async {
    final queryParams = <String, String>{};
    if (orderId != null) queryParams['orderId'] = orderId;

    final response = await _apiClient.get(
      '/warehouses/drivers/recommend',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => DriverModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取推荐司机失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<DispatchDriverModel>> getRecommendedDriversWithDetails(
    String warehouseId, {
    String? orderId,
  }) async {
    final queryParams = <String, String>{};
    if (orderId != null) queryParams['orderId'] = orderId;

    final response = await _apiClient.get(
      '/warehouses/drivers/recommend/details',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => DispatchDriverModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取推荐司机详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<DispatchDriverModel>> getAllAvailableDrivers(
      String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/drivers/all',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => DispatchDriverModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取司机列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> getWarehouseInfo(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/info',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取仓库信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateWarehouseInfo(
    String warehouseId, {
    String? name,
    String? address,
  }) async {
    final response = await _apiClient.put(
      '/warehouses/info',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '更新仓库信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> getProfile(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/profile',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取个人信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateProfile(
    String warehouseId, {
    String? name,
    String? phone,
  }) async {
    final response = await _apiClient.put(
      '/warehouses/profile',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '更新个人信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> changePassword(
    String warehouseId, {
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/change-password',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '修改密码失败',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> getNotificationSettings(
      String warehouseId) async {
    final userId = ApiConfig.getUserId();
    final response = await _apiClient.get(
      '/warehouses/notification-settings',
      headers: {
        'X-Warehouse-Id': warehouseId,
        'X-User-Id': userId,
      },
    );

    if (response.success && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取通知设置失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateNotificationSettings(
    String warehouseId, {
    required bool newOrder,
    required bool lowStock,
    required bool driverReturn,
  }) async {
    final userId = ApiConfig.getUserId();
    final response = await _apiClient.put(
      '/warehouses/notification-settings',
      headers: {
        'X-Warehouse-Id': warehouseId,
        'X-User-Id': userId,
      },
      body: {
        'newOrder': newOrder,
        'lowStock': lowStock,
        'driverReturn': driverReturn,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '更新通知设置失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<InventoryCheckModel>> getInventoryCheckRecords(
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
      '/warehouses/inventory/checks',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => InventoryCheckModel.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => InventoryCheckModel.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取盘点记录失败',
        statusCode: response.code,
      );
    }
  }

  Future<InventoryCheckModel?> getInventoryCheckDetail(
      String checkId, String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/inventory/checks/$checkId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success && response.data != null) {
      return InventoryCheckModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取盘点详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<InventoryCheckModel?> createInventoryCheck(
    String warehouseId, {
    String? checker,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/inventory/checks',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        if (checker != null) 'checker': checker,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success && response.data != null) {
      return InventoryCheckModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建盘点失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmInventoryCheck(
    String checkId, {
    String? warehouseId,
  }) async {
    final response = await _apiClient.post(
      '/warehouses/inventory/checks/$checkId/confirm',
      headers: {
        if (warehouseId != null) 'X-Warehouse-Id': warehouseId,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '确认盘点失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<InventoryChangeRecord>> getInventoryChangeRecords(
    String warehouseId, {
    String? productId,
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': pageSize.toString(),
      if (productId != null && productId.isNotEmpty) 'productId': productId,
      if (type != null && type.isNotEmpty) 'transactionType': type,
    };

    final response = await _apiClient.get(
      '/warehouses/inventory/transactions',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => InventoryChangeRecord.fromJson(e)).toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => InventoryChangeRecord.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取变动记录失败',
        statusCode: response.code,
      );
    }
  }
}

class ReturnModel {
  final String? id;
  final String? returnNo;
  final String? driverId;
  final String? driverName;
  final String? driverCode;
  final String? warehouseId;
  final String? warehouseName;
  final String? orderId;
  final String? orderNo;
  final int? bucketReturned;
  final int? actualBucketQty;
  final int? difference;
  final String? differenceReason;
  final String? status;
  final String? statusText;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? checkedAt;

  ReturnModel({
    this.id,
    this.returnNo,
    this.driverId,
    this.driverName,
    this.driverCode,
    this.warehouseId,
    this.warehouseName,
    this.orderId,
    this.orderNo,
    this.bucketReturned,
    this.actualBucketQty,
    this.difference,
    this.differenceReason,
    this.status,
    this.statusText,
    this.remark,
    this.createdAt,
    this.checkedAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReturnModel();
    return ReturnModel(
      id: json['id']?.toString(),
      returnNo: json['returnNo'] ?? json['return_no'],
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      driverName: json['driverName'] ?? json['driver_name'],
      driverCode: json['driverCode'] ?? json['driver_code'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      bucketReturned: json['bucketReturned'] ?? json['bucket_returned'],
      actualBucketQty: json['actualBucketQty'] ?? json['actual_bucket_qty'],
      difference: json['difference'],
      differenceReason: json['differenceReason'] ?? json['difference_reason'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      checkedAt: json['checkedAt'] != null
          ? DateTime.tryParse(json['checkedAt'].toString())
          : null,
    );
  }
}

class DriverModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? code;
  final String? warehouseId;
  final String? warehouseName;
  final String? area;
  final String? onlineStatus;
  final String? onlineStatusText;
  final int? currentTasks;
  final int? todayDeliveries;
  final double? currentLat;
  final double? currentLng;
  final String? lastLocationTime;
  final String? status;
  final String? statusText;

  DriverModel({
    this.id,
    this.name,
    this.phone,
    this.code,
    this.warehouseId,
    this.warehouseName,
    this.area,
    this.onlineStatus,
    this.onlineStatusText,
    this.currentTasks,
    this.todayDeliveries,
    this.currentLat,
    this.currentLng,
    this.lastLocationTime,
    this.status,
    this.statusText,
  });

  factory DriverModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DriverModel();
    return DriverModel(
      id: json['id']?.toString(),
      name: json['name'],
      phone: json['phone'],
      code: json['code'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      area: json['area'],
      onlineStatus: json['onlineStatus'] ?? json['online_status'],
      onlineStatusText: json['onlineStatusText'] ?? json['online_status_text'],
      currentTasks: json['currentTasks'] ?? json['current_tasks'],
      todayDeliveries: json['todayDeliveries'] ?? json['today_deliveries'],
      currentLat: _parseDouble(json['currentLat'] ?? json['current_lat']),
      currentLng: _parseDouble(json['currentLng'] ?? json['current_lng']),
      lastLocationTime: json['lastLocationTime'] ?? json['last_location_time'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
    );
  }
}

class DispatchDriverModel {
  final String? driverId;
  final String? code;
  final String? name;
  final String? phone;
  final double? currentLat;
  final double? currentLng;
  final String? onlineStatus;
  final String? onlineStatusText;
  final int? currentTaskCount;
  final int? todayCompletedCount;
  final double? rating;
  final int? totalDeliveries;
  final String? recommendReason;
  final String? recommendReasonText;
  final double? recommendScore;
  final double? distanceToWarehouse;
  final bool? boundToCurrentWarehouse;
  final String? warehouseName;

  DispatchDriverModel({
    this.driverId,
    this.code,
    this.name,
    this.phone,
    this.currentLat,
    this.currentLng,
    this.onlineStatus,
    this.onlineStatusText,
    this.currentTaskCount,
    this.todayCompletedCount,
    this.rating,
    this.totalDeliveries,
    this.recommendReason,
    this.recommendReasonText,
    this.recommendScore,
    this.distanceToWarehouse,
    this.boundToCurrentWarehouse,
    this.warehouseName,
  });

  factory DispatchDriverModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DispatchDriverModel();
    return DispatchDriverModel(
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      code: json['code'],
      name: json['name'],
      phone: json['phone'],
      currentLat: _parseDouble(json['currentLat'] ?? json['current_lat']),
      currentLng: _parseDouble(json['currentLng'] ?? json['current_lng']),
      onlineStatus: json['onlineStatus'] ?? json['online_status'],
      onlineStatusText: json['onlineStatusText'] ?? json['online_status_text'],
      currentTaskCount: json['currentTaskCount'] ?? json['current_task_count'],
      todayCompletedCount:
          json['todayCompletedCount'] ?? json['today_completed_count'],
      rating: _parseDouble(json['rating']),
      totalDeliveries: json['totalDeliveries'] ?? json['total_deliveries'],
      recommendReason: json['recommendReason'] ?? json['recommend_reason'],
      recommendReasonText:
          json['recommendReasonText'] ?? json['recommend_reason_text'],
      recommendScore:
          _parseDouble(json['recommendScore'] ?? json['recommend_score']),
      distanceToWarehouse: _parseDouble(
          json['distanceToWarehouse'] ?? json['distance_to_warehouse']),
      boundToCurrentWarehouse:
          json['boundToCurrentWarehouse'] ?? json['bound_to_current_warehouse'],
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
    );
  }
}

class AfterSalesModel {
  final String? id;
  final String? ticketNo;
  final String? orderId;
  final String? orderNo;
  final String? stationId;
  final String? stationName;
  final String? stationAddress;
  final String? warehouseId;
  final String? warehouseName;
  final String? type;
  final String? typeText;
  final String? status;
  final String? statusText;
  final String? reason;
  final List<String>? images;
  final List<AfterSalesItemModel>? items;
  final DateTime? createdAt;
  final DateTime? handledAt;
  final String? handleResult;

  AfterSalesModel({
    this.id,
    this.ticketNo,
    this.orderId,
    this.orderNo,
    this.stationId,
    this.stationName,
    this.stationAddress,
    this.warehouseId,
    this.warehouseName,
    this.type,
    this.typeText,
    this.status,
    this.statusText,
    this.reason,
    this.images,
    this.items,
    this.createdAt,
    this.handledAt,
    this.handleResult,
  });

  factory AfterSalesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AfterSalesModel();
    return AfterSalesModel(
      id: json['id']?.toString(),
      ticketNo:
          json['ticketNo'] ?? json['afterSalesNo'] ?? json['after_sales_no'],
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      stationId:
          json['stationId']?.toString() ?? json['station_id']?.toString(),
      stationName: json['stationName'] ?? json['station_name'],
      stationAddress: json['stationAddress'] ?? json['station_address'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      type: json['type'],
      typeText: json['typeText'] ?? json['type_text'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
      reason: json['reason'],
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => AfterSalesItemModel.fromJson(e))
              .toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      handledAt: json['handledAt'] != null
          ? DateTime.tryParse(json['handledAt'].toString())
          : null,
      handleResult: json['handleResult'] ?? json['handle_result'],
    );
  }
}

class AfterSalesItemModel {
  final String? productId;
  final String? productName;
  final int? quantity;
  final int? actualQuantity;

  AfterSalesItemModel({
    this.productId,
    this.productName,
    this.quantity,
    this.actualQuantity,
  });

  factory AfterSalesItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AfterSalesItemModel();
    return AfterSalesItemModel(
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      quantity: json['quantity'],
      actualQuantity: json['actualQuantity'] ?? json['actual_quantity'],
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
