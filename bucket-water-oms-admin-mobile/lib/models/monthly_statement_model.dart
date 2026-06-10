class MonthlyStatementModel {
  final String? id;
  final String? stationId;
  final String? stationName;
  final String? yearMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? openingBalance;
  final double? totalAmount;
  final double? paymentReceived;
  final double? closingBalance;
  final int? totalOrders;
  final int? completedOrders;
  final int? totalBuckets;
  final String? status;
  final DateTime? generatedAt;
  final DateTime? confirmedAt;
  final String? disputeReason;
  final DateTime? disputedAt;
  final List<MonthlyOrderSummary>? orders;
  final List<MonthlyProductSummary>? products;

  MonthlyStatementModel({
    this.id,
    this.stationId,
    this.stationName,
    this.yearMonth,
    this.startDate,
    this.endDate,
    this.openingBalance,
    this.totalAmount,
    this.paymentReceived,
    this.closingBalance,
    this.totalOrders,
    this.completedOrders,
    this.totalBuckets,
    this.status,
    this.generatedAt,
    this.confirmedAt,
    this.disputeReason,
    this.disputedAt,
    this.orders,
    this.products,
  });

  factory MonthlyStatementModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MonthlyStatementModel();
    }
    return MonthlyStatementModel(
      id: json['id']?.toString(),
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      yearMonth: json['yearMonth'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      openingBalance: _parseDouble(json['openingBalance']),
      totalAmount: _parseDouble(json['totalAmount']),
      paymentReceived: _parseDouble(json['paymentReceived']),
      closingBalance: _parseDouble(json['closingBalance']),
      totalOrders: json['totalOrders'],
      completedOrders: json['completedOrders'],
      totalBuckets: json['totalBuckets'],
      status: json['status'],
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'].toString())
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
      disputeReason: json['disputeReason'],
      disputedAt: json['disputedAt'] != null
          ? DateTime.tryParse(json['disputedAt'].toString())
          : null,
      orders: json['orders'] != null
          ? (json['orders'] as List)
              .map((e) => MonthlyOrderSummary.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => MonthlyProductSummary.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get formattedMonth {
    if (yearMonth == null) return '';
    return yearMonth!.replaceAll('-', '年') + '月';
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待确认';
      case 'confirmed':
        return '已确认';
      case 'paid':
        return '已结清';
      case 'disputed':
        return '有争议';
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

class MonthlyOrderSummary {
  final String? orderId;
  final String? orderNo;
  final DateTime? orderDate;
  final double? amount;
  final int? buckets;
  final String? status;
  final String? items;

  MonthlyOrderSummary({
    this.orderId,
    this.orderNo,
    this.orderDate,
    this.amount,
    this.buckets,
    this.status,
    this.items,
  });

  factory MonthlyOrderSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MonthlyOrderSummary();
    }
    return MonthlyOrderSummary(
      orderId: json['orderId']?.toString(),
      orderNo: json['orderNo'],
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'].toString())
          : null,
      amount: _parseDouble(json['amount']),
      buckets: json['buckets'],
      status: json['status'],
      items: json['items'],
    );
  }

  String get formattedDate {
    if (orderDate == null) return '';
    return '${orderDate!.month}-${orderDate!.day.toString().padLeft(2, '0')}';
  }

  String get amountText => amount != null ? '¥${amount!.toStringAsFixed(2)}' : '¥0.00';
}

class MonthlyProductSummary {
  final String? productId;
  final String? productName;
  final int? quantity;
  final String? unit;
  final double? unitPrice;
  final double? subtotal;

  MonthlyProductSummary({
    this.productId,
    this.productName,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.subtotal,
  });

  factory MonthlyProductSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MonthlyProductSummary();
    }
    return MonthlyProductSummary(
      productId: json['productId']?.toString(),
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
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
