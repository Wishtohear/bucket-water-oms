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
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) queryParams['status'] = status;

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
        return data.map((e) => OrderModel.fromJson(e)).toList();
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

    if (response.success) {
      return OrderModel.fromJson(response.data);
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

    if (response.success) {
      return OrderModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建订单失败',
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

  Future<List<OrderModel>> getDriverTasks(String driverId) async {
    final response = await _apiClient.get(
      '/drivers/tasks',
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取司机任务失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OrderModel>> getWarehouseOrders(String warehouseId) async {
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
