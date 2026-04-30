import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await _apiClient.get('/admin/dashboard');

      if (response.success && response.data != null) {
        return DashboardModel.fromJson(response.data);
      } else {
        return _getMockDashboardData();
      }
    } catch (e) {
      return _getMockDashboardData();
    }
  }

  Future<TodayStatsModel> getTodayStats() async {
    try {
      final response = await _apiClient.get('/admin/dashboard/stats');

      if (response.success && response.data != null) {
        return TodayStatsModel.fromJson(response.data);
      } else {
        return _getMockTodayStats();
      }
    } catch (e) {
      return _getMockTodayStats();
    }
  }

  Future<List<SalesTrendModel>> getSalesTrend({int days = 7}) async {
    try {
      final response = await _apiClient.get(
        '/admin/dashboard/sales-trend',
        queryParams: {'days': days.toString()},
      );

      if (response.success) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => SalesTrendModel.fromJson(e)).toList();
        }
        return _getMockSalesTrend();
      } else {
        return _getMockSalesTrend();
      }
    } catch (e) {
      return _getMockSalesTrend();
    }
  }

  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParams: {'unreadOnly': unreadOnly.toString()},
      );

      if (response.success) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => NotificationModel.fromJson(e)).toList();
        }
        return _getMockNotifications();
      } else {
        return _getMockNotifications();
      }
    } catch (e) {
      return _getMockNotifications();
    }
  }

  DashboardModel _getMockDashboardData() {
    return DashboardModel(
      todayStats: _getMockTodayStats(),
      salesTrend: _getMockSalesTrend(),
      notifications: _getMockNotifications(),
      recentOrders: _getMockRecentOrders(),
    );
  }

  TodayStatsModel _getMockTodayStats() {
    return TodayStatsModel(
      salesAmount: 42850.00,
      orderCount: 156,
      activeStations: 48,
      inventoryWarnings: 12,
      comparedToYesterday: 12.5,
    );
  }

  List<SalesTrendModel> _getMockSalesTrend() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return SalesTrendModel(
        date: '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        amount: 30000.0 + (index * 2000) + (index % 2 == 0 ? 5000 : 0),
        count: 100 + (index * 10),
      );
    });
  }

  List<NotificationModel> _getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: '库存告警：桶装纯净水剩余不足100桶',
        content: '中心仓库A区18.9L桶装水库存告警，当前库存95桶，低于最低库存阈值100桶。',
        type: 'warning',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      NotificationModel(
        id: '2',
        title: '新对账单争议：滨江水站 #O20260418',
        content: '滨江花园水站对对账单#O20260418有争议，金额差异¥230元。',
        type: 'info',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        title: '系统维护公告：4月20日凌晨02:00-04:00',
        content: '系统将于4月20日凌晨02:00-04:00进行例行维护，届时系统将暂停服务。',
        type: 'system',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  List<RecentOrderModel> _getMockRecentOrders() {
    final now = DateTime.now();
    return [
      RecentOrderModel(
        id: '1',
        orderNo: '#850019',
        stationName: '张记旗舰水站',
        amount: 1250.00,
        status: '待配送',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      RecentOrderModel(
        id: '2',
        orderNo: '#850018',
        stationName: '滨江花园水站',
        amount: 2380.00,
        status: '配送中',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      RecentOrderModel(
        id: '3',
        orderNo: '#850017',
        stationName: '七星区配送中心',
        amount: 4500.00,
        status: '已完成',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      RecentOrderModel(
        id: '4',
        orderNo: '#850016',
        stationName: '象山区供水站',
        amount: 1890.00,
        status: '已完成',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      RecentOrderModel(
        id: '5',
        orderNo: '#850015',
        stationName: '秀峰区净水厂',
        amount: 3200.00,
        status: '已完成',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }
}
