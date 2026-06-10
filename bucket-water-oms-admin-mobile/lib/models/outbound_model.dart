class OutboundModel {
  final String? id;
  final String? outboundNo;
  final String? orderId;
  final String? type;
  final String? customerId;
  final String? customerName;
  final String? status;
  final List<OutboundItem>? items;
  final String? handlerId;
  final String? handlerName;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? shippedAt;
  final DateTime? updatedAt;

  OutboundModel({
    this.id,
    this.outboundNo,
    this.orderId,
    this.type,
    this.customerId,
    this.customerName,
    this.status,
    this.items,
    this.handlerId,
    this.handlerName,
    this.remark,
    this.createdAt,
    this.shippedAt,
    this.updatedAt,
  });

  factory OutboundModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OutboundModel();
    }
    return OutboundModel(
      id: json['id']?.toString(),
      outboundNo: json['outboundNo'] ?? json['code'],
      orderId: json['orderId']?.toString(),
      type: json['type'],
      customerId: json['customerId']?.toString(),
      customerName: json['customerName'],
      status: json['status'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OutboundItem.fromJson(e))
              .toList()
          : null,
      handlerId: json['handlerId']?.toString(),
      handlerName: json['handlerName'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.tryParse(json['shippedAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (outboundNo != null) 'outboundNo': outboundNo,
      if (orderId != null) 'orderId': orderId,
      if (type != null) 'type': type,
      if (customerId != null) 'customerId': customerId,
      if (customerName != null) 'customerName': customerName,
      if (status != null) 'status': status,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (handlerId != null) 'handlerId': handlerId,
      if (handlerName != null) 'handlerName': handlerName,
      if (remark != null) 'remark': remark,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (shippedAt != null) 'shippedAt': shippedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
      case '待拣货':
        return '待拣货';
      case 'picking':
      case '拣货中':
        return '拣货中';
      case 'shipped':
      case '已出库':
        return '已出库';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending' || status == '待拣货';
  bool get isPicking => status == 'picking' || status == '拣货中';
  bool get isShipped => status == 'shipped' || status == '已出库';

  int get totalQuantity {
    if (items == null || items!.isEmpty) {
      return 0;
    }
    return items!.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }
}

class OutboundItem {
  final String? productId;
  final String? productName;
  final String? productSpec;
  final int? quantity;
  final int? pickedQuantity;

  OutboundItem({
    this.productId,
    this.productName,
    this.productSpec,
    this.quantity,
    this.pickedQuantity,
  });

  factory OutboundItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OutboundItem();
    }
    return OutboundItem(
      productId: json['productId']?.toString(),
      productName: json['productName'] ?? json['name'],
      productSpec: json['productSpec'] ?? json['spec'],
      quantity: json['quantity'],
      pickedQuantity: json['pickedQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (productSpec != null) 'productSpec': productSpec,
      if (quantity != null) 'quantity': quantity,
      if (pickedQuantity != null) 'pickedQuantity': pickedQuantity,
    };
  }
}

class OutboundRequest {
  final String orderId;
  final List<OutboundItemRequest> items;
  final String? remark;
  final String? type;

  OutboundRequest({
    required this.orderId,
    required this.items,
    this.remark,
    this.type = 'order',
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((e) => e.toJson()).toList(),
      if (remark != null) 'remark': remark,
      if (type != null) 'type': type,
    };
  }
}

class OutboundItemRequest {
  final String productId;
  final int quantity;

  OutboundItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
