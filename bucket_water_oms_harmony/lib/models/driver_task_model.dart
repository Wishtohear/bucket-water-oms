class DriverTaskModel {
  final String? id;
  final String? taskNo;
  final String? orderId;
  final String? orderNo;
  final String? status;
  final String? stationId;
  final String? stationName;
  final String? contactName;
  final String? contactPhone;
  final String? deliveryAddress;
  final double? longitude;
  final double? latitude;
  final List<TaskItemModel>? items;
  final int? totalQuantity;
  final double? amount;
  final String? paymentType;
  final DateTime? estimatedDeliveryTime;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  DriverTaskModel({
    this.id,
    this.taskNo,
    this.orderId,
    this.orderNo,
    this.status,
    this.stationId,
    this.stationName,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.longitude,
    this.latitude,
    this.items,
    this.totalQuantity,
    this.amount,
    this.paymentType,
    this.estimatedDeliveryTime,
    this.createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory DriverTaskModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverTaskModel();
    }
    return DriverTaskModel(
      id: json['id']?.toString(),
      taskNo: json['taskNo'] ?? json['no'],
      orderId: json['orderId']?.toString(),
      orderNo: json['orderNo'],
      status: json['status'],
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      deliveryAddress: json['deliveryAddress'],
      longitude: _parseDouble(json['longitude']),
      latitude: _parseDouble(json['latitude']),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => TaskItemModel.fromJson(e))
              .toList()
          : null,
      totalQuantity: json['totalQuantity'] ?? json['quantity'],
      amount: _parseDouble(json['amount']),
      paymentType: json['paymentType'],
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.tryParse(json['estimatedDeliveryTime'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.tryParse(json['pickedUpAt'].toString())
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待取货';
      case 'picked_up':
        return '已取货';
      case 'delivering':
        return '配送中';
      case 'delivered':
        return '已送达';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      case 'returned':
        return '已退货';
      default:
        return status ?? '未知';
    }
  }

  String get amountText =>
      amount != null ? '¥${amount!.toStringAsFixed(2)}' : '¥0.00';
  String get quantityText => '${totalQuantity ?? 0} 桶';
}

class TaskItemModel {
  final String? productId;
  final String? productName;
  final String? productSpec;
  final int? quantity;
  final int? deliveredQuantity;
  final double? unitPrice;

  TaskItemModel({
    this.productId,
    this.productName,
    this.productSpec,
    this.quantity,
    this.deliveredQuantity,
    this.unitPrice,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TaskItemModel();
    }
    return TaskItemModel(
      productId: json['productId']?.toString(),
      productName: json['productName'] ?? json['name'],
      productSpec: json['productSpec'] ?? json['spec'],
      quantity: json['quantity'],
      deliveredQuantity: json['deliveredQuantity'],
      unitPrice: _parseDouble(json['unitPrice']),
    );
  }

  String get quantityText => '${deliveredQuantity ?? quantity ?? 0} / ${quantity ?? 0}';
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
