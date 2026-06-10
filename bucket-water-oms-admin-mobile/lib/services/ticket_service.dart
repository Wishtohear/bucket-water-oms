import '../core/network/api_client.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<TicketStatsModel> getTicketStats() async {
    final response = await _apiClient.get('/tickets/stats');

    if (response.success && response.data != null) {
      return TicketStatsModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取水票统计失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<TicketHoldingModel>> getTicketHoldings() async {
    final response = await _apiClient.get('/tickets/holdings');

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => TicketHoldingModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取水票持有情况失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<TicketTransactionModel>> getTicketTransactions({
    String? filter,
    String? dateRange,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (filter != null) queryParams['filter'] = filter;
    if (dateRange != null) queryParams['dateRange'] = dateRange;

    final response = await _apiClient.get(
      '/tickets/transactions',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => TicketTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map && data['records'] != null) {
        return (data['records'] as List)
            .map((e) => TicketTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取水票使用记录失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> purchaseTicket({
    required String ticketId,
    required int quantity,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      '/tickets/purchase',
      body: {
        'ticketId': ticketId,
        'quantity': quantity,
        'paymentMethod': paymentMethod,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '购买水票失败',
        statusCode: response.code,
      );
    }
  }
}

class TicketStatsModel {
  final int? totalTickets;
  final int? availableTickets;
  final int? usedTickets;

  TicketStatsModel({
    this.totalTickets,
    this.availableTickets,
    this.usedTickets,
  });

  factory TicketStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TicketStatsModel();
    return TicketStatsModel(
      totalTickets: json['totalTickets'] ?? json['total_tickets'],
      availableTickets: json['availableTickets'] ?? json['available_tickets'],
      usedTickets: json['usedTickets'] ?? json['used_tickets'],
    );
  }
}

class TicketHoldingModel {
  final String? id;
  final String? ticketId;
  final String? ticketName;
  final String? ticketType;
  final int? totalQuantity;
  final int? usedQuantity;
  final int? remainingQuantity;
  final double? faceValue;
  final DateTime? purchaseDate;
  final DateTime? expireDate;
  final String? status;

  TicketHoldingModel({
    this.id,
    this.ticketId,
    this.ticketName,
    this.ticketType,
    this.totalQuantity,
    this.usedQuantity,
    this.remainingQuantity,
    this.faceValue,
    this.purchaseDate,
    this.expireDate,
    this.status,
  });

  factory TicketHoldingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TicketHoldingModel();
    return TicketHoldingModel(
      id: json['id']?.toString(),
      ticketId: json['ticketId']?.toString() ?? json['ticket_id']?.toString(),
      ticketName: json['ticketName'] ?? json['ticket_name'],
      ticketType: json['ticketType'] ?? json['ticket_type'],
      totalQuantity: json['totalQuantity'] ?? json['total_quantity'],
      usedQuantity: json['usedQuantity'] ?? json['used_quantity'],
      remainingQuantity: json['remainingQuantity'] ?? json['remaining_quantity'],
      faceValue: _parseDouble(json['faceValue'] ?? json['face_value']),
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'].toString())
          : json['buyDate'] != null
              ? DateTime.tryParse(json['buyDate'].toString())
              : null,
      expireDate: json['expireDate'] != null
          ? DateTime.tryParse(json['expireDate'].toString())
          : null,
      status: json['status'],
    );
  }

  String get statusText {
    if (status != null) return status!;
    if (remainingQuantity == null || remainingQuantity == 0) return '已用完';
    if (expireDate != null && expireDate!.isBefore(DateTime.now())) return '已过期';
    return '使用中';
  }

  bool get isExpired => expireDate != null && expireDate!.isBefore(DateTime.now());
  bool get isEmpty => remainingQuantity == null || remainingQuantity == 0;
}

class TicketTransactionModel {
  final String? id;
  final String? ticketId;
  final String? ticketName;
  final String? type;
  final String? typeText;
  final int? quantity;
  final double? amount;
  final DateTime? date;
  final String? orderId;
  final String? orderNo;
  final String? description;

  TicketTransactionModel({
    this.id,
    this.ticketId,
    this.ticketName,
    this.type,
    this.typeText,
    this.quantity,
    this.amount,
    this.date,
    this.orderId,
    this.orderNo,
    this.description,
  });

  factory TicketTransactionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TicketTransactionModel();
    return TicketTransactionModel(
      id: json['id']?.toString(),
      ticketId: json['ticketId']?.toString() ?? json['ticket_id']?.toString(),
      ticketName: json['ticketName'] ?? json['ticket_name'],
      type: json['type'],
      typeText: json['typeText'] ?? json['type_text'],
      quantity: json['quantity'],
      amount: _parseDouble(json['amount']),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      description: json['description'],
    );
  }

  String get typeTextComputed {
    if (typeText != null) return typeText!;
    switch (type) {
      case 'purchase':
        return '购买';
      case 'use':
        return '使用';
      case 'expire':
        return '过期';
      case 'refund':
        return '退款';
      default:
        return type ?? '其他';
    }
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
