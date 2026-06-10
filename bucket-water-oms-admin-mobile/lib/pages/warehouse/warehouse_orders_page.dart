import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/phone_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/components/status_badge.dart';
import '../../models/order_model.dart';
import '../../services/warehouse_service.dart';
import 'warehouse_dispatch_select_page.dart';

class WarehouseOrdersPage extends StatefulWidget {
  const WarehouseOrdersPage({super.key});

  @override
  State<WarehouseOrdersPage> createState() => _WarehouseOrdersPageState();
}

class _WarehouseOrdersPageState extends State<WarehouseOrdersPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final WarehouseService _warehouseService = WarehouseService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;

  int _pendingCount = 0;
  int _preparingCount = 0;
  int _dispatchedCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId != null && warehouseId.isNotEmpty) {
        final orders = await _warehouseService.getAllOrders(warehouseId);

        _pendingCount = orders
            .where((o) =>
                o.status == 'pending' ||
                o.status == '待接单' ||
                o.status == 'pending_review' ||
                o.status == '待审查' ||
                o.status == 'PENDING_REVIEW')
            .length;
        _preparingCount = orders
            .where((o) =>
                o.status == 'preparing' ||
                o.status == '备货中' ||
                o.status == 'PREPARING' ||
                o.status == 'reviewed' ||
                o.status == 'REVIEWED')
            .length;
        _dispatchedCount = orders
            .where((o) =>
                o.status == 'dispatched' ||
                o.status == '已派单' ||
                o.status == 'DISPATCHED')
            .length;
        _completedCount = orders
            .where((o) =>
                o.status == 'completed' ||
                o.status == '已完成' ||
                o.status == 'COMPLETED')
            .length;

        setState(() {
          _allOrders = orders;
          _filteredOrders = _filterOrdersByStatus(orders, _selectedTabIndex);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载订单失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<OrderModel> _filterOrdersByStatus(
      List<OrderModel> orders, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return orders
            .where((o) =>
                o.status == 'pending' ||
                o.status == '待接单' ||
                o.status == 'pending_review' ||
                o.status == '待审查' ||
                o.status == 'PENDING_REVIEW')
            .toList();
      case 1:
        return orders
            .where((o) =>
                o.status == 'preparing' ||
                o.status == '备货中' ||
                o.status == 'PREPARING' ||
                o.status == 'reviewed' ||
                o.status == 'REVIEWED')
            .toList();
      case 2:
        return orders
            .where((o) =>
                o.status == 'dispatched' ||
                o.status == '已派单' ||
                o.status == 'DISPATCHED')
            .toList();
      case 3:
        return orders
            .where((o) =>
                o.status == 'completed' ||
                o.status == '已完成' ||
                o.status == 'COMPLETED')
            .toList();
      default:
        return orders;
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _filteredOrders = _filterOrdersByStatus(_allOrders, index);
    });
  }

  Future<void> _onAcceptOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('接单确认'),
        content: Text('确定要接收订单 #${order.orderNo} 吗？'),
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

    if (confirmed == true) {
      try {
        final warehouseId = ApiConfig.getWarehouseId();
        if (warehouseId != null) {
          await _warehouseService.acceptOrder(order.id!, warehouseId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('订单 #${order.orderNo} 已接收'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadOrders();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('接单失败: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 16),
                            _buildOrderListFromAPI(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderListFromAPI() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无订单数据',
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
          child: _buildOrderCardFromAPI(order),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCardFromAPI(OrderModel order) {
    final statusColor = _getStatusColor(order.status ?? '');

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
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '订单 #${order.orderNo ?? order.id}',
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
                    text: order.statusText,
                    type: _getBadgeType(order.status ?? ''),
                    fontSize: 10,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '等待',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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
                onTap: () => _makePhoneCall(order.contactPhone ?? ''),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items != null && order.items!.isNotEmpty) ...[
                  ...order.items!.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.productName ?? '未知产品'} ${item.productSpec ?? ''}',
                              style: AppTextStyles.caption,
                            ),
                            Text(
                              '× ${item.quantity ?? 0} 桶',
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
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
                        '共计 ${order.totalQuantity} 桶',
                        style: AppTextStyles.captionSmall,
                      ),
                      Text(
                        '¥ ${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    '暂无商品信息',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _viewOrderDetail(order),
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
              if (_selectedTabIndex == 0)
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
                          '接单',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_selectedTabIndex == 1)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _onDispatchOrder(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '派单出库',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'urgent':
      case '紧急':
        return AppColors.error;
      case 'priority':
      case '优先':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  BadgeType _getBadgeType(String status) {
    switch (status) {
      case 'urgent':
      case '紧急':
        return BadgeType.error;
      case 'priority':
      case '优先':
        return BadgeType.warning;
      default:
        return BadgeType.info;
    }
  }

  void _viewOrderDetail(OrderModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看订单 #${order.orderNo ?? order.id} 详情'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _onDispatchOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('派单出库'),
        content: Text('确认要为订单 ${order.orderNo ?? order.id} 派单出库吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认派单'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WarehouseDispatchSelectPage(
            orderId: order.id ?? '',
            orderNo: order.orderNo,
            stationName: order.stationName,
            productInfo: order.items != null
                ? '${order.items!.length}种商品，共${order.totalQuantity ?? 0}桶'
                : null,
          ),
        ),
      ).then((result) {
        if (result == true) {
          _loadOrders();
        }
      });
    }
  }

  void _makePhoneCall(String phone) {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('暂无联系电话'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    PhoneUtils.makePhoneCall(phone, context: context);
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
        children: [
          _buildTabItem('待接单 ($_pendingCount)', 0),
          _buildTabItem('备货中 ($_preparingCount)', 1),
          _buildTabItem('已派单 ($_dispatchedCount)', 2),
          _buildTabItem('已完成 ($_completedCount)', 3),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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
              onTap: () {},
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
}
