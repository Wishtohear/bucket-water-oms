import '../models/order_model.dart';

class StatementModel {
  final String? id;
  final String? statementNo;
  final String? stationId;
  final String? stationName;
  final String? driverId;
  final String? driverName;
  final String? warehouseId;
  final String? warehouseName;
  final String? status;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final double? totalAmount;
  final double? baseSalary;
  final double? commission;
  final int? totalOrders;
  final int? deliveredBarrels;
  final int? returnedBarrels;
  final int? owedBarrels;
  final double? praiseRate;
  final List<OrderModel>? orders;
  final List<StatementItem>? items;
  final String? remark;

  StatementModel({
    this.id,
    this.statementNo,
    this.stationId,
    this.stationName,
    this.driverId,
    this.driverName,
    this.warehouseId,
    this.warehouseName,
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.confirmedAt,
    this.totalAmount,
    this.baseSalary,
    this.commission,
    this.totalOrders,
    this.deliveredBarrels,
    this.returnedBarrels,
    this.owedBarrels,
    this.praiseRate,
    this.orders,
    this.items,
    this.remark,
  });

  factory StatementModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StatementModel();
    }
    return StatementModel(
      id: json['id']?.toString() ?? json['statementId']?.toString(),
      statementNo: json['statementNo'] ?? json['statement_no'],
      stationId: json['stationId']?.toString() ?? json['station_id']?.toString(),
      stationName: json['stationName'] ?? json['station_name'],
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      driverName: json['driverName'] ?? json['driver_name'],
      warehouseId: json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      status: json['status'],
      type: json['type'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : json['start_date'] != null
              ? DateTime.tryParse(json['start_date'].toString())
              : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : json['end_date'] != null
              ? DateTime.tryParse(json['end_date'].toString())
              : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['generateDate'] != null
              ? DateTime.tryParse(json['generateDate'].toString())
              : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : json['confirmDate'] != null
              ? DateTime.tryParse(json['confirmDate'].toString())
              : null,
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
      baseSalary: _parseDouble(json['baseSalary'] ?? json['base_salary']),
      commission: _parseDouble(json['commission']),
      totalOrders: json['totalOrders'] ?? json['total_orders'],
      deliveredBarrels: json['deliveredBarrels'] ?? json['delivered_barrels'],
      returnedBarrels: json['returnedBarrels'] ?? json['returned_barrels'],
      owedBarrels: json['owedBarrels'] ?? json['owed_barrels'],
      praiseRate: _parseDouble(json['praiseRate'] ?? json['praise_rate']),
      orders: json['orders'] != null
          ? (json['orders'] as List)
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => StatementItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      remark: json['remark'],
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待确认';
      case 'confirmed':
        return '已确认';
      case 'disputed':
        return '有争议';
      case 'paid':
        return '已结清';
      default:
        return status ?? '未知';
    }
  }

  String get typeText {
    switch (type) {
      case 'monthly':
        return '月度对账单';
      case 'weekly':
        return '周对账单';
      case 'daily':
        return '日对账单';
      default:
        return '对账单';
    }
  }

  String get formattedDateRange {
    if (startDate == null || endDate == null) return '';
    final start = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
    final end = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    return '$start 至 $end';
  }

  String get formattedMonth {
    if (startDate == null) return '';
    return '${startDate!.year}年${startDate!.month.toString().padLeft(2, '0')}月';
  }

  String get praiseRateText {
    if (praiseRate == null) return '0%';
    return '${(praiseRate! * 100).toStringAsFixed(0)}%';
  }
}

class StatementItem {
  final String? productId;
  final String? productName;
  final int? quantity;
  final double? unitPrice;
  final double? subtotal;

  StatementItem({
    this.productId,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.subtotal,
  });

  factory StatementItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StatementItem();
    }
    return StatementItem(
      productId: json['productId']?.toString(),
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: _parseDouble(json['unitPrice']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  String get subtotalText =>
      subtotal != null ? '¥${subtotal!.toStringAsFixed(2)}' : '¥0.00';
}

class StatementDetailItem {
  final String? id;
  final String? date;
  final String? type;
  final String? description;
  final int? orderCount;
  final int? barrelCount;
  final double? amount;
  final String? status;

  StatementDetailItem({
    this.id,
    this.date,
    this.type,
    this.description,
    this.orderCount,
    this.barrelCount,
    this.amount,
    this.status,
  });

  factory StatementDetailItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StatementDetailItem();
    }
    return StatementDetailItem(
      id: json['id']?.toString(),
      date: json['date'],
      type: json['type'],
      description: json['description'],
      orderCount: json['orderCount'],
      barrelCount: json['barrelCount'],
      amount: _parseDouble(json['amount']),
      status: json['status'],
    );
  }

  String get amountText =>
      amount != null ? '¥${amount!.toStringAsFixed(2)}' : '¥0.00';

  String get typeText {
    switch (type) {
      case 'commission':
        return '配送提成';
      case 'reward':
        return '奖励';
      case 'penalty':
        return '扣款';
      case 'bonus':
        return '奖金';
      case 'deduction':
        return '扣减';
      default:
        return type ?? '其他';
    }
  }

  bool get isPositive {
    if (amount == null) return false;
    return amount! > 0;
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
