import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/admin_bottom_bar.dart';
import '../../shared/components/stat_card.dart';
import '../../shared/components/quick_action_button.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_model.dart';
import '../../main.dart';
import '../login/login_page.dart';
import 'admin_stations_page.dart';
import 'admin_drivers_page.dart';
import 'admin_warehouses_page.dart';
import 'admin_settings_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  DashboardModel? _dashboardData;
  List<RecentOrderModel>? _recentOrders;

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
      final dashboardService = DashboardService();
      final dashboardData = await dashboardService.getDashboardData();

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _recentOrders = dashboardData.recentOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载数据失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(appState),
          const AdminStationsPage(),
          const AdminDriversPage(),
          const AdminWarehousesPage(),
          const AdminSettingsPage(),
        ],
      ),
      bottomNavigationBar: AdminBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildHomeContent(AppState appState) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;

          if (isWideScreen) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: _buildMainContent(appState: appState, isWide: true),
                ),
              ],
            );
          } else {
            return _buildMainContent(appState: appState, isWide: false);
          }
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          right: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSidebarLogo(),
          const SizedBox(height: 30),
          Expanded(
            child: _buildSidebarMenu(),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '水厂运营后台',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '管理员端',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenu() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        _buildSidebarItem(
          icon: Icons.dashboard,
          label: '后台首页',
          isActive: true,
          onTap: () => setState(() => _currentIndex = 0),
        ),
        _buildSidebarItem(
          icon: Icons.store,
          label: '水站管理',
          onTap: () => setState(() => _currentIndex = 1),
        ),
        _buildSidebarItem(
          icon: Icons.local_shipping,
          label: '司机管理',
          onTap: () => setState(() => _currentIndex = 2),
        ),
        _buildSidebarItem(
          icon: Icons.warehouse,
          label: '仓库管理',
          onTap: () => setState(() => _currentIndex = 3),
        ),
        const Divider(height: 32),
        _buildSidebarItem(
          icon: Icons.category,
          label: '销售政策',
          onTap: () => _showComingSoon('销售政策'),
        ),
        _buildSidebarItem(
          icon: Icons.inventory,
          label: '库存管理',
          onTap: () => _showComingSoon('库存管理'),
        ),
        _buildSidebarItem(
          icon: Icons.account_balance_wallet,
          label: '财务管理',
          onTap: () => _showComingSoon('财务管理'),
        ),
        _buildSidebarItem(
          icon: Icons.bar_chart,
          label: '报表统计',
          onTap: () => _showComingSoon('报表统计'),
        ),
        const Divider(height: 32),
        _buildSidebarItem(
          icon: Icons.settings,
          label: '系统设置',
          onTap: () => setState(() => _currentIndex = 4),
        ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color:
            isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? const Border(
                left: BorderSide(
                  color: AppColors.primary,
                  width: 3,
                ),
              )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          '退出登录',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        onTap: _showLogoutDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildMainContent({required AppState appState, required bool isWide}) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: isWide ? _buildHeaderBar(appState) : null,
      body: _buildBody(appState, isWide),
    );
  }

  PreferredSizeWidget _buildHeaderBar(AppState appState) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            '数据概览',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '今天是 ${_getCurrentDate()}',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showComingSoon('通知'),
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Text(
                appState.currentUserName.isNotEmpty
                    ? appState.currentUserName
                    : '管理员',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(AppState appState, bool isWide) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isWide) _buildHeader(appState),
            if (isWide) _buildTodayStats(isWide: true),
            SizedBox(height: isWide ? 24 : 16),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildSalesTrendChart(),
                        const SizedBox(height: 24),
                        _buildQuickActions(isWide: isWide),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildNotifications(),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildTodayStats(isWide: false),
                  const SizedBox(height: 16),
                  _buildQuickActions(isWide: false),
                  const SizedBox(height: 16),
                  _buildNotifications(),
                ],
              ),
            const SizedBox(height: 16),
            _buildRecentOrders(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎回来，${appState.currentUserName.isNotEmpty ? appState.currentUserName : '管理员'}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '今天是 ${_getCurrentDate()}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MiniStatCard(
                  value:
                      _dashboardData?.todayStats?.orderCount?.toString() ?? '0',
                  label: '今日订单',
                  backgroundColor: AppColors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MiniStatCard(
                  value:
                      _dashboardData?.todayStats?.activeStations?.toString() ??
                          '0',
                  label: '活跃水站',
                  backgroundColor: AppColors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MiniStatCard(
                  value: _dashboardData?.todayStats?.salesAmountText ?? '¥0',
                  label: '今日销售额',
                  backgroundColor: AppColors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats({required bool isWide}) {
    final salesAmount = _dashboardData?.todayStats?.salesAmountText ?? '¥0.00';
    final orderCount = _dashboardData?.todayStats?.orderCount ?? 0;
    final activeStations = _dashboardData?.todayStats?.activeStations ?? 0;
    final inventoryAlerts = _dashboardData?.todayStats?.inventoryWarnings ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日概览',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: '今日销售额',
                      value: salesAmount,
                      icon: Icons.attach_money,
                      iconColor: AppColors.success,
                      trend: _dashboardData?.todayStats?.comparedText,
                      showTrend: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: '订单数',
                      value: orderCount.toString(),
                      unit: '单',
                      icon: Icons.shopping_cart,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: '活跃水站',
                      value: activeStations.toString(),
                      unit: '个',
                      icon: Icons.store,
                      iconColor: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: '库存预警',
                      value: inventoryAlerts.toString(),
                      unit: '条',
                      icon: Icons.warning,
                      iconColor: AppColors.error,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: '今日销售额',
                          value: salesAmount,
                          icon: Icons.attach_money,
                          iconColor: AppColors.success,
                          trend: _dashboardData?.todayStats?.comparedText,
                          showTrend: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: '订单数',
                          value: orderCount.toString(),
                          unit: '单',
                          icon: Icons.shopping_cart,
                          iconColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: '活跃水站',
                          value: activeStations.toString(),
                          unit: '个',
                          icon: Icons.store,
                          iconColor: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: '库存预警',
                          value: inventoryAlerts.toString(),
                          unit: '条',
                          icon: Icons.warning,
                          iconColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSalesTrendChart() {
    final salesTrend = _dashboardData?.salesTrend ?? [];

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '销售趋势',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '近7日订单及销售额统计',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildChartToggleButton('按周', false),
                  const SizedBox(width: 8),
                  _buildChartToggleButton('按月', true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: salesTrend.isEmpty
                ? Center(
                    child: Text(
                      '暂无销售数据',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : _buildBarChart(salesTrend),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => _showComingSoon('切换$label数据'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary.withOpacity(0.1) : AppColors.bgInput,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<SalesTrendModel> salesTrend) {
    final maxAmount = salesTrend
        .map((e) => e.amount ?? 0)
        .fold(0.0, (max, amount) => amount > max ? amount : max);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: salesTrend.map((trend) {
            final heightPercentage =
                maxAmount > 0 ? (trend.amount ?? 0) / maxAmount : 0.0;
            final height = heightPercentage * 160;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '¥${(trend.amount ?? 0).toStringAsFixed(0)}',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: height.clamp(20.0, 160.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  trend.date?.substring(5) ?? '',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions({required bool isWide}) {
    final quickActions = [
      QuickActionItem(
        icon: Icons.add_business,
        label: '新增水站',
        iconColor: AppColors.primary,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        onTap: () => _showComingSoon('新增水站'),
      ),
      QuickActionItem(
        icon: Icons.inventory_2,
        label: '入库登记',
        iconColor: AppColors.success,
        backgroundColor: AppColors.success.withOpacity(0.1),
        onTap: () => _showComingSoon('入库登记'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: quickActions.map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == quickActions.first ? 8 : 0,
                  left: item == quickActions.last ? 8 : 0,
                ),
                child: _buildQuickActionCard(item),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickActionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 32,
              color: item.iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: AppTextStyles.body2.copyWith(
                color: item.iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    final notifications = _dashboardData?.notifications ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '重要通知',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                '全部',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notifications.isEmpty)
          AppCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无通知',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...notifications.take(3).map((notification) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildNotificationItem(notification),
              )),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: notification.isRead == true
                  ? AppColors.success
                  : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title ?? '系统通知',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.content ?? '',
                  style: AppTextStyles.captionSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(notification.createdAt),
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    final orders = _recentOrders ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近订单',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                '查看全部',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          AppCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无订单',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...orders.take(5).map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderItem(order),
              )),
      ],
    );
  }

  Widget _buildOrderItem(RecentOrderModel order) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.stationName ?? '未知水站',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.orderNo ?? '',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${order.amount?.toStringAsFixed(2) ?? '0.00'}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                order.status ?? '',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}年${now.month}月${now.day}日';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${dateTime.month}-${dateTime.day}';
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AppState>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              '确定',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
