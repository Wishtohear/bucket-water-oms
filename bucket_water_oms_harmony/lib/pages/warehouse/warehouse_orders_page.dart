import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';
import '../../services/order_service.dart';
import '../../services/warehouse_service.dart';
import '../../models/order_model.dart';
import 'warehouse_order_detail_page.dart';

class WarehouseOrdersPage extends StatefulWidget {
  const WarehouseOrdersPage({super.key});

  @override
  State<WarehouseOrdersPage> createState() => _WarehouseOrdersPageState();
}

class _WarehouseOrdersPageState extends State<WarehouseOrdersPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];

  final List<_TabConfig> _tabs = const [
    _TabConfig('待接单', 'pending', 0),
    _TabConfig('备货中', 'preparing', 1),
    _TabConfig('已派单', 'dispatched', 2),
    _TabConfig('已完成', 'completed', 3),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderService = OrderService();
      final warehouseService = WarehouseService();
      const warehouseId = '0';

      final results = await Future.wait([
        orderService.getWarehouseOrders(warehouseId).catchError((_) => <OrderModel>[]),
        warehouseService.getPendingOrders(warehouseId).catchError((_) => <OrderModel>[]),
      ]);

      if (mounted) {
        final orders = <OrderModel>[];
        orders.addAll(results[0] as List<OrderModel>);
        orders.addAll(results[1] as List<OrderModel>);

        setState(() {
          _allOrders = orders;
          _isLoading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        _showErrorSnackbar('加载订单失败: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _applyFilter() {
    final tab = _tabs[_selectedTabIndex];
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final matchesStatus = _matchesStatus(order.status, tab.statusKey);
        if (!matchesStatus) return false;
        if (query.isEmpty) return true;
        final orderNo = (order.orderNo ?? order.id ?? '').toLowerCase();
        final station = (order.stationName ?? '').toLowerCase();
        return orderNo.contains(query) || station.contains(query);
      }).toList();
    });
  }

  bool _matchesStatus(String? orderStatus, String tabKey) {
    if (orderStatus == null) return tabKey == 'pending';
    switch (tabKey) {
      case 'pending':
        return orderStatus == 'pending' || orderStatus == 'confirmed';
      case 'preparing':
        return orderStatus == 'preparing' || orderStatus == 'processing';
      case 'dispatched':
        return orderStatus == 'dispatched' || orderStatus == 'shipping' || orderStatus == 'in_transit';
      case 'completed':
        return orderStatus == 'completed' || orderStatus == 'delivered' || orderStatus == 'cancelled';
      default:
        return true;
    }
  }

  int _getCountForTab(String statusKey) {
    return _allOrders.where((o) => _matchesStatus(o.status, statusKey)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildOrderList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: const Row(
        children: [
          Text(
            '订单管理',
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTabIndex == tab.index;
          final count = _getCountForTab(tab.statusKey);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = tab.index;
                });
                _applyFilter();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '${tab.label} ($count)',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: AppTextStyles.body2,
              decoration: InputDecoration(
                hintText: '搜索订单号/水站名称',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textPlaceholder,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _showFilterSnackbar(),
              borderRadius: BorderRadius.circular(16),
              child: const Icon(
                Icons.filter_list,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请使用顶部标签切换订单状态'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无订单',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final status = order.status ?? 'pending';
    final isUrgent = status == 'pending';
    final isCompleted = status == 'completed' || status == 'delivered';
    final priorityText = _getPriorityText(status);
    final priorityColor = _getPriorityColor(status);
    final badgeType = isUrgent ? BadgeType.error : (isCompleted ? BadgeType.success : BadgeType.info);
    final firstItem = order.items != null && order.items!.isNotEmpty
        ? order.items!.first
        : null;
    final productText = firstItem != null
        ? '${firstItem.productName ?? '商品'} × ${firstItem.quantity ?? 0}'
        : '暂无商品';
    final totalQty = order.totalQuantity;
    final amount = order.totalAmount ?? 0.0;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
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
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '订单 #${order.orderNo ?? order.id ?? ''}',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge(
                    text: priorityText,
                    type: badgeType,
                    fontSize: 10,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
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
                    const SizedBox(height: 2),
                    Text(
                      '地址: ${order.deliveryAddress ?? '暂无地址'}',
                      style: AppTextStyles.captionSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final phone = order.contactPhone;
                  if (phone != null && phone.isNotEmpty) {
                    _showErrorSnackbar('拨打: $phone');
                  } else {
                    _showErrorSnackbar('暂无联系电话');
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: AppColors.success,
                    size: 18,
                  ),
                ),
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
                    Expanded(
                      child: Text(
                        productText,
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '× $totalQty 桶',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (order.items != null && order.items!.length > 1) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '共 ${order.items!.length} 种商品',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '共计 $totalQty 桶',
                      style: AppTextStyles.captionSmall,
                    ),
                    Text(
                      '¥ ${amount.toStringAsFixed(2)}',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WarehouseOrderDetailPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '查看详情',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _onAcceptOrder(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                    child: Center(
                      child: Text(
                        isCompleted ? '已完成' : '接单',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  String _getPriorityText(String status) {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'confirmed':
        return '已确认';
      case 'preparing':
        return '备货中';
      case 'processing':
        return '处理中';
      case 'dispatched':
      case 'shipping':
      case 'in_transit':
        return '已派单';
      case 'delivered':
        return '已送达';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.error;
      case 'confirmed':
      case 'preparing':
        return AppColors.warning;
      case 'processing':
        return AppColors.primary;
      case 'dispatched':
      case 'shipping':
        return AppColors.purple;
      case 'completed':
      case 'delivered':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _onAcceptOrder(OrderModel order) async {
    if (order.status == 'completed' || order.status == 'delivered') {
      _showErrorSnackbar('订单已完成，无需操作');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('接单确认'),
        content: Text('确定要接收订单 #${order.orderNo ?? order.id} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认接单'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final orderService = OrderService();
      final newStatus = order.status == 'pending' ? 'confirmed' : 'preparing';
      final success = await orderService.updateOrderStatus(
        order.id ?? '',
        newStatus,
      );

      if (success && mounted) {
        _showSuccessSnackbar('订单 #${order.orderNo ?? order.id} 已接收');
        await _loadData();
      } else if (mounted) {
        _showErrorSnackbar('接单失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('接单失败: $e');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final String statusKey;
  final int index;

  const _TabConfig(this.label, this.statusKey, this.index);
}
