import '../core/network/api_client.dart';
import '../models/order_model.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  factory DriverService() => _instance;
  DriverService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> getDriverTasks(String driverId) async {
    final response = await _apiClient.get(
      '/drivers/tasks',
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取司机任务失败',
        statusCode: response.code,
      );
    }
  }

  Future<OrderModel> startDelivery(String orderId) async {
    final response = await _apiClient.post('/drivers/$orderId/start-delivery');

    if (response.success) {
      return OrderModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '开始配送失败',
        statusCode: response.code,
      );
    }
  }

  Future<OrderModel> deliverOrder(
    String orderId, {
    String? signature,
    List<String>? photos,
    String? code,
  }) async {
    final response = await _apiClient.post(
      '/drivers/$orderId/deliver',
      body: {
        if (signature != null) 'signature': signature,
        if (photos != null) 'photos': photos,
        if (code != null) 'code': code,
      },
    );

    if (response.success) {
      return OrderModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '配送签收失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> warehouseReturn(
    String driverId, {
    required int emptyBarrels,
    required String warehouseId,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/drivers/warehouse-return',
      body: {
        'emptyBarrels': emptyBarrels,
        'warehouseId': warehouseId,
        if (remark != null) 'remark': remark,
      },
      headers: {'X-Driver-Id': driverId},
    );

    return response.success;
  }

  Future<Map<String, dynamic>> getDriverStatement(
    String driverId, {
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiClient.get(
      '/drivers/statements',
      queryParams: {
        'startDate': startDate,
        'endDate': endDate,
      },
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success) {
      return response.data ?? {};
    } else {
      throw ApiException(
        response.message ?? '获取司机对账单失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> confirmStatement(String statementId) async {
    final response =
        await _apiClient.post('/drivers/statements/$statementId/confirm');
    return response.success;
  }

  Future<Map<String, dynamic>> generateStatement(
    String driverId, {
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiClient.post(
      '/drivers/statements/generate',
      body: {
        'startDate': startDate,
        'endDate': endDate,
      },
      headers: {'X-Driver-Id': driverId},
    );

    if (response.success) {
      return response.data ?? {};
    } else {
      throw ApiException(
        response.message ?? '生成对账单失败',
        statusCode: response.code,
      );
    }
  }
}
