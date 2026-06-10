import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/components/status_badge.dart';
import '../../models/order_model.dart';
import '../../services/warehouse_service.dart';
import 'warehouse_order_detail_page.dart';
import 'warehouse_dispatch_select_page.dart';

class WarehouseOutboundPage extends StatefulWidget {
  const WarehouseOutboundPage({super.key});

  @override
  State<WarehouseOutboundPage> createState() => _WarehouseOutboundPageState();
}

class _WarehouseOutboundPageState extends State<WarehouseOutboundPage> {
  final TextEditingController _searchController = TextEditingController();
  final WarehouseService _warehouseService = WarehouseService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['待派单', '配送中', '已完成'];
  final List<List<String>> _tabStatuses = [
    ['preparing', 'PREPARING', '备货中'],
    ['dispatched', 'DISPATCHED', '已派单'],
    ['completed', 'COMPLETED', '已完成'],
  ];

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

  List<OrderModel> _filterOrdersByStatus(List<OrderModel> orders, int tabIndex) {
    final statuses = _tabStatuses[tabIndex];
    return orders.where((order) {
      return statuses.contains(order.status);
    }).toList();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _filteredOrders = _filterOrdersByStatus(_allOrders, index);
    });
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知时间';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
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
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    if (_filteredOrders.isEmpty) {
      return _buildEmptyState();
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
    final statusText = _getStatusText(order.status ?? '');
    final statusColor = _getStatusColor(order.status ?? '');

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
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
                      '订单号: ${order.orderNo ?? order.id ?? ''}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.stationName ?? '未知水站',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: statusText,
                type: _getBadgeType(order.status ?? ''),
                fontSize: 10,
              ),
            ],
          ),
          if (order.items != null && order.items!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...order.items!.take(2).map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${product.productName ?? '未知产品'}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'x ${product.quantity ?? 0}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )),
            if (order.items!.length > 2)
              Text(
                '... 共 ${order.items!.length} 种商品',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
          ],
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateTime(order.createdAt),
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  _buildActionButton(
                    text: '查看详情',
                    isPrimary: false,
                    onTap: () => _viewOrderDetail(order),
                  ),
                  if (_selectedTabIndex == 0) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      text: '派单出库',
                      isPrimary: true,
                      onTap: () => _onDispatchOrder(order),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.bgInput,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          text,
          style: AppTextStyles.captionSmall.copyWith(
            color: isPrimary ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
      case 'PENDING':
        return '待接单';
      case 'preparing':
      case 'PREPARING':
        return '备货中';
      case 'dispatched':
      case 'DISPATCHED':
        return '配送中';
      case 'completed':
      case 'COMPLETED':
        return '已完成';
      default:
        return status ?? '未知';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'PENDING':
        return AppColors.warning;
      case 'preparing':
      case 'PREPARING':
        return AppColors.primary;
      case 'dispatched':
      case 'DISPATCHED':
        return AppColors.success;
      case 'completed':
      case 'COMPLETED':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  BadgeType _getBadgeType(String status) {
    switch (status) {
      case 'pending':
      case 'PENDING':
        return BadgeType.warning;
      case 'preparing':
      case 'PREPARING':
        return BadgeType.primary;
      case 'dispatched':
      case 'DISPATCHED':
        return BadgeType.success;
      case 'completed':
      case 'COMPLETED':
        return BadgeType.success;
      default:
        return BadgeType.info;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
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
          const SizedBox(height: 8),
          Text(
            '当前没有需要处理的订单',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WarehouseOrderDetailPage(order: order),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '订单管理',
              style: AppTextStyles.h3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          _tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index == _selectedTabIndex
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: index == _selectedTabIndex
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: index == _selectedTabIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
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
                hintText: '搜索订单号/客户名称',
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
