import '../core/network/api_client.dart';

class BucketService {
  static final BucketService _instance = BucketService._internal();
  factory BucketService() => _instance;
  BucketService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<BucketSummaryModel> getBucketSummary() async {
    final response = await _apiClient.get('/stations/bucket-summary');

    if (response.success && response.data != null) {
      return BucketSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取空桶汇总失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<BucketTransactionModel>> getBucketTransactions({
    String? startDate,
    String? endDate,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/stations/bucket-transactions',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) =>
                BucketTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['records'] != null) {
        return (data['records'] as List)
            .map((e) =>
                BucketTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) =>
                BucketTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取空桶往来记录失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> payBucketDeposit(int bucketNum) async {
    final response = await _apiClient.post(
      '/stations/bucket-deposit/pay?bucketNum=$bucketNum',
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '补缴押金失败',
        statusCode: response.code,
      );
    }
  }
}

class BucketSummaryModel {
  final int? depositBucketNum;
  final int? owedBucketNum;
  final double? owedDepositAmount;
  final double? bucketDepositPerUnit;
  final int? owedThreshold;
  final bool? overThreshold;
  final int? monthReturn;
  final int? monthOwe;
  final int? monthNet;
  final int? totalReturn;
  final int? totalOwe;

  BucketSummaryModel({
    this.depositBucketNum,
    this.owedBucketNum,
    this.owedDepositAmount,
    this.bucketDepositPerUnit,
    this.owedThreshold,
    this.overThreshold,
    this.monthReturn,
    this.monthOwe,
    this.monthNet,
    this.totalReturn,
    this.totalOwe,
  });

  factory BucketSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BucketSummaryModel();
    return BucketSummaryModel(
      depositBucketNum: json['depositBucketNum'] ?? json['deposit_bucket_num'],
      owedBucketNum: json['owedBucketNum'] ?? json['owed_bucket_num'],
      owedDepositAmount: _parseDouble(
          json['owedDepositAmount'] ?? json['owed_deposit_amount']),
      bucketDepositPerUnit: _parseDouble(
          json['bucketDepositPerUnit'] ?? json['bucket_deposit_per_unit']),
      owedThreshold: json['owedThreshold'] ?? json['owed_threshold'],
      overThreshold: json['overThreshold'] ?? json['over_threshold'],
      monthReturn: json['monthReturn'] ?? json['month_return'],
      monthOwe: json['monthOwe'] ?? json['month_owe'],
      monthNet: json['monthNet'] ?? json['month_net'],
      totalReturn: json['totalReturn'] ?? json['total_return'],
      totalOwe: json['totalOwe'] ?? json['total_owe'],
    );
  }

  double get depositAmount =>
      (bucketDepositPerUnit ?? 0) * (owedBucketNum ?? 0);
}

class BucketTransactionModel {
  final String? id;
  final String? type;
  final String? typeText;
  final String? description;
  final double? amount;
  final DateTime? date;
  final String? driver;
  final String? orderId;
  final String? orderNo;

  BucketTransactionModel({
    this.id,
    this.type,
    this.typeText,
    this.description,
    this.amount,
    this.date,
    this.driver,
    this.orderId,
    this.orderNo,
  });

  factory BucketTransactionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BucketTransactionModel();
    return BucketTransactionModel(
      id: json['id']?.toString(),
      type: json['type'],
      typeText: json['typeText'] ?? json['type_text'],
      description: json['description'],
      amount: _parseDouble(json['amount']),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      driver: json['driver'],
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
    );
  }

  String get typeTextComputed {
    if (typeText != null) return typeText!;
    switch (type) {
      case 'return':
        return '回桶';
      case 'delivery':
        return '送桶';
      case 'deposit':
        return '押金';
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
