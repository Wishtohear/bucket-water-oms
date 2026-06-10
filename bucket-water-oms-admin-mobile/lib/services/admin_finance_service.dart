import '../core/network/api_client.dart';

class AdminFinanceService {
  static final AdminFinanceService _instance = AdminFinanceService._internal();
  factory AdminFinanceService() => _instance;
  AdminFinanceService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<FinanceOverviewResponse> getFinanceOverview() async {
    final response = await _apiClient.get('/admin/finance/overview');

    if (response.success && response.data != null) {
      return FinanceOverviewResponse.fromJson(
          response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<FinanceStatementListResponse> getStatements({
    String? stationId,
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (stationId != null) queryParams['stationId'] = stationId;
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/admin/finance/statements',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<FinanceStatementModel> statements = [];
      int total = 0;
      FinanceOverviewResponse? overview;

      if (data != null) {
        if (data is List) {
          statements = data
              .map((e) =>
                  FinanceStatementModel.fromJson(e as Map<String, dynamic>))
              .toList();
          total = statements.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            statements = (data['list'] as List)
                .map((e) =>
                    FinanceStatementModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (data['records'] != null) {
            statements = (data['records'] as List)
                .map((e) =>
                    FinanceStatementModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? statements.length;
          if (data['overview'] != null) {
            overview = FinanceOverviewResponse.fromJson(
                data['overview'] as Map<String, dynamic>);
          }
        }
      }

      return FinanceStatementListResponse(
        statements: statements,
        total: total,
        page: page,
        pageSize: pageSize,
        overview: overview,
      );
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<FinanceStatementModel> getStatementDetail(String statementId) async {
    final response =
        await _apiClient.get('/admin/finance/statements/$statementId');

    if (response.success && response.data != null) {
      return FinanceStatementModel.fromJson(
          response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmStatement(String statementId) async {
    final response = await _apiClient.post(
      '/admin/finance/statements/$statementId/confirm',
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }
}

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
  final List<OrderItem>? orders;

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
          ? DateTime.tryParse(json['startDate'] ?? json['start_date'] ?? '')
          : null,
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.tryParse(json['endDate'] ?? json['end_date'] ?? '')
          : null,
      orders: json['orders'] != null
          ? (json['orders'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : null,
    );
  }
}

class OrderItem {
  final String? id;
  final String? orderNo;
  final double? amount;
  final DateTime? createdAt;

  OrderItem({
    this.id,
    this.orderNo,
    this.amount,
    this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderItem();
    return OrderItem(
      id: json['id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      amount: _parseDouble(json['amount']),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '')
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
