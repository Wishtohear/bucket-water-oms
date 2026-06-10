class OrderModel {
  final String? id;
  final String? orderNo;
  final String? status;
  final String? _statusText;
  final String? stationId;
  final String? stationName;
  final String? stationCode;
  final String? contactName;
  final String? contactPhone;
  final String? deliveryAddress;
  final List<OrderItemModel>? items;
  final double? totalAmount;
  final String? paymentType;
  final String? paymentTypeText;
  final String? paymentStatus;
  final String? remark;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? warehouseId;
  final String? warehouseName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final DateTime? reviewedAt;
  final DateTime? dispatchedAt;
  final double? latitude;
  final double? longitude;
  final double? stationLat;
  final double? stationLng;
  final double? distance;
  final int? totalBuckets;
  final int? actualBuckets;
  final int? _totalQuantity;
  final String? signType;
  final List<String>? signPhotos;
  final String? rejectReason;
  final double? bucketDeposit;
  final double? depositBalance;
  final double? creditLimit;
  final double? creditUsed;
  final int? depositBucketCount;
  final int? owedBuckets;
  final double? owedBucketDeposit;

  OrderModel({
    this.id,
    this.orderNo,
    this.status,
    String? statusText,
    this.stationId,
    this.stationName,
    this.stationCode,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.items,
    this.totalAmount,
    this.paymentType,
    this.paymentTypeText,
    this.paymentStatus,
    this.remark,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.warehouseId,
    this.warehouseName,
    this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.reviewedAt,
    this.dispatchedAt,
    this.latitude,
    this.longitude,
    this.stationLat,
    this.stationLng,
    this.distance,
    this.totalBuckets,
    this.actualBuckets,
    int? totalQuantity,
    this.signType,
    this.signPhotos,
    this.rejectReason,
    this.bucketDeposit,
    this.depositBalance,
    this.creditLimit,
    this.creditUsed,
    this.depositBucketCount,
    this.owedBuckets,
    this.owedBucketDeposit,
  })  : _statusText = statusText,
        _totalQuantity = totalQuantity;

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OrderModel();
    }
    return OrderModel(
      id: json['id']?.toString() ?? json['orderId']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
      stationId:
          json['stationId']?.toString() ?? json['station_id']?.toString(),
      stationName: json['stationName'] ?? json['station_name'],
      stationCode: json['stationCode'] ?? json['station_code'],
      contactName: json['contactName'] ?? json['contact_name'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      deliveryAddress: json['deliveryAddress'] ?? json['delivery_address'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : null,
      totalAmount: _parseDouble(
          json['totalAmount'] ?? json['total_amount'] ?? json['amount']),
      paymentType: json['paymentType'] ?? json['payment_type'],
      paymentTypeText: json['paymentTypeText'] ?? json['payment_type_text'],
      paymentStatus: json['paymentStatus'] ?? json['payment_status'],
      remark: json['remark'],
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      driverName: json['driverName'] ?? json['driver_name'],
      driverPhone: json['driverPhone'] ?? json['driver_phone'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      dispatchedAt: json['dispatchedAt'] != null
          ? DateTime.tryParse(json['dispatchedAt'].toString())
          : null,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      stationLat: _parseDouble(json['stationLat'] ?? json['station_lat']),
      stationLng: _parseDouble(json['stationLng'] ?? json['station_lng']),
      distance: _parseDouble(json['distance']),
      totalBuckets: json['totalBuckets'] ?? json['total_buckets'],
      actualBuckets: json['actualBuckets'] ?? json['actual_buckets'],
      totalQuantity: json['totalQuantity'] ?? json['total_quantity'],
      signType: json['signType'] ?? json['sign_type'],
      signPhotos: json['signPhotos'] != null
          ? (json['signPhotos'] as List).map((e) => e.toString()).toList()
          : json['sign_photos'] != null
              ? (json['sign_photos'] as List).map((e) => e.toString()).toList()
              : null,
      rejectReason: json['rejectReason'] ?? json['reject_reason'],
      bucketDeposit:
          _parseDouble(json['bucketDeposit'] ?? json['bucket_deposit']),
      depositBalance:
          _parseDouble(json['depositBalance'] ?? json['deposit_balance']),
      creditLimit: _parseDouble(json['creditLimit'] ?? json['credit_limit']),
      creditUsed: _parseDouble(json['creditUsed'] ?? json['credit_used']),
      depositBucketCount:
          json['depositBucketCount'] ?? json['deposit_bucket_count'],
      owedBuckets: json['owedBuckets'] ?? json['owed_buckets'],
      owedBucketDeposit: _parseDouble(
          json['owedBucketDeposit'] ?? json['owed_bucket_deposit']),
    );
  }

  String get statusText {
    if (_statusText != null && _statusText!.isNotEmpty) {
      return _statusText!;
    }
    return _computeStatusText;
  }

  String get _computeStatusText {
    return _statusToText(status);
  }

  static String _statusToText(String? status) {
    switch (status) {
      case 'pending':
      case 'PENDING':
        return '待处理';
      case 'pending_review':
      case 'PENDING_REVIEW':
        return '待审查';
      case 'confirmed':
      case 'CONFIRMED':
      case 'review_passed':
        return '已确认';
      case 'reviewed':
      case 'REVIEWED':
        return '已接单';
      case 'preparing':
      case 'PREPARING':
        return '备货中';
      case 'dispatched':
      case 'DISPATCHED':
        return '已派单';
      case 'delivering':
      case 'DELIVERING':
      case 'processing':
        return '配送中';
      case 'delivered':
      case 'DELIVERED':
        return '已送达';
      case 'completed':
      case 'COMPLETED':
        return '已完成';
      case 'cancelled':
      case 'CANCELLED':
        return '已取消';
      case 'rejected':
      case 'REJECTED':
        return '已拒单';
      case 'refunded':
      case 'REFUNDED':
        return '已退款';
      default:
        return status ?? '未知';
    }
  }

  String get paymentTypeTextComputed {
    if (paymentTypeText != null) return paymentTypeText!;
    switch (paymentType) {
      case 'prepaid':
      case 'PREPAID':
        return '预付款';
      case 'monthly':
      case 'MONTHLY':
        return '月结';
      case 'credit':
      case 'CREDIT':
        return '信用支付';
      default:
        return paymentType ?? '未知';
    }
  }

  int get totalQuantity {
    if (_totalQuantity != null && _totalQuantity! > 0) {
      return _totalQuantity!;
    }
    if (items == null || items!.isEmpty) {
      return totalBuckets ?? 0;
    }
    return items!.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }
}

class OrderItemModel {
  final String? productId;
  final String? productName;
  final String? productSpec;
  final int? quantity;
  final double? unitPrice;
  final double? subtotal;
  final String? productImage;

  OrderItemModel({
    this.productId,
    this.productName,
    this.productSpec,
    this.quantity,
    this.unitPrice,
    this.subtotal,
    this.productImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OrderItemModel();
    }
    return OrderItemModel(
      productId: json['productId']?.toString(),
      productName: json['productName'] ?? json['name'],
      productSpec: json['productSpec'] ?? json['spec'],
      quantity: json['quantity'],
      unitPrice: _parseDouble(json['unitPrice'] ?? json['price']),
      subtotal: _parseDouble(json['subtotal']),
      productImage: json['productImage'] ?? json['image'],
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
