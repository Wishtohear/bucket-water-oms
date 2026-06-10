import '../core/network/api_client.dart';
import '../models/admin_models.dart';

class AdminStationService {
  static final AdminStationService _instance = AdminStationService._internal();
  factory AdminStationService() => _instance;
  AdminStationService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<StationListResponse> getStations({
    String? keyword,
    String? status,
    String? balanceStatus,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }
    if (status != null && status.isNotEmpty && status != '全部状态') {
      queryParams['status'] = _parseStatus(status);
    }
    if (balanceStatus != null &&
        balanceStatus.isNotEmpty &&
        balanceStatus != '全部') {
      queryParams['balanceStatus'] = _parseBalanceStatus(balanceStatus);
    }

    final response = await _apiClient.get(
      '/admin/stations',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<StationModel> stations = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          stations = data
              .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
              .toList();
          total = stations.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            stations = (data['list'] as List)
                .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? stations.length;
        }
      }

      return StationListResponse(
        stations: stations,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '获取水站列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<StationModel> getStationDetail(String stationId) async {
    try {
      final response = await _apiClient.get('/admin/stations/$stationId');

      if (response.success && response.data != null) {
        return StationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        final accountResponse =
            await _apiClient.get('/admin/stations/$stationId/account');
        if (accountResponse.success && accountResponse.data != null) {
          return StationModel.fromJson(
              accountResponse.data as Map<String, dynamic>);
        }
        throw ApiException(
          response.message ?? '获取水站详情失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      return StationModel();
    }
  }

  Future<StationAccountModel> getStationAccount(String stationId) async {
    try {
      final response =
          await _apiClient.get('/admin/stations/$stationId/account');

      if (response.success && response.data != null) {
        return StationAccountModel.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        return StationAccountModel();
      }
    } catch (e) {
      return StationAccountModel();
    }
  }

  Future<StationModel> createStation(StationModel station,
      {String? password}) async {
    final body = station.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    } else {
      body['password'] = '123456';
    }

    final response = await _apiClient.post(
      '/admin/stations',
      body: body,
    );

    if (response.success && response.data != null) {
      return StationModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建水站失败',
        statusCode: response.code,
      );
    }
  }

  Future<StationModel> updateStation(String stationId, StationModel station,
      {String? password}) async {
    final body = station.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await _apiClient.put(
      '/admin/stations/$stationId',
      body: body,
    );

    if (response.success && response.data != null) {
      return StationModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新水站失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateStationStatus(String stationId, String status) async {
    final response = await _apiClient.put(
      '/admin/stations/$stationId/status',
      body: {'status': status},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '更新水站状态失败',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<bool> updateSalesPolicy(
      String stationId, Map<String, dynamic> policy) async {
    final response = await _apiClient.put(
      '/admin/stations/policy',
      body: {
        'stationId': stationId,
        ...policy,
      },
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '更新销售政策失败',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<StationModel> updateStationLocation(
    String stationId, {
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (address != null) 'address': address,
    };

    final response = await _apiClient.put(
      '/admin/stations/$stationId/location',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      return StationModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新水站位置失败',
        statusCode: response.code,
      );
    }
  }

  String _parseStatus(String status) {
    switch (status) {
      case '正常运营':
        return 'active';
      case '欠费停供':
        return 'suspended';
      case '已注销':
        return 'closed';
      default:
        return status;
    }
  }

  String _parseBalanceStatus(String balanceStatus) {
    switch (balanceStatus) {
      case '余额充足':
        return 'sufficient';
      case '余额不足':
        return 'low';
      case '账户欠费':
        return 'overdue';
      default:
        return balanceStatus;
    }
  }
}

class StationListResponse {
  final List<StationModel> stations;
  final int total;
  final int page;
  final int pageSize;

  StationListResponse({
    required this.stations,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

class StationAccountModel {
  final double? balance;
  final double? creditLimit;
  final double? usedCredit;
  final int? totalBarrels;
  final int? emptyBarrels;
  final int? debtBarrels;
  final double? debtAmount;

  StationAccountModel({
    this.balance,
    this.creditLimit,
    this.usedCredit,
    this.totalBarrels,
    this.emptyBarrels,
    this.debtBarrels,
    this.debtAmount,
  });

  factory StationAccountModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationAccountModel();
    return StationAccountModel(
      balance:
          _parseDouble(json['balance']) ?? _parseDouble(json['depositBalance']),
      creditLimit: _parseDouble(json['creditLimit']) ??
          _parseDouble(json['credit_limit']),
      usedCredit:
          _parseDouble(json['usedCredit']) ?? _parseDouble(json['used_credit']),
      totalBarrels: json['totalBarrels'] ??
          json['total_barrels'] ??
          json['depositBucketNum'],
      emptyBarrels: json['emptyBarrels'] ?? json['empty_barrels'],
      debtBarrels:
          json['debtBarrels'] ?? json['debt_barrels'] ?? json['owedBucketNum'],
      debtAmount:
          _parseDouble(json['debtAmount']) ?? _parseDouble(json['debt_amount']),
    );
  }

  double? get availableCredit => (creditLimit ?? 0) - (usedCredit ?? 0);
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
