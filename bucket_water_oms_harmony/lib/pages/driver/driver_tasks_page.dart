import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/stat_card.dart';
import '../../services/driver_service.dart';
import '../../services/driver_status_service.dart';
import '../../models/order_model.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';
import '../login/login_page.dart';
import 'driver_statement_page.dart';
import 'driver_order_detail_page.dart';
import 'driver_barrel_page.dart';
import 'driver_warehouse_return_page.dart';
import 'driver_settings_page.dart';

class DriverTasksPage extends StatefulWidget {
  const DriverTasksPage({super.key});

  @override
  State<DriverTasksPage> createState() => _DriverTasksPageState();
}

class _DriverTasksPageState extends State<DriverTasksPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdatingStatus = false;
  late TabController _tabController;

  List<OrderModel> _pendingTasks = [];
  List<OrderModel> _deliveringTasks = [];
  List<OrderModel> _completedTasks = [];

  late DriverStatusService _statusService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _statusService = DriverStatusService();
    _statusService.addListener(_onStatusChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statusService.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (mounted) {
      setState(() {});
      if (_statusService.currentStatus?.isAutomaticOffline == true) {
        _showAutomaticOfflineSnackBar();
      }
    }
  }

  void _showAutomaticOfflineSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('网络连接不稳定，已自动切换为离线状态'),
        backgroundColor: AppColors.warning,
        action: SnackBarAction(
          label: '重新上线',
          textColor: AppColors.white,
          onPressed: () {
            _goOnline();
          },
        ),
      ),
    );
  }

  Future<void> _goOnline() async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _statusService.goOnline();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已成功上线'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上线失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _goOffline() async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _statusService.goOffline();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已成功下线'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下线失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _goOnBreak() async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _statusService.goOnBreak();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已开始休息'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final driverService = DriverService();
      final driverId = appState.userId ?? 'demo';
      final tasks = await driverService.getDriverTasks(driverId);

      if (mounted) {
        setState(() {
          _pendingTasks = tasks
              .where((t) => t.status == 'pending' || t.status == 'assigned')
              .toList();
          _deliveringTasks = tasks
              .where((t) => t.status == 'delivering' || t.status == 'picked_up')
              .toList();
          _completedTasks = tasks
              .where((t) => t.status == 'completed' || t.status == 'delivered')
              .toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      _loadMockData();
    } catch (e) {
      _loadMockData();
    }
  }

  void _loadMockData() {
    if (mounted) {
      setState(() {
        _pendingTasks = [
          OrderModel(
            id: '1',
            orderNo: 'ORD001',
            status: 'pending',
            contactName: '张老板',
            contactPhone: '138****8888',
            deliveryAddress: '秀峰区XX路88号',
            totalAmount: 1850.00,
            stationName: '张记旗舰水站',
            items: [
              OrderItemModel(productName: '18.9L 桶装水', quantity: 50),
              OrderItemModel(productName: '11.3L 桶装水', quantity: 20),
            ],
          ),
          OrderModel(
            id: '2',
            orderNo: 'ORD002',
            status: 'pending',
            contactName: '李老板',
            contactPhone: '139****6666',
            deliveryAddress: '七星区龙隐路12号',
            totalAmount: 750.00,
            stationName: '李家水铺',
            items: [
              OrderItemModel(productName: '18.9L 桶装水', quantity: 30),
            ],
          ),
          OrderModel(
            id: '3',
            orderNo: 'ORD003',
            status: 'pending',
            contactName: '老板',
            contactPhone: '137****5555',
            deliveryAddress: '象山区环城南二路...',
            totalAmount: 1200.00,
            stationName: '好运来水店',
            items: [
              OrderItemModel(productName: '18.9L 桶装水', quantity: 30),
              OrderItemModel(productName: '11.3L 桶装水', quantity: 15),
            ],
          ),
        ];
        _deliveringTasks = [
          OrderModel(
            id: '4',
            orderNo: 'ORD004',
            status: 'delivering',
            contactName: '张老板',
            contactPhone: '138****8888',
            deliveryAddress: '秀峰区XX路88号',
            totalAmount: 1850.00,
            stationName: '张记旗舰水站',
            items: [
              OrderItemModel(productName: '18.9L 桶装水', quantity: 50),
              OrderItemModel(productName: '11.3L 桶装水', quantity: 20),
            ],
          ),
        ];
        _completedTasks = [
          OrderModel(
            id: '5',
            orderNo: 'ORD005',
            status: 'completed',
            contactName: '老板',
            contactPhone: '136****4444',
            deliveryAddress: '七星区XX路',
            totalAmount: 950.00,
            stationName: '青山水店',
            items: [
              OrderItemModel(productName: '18.9L 桶装水', quantity: 40),
            ],
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTasksContent(),
          const DriverBarrelPage(),
          const DriverStatementPage(),
          const DriverSettingsPage(),
        ],
      ),
      bottomNavigationBar: DriverBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
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

  Widget _buildTasksContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: AppColors.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadData, child: const Text('重新加载')),
          ],
        ),
      );
    }

    final appState = context.watch<AppState>();

    return Column(
      children: [
        _buildHeader(context, appState),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRouteCard(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  _buildTaskList(),
                  const SizedBox(height: 16),
                  _buildReturnCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusService.currentStatus?.status ==
                                  DriverStatusType.online
                              ? AppColors.success
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '早上好，',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    appState.currentUserName.isNotEmpty
                        ? '${appState.currentUserName}师傅'
                        : '王力师傅',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appState.currentStationName} · 中心仓库A库区',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusIndicator(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  value:
                      '${_pendingTasks.length > 0 ? _pendingTasks.length : 8}',
                  label: '今日待配送',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  value:
                      '${_deliveringTasks.length > 0 ? _deliveringTasks.length : 2}',
                  label: '配送中',
                  valueColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  value:
                      '${_completedTasks.length > 0 ? _completedTasks.length : 5}',
                  label: '累计完成',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String value,
    required String label,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.white.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.statNumber.copyWith(
                    fontSize: 24,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '单',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    final status = _statusService.currentStatus;
    if (status?.status == DriverStatusType.online) {
      return '在线';
    } else if (status?.status == DriverStatusType.breakTime) {
      return '休息中';
    } else {
      return '离线';
    }
  }

  Widget _buildStatusIndicator() {
    final status = _statusService.currentStatus;
    final isOnline = status?.status == DriverStatusType.online;
    final isOnBreak = status?.status == DriverStatusType.breakTime;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isOnline
                ? Icons.check_circle
                : (isOnBreak ? Icons.free_breakfast : Icons.circle_outlined),
            color: isOnline
                ? AppColors.success
                : (isOnBreak ? AppColors.warning : AppColors.textSecondary),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (isOnline || isOnBreak)
            _buildStatusActionButtons()
          else
            _buildOnlineButton(),
        ],
      ),
    );
  }

  Widget _buildOnlineButton() {
    return ElevatedButton(
      onPressed: _isUpdatingStatus ? null : _goOnline,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: _isUpdatingStatus
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : const Text('上线', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: _isUpdatingStatus ? null : _goOnBreak,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.white),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('休息', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isUpdatingStatus ? null : _goOffline,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('下线', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildRouteCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map, color: AppColors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '智能规划配送路线',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已避开拥堵路段，预计用时 45min',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '共 3 个配送点 · 总里程 12.5km',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward,
                  color: AppColors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _tabController.animateTo(0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 2)),
              ),
              child: Text(
                '待配送 (${_pendingTasks.length > 0 ? _pendingTasks.length : 8})',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _tabController.animateTo(1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '配送中 (${_deliveringTasks.length > 0 ? _deliveringTasks.length : 2})',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _tabController.animateTo(2),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '已完成 (${_completedTasks.length > 0 ? _completedTasks.length : 5})',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    if (_pendingTasks.isEmpty &&
        _deliveringTasks.isEmpty &&
        _completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('暂无任务',
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_pendingTasks.isNotEmpty)
          ..._pendingTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTaskCard(order, isActive: index == 0),
            );
          }),
        if (_deliveringTasks.isNotEmpty)
          ..._deliveringTasks.map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDeliveringCard(order),
            );
          }),
        if (_completedTasks.isNotEmpty)
          ..._completedTasks.take(3).map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCompletedCard(order),
            );
          }),
      ],
    );
  }

  Widget _buildTaskCard(OrderModel order, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '第${_pendingTasks.indexOf(order) + 1}单',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: isActive
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('配送序列', style: AppTextStyles.captionSmall),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? '预约 14:00' : '待配送',
                  style: AppTextStyles.captionSmall.copyWith(
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.stationName ?? order.contactName ?? '未知水站',
                      style: AppTextStyles.subtitle2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.navigation,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                            '距您 2.5km · ${order.deliveryAddress ?? '秀峰区XX路88号'}',
                            style: AppTextStyles.captionSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                            '${order.contactName ?? '张老板'} ${order.contactPhone ?? '138****8888'}',
                            style: AppTextStyles.captionSmall),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.success : AppColors.bgInput,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone,
                    color: isActive ? AppColors.white : AppColors.textSecondary,
                    size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('货物明细:', style: AppTextStyles.caption),
                    Text('点击查看详情', style: AppTextStyles.captionSmall),
                  ],
                ),
                const SizedBox(height: 8),
                if (order.items != null && order.items!.isNotEmpty)
                  ...order.items!.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.productName ?? '18.9L 桶装水',
                              style: AppTextStyles.body2),
                          Text('× ${item.quantity ?? 0} 桶',
                              style: AppTextStyles.body2
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  })
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('18.9L 桶装水', style: AppTextStyles.body2),
                      Text('× ${order.totalQuantity ?? 50} 桶',
                          style: AppTextStyles.body2
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('当前欠桶:', style: AppTextStyles.captionSmall),
                    Text('5个',
                        style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Text('历史欠桶:', style: AppTextStyles.captionSmall),
                    Text('8个',
                        style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isActive)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DriverOrderDetailPage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.navigation,
                              color: AppColors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '开始配送',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on,
                        color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '待前面的单完成后再配送',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveringCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.orange.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '配送中',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text('开始时间: 14:20', style: AppTextStyles.captionSmall),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.stationName ?? '张记旗舰水站',
                        style: AppTextStyles.subtitle2
                            .copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('进行中',
                          style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(order.deliveryAddress ?? '秀峰区XX路88号',
                        style: AppTextStyles.captionSmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.navigation,
                            color: AppColors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '查看导航',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '确认送达',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(OrderModel order) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: AppColors.success, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text('已完成',
                      style: AppTextStyles.subtitle2
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('14:35', style: AppTextStyles.captionSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.stationName ?? '青山水店', style: AppTextStyles.body2),
              Text('18.9L × ${order.totalQuantity ?? 40}桶',
                  style: AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Text('回桶: +35个 · 欠桶: 5个', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const DriverWarehouseReturnPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF52C41A), Color(0xFF73D13D)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.warehouse, color: AppColors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '回仓申请与清点',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '当前车上空桶：75个',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '待交回仓库：15个',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '去处理',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      color: AppColors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
