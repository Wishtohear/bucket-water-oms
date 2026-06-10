import '../core/network/api_client.dart';
import '../models/inventory_models.dart';

class AdminInventoryService {
  static final AdminInventoryService _instance = AdminInventoryService._internal();
  factory AdminInventoryService() => _instance;
  AdminInventoryService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<InventoryOverviewResponse> getInventoryOverview() async {
    final response = await _apiClient.get('/admin/inventory/overview');

    if (response.success && response.data != null) {
      return InventoryOverviewResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取库存概览失败',
        statusCode: response.code,
      );
    }
  }

  Future<InventoryListResponse> getInventoryList({
    String? warehouseId,
    String? productId,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (warehouseId != null) queryParams['warehouseId'] = warehouseId;
    if (productId != null) queryParams['productId'] = productId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      '/admin/inventory',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<InventoryItemModel> items = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          items = data.map((e) => InventoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
          total = items.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            items = (data['list'] as List)
                .map((e) => InventoryItemModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? items.length;
        }
      }

      return InventoryListResponse(
        items: items,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '获取库存列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<InventoryRecordListResponse> getInventoryRecords({
    String? warehouseId,
    String? type,
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (warehouseId != null) queryParams['warehouseId'] = warehouseId;
    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/admin/inventory/records',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<InventoryRecordModel> records = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          records = data.map((e) => InventoryRecordModel.fromJson(e as Map<String, dynamic>)).toList();
          total = records.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            records = (data['list'] as List)
                .map((e) => InventoryRecordModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? records.length;
        }
      }

      return InventoryRecordListResponse(
        records: records,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '获取库存记录失败',
        statusCode: response.code,
      );
    }
  }
}

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
