import '../core/network/api_client.dart';
import '../models/report_models.dart';

class AdminReportService {
  static final AdminReportService _instance = AdminReportService._internal();
  factory AdminReportService() => _instance;
  AdminReportService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<ReportStatsResponse> getDashboardStats() async {
    final response = await _apiClient.get('/admin/reports/dashboard-stats');

    if (response.success && response.data != null) {
      return ReportStatsResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取Dashboard统计失败',
        statusCode: response.code,
      );
    }
  }

  Future<ReportStatsResponse> getStats({
    String? startDate,
    String? endDate,
    String? stationId,
    String? warehouseId,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (stationId != null) queryParams['stationId'] = stationId;
    if (warehouseId != null) queryParams['warehouseId'] = warehouseId;

    final response = await _apiClient.get(
      '/admin/reports/stats',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      return ReportStatsResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取报表统计失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<SalesTrendData>> getSalesTrend({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period ?? 'week',
    };
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/admin/reports/sales-trend',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => SalesTrendData.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    throw ApiException(
      response.message ?? '获取销售趋势失败',
      statusCode: response.code,
    );
  }

  Future<List<ProductDistributionData>> getProductDistribution({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/admin/reports/product-distribution',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => ProductDistributionData.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    throw ApiException(
      response.message ?? '获取产品分布失败',
      statusCode: response.code,
    );
  }

  Future<List<StationRankingData>> getStationRankings({
    String? period,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (period != null) queryParams['period'] = period;

    final response = await _apiClient.get(
      '/admin/reports/station-rankings',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => StationRankingData.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    throw ApiException(
      response.message ?? '获取水站排行失败',
      statusCode: response.code,
    );
  }

  Future<DailySalesResponse> getDailySales({
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 30,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/admin/reports/daily-sales',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      return DailySalesResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取日报失败',
        statusCode: response.code,
      );
    }
  }

  Future<String?> exportReport({
    required String type,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'type': type,
    };
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/admin/reports/export',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['url']?.toString();
    }
    throw ApiException(
      response.message ?? '导出报表失败',
      statusCode: response.code,
    );
  }
}

class ReportStatsResponse {
  final double totalSales;
  final double todaySales;
  final int totalOrders;
  final int todayOrders;
  final int totalStations;
  final int activeStations;
  final int totalWarehouses;
  final int warningWarehouses;
  final int totalDrivers;
  final int onlineDrivers;
  final int monthDeliveries;
  final double comparedToYesterday;

  ReportStatsResponse({
    required this.totalSales,
    required this.todaySales,
    required this.totalOrders,
    required this.todayOrders,
    required this.totalStations,
    required this.activeStations,
    required this.totalWarehouses,
    required this.warningWarehouses,
    required this.totalDrivers,
    required this.onlineDrivers,
    required this.monthDeliveries,
    required this.comparedToYesterday,
  });

  factory ReportStatsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReportStatsResponse(
        totalSales: 0,
        todaySales: 0,
        totalOrders: 0,
        todayOrders: 0,
        totalStations: 0,
        activeStations: 0,
        totalWarehouses: 0,
        warningWarehouses: 0,
        totalDrivers: 0,
        onlineDrivers: 0,
        monthDeliveries: 0,
        comparedToYesterday: 0,
      );
    }
    return ReportStatsResponse(
      totalSales: _parseDouble(json['totalSales']) ?? _parseDouble(json['total_sales']) ?? 0,
      todaySales: _parseDouble(json['todaySales']) ?? _parseDouble(json['today_sales']) ?? 0,
      totalOrders: json['totalOrders'] ?? json['total_orders'] ?? 0,
      todayOrders: json['todayOrders'] ?? json['today_orders'] ?? 0,
      totalStations: json['totalStations'] ?? json['total_stations'] ?? 0,
      activeStations: json['activeStations'] ?? json['active_stations'] ?? 0,
      totalWarehouses: json['totalWarehouses'] ?? json['total_warehouses'] ?? 0,
      warningWarehouses: json['warningWarehouses'] ?? json['warning_warehouses'] ?? 0,
      totalDrivers: json['totalDrivers'] ?? json['total_drivers'] ?? 0,
      onlineDrivers: json['onlineDrivers'] ?? json['online_drivers'] ?? 0,
      monthDeliveries: json['monthDeliveries'] ?? json['month_deliveries'] ?? 0,
      comparedToYesterday: _parseDouble(json['comparedToYesterday']) ?? _parseDouble(json['compared_to_yesterday']) ?? 0,
    );
  }
}

class SalesTrendData {
  final String date;
  final double amount;
  final int orderCount;

  SalesTrendData({
    required this.date,
    required this.amount,
    required this.orderCount,
  });

  factory SalesTrendData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SalesTrendData(date: '', amount: 0, orderCount: 0);
    return SalesTrendData(
      date: json['date'] ?? '',
      amount: _parseDouble(json['amount']) ?? 0,
      orderCount: json['orderCount'] ?? json['order_count'] ?? 0,
    );
  }
}

class ProductDistributionData {
  final String productName;
  final int quantity;
  final double percentage;

  ProductDistributionData({
    required this.productName,
    required this.quantity,
    required this.percentage,
  });

  factory ProductDistributionData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductDistributionData(productName: '', quantity: 0, percentage: 0);
    return ProductDistributionData(
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      percentage: _parseDouble(json['percentage']) ?? 0,
    );
  }
}

class StationRankingData {
  final int rank;
  final String stationName;
  final double salesAmount;
  final int orderCount;

  StationRankingData({
    required this.rank,
    required this.stationName,
    required this.salesAmount,
    required this.orderCount,
  });

  factory StationRankingData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationRankingData(rank: 0, stationName: '', salesAmount: 0, orderCount: 0);
    return StationRankingData(
      rank: json['rank'] ?? 0,
      stationName: json['stationName'] ?? json['station_name'] ?? '',
      salesAmount: _parseDouble(json['salesAmount']) ?? _parseDouble(json['sales_amount']) ?? 0,
      orderCount: json['orderCount'] ?? json['order_count'] ?? 0,
    );
  }
}

class DailySalesResponse {
  final List<DailySalesItem> items;
  final double totalSales;
  final int totalOrders;

  DailySalesResponse({
    required this.items,
    required this.totalSales,
    required this.totalOrders,
  });

  factory DailySalesResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DailySalesResponse(items: [], totalSales: 0, totalOrders: 0);
    }
    return DailySalesResponse(
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => DailySalesItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      totalSales: _parseDouble(json['totalSales']) ?? _parseDouble(json['total_sales']) ?? 0,
      totalOrders: json['totalOrders'] ?? json['total_orders'] ?? 0,
    );
  }
}

class DailySalesItem {
  final String date;
  final double salesAmount;
  final int orderCount;

  DailySalesItem({
    required this.date,
    required this.salesAmount,
    required this.orderCount,
  });

  factory DailySalesItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DailySalesItem(date: '', salesAmount: 0, orderCount: 0);
    return DailySalesItem(
      date: json['date'] ?? '',
      salesAmount: _parseDouble(json['salesAmount']) ?? _parseDouble(json['sales_amount']) ?? 0,
      orderCount: json['orderCount'] ?? json['order_count'] ?? 0,
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
