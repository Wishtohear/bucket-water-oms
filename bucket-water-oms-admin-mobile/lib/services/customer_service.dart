import '../core/network/api_client.dart';
import '../models/customer_model.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<CustomerModel>> getCustomers({
    String? stationId,
    String? keyword,
  }) async {
    final headers = <String, String>{};
    if (stationId != null) {
      headers['X-Station-Id'] = stationId;
    }

    final queryParams = <String, String>{};
    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    final response = await _apiClient.get(
      '/customers',
      queryParams: queryParams,
      headers: headers,
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => CustomerModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取客户列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<CustomerModel> getCustomer(String customerId) async {
    final response = await _apiClient.get('/customers/$customerId');

    if (response.success) {
      return CustomerModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取客户详情失败',
        statusCode: response.code,
      );
    }
  }

  Future<CustomerModel> createCustomer({
    required String stationId,
    required String name,
    required String phone,
    String? address,
    String? contact,
  }) async {
    final response = await _apiClient.post(
      '/customers',
      body: {
        'name': name,
        'phone': phone,
        if (address != null) 'address': address,
        if (contact != null) 'contact': contact,
      },
      headers: {'X-Station-Id': stationId},
    );

    if (response.success) {
      return CustomerModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '创建客户失败',
        statusCode: response.code,
      );
    }
  }

  Future<CustomerModel> updateCustomer(
    String customerId, {
    String? name,
    String? phone,
    String? address,
    String? contact,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (contact != null) body['contact'] = contact;

    final response = await _apiClient.put(
      '/customers/$customerId',
      body: body,
    );

    if (response.success) {
      return CustomerModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '更新客户失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    final response = await _apiClient.delete('/customers/$customerId');
    return response.success;
  }
}
