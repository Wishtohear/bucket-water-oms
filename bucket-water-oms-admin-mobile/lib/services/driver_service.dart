import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/driver_task_model.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  factory DriverService() => _instance;
  DriverService._internal();

  final ApiClient _apiClient = ApiClient();

  String _getDriverId() {
    final driverId = ApiConfig.getDriverId();
    if (driverId.isNotEmpty) {
      return driverId;
    }
    return ApiConfig.getUserId();
  }

  Future<DriverInfoData> getDriverInfo(String? driverId) async {
    final actualDriverId = driverId ?? _getDriverId();
    try {
      final response = await _apiClient.get(
        '/drivers/info',
        headers: {'X-Driver-Id': actualDriverId},
      );

      // 调试日志：打印原始响应数据
      print('═══════════════════════════════════════════════════════════');
      print('Driver Info API Response:');
      print('  success: ${response.success}');
      print('  message: ${response.message}');
      print('  data type: ${response.data.runtimeType}');
      print('  data: ${response.data}');
      if (response.data is Map) {
        final data = response.data as Map;
        print('  vehicle: ${data['vehicle']}');
        print('  warehouseName: ${data['warehouseName']}');
        print('  warehouse: ${data['warehouse']}');
        print('  vehicleInfo: ${data['vehicleInfo']}');
        print('  licensePlate: ${data['licensePlate']}');
      }
      print('═══════════════════════════════════════════════════════════');

      if (response.success && response.data != null) {
        return DriverInfoData.fromJson(response.data);
      } else {
        throw ApiException(
          response.message ?? '获取司机信息失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取司机信息失败: $e');
    }
  }

  Future<DriverDashboardData> getDriverDashboard(String? driverId) async {
    final actualDriverId = driverId ?? _getDriverId();
    try {
      final response = await _apiClient.get(
        '/drivers/dashboard',
        headers: {'X-Driver-Id': actualDriverId},
      );

      if (response.success && response.data != null) {
        return DriverDashboardData.fromJson(response.data);
      } else {
        throw ApiException(
          response.message ?? '获取仪表盘数据失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取仪表盘数据失败: $e');
    }
  }

  Future<List<DriverTaskModel>> getDriverTasks(
    String? driverId, {
    String? status,
    String? sortBy,
  }) async {
    final actualDriverId = driverId ?? _getDriverId();
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    try {
      final response = await _apiClient.get(
        '/drivers/tasks',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        headers: {'X-Driver-Id': actualDriverId},
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => DriverTaskModel.fromJson(e)).toList();
        }
        throw ApiException('获取任务列表失败: 数据格式错误');
      } else {
        throw ApiException(
          response.message ?? '获取任务列表失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取任务列表失败: $e');
    }
  }

  Future<RoutePlanningData> getRoutePlanning(
      String? driverId, List<String> orderIds) async {
    final actualDriverId = driverId ?? _getDriverId();
    try {
      final response = await _apiClient.get(
        '/drivers/route-planning',
        queryParams: {'orderIds': orderIds.join(',')},
        headers: {'X-Driver-Id': actualDriverId},
      );

      if (response.success && response.data != null) {
        return RoutePlanningData.fromJson(response.data);
      } else {
        throw ApiException(
          response.message ?? '获取路线规划失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取路线规划失败: $e');
    }
  }

  Future<DriverTaskModel> startDelivery(String taskId) async {
    final response = await _apiClient.post('/drivers/$taskId/start-delivery');

    if (response.success && response.data != null) {
      return DriverTaskModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '开始配送失败',
        statusCode: response.code,
      );
    }
  }

  Future<DriverTaskModel> deliverOrder(
    String taskId, {
    DriverDeliveryConfirm? confirm,
  }) async {
    final response = await _apiClient.post(
      '/drivers/$taskId/deliver',
      body: confirm?.toJson(),
    );

    if (response.success && response.data != null) {
      return DriverTaskModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '配送签收失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> warehouseReturn(
    String? driverId, {
    required int bucketReturn,
    required String warehouseId,
    String? remark,
    bool? isNewStationDelivery,
    List<Map<String, dynamic>>? stationDeliveries,
  }) async {
    final actualDriverId = driverId ?? _getDriverId();
    final body = <String, dynamic>{
      'bucketReturn': bucketReturn,
      'warehouseId': warehouseId,
    };
    if (remark != null) body['remark'] = remark;
    if (isNewStationDelivery != null) body['isNewStationDelivery'] = isNewStationDelivery;
    if (stationDeliveries != null && stationDeliveries.isNotEmpty) {
      body['stationDeliveries'] = stationDeliveries;
    }

    final response = await _apiClient.post(
      '/drivers/warehouse-return',
      body: body,
      headers: {'X-Driver-Id': actualDriverId},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '回仓申请失败',
        statusCode: response.code,
      );
    }
    return response.success;
  }

  Future<bool> updateLocation(
    String? driverId, {
    required double longitude,
    required double latitude,
    String? address,
  }) async {
    final actualDriverId = driverId ?? _getDriverId();
    final response = await _apiClient.post(
      '/drivers/location',
      body: {
        'longitude': longitude,
        'latitude': latitude,
        if (address != null) 'address': address,
      },
      headers: {'X-Driver-Id': actualDriverId},
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '更新位置失败',
        statusCode: response.code,
      );
    }
    return response.success;
  }

  Future<bool> driverCheckIn(DriverCheckIn checkIn) async {
    final response = await _apiClient.post(
      '/drivers/check-in',
      body: checkIn.toJson(),
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '打卡失败',
        statusCode: response.code,
      );
    }
    return response.success;
  }

  Future<Map<String, dynamic>> getDriverStatus(String? driverId) async {
    final actualDriverId = driverId ?? _getDriverId();
    try {
      final response = await _apiClient.get(
        '/drivers/status',
        headers: {'X-Driver-Id': actualDriverId},
      );

      if (response.success && response.data != null) {
        return response.data ?? {};
      } else {
        throw ApiException(
          response.message ?? '获取司机状态失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取司机状态失败: $e');
    }
  }

  Future<DriverStatementData?> getDriverStatements(
    String? driverId, {
    String? status,
  }) async {
    final actualDriverId = driverId ?? _getDriverId();
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      queryParams['latest'] = 'true';

      final response = await _apiClient.get(
        '/drivers/statements',
        queryParams: queryParams,
        headers: {'X-Driver-Id': actualDriverId},
      );

      if (response.success && response.data != null) {
        if (response.data is List && (response.data as List).isNotEmpty) {
          return DriverStatementData.fromJson(response.data[0]);
        } else if (response.data is Map) {
          return DriverStatementData.fromJson(response.data);
        }
        throw ApiException('获取对账单失败: 数据格式错误');
      } else {
        throw ApiException(
          response.message ?? '获取对账单失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取对账单失败: $e');
    }
  }

  Future<bool> confirmStatement(String statementId) async {
    final response =
        await _apiClient.post('/drivers/statements/$statementId/confirm');

    if (!response.success) {
      throw ApiException(
        response.message ?? '确认对账单失败',
        statusCode: response.code,
      );
    }
    return response.success;
  }

  Future<List<BarrelRecordData>> getBarrelRecords(String? driverId,
      {String? type}) async {
    final actualDriverId = driverId ?? _getDriverId();
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.get(
        '/drivers/barrel-records',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        headers: {'X-Driver-Id': actualDriverId},
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => BarrelRecordData.fromJson(e)).toList();
        }
        throw ApiException('获取空桶记录失败: 数据格式错误');
      } else {
        throw ApiException(
          response.message ?? '获取空桶记录失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取空桶记录失败: $e');
    }
  }
}

