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
  final int barrelCount;
  final int emptyBarrelReturn;
  final int newStations;

  DailySalesItem({
    required this.date,
    required this.salesAmount,
    required this.orderCount,
    this.barrelCount = 0,
    this.emptyBarrelReturn = 0,
    this.newStations = 0,
  });

  factory DailySalesItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DailySalesItem(date: '', salesAmount: 0, orderCount: 0);
    return DailySalesItem(
      date: json['date'] ?? '',
      salesAmount: _parseDouble(json['salesAmount']) ?? _parseDouble(json['sales_amount']) ?? 0,
      orderCount: json['orderCount'] ?? json['order_count'] ?? 0,
      barrelCount: json['barrelCount'] ?? json['barrel_count'] ?? 0,
      emptyBarrelReturn: json['emptyBarrelReturn'] ?? json['empty_barrel_return'] ?? 0,
      newStations: json['newStations'] ?? json['new_stations'] ?? 0,
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
