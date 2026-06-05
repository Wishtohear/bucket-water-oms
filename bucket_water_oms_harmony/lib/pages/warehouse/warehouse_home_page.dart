import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../services/warehouse_service.dart';
import '../../services/inventory_service.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../main.dart';
import '../login/login_page.dart';
import 'warehouse_orders_page.dart';
import 'warehouse_inbound_page.dart';
import 'warehouse_outbound_page.dart';
import 'warehouse_inventory_page.dart';
import 'warehouse_order_detail_page.dart';
import 'warehouse_return_list_page.dart';
import 'warehouse_after_sales_page.dart';
import 'warehouse_settings_page.dart';

class WarehouseHomePage extends StatefulWidget {
  const WarehouseHomePage({super.key});

  @override
  State<WarehouseHomePage> createState() => _WarehouseHomePageState();
}

class _WarehouseHomePageState extends State<WarehouseHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  List<OrderModel> _pendingOrders = [];
  List<InventoryModel> _inventoryList = [];
  List<OrderModel> _recentOrders = [];
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final warehouseService = WarehouseService();
      final inventoryService = InventoryService();
      final orderService = OrderService();

      final warehouseId = appState.userId ?? '0';

      final results = await Future.wait([
        warehouseService.getDashboard(warehouseId).catchError((_) => <String, dynamic>{}),
        warehouseService.getPendingOrders(warehouseId).catchError((_) => <OrderModel>[]),
        inventoryService.getWarehouseInventory(warehouseId).catchError((_) => <InventoryModel>[]),
        orderService.getWarehouseOrders(warehouseId).catchError((_) => <OrderModel>[]),
      ]);

      if (mounted) {
        setState(() {
          _dashboardData = results[0] as Map<String, dynamic>;
          _pendingOrders = results[1] as List<OrderModel>;
          _inventoryList = results[2] as List<InventoryModel>;
          _recentOrders = (results[3] as List<OrderModel>).take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        _showErrorSnackbar('加载数据失败: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const WarehouseOrdersPage(),
          const WarehouseInboundPage(),
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
            child: Text(
              appState.currentUserName.isNotEmpty
                  ? appState.currentUserName
                  : (appState.currentStationName.isNotEmpty
                      ? appState.currentStationName
                      : '仓库'),
              style:
                  AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: AppColors.textSecondary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const WarehouseInventoryPage()),
              );
            },
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
              onTap: () => setState(() => _currentIndex = 2)),
          _buildTabItem('出库',
              isSelected: false,
              onTap: () => setState(() => _currentIndex = 1)),
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
    final todayInbound = _dashboardData['todayInbound'] ?? 0;
    final todayOutbound = _dashboardData['todayOutbound'] ?? 0;
    final inboundTrend = _dashboardData['inboundTrend'] as double?;
    final outboundTrend = _dashboardData['outboundTrend'] as double?;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: '今日入库',
            value: '$todayInbound',
            unit: '桶',
            icon: Icons.move_to_inbox,
            iconColor: AppColors.primary,
            trend: inboundTrend != null
                ? '${inboundTrend >= 0 ? '+' : ''}${inboundTrend.toStringAsFixed(1)}%'
                : '0%',
            trendColor:
                inboundTrend == null || inboundTrend >= 0
                    ? AppColors.success
                    : AppColors.error,
            isPositive: inboundTrend == null ? null : inboundTrend >= 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: '今日出库',
            value: '$todayOutbound',
            unit: '桶',
            icon: Icons.outbox,
            iconColor: AppColors.success,
            trend: outboundTrend != null
                ? '${outboundTrend >= 0 ? '+' : ''}${outboundTrend.toStringAsFixed(1)}%'
                : '0%',
            trendColor:
                outboundTrend == null || outboundTrend >= 0
                    ? AppColors.primary
                    : AppColors.error,
            isPositive: outboundTrend == null ? null : outboundTrend >= 0,
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
    final lowStockItems = _inventoryList.where((item) => item.isLowStock).toList();

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
            ...lowStockItems.take(2).map((item) => _buildWarningItem(
                  item.productName ?? '未知产品',
                  '库存不足 (${item.stock ?? 0}/${item.minStock ?? 0})',
                )),
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
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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

  Widget _buildOrderStats() {
    final pendingCount = _dashboardData['pendingOrderCount'] ?? _pendingOrders.length;
    final returnCount = _dashboardData['pendingReturnCount'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildOrderStatCard(
            label: '待接单',
            count: pendingCount is int ? pendingCount : 0,
            icon: Icons.assignment,
            iconColor: AppColors.warning,
            onTap: () => setState(() => _currentIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOrderStatCard(
            label: '待核对',
            count: returnCount is int ? returnCount : 0,
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
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
                icon: Icons.assignment,
                iconColor: AppColors.warning,
                backgroundColor: AppColors.warning.withOpacity(0.1),
                label: '订单管理',
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildQuickActionItem(
                icon: Icons.add_box,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                label: '采购入库',
                onTap: () => setState(() => _currentIndex = 2),
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
              _buildQuickActionItem(
                icon: Icons.support_agent,
                iconColor: AppColors.error,
                backgroundColor: AppColors.error.withOpacity(0.1),
                label: '售后处理',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WarehouseAfterSalesPage()),
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
              onTap: () => setState(() => _currentIndex = 1),
              child: Text(
                '查看全部',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Text(
              '暂无最近任务',
              style: AppTextStyles.body2
                  .copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ..._recentOrders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTaskItem(order),
              )),
      ],
    );
  }

  Widget _buildTaskItem(OrderModel order) {
    final isCompleted = order.status == 'completed' || order.status == 'delivered';
    final isUrgent = order.status == 'pending' || order.status == 'confirmed';
    final statusColor = isCompleted
        ? AppColors.success
        : (isUrgent ? AppColors.warning : AppColors.primary);
    final statusText = order.statusText;
    final iconData = isCompleted
        ? Icons.local_shipping
        : (isUrgent ? Icons.assignment : Icons.inventory);
    final itemSummary = order.items != null && order.items!.isNotEmpty
        ? '${order.items!.first.productName ?? '商品'} × ${order.items!.first.quantity ?? 0}'
        : '暂无商品';
    final detail = '${order.stationName ?? '未知水站'} | $itemSummary';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WarehouseOrderDetailPage(),
          ),
        );
      },
      child: Container(
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
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '订单 ${order.orderNo ?? order.id ?? ''}',
                          style: AppTextStyles.subtitle2
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: AppTextStyles.captionSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