class DriverDashboardData {
  final int todayDeliveries;
  final int pendingDeliveries;
  final int completedDeliveries;
  final int totalBucketsOnWay;
  final int owedBuckets;
  final int bucketThreshold;
  final double todayEarnings;
  final String? driverName;
  final String? warehouseName;
  final List<DriverTaskModel> recentTasks;
  final List<NotificationData> notifications;

  DriverDashboardData({
    required this.todayDeliveries,
    required this.pendingDeliveries,
    required this.completedDeliveries,
    required this.totalBucketsOnWay,
    required this.owedBuckets,
    required this.bucketThreshold,
    required this.todayEarnings,
    this.driverName,
    this.warehouseName,
    required this.recentTasks,
    required this.notifications,
  });

  factory DriverDashboardData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverDashboardData(
        todayDeliveries: 0,
        pendingDeliveries: 0,
        completedDeliveries: 0,
        totalBucketsOnWay: 0,
        owedBuckets: 0,
        bucketThreshold: 10,
        todayEarnings: 0,
        recentTasks: [],
        notifications: [],
      );
    }

    final recentTasksList = json['recentTasks'] as List? ?? [];
    final notificationsList = json['notifications'] as List? ?? [];

    return DriverDashboardData(
      todayDeliveries: json['todayDeliveries'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      completedDeliveries: json['completedDeliveries'] ?? 0,
      totalBucketsOnWay: json['totalBucketsOnWay'] ?? 0,
      owedBuckets: json['owedBuckets'] ?? 0,
      bucketThreshold: json['bucketThreshold'] ?? 10,
      todayEarnings: _parseDouble(json['todayEarnings']),
      driverName: json['driverName'],
      warehouseName: json['warehouseName'],
      recentTasks:
          recentTasksList.map((e) => DriverTaskModel.fromJson(e)).toList(),
      notifications:
          notificationsList.map((e) => NotificationData.fromJson(e)).toList(),
    );
  }
}

