import '../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> getOrders({
    String? stationId,
    String? status,
    String? keyword,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (keyword != null) queryParams['keyword'] = keyword;

    final headers = <String, String>{};
    if (stationId != null) {
      headers['X-Station-Id'] = stationId;
    }

    final response = await _apiClient.get(
      '/orders',
      queryParams: queryParams,
      headers: headers,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['records'] != null) {
        return (data['records'] as List)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
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

  Future<OrderModel> getOrderDetail(String orderId) async {
    final response = await _apiClient.get('/orders/$orderId');

    if (response.success && response.data != null) {
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取订单详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    final response = await _apiClient.post(
      '/orders',
      body: request.toJson(),
    );

    if (response.success && response.data != null) {
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建订单失败',
        statusCode: response.code,
      );
    }
  }

  Future<OrderModel> updateOrder(
      String orderId, UpdateOrderRequest request) async {
    final response = await _apiClient.put(
      '/orders/$orderId',
      body: request.toJson(),
    );

    if (response.success && response.data != null) {
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新订单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final endpoint = reason != null
        ? '/orders/$orderId/cancel?reason=$reason'
        : '/orders/$orderId/cancel';
    final response = await _apiClient.post(endpoint);

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '取消订单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final response = await _apiClient.put(
      '/orders/$orderId/status',
      body: {'status': status},
    );

    return response.success;
  }

  Future<bool> verifyOrderCode(String orderId, String verifyCode) async {
    final response = await _apiClient.post(
      '/orders/$orderId/verify-code',
      body: {'verifyCode': verifyCode},
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '验证码验证失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmOrderDelivery(String orderId, String confirmCode) async {
    final response = await _apiClient.post(
      '/orders/$orderId/confirm',
      body: {'confirmCode': confirmCode},
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '确认收货失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OrderModel>> getDriverTasks(String driverId) async {
    final response = await _apiClient.get(
      '/drivers/tasks',
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取司机任务失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OrderModel>> getWarehouseOrders(
    String warehouseId, {
    String? status,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/warehouses/orders',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['records'] != null) {
        return (data['records'] as List)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取仓库订单失败',
        statusCode: response.code,
      );
    }
  }
}

class CreateOrderRequest {
  final String warehouseId;
  final List<OrderItemDTO> items;
  final String deliveryAddress;
  final String contactName;
  final String contactPhone;
  final String? paymentType;
  final String? remark;

  CreateOrderRequest({
    required this.warehouseId,
    required this.items,
    required this.deliveryAddress,
    required this.contactName,
    required this.contactPhone,
    this.paymentType,
    this.remark,
  });

  Map<String, dynamic> toJson() => {
        'warehouseId': warehouseId,
        'items': items.map((e) => e.toJson()).toList(),
        'deliveryAddress': deliveryAddress,
        'contactName': contactName,
        'contactPhone': contactPhone,
        if (paymentType != null) 'paymentType': paymentType,
        if (remark != null) 'remark': remark,
      };
}

class UpdateOrderRequest {
  final String? warehouseId;
  final List<OrderItemDTO>? items;
  final String? remark;

  UpdateOrderRequest({
    this.warehouseId,
    this.items,
    this.remark,
  });

  Map<String, dynamic> toJson() => {
        if (warehouseId != null) 'warehouseId': warehouseId,
        if (items != null && items!.isNotEmpty)
          'items': items!.map((e) => e.toJson()).toList(),
        if (remark != null) 'remark': remark,
      };
}

class OrderItemDTO {
  final String productId;
  final int quantity;

  OrderItemDTO({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
