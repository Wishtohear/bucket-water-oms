class OrderModel {
  final String? id;
  final String? orderNo;
  final String? status;
  final String? stationId;
  final String? stationName;
  final String? contactName;
  final String? contactPhone;
  final String? deliveryAddress;
  final List<OrderItemModel>? items;
  final double? totalAmount;
  final String? paymentType;
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

  OrderModel({
    this.id,
    this.orderNo,
    this.status,
    this.stationId,
    this.stationName,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.items,
    this.totalAmount,
    this.paymentType,
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
  });

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OrderModel();
    }
    return OrderModel(
      id: json['id']?.toString(),
      orderNo: json['orderNo'] ?? json['orderNo'],
      status: json['status'],
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      deliveryAddress: json['deliveryAddress'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : null,
      totalAmount: _parseDouble(json['totalAmount'] ?? json['amount']),
      paymentType: json['paymentType'],
      paymentStatus: json['paymentStatus'],
      remark: json['remark'],
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      warehouseId: json['warehouseId']?.toString(),
      warehouseName: json['warehouseName'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'confirmed':
        return '已确认';
      case 'processing':
        return '配送中';
      case 'delivered':
        return '已送达';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      case 'refunded':
        return '已退款';
      default:
        return status ?? '未知';
    }
  }

  String get paymentTypeText {
    switch (paymentType) {
      case 'prepaid':
        return '预付款';
      case 'monthly':
        return '月结';
      case 'credit':
        return '信用支付';
      default:
        return paymentType ?? '未知';
    }
  }

  int get totalQuantity {
    if (items == null || items!.isEmpty) {
      return 0;
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
