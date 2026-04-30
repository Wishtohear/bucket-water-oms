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
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final double? totalAmount;
  final int? totalOrders;
  final int? deliveredBarrels;
  final int? returnedBarrels;
  final int? owedBarrels;
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
    this.startDate,
    this.endDate,
    this.createdAt,
    this.confirmedAt,
    this.totalAmount,
    this.totalOrders,
    this.deliveredBarrels,
    this.returnedBarrels,
    this.owedBarrels,
    this.orders,
    this.items,
    this.remark,
  });

  factory StatementModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StatementModel();
    }
    return StatementModel(
      id: json['id']?.toString(),
      statementNo: json['statementNo'],
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'],
      warehouseId: json['warehouseId']?.toString(),
      warehouseName: json['warehouseName'],
      status: json['status'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
      totalAmount: _parseDouble(json['totalAmount']),
      totalOrders: json['totalOrders'],
      deliveredBarrels: json['deliveredBarrels'],
      returnedBarrels: json['returnedBarrels'],
      owedBarrels: json['owedBarrels'],
      orders: json['orders'] != null
          ? (json['orders'] as List)
              .map((e) => OrderModel.fromJson(e))
              .toList()
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => StatementItem.fromJson(e))
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

  String get formattedDateRange {
    if (startDate == null || endDate == null) return '';
    final start = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
    final end = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    return '$start 至 $end';
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
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
