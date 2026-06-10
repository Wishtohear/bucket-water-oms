import '../core/network/api_client.dart';

class StationBucketService {
  static final StationBucketService _instance =
      StationBucketService._internal();
  factory StationBucketService() => _instance;
  StationBucketService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<StationBucketInfo?> getBucketInfo(String stationId) async {
    try {
      final headers = <String, String>{
        'X-Station-Id': stationId,
      };

      final response = await _apiClient.get(
        '/stations/bucket-info',
        headers: headers,
      );

      if (response.success && response.data != null) {
        return StationBucketInfo.fromJson(response.data);
      }
      return _getMockBucketInfo();
    } catch (e) {
      return _getMockBucketInfo();
    }
  }

  Future<List<BucketTransaction>> getBucketTransactions(
    String stationId, {
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final headers = <String, String>{
        'X-Station-Id': stationId,
      };

      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _apiClient.get(
        '/stations/bucket-transactions',
        queryParams: queryParams,
        headers: headers,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => BucketTransaction.fromJson(e)).toList();
        } else if (data is Map && data['list'] != null) {
          return (data['list'] as List)
              .map((e) => BucketTransaction.fromJson(e))
              .toList();
        }
      }
      return _getMockTransactions();
    } catch (e) {
      return _getMockTransactions();
    }
  }

  Future<BucketDepositPolicy?> getDepositPolicy(String stationId) async {
    try {
      final headers = <String, String>{
        'X-Station-Id': stationId,
      };

      final response = await _apiClient.get(
        '/stations/deposit-policy',
        headers: headers,
      );

      if (response.success && response.data != null) {
        return BucketDepositPolicy.fromJson(response.data);
      }
      return _getMockDepositPolicy();
    } catch (e) {
      return _getMockDepositPolicy();
    }
  }

  Future<bool> payDeposit(
    String stationId, {
    required int bucketCount,
    required double amount,
    String paymentMethod = 'wechat',
  }) async {
    try {
      final headers = <String, String>{
        'X-Station-Id': stationId,
      };

      final response = await _apiClient.post(
        '/stations/bucket-deposit/pay',
        headers: headers,
        body: {
          'bucketNum': bucketCount,
          'amount': amount,
          'paymentMethod': paymentMethod,
        },
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<MonthlyBucketStats?> getMonthlyStats(
    String stationId, {
    String? yearMonth,
  }) async {
    try {
      final headers = <String, String>{
        'X-Station-Id': stationId,
      };

      final queryParams = <String, String>{};
      if (yearMonth != null) queryParams['yearMonth'] = yearMonth;

      final response = await _apiClient.get(
        '/stations/bucket-monthly-stats',
        queryParams: queryParams,
        headers: headers,
      );

      if (response.success && response.data != null) {
        return MonthlyBucketStats.fromJson(response.data);
      }
      return _getMockMonthlyStats();
    } catch (e) {
      return _getMockMonthlyStats();
    }
  }

  StationBucketInfo _getMockBucketInfo() {
    return StationBucketInfo(
      depositBucketNum: 100,
      oweBuckets: 8,
      depositPerBucket: 40.0,
      owedThreshold: 10,
      totalDeposit: 4000.0,
      owedDeposit: 320.0,
    );
  }

  List<BucketTransaction> _getMockTransactions() {
    final now = DateTime.now();
    return [
      BucketTransaction(
        id: '1',
        stationId: '1',
        type: 'return',
        title: '回桶',
        subtitle: '订单#202604180082配送完成',
        amount: '+50',
        time: now.subtract(const Duration(hours: 2)),
        driver: '王力',
      ),
      BucketTransaction(
        id: '2',
        stationId: '1',
        type: 'owe',
        title: '欠桶',
        subtitle: '订单#202604180082客户无桶可退',
        amount: '+8',
        time: now.subtract(const Duration(hours: 2)),
        driver: '王力',
      ),
      BucketTransaction(
        id: '3',
        stationId: '1',
        type: 'deposit_refund',
        title: '补缴押金',
        subtitle: '因欠桶达到阈值，主动补缴',
        amount: '¥800.00',
        time: now.subtract(const Duration(days: 10)),
        driver: '微信支付',
      ),
      BucketTransaction(
        id: '4',
        stationId: '1',
        type: 'return',
        title: '回桶',
        subtitle: '订单#202604150075配送完成',
        amount: '+70',
        time: now.subtract(const Duration(days: 9)),
        driver: '李明',
      ),
      BucketTransaction(
        id: '5',
        stationId: '1',
        type: 'deposit',
        title: '开户押金',
        subtitle: '水站开户，初始押金',
        amount: '¥4,000.00',
        time: now.subtract(const Duration(days: 54)),
        driver: '初始开户',
      ),
    ];
  }

  BucketDepositPolicy _getMockDepositPolicy() {
    return BucketDepositPolicy(
      depositPerBucket: 40.0,
      owedThreshold: 10,
      overThresholdAction: '限制下单',
    );
  }

  MonthlyBucketStats _getMockMonthlyStats() {
    return MonthlyBucketStats(
      yearMonth: '2026-04',
      returned: 120,
      owed: 20,
      netReturned: 100,
      totalReturned: 500,
      totalOwed: 400,
    );
  }
}

class StationBucketInfo {
  final int? depositBucketNum;
  final int? oweBuckets;
  final double? depositPerBucket;
  final int? owedThreshold;
  final double? totalDeposit;
  final double? owedDeposit;

  StationBucketInfo({
    this.depositBucketNum,
    this.oweBuckets,
    this.depositPerBucket,
    this.owedThreshold,
    this.totalDeposit,
    this.owedDeposit,
  });

  factory StationBucketInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationBucketInfo();
    return StationBucketInfo(
      depositBucketNum: json['depositBucketNum'] ?? json['deposit_bucket_num'],
      oweBuckets: json['oweBuckets'] ?? json['owe_buckets'],
      depositPerBucket:
          _parseDouble(json['depositPerBucket'] ?? json['deposit_per_bucket']),
      owedThreshold: json['owedThreshold'] ?? json['owed_threshold'],
      totalDeposit: _parseDouble(json['totalDeposit'] ?? json['total_deposit']),
      owedDeposit: _parseDouble(json['owedDeposit'] ?? json['owed_deposit']),
    );
  }

  double get availableBuckets =>
      ((depositBucketNum ?? 0) - (oweBuckets ?? 0)).toDouble();
}

class BucketTransaction {
  final String? id;
  final String? stationId;
  final String? type;
  final String? title;
  final String? subtitle;
  final String? amount;
  final DateTime? time;
  final String? driver;
  final String? orderId;
  final String? orderNo;

  BucketTransaction({
    this.id,
    this.stationId,
    this.type,
    this.title,
    this.subtitle,
    this.amount,
    this.time,
    this.driver,
    this.orderId,
    this.orderNo,
  });

  factory BucketTransaction.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BucketTransaction();
    return BucketTransaction(
      id: json['id']?.toString(),
      stationId:
          json['stationId']?.toString() ?? json['station_id']?.toString(),
      type: json['type'],
      title: json['title'],
      subtitle: json['subtitle'],
      amount: json['amount']?.toString(),
      time: json['time'] != null
          ? DateTime.tryParse(json['time'].toString())
          : null,
      driver: json['driver'] ?? json['driverName'],
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
    );
  }

  String get formattedTime {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${time!.month.toString().padLeft(2, '0')}-${time!.day.toString().padLeft(2, '0')} ${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
  }
}

class BucketDepositPolicy {
  final double? depositPerBucket;
  final int? owedThreshold;
  final String? overThresholdAction;

  BucketDepositPolicy({
    this.depositPerBucket,
    this.owedThreshold,
    this.overThresholdAction,
  });

  factory BucketDepositPolicy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BucketDepositPolicy();
    return BucketDepositPolicy(
      depositPerBucket:
          _parseDouble(json['depositPerBucket'] ?? json['deposit_per_bucket']),
      owedThreshold: json['owedThreshold'] ?? json['owed_threshold'],
      overThresholdAction:
          json['overThresholdAction'] ?? json['over_threshold_action'],
    );
  }
}

class MonthlyBucketStats {
  final String? yearMonth;
  final int? returned;
  final int? owed;
  final int? netReturned;
  final int? totalReturned;
  final int? totalOwed;

  MonthlyBucketStats({
    this.yearMonth,
    this.returned,
    this.owed,
    this.netReturned,
    this.totalReturned,
    this.totalOwed,
  });

  factory MonthlyBucketStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MonthlyBucketStats();
    return MonthlyBucketStats(
      yearMonth: json['yearMonth'] ?? json['year_month'],
      returned: json['returned'],
      owed: json['owed'],
      netReturned: json['netReturned'] ?? json['net_returned'],
      totalReturned: json['totalReturned'] ?? json['total_returned'],
      totalOwed: json['totalOwed'] ?? json['total_owed'],
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
