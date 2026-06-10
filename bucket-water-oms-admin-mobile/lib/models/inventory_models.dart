class InventoryOverviewResponse {
  final int totalProducts;
  final int totalBarrels;
  final int emptyBarrels;
  final double totalValue;
  final int warningProducts;
  final int lowStockProducts;
  final List<WarehouseInventorySummary> warehouses;

  InventoryOverviewResponse({
    required this.totalProducts,
    required this.totalBarrels,
    required this.emptyBarrels,
    required this.totalValue,
    required this.warningProducts,
    required this.lowStockProducts,
    required this.warehouses,
  });

  factory InventoryOverviewResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InventoryOverviewResponse(
        totalProducts: 0,
        totalBarrels: 0,
        emptyBarrels: 0,
        totalValue: 0,
        warningProducts: 0,
        lowStockProducts: 0,
        warehouses: [],
      );
    }
    return InventoryOverviewResponse(
      totalProducts: json['totalProducts'] ?? json['total_products'] ?? 0,
      totalBarrels: json['totalBarrels'] ?? json['total_barrels'] ?? 0,
      emptyBarrels: json['emptyBarrels'] ?? json['empty_barrels'] ?? 0,
      totalValue: _parseDouble(json['totalValue']) ?? _parseDouble(json['total_value']) ?? 0,
      warningProducts: json['warningProducts'] ?? json['warning_products'] ?? 0,
      lowStockProducts: json['lowStockProducts'] ?? json['low_stock_products'] ?? 0,
      warehouses: json['warehouses'] != null
          ? (json['warehouses'] as List)
              .map((e) => WarehouseInventorySummary.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class WarehouseInventorySummary {
  final String warehouseId;
  final String warehouseName;
  final int productStock;
  final int emptyBarrels;
  final int warningLevel;

  WarehouseInventorySummary({
    required this.warehouseId,
    required this.warehouseName,
    required this.productStock,
    required this.emptyBarrels,
    required this.warningLevel,
  });

  factory WarehouseInventorySummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseInventorySummary(
        warehouseId: '',
        warehouseName: '',
        productStock: 0,
        emptyBarrels: 0,
        warningLevel: 0,
      );
    }
    return WarehouseInventorySummary(
      warehouseId: json['warehouseId']?.toString() ?? json['warehouse_id']?.toString() ?? '',
      warehouseName: json['warehouseName'] ?? json['warehouse_name'] ?? '',
      productStock: json['productStock'] ?? json['product_stock'] ?? 0,
      emptyBarrels: json['emptyBarrels'] ?? json['empty_barrels'] ?? 0,
      warningLevel: json['warningLevel'] ?? json['warning_level'] ?? 0,
    );
  }

  String get warningLevelText {
    switch (warningLevel) {
      case 0:
        return '正常';
      case 1:
        return '预警';
      case 2:
        return '告警';
      default:
        return '未知';
    }
  }
}

class InventoryItemModel {
  final String? id;
  final String? warehouseId;
  final String? warehouseName;
  final String? productId;
  final String? productName;
  final int? currentStock;
  final int? minStock;
  final int? maxStock;
  final String? unit;
  final String? status;

  InventoryItemModel({
    this.id,
    this.warehouseId,
    this.warehouseName,
    this.productId,
    this.productName,
    this.currentStock,
    this.minStock,
    this.maxStock,
    this.unit,
    this.status,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryItemModel();
    return InventoryItemModel(
      id: json['id']?.toString(),
      warehouseId: json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      currentStock: json['currentStock'] ?? json['current_stock'],
      minStock: json['minStock'] ?? json['min_stock'],
      maxStock: json['maxStock'] ?? json['max_stock'],
      unit: json['unit'],
      status: json['status'],
    );
  }

  String get statusText {
    switch (status) {
      case 'normal':
        return '正常';
      case 'low':
        return '库存不足';
      case 'warning':
        return '预警';
      case 'overstock':
        return '库存过剩';
      default:
        return status ?? '未知';
    }
  }

  bool get isLowStock => currentStock != null && minStock != null && currentStock! < minStock!;
}

class InventoryRecordModel {
  final String? id;
  final String? warehouseId;
  final String? warehouseName;
  final String? productId;
  final String? productName;
  final int? quantity;
  final String? type;
  final String? reason;
  final String? operator;
  final DateTime? createdAt;

  InventoryRecordModel({
    this.id,
    this.warehouseId,
    this.warehouseName,
    this.productId,
    this.productName,
    this.quantity,
    this.type,
    this.reason,
    this.operator,
    this.createdAt,
  });

  factory InventoryRecordModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryRecordModel();
    return InventoryRecordModel(
      id: json['id']?.toString(),
      warehouseId: json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      quantity: json['quantity'],
      type: json['type'],
      reason: json['reason'],
      operator: json['operator'],
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,
    );
  }

  String get typeText {
    switch (type) {
      case 'inbound':
        return '入库';
      case 'outbound':
        return '出库';
      case 'production':
        return '生产入库';
      case 'return':
        return '退货入库';
      case 'transfer':
        return '调拨入库';
      case 'sale':
        return '销售出库';
      case 'damage':
        return '库存报损';
      case 'empty_return':
        return '空桶回厂';
      default:
        return type ?? '未知';
    }
  }

  bool get isInbound {
    return type == 'inbound' || type == 'production' || type == 'return' || type == 'transfer' || type == 'empty_return';
  }
}

class InventoryListResponse {
  final List<InventoryItemModel> items;
  final int total;
  final int page;
  final int pageSize;

  InventoryListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

class InventoryRecordListResponse {
  final List<InventoryRecordModel> records;
  final int total;
  final int page;
  final int pageSize;

  InventoryRecordListResponse({
    required this.records,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
