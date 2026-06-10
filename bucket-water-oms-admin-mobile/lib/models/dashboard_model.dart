class DashboardModel {
  final TodayStatsModel? todayStats;
  final List<SalesTrendModel>? salesTrend;
  final List<NotificationModel>? notifications;
  final List<InventoryWarningModel>? inventoryWarnings;
  final List<RecentOrderModel>? recentOrders;
  final double? accountBalance;
  final double? creditLimit;
  final double? usedCredit;
  final int? totalBarrels;
  final int? emptyBarrels;

  DashboardModel({
    this.todayStats,
    this.salesTrend,
    this.notifications,
    this.inventoryWarnings,
    this.recentOrders,
    this.accountBalance,
    this.creditLimit,
    this.usedCredit,
    this.totalBarrels,
    this.emptyBarrels,
  });

  factory DashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardModel();
    }
    return DashboardModel(
      todayStats: json['todayStats'] != null
          ? TodayStatsModel.fromJson(json['todayStats'])
          : null,
      salesTrend: json['salesTrend'] != null
          ? (json['salesTrend'] as List)
              .map((e) => SalesTrendModel.fromJson(e))
              .toList()
          : null,
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((e) => NotificationModel.fromJson(e))
              .toList()
          : null,
      inventoryWarnings: json['inventoryWarnings'] != null
          ? (json['inventoryWarnings'] as List)
              .map((e) => InventoryWarningModel.fromJson(e))
              .toList()
          : null,
      recentOrders: json['recentOrders'] != null
          ? (json['recentOrders'] as List)
              .map((e) => RecentOrderModel.fromJson(e))
              .toList()
          : null,
      accountBalance: _parseDouble(json['accountBalance'] ?? json['balance']),
      creditLimit: _parseDouble(json['creditLimit']),
      usedCredit: _parseDouble(json['usedCredit']),
      totalBarrels: json['totalBarrels'],
      emptyBarrels: json['emptyBarrels'],
    );
  }

  double get availableCredit =>
      (creditLimit ?? 0) - (usedCredit ?? 0);

  String get accountBalanceText =>
      accountBalance != null ? '${accountBalance!.toStringAsFixed(2)}' : '0.00';
  String get creditText =>
      '¥${availableCredit.toStringAsFixed(0)} / ¥${(creditLimit ?? 0).toStringAsFixed(0)}';
}

class TodayStatsModel {
  final double? salesAmount;
  final int? orderCount;
  final int? activeStations;
  final int? inventoryWarnings;
  final double? comparedToYesterday;

  TodayStatsModel({
    this.salesAmount,
    this.orderCount,
    this.activeStations,
    this.inventoryWarnings,
    this.comparedToYesterday,
  });

  factory TodayStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TodayStatsModel();
    }
    return TodayStatsModel(
      salesAmount: _parseDouble(json['salesAmount']),
      orderCount: json['orderCount'],
      activeStations: json['activeStations'],
      inventoryWarnings: json['inventoryWarnings'],
      comparedToYesterday: _parseDouble(json['comparedToYesterday']),
    );
  }

  String get salesAmountText =>
      salesAmount != null ? '¥${salesAmount!.toStringAsFixed(2)}' : '¥0.00';
  String get orderCountText => '${orderCount ?? 0} 单';
  String get comparedText =>
      comparedToYesterday != null ? '${comparedToYesterday! >= 0 ? '+' : ''}${comparedToYesterday!.toStringAsFixed(1)}%' : '0%';
}

class SalesTrendModel {
  final String? date;
  final double? amount;
  final int? count;

  SalesTrendModel({
    this.date,
    this.amount,
    this.count,
  });

  factory SalesTrendModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SalesTrendModel();
    }
    return SalesTrendModel(
      date: json['date'],
      amount: _parseDouble(json['amount']),
      count: json['count'],
    );
  }
}

class NotificationModel {
  final String? id;
  final String? title;
  final String? content;
  final String? type;
  final bool? isRead;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.title,
    this.content,
    this.type,
    this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NotificationModel();
    }
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title'],
      content: json['content'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class InventoryWarningModel {
  final String? productId;
  final String? productName;
  final String? warehouseId;
  final String? warehouseName;
  final int? currentStock;
  final int? minStock;
  final String? warningType;

  InventoryWarningModel({
    this.productId,
    this.productName,
    this.warehouseId,
    this.warehouseName,
    this.currentStock,
    this.minStock,
    this.warningType,
  });

  factory InventoryWarningModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InventoryWarningModel();
    }
    return InventoryWarningModel(
      productId: json['productId']?.toString(),
      productName: json['productName'],
      warehouseId: json['warehouseId']?.toString(),
      warehouseName: json['warehouseName'],
      currentStock: json['currentStock'] ?? json['stock'],
      minStock: json['minStock'],
      warningType: json['warningType'],
    );
  }
}

class RecentOrderModel {
  final String? id;
  final String? orderNo;
  final String? stationName;
  final double? amount;
  final String? status;
  final DateTime? createdAt;

  RecentOrderModel({
    this.id,
    this.orderNo,
    this.stationName,
    this.amount,
    this.status,
    this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RecentOrderModel();
    }
    return RecentOrderModel(
      id: json['id']?.toString(),
      orderNo: json['orderNo'],
      stationName: json['stationName'],
      amount: _parseDouble(json['amount']),
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
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
