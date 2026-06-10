class FinanceOverviewResponse {
  final double totalReceivable;
  final double totalPaid;
  final double totalUnpaid;
  final double overdueAmount;
  final int totalStations;
  final int pendingStatements;
  final int overdueStatements;

  FinanceOverviewResponse({
    required this.totalReceivable,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.overdueAmount,
    required this.totalStations,
    required this.pendingStatements,
    required this.overdueStatements,
  });

  factory FinanceOverviewResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FinanceOverviewResponse(
        totalReceivable: 0,
        totalPaid: 0,
        totalUnpaid: 0,
        overdueAmount: 0,
        totalStations: 0,
        pendingStatements: 0,
        overdueStatements: 0,
      );
    }
    return FinanceOverviewResponse(
      totalReceivable: _parseDouble(json['totalReceivable']) ??
          _parseDouble(json['total_receivable']) ??
          0,
      totalPaid: _parseDouble(json['totalPaid']) ??
          _parseDouble(json['total_paid']) ??
          0,
      totalUnpaid: _parseDouble(json['totalUnpaid']) ??
          _parseDouble(json['total_unpaid']) ??
          0,
      overdueAmount: _parseDouble(json['overdueAmount']) ??
          _parseDouble(json['overdue_amount']) ??
          0,
      totalStations: json['totalStations'] ?? json['total_stations'] ?? 0,
      pendingStatements:
          json['pendingStatements'] ?? json['pending_statements'] ?? 0,
      overdueStatements:
          json['overdueStatements'] ?? json['overdue_statements'] ?? 0,
    );
  }
}

class FinanceStatementModel {
  final String? id;
  final String? stationId;
  final String? stationName;
  final String? period;
  final double? totalAmount;
  final double? paidAmount;
  final double? unpaidAmount;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final List<FinanceOrderItem>? orders;

  FinanceStatementModel({
    this.id,
    this.stationId,
    this.stationName,
    this.period,
    this.totalAmount,
    this.paidAmount,
    this.unpaidAmount,
    this.status,
    this.startDate,
    this.endDate,
    this.dueDate,
    this.orders,
  });

  factory FinanceStatementModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FinanceStatementModel();
    return FinanceStatementModel(
      id: json['id']?.toString(),
      stationId:
          json['stationId']?.toString() ?? json['station_id']?.toString(),
      stationName: json['stationName'] ?? json['station_name'],
      period: json['period'],
      totalAmount: _parseDouble(json['totalAmount']) ??
          _parseDouble(json['total_amount']),
      paidAmount:
          _parseDouble(json['paidAmount']) ?? _parseDouble(json['paid_amount']),
      unpaidAmount: _parseDouble(json['unpaidAmount']) ??
          _parseDouble(json['unpaid_amount']),
      status: json['status'],
      startDate: json['startDate'] != null || json['start_date'] != null
          ? DateTime.tryParse(json['startDate'] ?? json['start_date'])
          : null,
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.tryParse(json['endDate'] ?? json['end_date'])
          : null,
      dueDate: json['dueDate'] != null || json['due_date'] != null
          ? DateTime.tryParse(json['dueDate'] ?? json['due_date'])
          : null,
      orders: json['orders'] != null
          ? (json['orders'] as List)
              .map((e) => FinanceOrderItem.fromJson(e))
              .toList()
          : null,
    );
  }

  String get statusText {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'paid':
      case 'settled':
        return '已确认';
      case 'pending':
        return '待确认';
      case 'disputed':
        return '有争议';
      case 'overdue':
        return '已逾期';
      default:
        return status ?? '未知';
    }
  }
}

class FinanceOrderItem {
  final String? id;
  final String? orderNo;
  final double? amount;
  final DateTime? createdAt;

  FinanceOrderItem({
    this.id,
    this.orderNo,
    this.amount,
    this.createdAt,
  });

  factory FinanceOrderItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FinanceOrderItem();
    return FinanceOrderItem(
      id: json['id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      amount: _parseDouble(json['amount']),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,
    );
  }
}

class FinanceStatementListResponse {
  final List<FinanceStatementModel> statements;
  final int total;
  final int page;
  final int pageSize;
  final FinanceOverviewResponse? overview;

  FinanceStatementListResponse({
    required this.statements,
    required this.total,
    required this.page,
    required this.pageSize,
    this.overview,
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
