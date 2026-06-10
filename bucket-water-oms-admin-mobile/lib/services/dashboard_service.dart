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
    } else {
      throw ApiException(
        response.message ?? '获取Dashboard数据失败',
        statusCode: response.code,
      );
    }
  }

  Future<TodayStatsModel> getTodayStats() async {
    final response = await _apiClient.get('/admin/dashboard/stats');

    if (response.success && response.data != null) {
      return TodayStatsModel.fromJson(response.data);
    } else {
      throw ApiException(
        response.message ?? '获取今日统计失败',
        statusCode: response.code,
      );
    }
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
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取销售趋势失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<NotificationModel>> getNotifications(
      {bool unreadOnly = false}) async {
    final response = await _apiClient.get(
      '/notifications',
      queryParams: {'unreadOnly': unreadOnly.toString()},
    );

    if (response.success) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取通知列表失败',
        statusCode: response.code,
      );
    }
  }
}
