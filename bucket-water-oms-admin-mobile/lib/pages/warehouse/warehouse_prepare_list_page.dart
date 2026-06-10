import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';
import '../../models/order_model.dart';
import '../../services/warehouse_service.dart';

class WarehousePrepareListPage extends StatefulWidget {
  const WarehousePrepareListPage({super.key});

  @override
  State<WarehousePrepareListPage> createState() => _WarehousePrepareListPageState();
}

class _WarehousePrepareListPageState extends State<WarehousePrepareListPage> {
  int _selectedFilterIndex = 0;
  final WarehouseService _warehouseService = WarehouseService();
  
  List<OrderModel> _preparingOrders = [];
  bool _isLoading = false;

  final List<String> _filters = ['全部', '备货中', '待派单', '已派单'];

  @override
  void initState() {
    super.initState();
    _loadPreparingOrders();
  }

  Future<void> _loadPreparingOrders() async {
    setState(() => _isLoading = true);
    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId != null && warehouseId.isNotEmpty) {
        final orders = await _warehouseService.getOrders(warehouseId);
        setState(() {
          _preparingOrders = orders.where((order) {
            final status = order.status?.toLowerCase() ?? '';
            return status.contains('preparing') || 
                   status.contains('pending') ||
                   status.contains('dispatched');
          }).toList();
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
            content: Text('加载备货列表失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<OrderModel> _getFilteredOrders() {
    if (_selectedFilterIndex == 0) {
      return _preparingOrders;
    }
    
    return _preparingOrders.where((order) {
      final status = order.status?.toLowerCase() ?? '';
      switch (_selectedFilterIndex) {
        case 1:
          return status.contains('preparing');
        case 2:
          return status.contains('pending');
        case 3:
          return status.contains('dispatched');
        default:
          return true;
      }
    }).toList();
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildFilterTabs(),
                          const SizedBox(height: 16),
                          _buildOrderList(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WarehouseBottomBar(
        currentIndex: 1,
        onTap: (index) {},
      ),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '备货中 (${_preparingOrders.length})',
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
          _buildTabItem('待接单', 0),
          _buildTabItem('备货中', 1),
          _buildTabItem('已派单', 2),
          _buildTabItem('已完成', 3),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(
              color: index == 1 ? AppColors.primary : AppColors.textSecondary,
              fontWeight: index == 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _filters[index],
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderList() {
    final filteredOrders = _getFilteredOrders();
    
    if (filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无备货订单',
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
      children: filteredOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final status = order.status ?? '';
    final isPreparing = status.toLowerCase().contains('preparing');
    final isPendingDispatch = status.toLowerCase().contains('pending') && !isPreparing;
    final isDispatched = status.toLowerCase().contains('dispatched');

    Color statusColor = AppColors.primary;
    BadgeType badgeType = BadgeType.info;
    
    if (isPreparing) {
      statusColor = AppColors.primary;
      badgeType = BadgeType.info;
    } else if (isPendingDispatch) {
      statusColor = AppColors.warning;
      badgeType = BadgeType.warning;
    } else if (isDispatched) {
      statusColor = AppColors.success;
      badgeType = BadgeType.success;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      borderColor: isPreparing ? AppColors.primary.withOpacity(0.2) : null,
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
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge(
                    text: order.statusText,
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
                        '共计 ${order.totalQuantity ?? 0} 桶',
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
                  onTap: () => _onPrintOrder(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.print,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDispatched ? '打印配送单' : '打印备货单',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
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
                  onTap: isDispatched ? null : () => _onSelectDriver(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDispatched ? AppColors.bgInput : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: isDispatched
                              ? AppColors.textTertiary
                              : AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDispatched ? '已派单' : '选择司机',
                          style: AppTextStyles.caption.copyWith(
                            color: isDispatched
                                ? AppColors.textTertiary
                                : AppColors.white,
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

  void _onPrintOrder(OrderModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在打印备货单...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onSelectDriver(OrderModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('选择司机功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
