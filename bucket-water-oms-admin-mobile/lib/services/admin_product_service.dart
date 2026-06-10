import '../core/network/api_client.dart';
import '../models/admin_models.dart';

class AdminProductService {
  static final AdminProductService _instance = AdminProductService._internal();
  factory AdminProductService() => _instance;
  AdminProductService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<ProductListResponse> getProducts({
    String? keyword,
    String? category,
    String? status,
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
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/admin/products',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<ProductModel> products = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          products = data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
          total = products.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            products = (data['list'] as List)
                .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (data['records'] != null) {
            products = (data['records'] as List)
                .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? products.length;
        }
      }

      return ProductListResponse(
        products: products,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<ProductModel> getProductDetail(String productId) async {
    final response = await _apiClient.get('/admin/products/$productId');

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _apiClient.post(
      '/admin/products',
      body: product.toJson(),
    );

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<ProductModel> updateProduct(String productId, ProductModel product) async {
    final response = await _apiClient.put(
      '/admin/products/$productId',
      body: product.toJson(),
    );

    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateProductStatus(String productId, String status) async {
    final response = await _apiClient.put(
      '/admin/products/$productId/status',
      body: {'status': status},
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

class ProductListResponse {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int pageSize;

  ProductListResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}
