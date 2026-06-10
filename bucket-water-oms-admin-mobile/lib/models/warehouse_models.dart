class InboundModel {
  final String? id;
  final String? inboundNo;
  final String? warehouseId;
  final String? warehouseName;
  final String? type;
  final String? typeText;
  final String? status;
  final String? statusText;
  final double? totalAmount;
  final int? totalQuantity;
  final String? remark;
  final String? creator;
  final String? checker;
  final DateTime? createTime;
  final DateTime? checkTime;
  final List<InboundItemModel>? items;
  final String? productName;
  final int? quantity;
  final String? handlerName;
  final DateTime? createdAt;

  InboundModel({
    this.id,
    this.inboundNo,
    this.warehouseId,
    this.warehouseName,
    this.type,
    this.typeText,
    this.status,
    this.statusText,
    this.totalAmount,
    this.totalQuantity,
    this.remark,
    this.creator,
    this.checker,
    this.createTime,
    this.checkTime,
    this.items,
    this.productName,
    this.quantity,
    this.handlerName,
    this.createdAt,
  });

  factory InboundModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InboundModel();
    return InboundModel(
      id: json['id']?.toString(),
      inboundNo: json['inboundNo'] ?? json['code'],
      warehouseId: json['warehouseId']?.toString(),
      warehouseName: json['warehouseName'],
      type: json['type'],
      typeText: json['typeText'],
      status: json['status'],
      statusText: json['statusText'],
      totalAmount: _parseDouble(json['totalAmount']),
      totalQuantity: json['totalQuantity'],
      remark: json['remark'],
      creator: json['creator'],
      checker: json['checker'],
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'].toString())
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      checkTime: json['checkTime'] != null
          ? DateTime.tryParse(json['checkTime'].toString())
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => InboundItemModel.fromJson(e))
              .toList()
          : null,
      productName: json['productName'],
      quantity: json['quantity'],
      handlerName: json['handlerName'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  String get statusDisplayText {
    if (statusText != null) return statusText!;
    switch (status) {
      case 'pending':
        return '待核验';
      case 'confirmed':
        return '已确认';
      case 'rejected':
        return '已拒绝';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isRejected => status == 'rejected';
  bool get isPreparing => status == 'preparing';
}

class InboundItemModel {
  final String? id;
  final String? inboundId;
  final String? productId;
  final String? productName;
  final int? quantity;
  final double? price;
  final double? amount;

  InboundItemModel({
    this.id,
    this.inboundId,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.amount,
  });

  factory InboundItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InboundItemModel();
    return InboundItemModel(
      id: json['id']?.toString(),
      inboundId: json['inboundId']?.toString(),
      productId: json['productId']?.toString(),
      productName: json['productName'],
      quantity: json['quantity'],
      price: _parseDouble(json['price']),
      amount: _parseDouble(json['amount']),
    );
  }
}

class InboundRequest {
  final String? supplierId;
  final String? supplierName;
  final List<InboundItem> items;
  final String? remark;
  final String? type;

  InboundRequest({
    this.supplierId,
    this.supplierName,
    required this.items,
    this.remark,
    this.type = 'purchase',
  });

  Map<String, dynamic> toJson() {
    return {
      if (supplierId != null) 'supplierId': supplierId,
      if (supplierName != null) 'supplierName': supplierName,
      'items': items.map((e) => e.toJson()).toList(),
      if (remark != null) 'remark': remark,
      if (type != null) 'type': type,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
    };
  }
}

class OutboundModel {
  final String? id;
  final String? outboundNo;
  final String? warehouseId;
  final String? warehouseName;
  final String? orderId;
  final String? orderNo;
  final String? type;
  final String? typeText;
  final String? status;
  final String? statusText;
  final double? totalAmount;
  final int? totalQuantity;
  final String? stationId;
  final String? stationName;
  final String? remark;
  final String? creator;
  final String? confirmer;
  final DateTime? createTime;
  final DateTime? confirmTime;
  final List<OutboundItemModel>? items;

  OutboundModel({
    this.id,
    this.outboundNo,
    this.warehouseId,
    this.warehouseName,
    this.orderId,
    this.orderNo,
    this.type,
    this.typeText,
    this.status,
    this.statusText,
    this.totalAmount,
    this.totalQuantity,
    this.stationId,
    this.stationName,
    this.remark,
    this.creator,
    this.confirmer,
    this.createTime,
    this.confirmTime,
    this.items,
  });

  factory OutboundModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OutboundModel();
    return OutboundModel(
      id: json['id']?.toString(),
      outboundNo: json['outboundNo'] ?? json['code'],
      warehouseId: json['warehouseId']?.toString(),
      warehouseName: json['warehouseName'],
      orderId: json['orderId']?.toString(),
      orderNo: json['orderNo'],
      type: json['type'],
      typeText: json['typeText'],
      status: json['status'],
      statusText: json['statusText'],
      totalAmount: _parseDouble(json['totalAmount']),
      totalQuantity: json['totalQuantity'],
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      remark: json['remark'],
      creator: json['creator'],
      confirmer: json['confirmer'],
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'].toString())
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      confirmTime: json['confirmTime'] != null
          ? DateTime.tryParse(json['confirmTime'].toString())
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OutboundItemModel.fromJson(e))
              .toList()
          : null,
    );
  }

  String get statusDisplayText {
    if (statusText != null) return statusText!;
    switch (status) {
      case 'pending':
        return '待出库';
      case 'confirmed':
        return '已出库';
      case 'rejected':
        return '已拒绝';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isRejected => status == 'rejected';
  bool get isPreparing => status == 'preparing';
}

class OutboundItemModel {
  final String? id;
  final String? outboundId;
  final String? productId;
  final String? productName;
  final int? quantity;
  final double? price;
  final double? amount;

  OutboundItemModel({
    this.id,
    this.outboundId,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.amount,
  });

  factory OutboundItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OutboundItemModel();
    return OutboundItemModel(
      id: json['id']?.toString(),
      outboundId: json['outboundId']?.toString(),
      productId: json['productId']?.toString(),
      productName: json['productName'],
      quantity: json['quantity'],
      price: _parseDouble(json['price']),
      amount: _parseDouble(json['amount']),
    );
  }
}

class BucketInboundModel {
  final String? id;
  final String? inboundNo;
  final String? type;
  final String? driverId;
  final String? driverName;
  final int? quantity;
  final String? bucketType;
  final String? source;
  final String? status;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? confirmedAt;

  BucketInboundModel({
    this.id,
    this.inboundNo,
    this.type,
    this.driverId,
    this.driverName,
    this.quantity,
    this.bucketType,
    this.source,
    this.status,
    this.remark,
    this.createdAt,
    this.confirmedAt,
  });

  factory BucketInboundModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BucketInboundModel();
    return BucketInboundModel(
      id: json['id']?.toString(),
      inboundNo: json['inboundNo'] ?? json['code'],
      type: json['type'],
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'] ?? json['driverName'],
      quantity: json['quantity'],
      bucketType: json['bucketType'] ?? json['bucket_type'],
      source: json['source'],
      status: json['status'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
    );
  }

  String get typeText {
    switch (type) {
      case 'driver_return':
        return '司机回桶';
      case 'clean':
        return '清洗入库';
      case 'transfer_in':
        return '调拨入库';
      default:
        return type ?? '未知';
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
      case '待核验':
        return '待核验';
      case 'confirmed':
      case '已完成':
        return '已入库';
      case 'rejected':
      case '已拒绝':
        return '已拒绝';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending' || status == '待核验';
  bool get isCompleted => status == 'confirmed' || status == '已完成';
}

class BucketOutboundModel {
  final String? id;
  final String? outboundNo;
  final String? type;
  final String? driverId;
  final String? driverName;
  final int? quantity;
  final String? bucketType;
  final String? destination;
  final String? status;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? confirmedAt;

  BucketOutboundModel({
    this.id,
    this.outboundNo,
    this.type,
    this.driverId,
    this.driverName,
    this.quantity,
    this.bucketType,
    this.destination,
    this.status,
    this.remark,
    this.createdAt,
    this.confirmedAt,
  });

  factory BucketOutboundModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BucketOutboundModel();
    return BucketOutboundModel(
      id: json['id']?.toString(),
      outboundNo: json['outboundNo'] ?? json['code'],
      type: json['type'],
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'] ?? json['driverName'],
      quantity: json['quantity'],
      bucketType: json['bucketType'] ?? json['bucket_type'],
      destination: json['destination'],
      status: json['status'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
    );
  }

  String get typeText {
    switch (type) {
      case 'driver_pickup':
        return '司机领用';
      case 'transfer_out':
        return '调拨出库';
      case 'damage':
        return '损耗出库';
      default:
        return type ?? '未知';
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
      case '待领取':
        return '待领取';
      case 'confirmed':
      case '已完成':
        return '已出库';
      case 'rejected':
      case '已拒绝':
        return '已拒绝';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending' || status == '待领取';
  bool get isCompleted => status == 'confirmed' || status == '已完成';
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class InventoryCheckModel {
  final String? id;
  final String? checkNo;
  final String? warehouseId;
  final String? warehouseName;
  final DateTime? checkDate;
  final String? checker;
  final String? status;
  final String? statusText;
  final int? totalProducts;
  final int? matchedProducts;
  final int? discrepancyProducts;
  final String? summary;
  final DateTime? createdAt;

  InventoryCheckModel({
    this.id,
    this.checkNo,
    this.warehouseId,
    this.warehouseName,
    this.checkDate,
    this.checker,
    this.status,
    this.statusText,
    this.totalProducts,
    this.matchedProducts,
    this.discrepancyProducts,
    this.summary,
    this.createdAt,
  });

  factory InventoryCheckModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryCheckModel();
    return InventoryCheckModel(
      id: json['id']?.toString(),
      checkNo: json['checkNo'] ?? json['check_no'],
      warehouseId: json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      checkDate: json['checkDate'] != null
          ? DateTime.tryParse(json['checkDate'].toString())
          : json['check_date'] != null
              ? DateTime.tryParse(json['check_date'].toString())
              : null,
      checker: json['checker'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
      totalProducts: json['totalProducts'] ?? json['total_products'],
      matchedProducts: json['matchedProducts'] ?? json['matched_products'],
      discrepancyProducts: json['discrepancyProducts'] ?? json['discrepancy_products'],
      summary: json['summary'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get hasDiscrepancy =>
      discrepancyProducts != null && discrepancyProducts! > 0;
}

class InventoryCheckItemModel {
  final String? id;
  final String? checkId;
  final String? productId;
  final String? productName;
  final String? category;
  final int? systemQuantity;
  final int? actualQuantity;
  final int? discrepancy;
  final String? remark;

  InventoryCheckItemModel({
    this.id,
    this.checkId,
    this.productId,
    this.productName,
    this.category,
    this.systemQuantity,
    this.actualQuantity,
    this.discrepancy,
    this.remark,
  });

  factory InventoryCheckItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryCheckItemModel();
    return InventoryCheckItemModel(
      id: json['id']?.toString(),
      checkId: json['checkId']?.toString() ?? json['check_id']?.toString(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      category: json['category'],
      systemQuantity: json['systemQuantity'] ?? json['system_quantity'],
      actualQuantity: json['actualQuantity'] ?? json['actual_quantity'],
      discrepancy: json['discrepancy'],
      remark: json['remark'],
    );
  }

  bool get hasDiscrepancy => discrepancy != null && discrepancy != 0;
}

class InventoryChangeRecord {
  final String? id;
  final String? inventoryId;
  final String? productName;
  final String? type;
  final String? typeText;
  final int? quantity;
  final int? beforeStock;
  final int? afterStock;
  final String? operator;
  final String? remark;
  final DateTime? createdAt;

  InventoryChangeRecord({
    this.id,
    this.inventoryId,
    this.productName,
    this.type,
    this.typeText,
    this.quantity,
    this.beforeStock,
    this.afterStock,
    this.operator,
    this.remark,
    this.createdAt,
  });

  factory InventoryChangeRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryChangeRecord();
    return InventoryChangeRecord(
      id: json['id']?.toString(),
      inventoryId: json['inventoryId']?.toString() ?? json['inventory_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      type: json['type'],
      typeText: json['typeText'] ?? json['type_text'],
      quantity: json['quantity'],
      beforeStock: json['beforeStock'] ?? json['before_stock'],
      afterStock: json['afterStock'] ?? json['after_stock'],
      operator: json['operator'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
    );
  }
}

class CreateInboundRequest {
  final String? type;
  final String? source;
  final String? relatedOrderNo;
  final String? remark;
  final List<CreateInboundItem> items;

  CreateInboundRequest({
    this.type,
    this.source,
    this.relatedOrderNo,
    this.remark,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (relatedOrderNo != null) 'relatedOrderNo': relatedOrderNo,
      if (remark != null) 'remark': remark,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateInboundItem {
  final String productId;
  final int quantity;
  final double? unitPrice;

  CreateInboundItem({
    required this.productId,
    required this.quantity,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
    };
  }
}
