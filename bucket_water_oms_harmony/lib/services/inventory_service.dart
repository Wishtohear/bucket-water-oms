import '../core/network/api_client.dart';
import '../models/product_model.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<InventoryModel>> getStationInventory(String stationId) async {
    final response = await _apiClient.get(
      '/stations/inventory',
      headers: {'X-Station-Id': stationId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => InventoryModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取库存失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<InventoryModel>> getWarehouseInventory(String warehouseId) async {
    final response = await _apiClient.get(
      '/warehouses/inventory',
      headers: {'X-Warehouse-Id': warehouseId},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => InventoryModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取仓库库存失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<ProductModel>> getProducts({
    String? category,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (category != null) queryParams['category'] = category;

    final response = await _apiClient.get(
      '/products',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取产品列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<ProductModel> getProductDetail(String productId) async {
    final response = await _apiClient.get('/products/$productId');

    if (response.success) {
      return ProductModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取产品详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateInventory(String warehouseId, String productId, int quantity) async {
    final response = await _apiClient.put(
      '/warehouses/inventory',
      headers: {'X-Warehouse-Id': warehouseId},
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );

    return response.success;
  }
}
