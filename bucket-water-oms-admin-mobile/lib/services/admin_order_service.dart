import '../core/network/api_client.dart';

class AdminOrderService {
  static final AdminOrderService _instance = AdminOrderService._internal();
  factory AdminOrderService() => _instance;
  AdminOrderService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<OrderListResponse> getOrders({
    String? keyword,
    String? status,
    String? warehouseId,
    String? stationId,
    String? startDate,
    String? endDate,
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
      queryParams['status'] = _parseStatus(status);
    }
    if (warehouseId != null && warehouseId.isNotEmpty) {
      queryParams['warehouseId'] = warehouseId;
    }
    if (stationId != null && stationId.isNotEmpty) {
      queryParams['stationId'] = stationId;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      '/admin/orders/page',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<OrderModel> orders = [];
      int total = 0;
      OrderStatsResponse? stats;

      if (data != null) {
        if (data is List) {
          orders = data
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
          total = orders.length;
        } else if (data is Map<String, dynamic>) {
          if (data['records'] != null) {
            orders = (data['records'] as List)
                .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (data['list'] != null) {
            orders = (data['list'] as List)
                .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? orders.length;
          if (data['stats'] != null) {
            stats = OrderStatsResponse.fromJson(
                data['stats'] as Map<String, dynamic>);
          }
        }
      }

      return OrderListResponse(
        orders: orders,
        total: total,
        page: page,
        pageSize: pageSize,
        stats: stats,
      );
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<OrderModel?> getOrderDetail(String orderId) async {
    final response = await _apiClient.get('/admin/orders/$orderId');

    if (response.success && response.data != null) {
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final response = await _apiClient.post(
      '/admin/orders/$orderId/cancel',
      body: reason != null ? {'reason': reason} : null,
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<OrderStatsResponse> getOrderStats() async {
    final response = await _apiClient.get('/admin/orders/stats');

    if (response.success && response.data != null) {
      return OrderStatsResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  String _parseStatus(String status) {
    switch (status) {
      case '待审查':
        return 'pending';
      case '已接单':
        return 'accepted';
      case '已派单':
        return 'dispatched';
      case '配送中':
        return 'delivering';
      case '已完成':
        return 'completed';
      case '已取消':
        return 'cancelled';
      case '已拒单':
        return 'rejected';
      default:
        return status;
    }
  }
}

class OrderListResponse {
  final List<OrderModel> orders;
  final int total;
  final int page;
  final int pageSize;
  final OrderStatsResponse? stats;

  OrderListResponse({
    required this.orders,
    required this.total,
    required this.page,
    required this.pageSize,
    this.stats,
  });

  bool get hasMore => (page * pageSize) < total;
}

class OrderStatsResponse {
  final int todayOrderCount;
  final int pendingReviewCount;
  final int todayCompletedCount;
  final int deliveringCount;

  OrderStatsResponse({
    required this.todayOrderCount,
    required this.pendingReviewCount,
    required this.todayCompletedCount,
    required this.deliveringCount,
  });

  factory OrderStatsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OrderStatsResponse(
        todayOrderCount: 0,
        pendingReviewCount: 0,
        todayCompletedCount: 0,
        deliveringCount: 0,
      );
    }
    return OrderStatsResponse(
      todayOrderCount:
          json['todayOrderCount'] ?? json['today_order_count'] ?? 0,
      pendingReviewCount:
          json['pendingReviewCount'] ?? json['pending_review_count'] ?? 0,
      todayCompletedCount:
          json['todayCompletedCount'] ?? json['today_completed_count'] ?? 0,
      deliveringCount: json['deliveringCount'] ?? json['delivering_count'] ?? 0,
    );
  }
}

class OrderModel {
  final String? id;
  final String? orderNo;
  final String? stationId;
  final String? stationName;
  final String? stationAddress;
  final String? warehouseId;
  final String? warehouseName;
  final String? driverId;
  final String? driverName;
  final String? status;
  final String? statusText;
  final double? totalAmount;
  final int? totalBuckets;
  final String? paymentType;
  final String? paymentTypeText;
  final DateTime? createTime;
  final DateTime? reviewedAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final String? rejectReason;
  final String? signType;
  final List<String>? signPhotos;
  final String? contactName;
  final String? contactPhone;
  final String? deliveryAddress;
  final String? remark;
  final List<OrderItemModel>? items;

  OrderModel({
    this.id,
    this.orderNo,
    this.stationId,
    this.stationName,
    this.stationAddress,
    this.warehouseId,
    this.warehouseName,
    this.driverId,
    this.driverName,
    this.status,
    this.statusText,
    this.totalAmount,
    this.totalBuckets,
    this.paymentType,
    this.paymentTypeText,
    this.createTime,
    this.reviewedAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.rejectReason,
    this.signType,
    this.signPhotos,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.remark,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderModel();
    return OrderModel(
      id: json['id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      stationId:
          json['stationId']?.toString() ?? json['station_id']?.toString(),
      stationName: json['stationName'] ?? json['station_name'],
      stationAddress: json['stationAddress'] ?? json['station_address'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      driverName: json['driverName'] ?? json['driver_name'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
      totalBuckets: json['totalBuckets'] ?? json['total_buckets'],
      paymentType: json['paymentType'] ?? json['payment_type'],
      paymentTypeText: json['paymentTypeText'] ?? json['payment_type_text'],
      createTime: json['createTime'] != null || json['create_time'] != null
          ? DateTime.tryParse(json['createTime'] ?? json['create_time'] ?? '')
          : null,
      reviewedAt: json['reviewedAt'] != null || json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewedAt'] ?? json['reviewed_at'] ?? '')
          : null,
      dispatchedAt:
          json['dispatchedAt'] != null || json['dispatched_at'] != null
              ? DateTime.tryParse(
                  json['dispatchedAt'] ?? json['dispatched_at'] ?? '')
              : null,
      deliveredAt: json['deliveredAt'] != null || json['delivered_at'] != null
          ? DateTime.tryParse(json['deliveredAt'] ?? json['delivered_at'] ?? '')
          : null,
      rejectReason: json['rejectReason'] ?? json['reject_reason'],
      signType: json['signType'] ?? json['sign_type'],
      signPhotos: json['signPhotos'] != null
          ? List<String>.from(json['signPhotos'])
          : null,
      contactName: json['contactName'] ?? json['contact_name'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      deliveryAddress: json['deliveryAddress'] ?? json['delivery_address'],
      remark: json['remark'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : null,
    );
  }

  String get paymentMethodText {
    switch (paymentType) {
      case 'prepaid':
        return '预存金支付';
      case 'monthly':
        return '月结';
      case 'credit':
        return '信用支付';
      default:
        return paymentTypeText ?? '未知';
    }
  }
}

class OrderItemModel {
  final String? productId;
  final String? productName;
  final double? price;
  final int? quantity;
  final double? amount;

  OrderItemModel({
    this.productId,
    this.productName,
    this.price,
    this.quantity,
    this.amount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderItemModel();
    return OrderItemModel(
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      price: _parseDouble(json['price']),
      quantity: json['quantity'],
      amount: _parseDouble(json['amount']),
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