class NotificationData {
  final String id;
  final String title;
  final String content;
  final String? type;
  final String? createdAt;

  NotificationData({
    required this.id,
    required this.title,
    required this.content,
    this.type,
    this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NotificationData(id: '', title: '', content: '');
    }
    return NotificationData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'],
      createdAt: json['createdAt'],
    );
  }
}

class RoutePlanningData {
  final double totalDistance;
  final int estimatedMinutes;
  final int pointCount;
  final List<WaypointData> waypoints;

  RoutePlanningData({
    required this.totalDistance,
    required this.estimatedMinutes,
    required this.pointCount,
    required this.waypoints,
  });

  factory RoutePlanningData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RoutePlanningData(
        totalDistance: 0,
        estimatedMinutes: 0,
        pointCount: 0,
        waypoints: [],
      );
    }

    final waypointsList = json['waypoints'] as List? ?? [];

    return RoutePlanningData(
      totalDistance: _parseDouble(json['totalDistance']),
      estimatedMinutes: json['estimatedMinutes'] ?? json['duration'] ?? 0,
      pointCount: json['pointCount'] ?? waypointsList.length,
      waypoints: waypointsList.map((e) => WaypointData.fromJson(e)).toList(),
    );
  }
}

class WaypointData {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String? orderId;

  WaypointData({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    this.orderId,
  });

  factory WaypointData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WaypointData(id: '', name: '', lat: 0, lng: 0, type: '');
    }
    return WaypointData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      type: json['type'] ?? '',
      orderId: json['orderId']?.toString(),
    );
  }
}

class DriverStatementData {
  final String id;
  final String month;
  final double pendingAmount;
  final double baseSalary;
  final double deliveryCommission;
  final int completedOrders;
  final int totalBarrels;
  final int goodRating;
  final String status;
  final List<StatementDetailItem> details;

  DriverStatementData({
    required this.id,
    required this.month,
    required this.pendingAmount,
    required this.baseSalary,
    required this.deliveryCommission,
    required this.completedOrders,
    required this.totalBarrels,
    required this.goodRating,
    required this.status,
    required this.details,
  });

