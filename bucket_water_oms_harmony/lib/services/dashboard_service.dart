import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> getDashboardData() async {
    final response = await _apiClient.get('/admin/dashboard');
    if (response.success && response.data != null) {
      return DashboardModel.fromJson(response.data);
    }
    throw ApiException(
      code: response.code ?? 500,
      message: response.message ?? '获取 Dashboard 数据失败',
    );
  }

  Future<TodayStatsModel> getTodayStats() async {
    final response = await _apiClient.get('/admin/dashboard/stats');
    if (response.success && response.data != null) {
      return TodayStatsModel.fromJson(response.data);
    }
    throw ApiException(
      code: response.code ?? 500,
      message: response.message ?? '获取今日统计失败',
    );
  }

  Future<List<SalesTrendModel>> getSalesTrend({int days = 7}) async {
    final response = await _apiClient.get(
      '/admin/dashboard/sales-trend',
      queryParams: {'days': days.toString()},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => SalesTrendModel.fromJson(e)).toList();
      }
      if (data is Map && data['list'] is List) {
        return (data['list'] as List)
            .map((e) => SalesTrendModel.fromJson(e))
            .toList();
      }
      return <SalesTrendModel>[];
    }
    throw ApiException(
      code: response.code ?? 500,
      message: response.message ?? '获取销售趋势失败',
    );
  }

  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParams: {'unreadOnly': unreadOnly.toString()},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
      if (data is Map && data['list'] is List) {
        return (data['list'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
      return <NotificationModel>[];
    }
    throw ApiException(
      code: response.code ?? 500,
      message: response.message ?? '获取通知失败',
    );
  }

  Future<List<RecentOrderModel>> getRecentOrders({int limit = 10}) async {
    final response = await _apiClient.get(
      '/admin/orders/page',
      queryParams: {'page': '1', 'size': limit.toString()},
    );
    if (response.success) {
      final data = response.data;
      List rawList = [];
      if (data is Map && data['records'] is List) {
        rawList = data['records'] as List;
      } else if (data is List) {
        rawList = data;
      }
      return rawList.map((e) {
        if (e is RecentOrderModel) return e;
        if (e is Map) return RecentOrderModel.fromJson(e);
        return null;
      }).whereType<RecentOrderModel>().toList();
    }
    throw ApiException(
      code: response.code ?? 500,
      message: response.message ?? '获取最近订单失败',
    );
  }
}

class ApiException implements Exception {
  final int code;
  final String message;
  ApiException({required this.code, required this.message});
  @override
  String toString() => 'ApiException($code, $message)';
}
