import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/widgets/predictive_back_wrapper.dart';
import '../../services/warehouse_service.dart';
import '../../services/warehouse_dashboard_service.dart';
import '../../services/inventory_service.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/warehouse_dashboard_model.dart';
import '../../core/network/api_client.dart';
import '../../stores/sse_store.dart';
import '../../shared/widgets/sse_status_widget.dart';
import '../../main.dart';
import 'warehouse_orders_page.dart';
import 'warehouse_inbound_page.dart';
import 'warehouse_orders_page.dart';
import 'warehouse_inventory_page.dart';
import 'warehouse_return_list_page.dart';
import 'warehouse_settings_page.dart';

class WarehouseHomePage extends StatefulWidget {
  const WarehouseHomePage({super.key});

  @override
  State<WarehouseHomePage> createState() => _WarehouseHomePageState();
}

class _WarehouseHomePageState extends State<WarehouseHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;

  List<OrderModel> _pendingOrders = [];
  List<InventoryModel> _inventoryList = [];

  int _todayInbound = 0;
  int _todayOutbound = 0;
  int _pendingOrdersCount = 0;
  int _pendingReturnCheckCount = 0;
  int _lowStockCount = 0;

  String _warehouseName = '';
  String _warehouseAddress = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _initSse();
  }

  Future<void> _initSse() async {
    final sseStore = context.read<SseStore>();
    await sseStore.requestNotificationPermissions();

    final warehouseId = ApiConfig.getWarehouseId();
    final userId = ApiConfig.getUserId();
    final role = ApiConfig.getUserRole();

    final sseUserId = warehouseId.isNotEmpty ? warehouseId : userId;

    debugPrint('[WarehouseHomePage] SSE初始化: userId=$sseUserId, role=$role');

    if (sseUserId.isNotEmpty) {
      sseStore.connect(sseUserId, role);
    } else {
      debugPrint('[WarehouseHomePage] SSE初始化失败: userId为空');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = context.read<AppState>();
      final warehouseService = WarehouseService();
      final warehouseDashboardService = WarehouseDashboardService();
      final inventoryService = InventoryService();

      final warehouseId = appState.userId;

      if (warehouseId == null || warehouseId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final orders = await warehouseService.getPendingOrders(warehouseId);
      final inventory =
          await inventoryService.getWarehouseInventory(warehouseId);

      WarehouseDashboardModel? dashboard;
      try {
        dashboard = await warehouseDashboardService.getDashboard(warehouseId);
      } catch (e) {
        debugPrint('[WarehouseHomePage] Dashboard API调用失败: $e');
      }

      Map<String, dynamic>? warehouseInfo;
      try {
        warehouseInfo = await warehouseService.getWarehouseInfo(warehouseId);
      } catch (e) {
        debugPrint('[WarehouseHomePage] 获取仓库信息失败: $e');
      }

      if (mounted) {
        setState(() {
          _pendingOrders = orders;
          _inventoryList = inventory;

          if (dashboard != null) {
            _todayInbound = dashboard.todayInboundCount;
            _todayOutbound = dashboard.todayOutboundCount;
            _pendingOrdersCount = dashboard.pendingOrders;
            _lowStockCount = dashboard.lowStockProducts;
          } else {
            _pendingOrdersCount = orders.length;
            _lowStockCount = _inventoryList
                .where((item) => item.stock != null && item.stock! < 50)
                .length;
          }

          if (warehouseInfo != null) {
            _warehouseName = warehouseInfo['name'] ?? '';
            _warehouseAddress = warehouseInfo['address'] ?? '';
          }

          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      debugPrint('[WarehouseHomePage] API异常: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[WarehouseHomePage] 未知错误: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PredictiveBackWrapper(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const WarehouseInboundPage(),
            const WarehouseOrdersPage(),
            const WarehouseInventoryPage(),
            const WarehouseSettingsPage(),
          ],
        ),
        bottomNavigationBar: WarehouseBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final appState = context.watch<AppState>();

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(appState),
          _buildTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 16),
                    _buildWarningCard(),
                    const SizedBox(height: 16),
                    _buildOrderStats(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildRecentTasks(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    final displayName = _warehouseName.isNotEmpty
        ? _warehouseName
        : (appState.currentUserName.isNotEmpty
            ? appState.currentUserName
            : '仓库');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.warehouse, color: AppColors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.subtitle1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Consumer<SseStore>(
                  builder: (context, sseStore, _) {
                    return SseStatusIndicator(showLabel: true);
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.textSecondary,
            onPressed: () => setState(() => _currentIndex = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          _buildTabItem('概览', isSelected: true),
          _buildTabItem('入库',
              isSelected: false,
              onTap: () => setState(() => _currentIndex = 1)),
          _buildTabItem('订单',
              isSelected: false,
              onTap: () => setState(() => _currentIndex = 2)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label,
      {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: '今日入库',
            value: _todayInbound > 0 ? '$_todayInbound' : '--',
            unit: '桶',
            icon: Icons.move_to_inbox,
            iconColor: AppColors.primary,
            trend: _todayInbound > 0 ? '+12%' : '--',
            trendColor: AppColors.success,
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: '今日出库',
            value: _todayOutbound > 0 ? '$_todayOutbound' : '--',
            unit: '桶',
            icon: Icons.outbox,
            iconColor: AppColors.success,
            trend: _todayOutbound > 0 ? '持平' : '--',
            trendColor: AppColors.primary,
            isPositive: null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required String trend,
    required Color trendColor,
    required bool? isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.statNumber.copyWith(fontSize: 28),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: AppTextStyles.caption),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive == null
                    ? Icons.remove
                    : (isPositive ? Icons.arrow_upward : Icons.arrow_downward),
                size: 12,
                color: trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: AppTextStyles.captionSmall.copyWith(color: trendColor),
              ),
              const SizedBox(width: 4),
              Text('较昨日', style: AppTextStyles.captionSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    final lowStockItems = _getLowStockItems();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 24),
              const SizedBox(width: 8),
              Text(
                '库存预警',
                style: AppTextStyles.subtitle2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lowStockItems.length}条记录',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lowStockItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '暂无库存预警',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...lowStockItems.take(2).map(
                (item) => _buildWarningItem(item['name']!, item['status']!)),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String name, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: AppTextStyles.body2),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getLowStockItems() {
    return _inventoryList
        .where((item) => item.stock != null && item.stock! < 50)
        .take(5)
        .map((item) => {
              'name': item.productName ?? '未知商品',
              'status': '库存不足 (${item.stock ?? 0})',
            })
        .toList();
  }

  Widget _buildOrderStats() {
    return Row(
      children: [
        Expanded(
          child: _buildOrderStatCard(
            label: '待接单',
            count: _pendingOrdersCount,
            icon: Icons.assignment,
            iconColor: AppColors.warning,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WarehouseOrdersPage()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOrderStatCard(
            label: '待核对',
            count: _pendingReturnCheckCount,
            icon: Icons.checklist,
            iconColor: AppColors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const WarehouseReturnListPage()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatCard({
    required String label,
    required int count,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              '查看订单',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快捷操作',
            style:
                AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.move_to_inbox,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                label: '入库管理',
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildQuickActionItem(
                icon: Icons.assignment,
                iconColor: AppColors.warning,
                backgroundColor: AppColors.warning.withOpacity(0.1),
                label: '订单管理',
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildQuickActionItem(
                icon: Icons.inventory_2,
                iconColor: AppColors.success,
                backgroundColor: AppColors.success.withOpacity(0.1),
                label: '库存管理',
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _buildQuickActionItem(
                icon: Icons.checklist,
                iconColor: AppColors.purple,
                backgroundColor: AppColors.purple.withOpacity(0.1),
                label: '回仓核对',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WarehouseReturnListPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks() {
    if (_pendingOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近任务',
              style:
                  AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WarehouseOrdersPage()),
                );
              },
              child: Text(
                '查看全部',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._pendingOrders.take(3).map((order) => _buildTaskItem(order)),
      ],
    );
  }

  Widget _buildTaskItem(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.assignment,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '订单 #${order.orderNo ?? order.id}',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.stationName ?? '未知水站',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.statusText,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