  factory DriverStatementData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverStatementData(
        id: '',
        month: '',
        pendingAmount: 0,
        baseSalary: 0,
        deliveryCommission: 0,
        completedOrders: 0,
        totalBarrels: 0,
        goodRating: 0,
        status: '',
        details: [],
      );
    }

    return DriverStatementData(
      id: json['id']?.toString() ?? '',
      month: json['month'] ?? '',
      pendingAmount: _parseDouble(json['pendingAmount']),
      baseSalary: _parseDouble(json['baseSalary']),
      deliveryCommission: _parseDouble(json['deliveryCommission']),
      completedOrders: json['completedOrders'] ?? 0,
      totalBarrels: json['totalBarrels'] ?? 0,
      goodRating: json['goodRating'] ?? 0,
      status: json['status'] ?? '',
      details: [],
    );
  }
}

class StatementDetailItem {
  final String title;
  final String subtitle;
  final double amount;
  final bool isPositive;
  final bool isBlue;

  StatementDetailItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    this.isBlue = false,
  });

  factory StatementDetailItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StatementDetailItem(
        title: '',
        subtitle: '',
        amount: 0,
        isPositive: true,
      );
    }
    return StatementDetailItem(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      amount: _parseDouble(json['amount']),
      isPositive: json['isPositive'] ?? true,
      isBlue: json['isBlue'] ?? false,
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class DriverInfoData {
  final String? id;
  final String? name;
  final String? phone;
  final String? code;
  final String? vehicle;
  final String? warehouse;
  final String? area;
  final String? status;
  final int todayDeliveries;
  final int totalDeliveries;
  final double monthIncome;
  final int owedBuckets;
  final int bucketOnWay;
  final int depositBuckets;
  final double depositPrice;
  final double totalOwedAmount;

  DriverInfoData({
    this.id,
    this.name,
    this.phone,
    this.code,
    this.vehicle,
    this.warehouse,
    this.area,
    this.status,
    this.todayDeliveries = 0,
    this.totalDeliveries = 0,
    this.monthIncome = 0,
    this.owedBuckets = 0,
    this.bucketOnWay = 0,
    this.depositBuckets = 0,
    this.depositPrice = 20.0,
    this.totalOwedAmount = 0,
  });

  factory DriverInfoData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverInfoData();
    }
    return DriverInfoData(
      id: json['id']?.toString(),
      name: json['name'],
      phone: json['phone'],
      code: json['code'] ?? json['driverCode'],
      vehicle: json['vehicle'] ?? json['vehicleInfo'] ?? json['licensePlate'],
      warehouse: json['warehouseName'] ?? json['warehouse'],
      area: json['area'] ?? json['deliveryArea'],
      status: json['status'],
      todayDeliveries: json['todayDeliveries'] ?? 0,
      totalDeliveries: json['totalDeliveries'] ?? 0,
      monthIncome: _parseDouble(json['monthIncome']),
      owedBuckets: json['owedBuckets'] ?? 0,
      bucketOnWay: json['bucketOnWay'] ?? 0,
      depositBuckets: json['depositBuckets'] ?? 0,
      depositPrice: _parseDouble(json['depositPrice']),
      totalOwedAmount: _parseDouble(json['totalOwedAmount']),
    );
  }
}

class BarrelRecordData {
  final String id;
  final String date;
  final String type;
  final String typeText;
  final int quantity;
  final String? orderNo;
  final String? stationName;
  final int balance;

  BarrelRecordData({
    required this.id,
    required this.date,
    required this.type,
    required this.typeText,
    required this.quantity,
    this.orderNo,
    this.stationName,
    required this.balance,
  });

  factory BarrelRecordData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BarrelRecordData(
        id: '',
        date: '',
        type: '',
        typeText: '',
        quantity: 0,
        balance: 0,
      );
    }
    return BarrelRecordData(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? json['createdAt'] ?? '',
      type: json['type'] ?? '',
      typeText: json['typeText'] ?? (json['type'] == 'return' ? '回桶' : '领桶'),
      quantity: json['quantity'] ?? 0,
      orderNo: json['orderNo'],
      stationName: json['stationName'],
      balance: json['balance'] ?? 0,
    );
  }

  bool get isReturn => type == 'return';
  bool get isPickup => type == 'pickup';
}
