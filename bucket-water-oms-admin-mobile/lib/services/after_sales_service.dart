import '../core/network/api_client.dart';
import '../models/after_sales_model.dart';

class AfterSalesService {
  static final AfterSalesService _instance = AfterSalesService._internal();
  factory AfterSalesService() => _instance;
  AfterSalesService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<AfterSalesModel>> getStationAfterSalesList({
    String? status,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final response = await _apiClient.get(
      '/after-sales',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => AfterSalesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => AfterSalesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['records'] != null) {
        return (data['records'] as List)
            .map((e) => AfterSalesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取售后列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<AfterSalesModel?> getStationAfterSalesDetail(
      String afterSalesId) async {
    final response = await _apiClient.get('/after-sales/$afterSalesId');

    if (response.success) {
      return AfterSalesModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取售后详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<AfterSalesModel?> createStationAfterSales(
      CreateAfterSalesRequestV2 request) async {
    final response = await _apiClient.post(
      '/after-sales',
      body: request.toJson(),
    );

    if (response.success) {
      return AfterSalesModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '创建售后申请失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> cancelStationAfterSales(String afterSalesId) async {
    final response = await _apiClient.post('/after-sales/$afterSalesId/cancel');

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '取消售后申请失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<AfterSalesModel>> getWarehouseAfterSalesList(
    String warehouseId, {
    String? status,
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final response = await _apiClient.get(
      '/after-sales',
      queryParams: queryParams,
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => AfterSalesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['list'] != null) {
        return (data['list'] as List)
            .map((e) => AfterSalesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取售后列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<AfterSalesModel?> getWarehouseAfterSalesDetail(
    String afterSalesId,
    String warehouseId,
  ) async {
    final response = await _apiClient.get(
      '/after-sales/$afterSalesId',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      return AfterSalesModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取售后详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> processWarehouseAfterSales(
    String afterSalesId, {
    required String result,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/after-sales/$afterSalesId/process',
      body: {
        'result': result,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '处理售后失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> completeWarehouseAfterSales(
    String afterSalesId, {
    required String result,
    String? remark,
  }) async {
    final response = await _apiClient.post(
      '/after-sales/$afterSalesId/complete',
      body: {
        'result': result,
        if (remark != null) 'remark': remark,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '完成售后失败',
        statusCode: response.code,
      );
    }
  }
}

class CreateAfterSalesRequestV2 {
  final String orderId;
  final String type;
  final String productId;
  final int quantity;
  final String reason;
  final List<String>? images;

  CreateAfterSalesRequestV2({
    required this.orderId,
    required this.type,
    required this.productId,
    required this.quantity,
    required this.reason,
    this.images,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'type': type,
        'productId': productId,
        'quantity': quantity,
        'reason': reason,
        if (images != null) 'images': images,
      };
}
