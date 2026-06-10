import '../core/network/api_client.dart';
import '../models/admin_models.dart';

class AdminDriverService {
  static final AdminDriverService _instance = AdminDriverService._internal();
  factory AdminDriverService() => _instance;
  AdminDriverService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<DriverListResponse> getDrivers({
    String? keyword,
    String? onlineStatus,
    String? region,
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
    if (onlineStatus != null &&
        onlineStatus.isNotEmpty &&
        onlineStatus != '全部状态') {
      queryParams['onlineStatus'] = _parseOnlineStatus(onlineStatus);
    }
    if (region != null && region.isNotEmpty && region != '全部区域') {
      queryParams['region'] = region;
    }

    final response = await _apiClient.get(
      '/admin/drivers',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<DriverModel> drivers = [];
      int total = 0;
      DriverStats? stats;

      if (data != null) {
        if (data is List) {
          drivers = data
              .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
              .toList();
          total = drivers.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            drivers = (data['list'] as List)
                .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? drivers.length;
          if (data['stats'] != null) {
            stats = DriverStats.fromJson(data['stats'] as Map<String, dynamic>);
          }
        }
      }

      return DriverListResponse(
        drivers: drivers,
        total: total,
        page: page,
        pageSize: pageSize,
        stats: stats,
      );
    } else {
      throw ApiException(
        response.message ?? '获取司机列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<DriverModel> getDriverDetail(String driverId) async {
    final response = await _apiClient.get('/admin/drivers/$driverId');

    if (response.success && response.data != null) {
      return DriverModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取司机详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<DriverModel> createDriver(DriverModel driver,
      {String? password}) async {
    final body = driver.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    } else {
      body['password'] = '123456';
    }

    final response = await _apiClient.post(
      '/admin/drivers',
      body: body,
    );

    if (response.success && response.data != null) {
      return DriverModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建司机失败',
        statusCode: response.code,
      );
    }
  }

  Future<DriverModel> updateDriver(String driverId, DriverModel driver,
      {String? password}) async {
    final body = driver.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await _apiClient.put(
      '/admin/drivers/$driverId',
      body: body,
    );

    if (response.success && response.data != null) {
      return DriverModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '更新司机失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateDriverStatus(String driverId, String status) async {
    final response = await _apiClient.put(
      '/admin/drivers/$driverId/status',
      body: {'status': status},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '更新司机状态失败',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<bool> resetPassword(String driverId, {String? newPassword}) async {
    final response = await _apiClient.post(
      '/admin/drivers/$driverId/reset-password',
      body: newPassword != null ? {'password': newPassword} : null,
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '重置密码失败',
        statusCode: response.code,
      );
    }
    return true;
  }

  String _parseOnlineStatus(String status) {
    switch (status) {
      case '在线':
        return 'online';
      case '离线':
        return 'offline';
      case '休息中':
        return 'resting';
      case '配送中':
        return 'delivering';
      default:
        return status;
    }
  }
}

class DriverListResponse {
  final List<DriverModel> drivers;
  final int total;
  final int page;
  final int pageSize;
  final DriverStats? stats;

  DriverListResponse({
    required this.drivers,
    required this.total,
    required this.page,
    required this.pageSize,
    this.stats,
  });

  bool get hasMore => (page * pageSize) < total;
}

class DriverStats {
  final int totalDrivers;
  final int onlineDrivers;
  final int deliveringDrivers;
  final int monthDeliveries;

  DriverStats({
    required this.totalDrivers,
    required this.onlineDrivers,
    required this.deliveringDrivers,
    required this.monthDeliveries,
  });

  factory DriverStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverStats(
        totalDrivers: 0,
        onlineDrivers: 0,
        deliveringDrivers: 0,
        monthDeliveries: 0,
      );
    }
    return DriverStats(
      totalDrivers: json['totalDrivers'] ?? json['total_drivers'] ?? 0,
      onlineDrivers: json['onlineDrivers'] ?? json['online_drivers'] ?? 0,
      deliveringDrivers:
          json['deliveringDrivers'] ?? json['delivering_drivers'] ?? 0,
      monthDeliveries: json['monthDeliveries'] ?? json['month_deliveries'] ?? 0,
    );
  }
}
