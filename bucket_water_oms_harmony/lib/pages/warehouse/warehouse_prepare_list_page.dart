import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';

class WarehousePrepareListPage extends StatefulWidget {
  const WarehousePrepareListPage({super.key});

  @override
  State<WarehousePrepareListPage> createState() => _WarehousePrepareListPageState();
}

class _WarehousePrepareListPageState extends State<WarehousePrepareListPage> {
  int _selectedFilterIndex = 0;
  final List<Map<String, dynamic>> _preparingOrders = [
    {
      'id': '850018',
      'status': 'preparing',
      'statusText': '备货中',
      'statusColor': AppColors.primary,
      'waitTime': '25分钟',
      'customer': '张记旗舰水站',
      'address': '桂林市秀峰区XX路XX号',
      'products': [
        {'name': '18.9L 桶装水', 'quantity': '50 桶'},
        {'name': '11.3L 迷你桶', 'quantity': '20 桶'},
      ],
      'totalQuantity': 70,
      'preparedQuantity': 50,
      'deliveryTime': '14:00',
      'deliveryDuration': '25分钟',
      'driverName': '张小龙',
      'driverStatus': '正在前往仓库取货',
    },
    {
      'id': '850019',
      'status': 'pending_dispatch',
      'statusText': '待派单',
      'statusColor': AppColors.warning,
      'waitTime': '',
      'customer': '王记纯净水站',
      'address': '桂林市象山区XX路XX号',
      'products': [
        {'name': '18.9L 桶装水', 'quantity': '30 桶'},
      ],
      'totalQuantity': 30,
      'preparedQuantity': 30,
      'deliveryTime': '15:30',
      'distance': '3.5km',
      'driverName': '',
      'driverStatus': '',
    },
    {
      'id': '850020',
      'status': 'dispatched',
      'statusText': '已派单',
      'statusColor': AppColors.success,
      'waitTime': '',
      'customer': '李老板水站',
      'address': '桂林市七星区XX路XX号',
      'products': [
        {'name': '18.9L 桶装水', 'quantity': '100 桶'},
        {'name': '空桶回收', 'quantity': '80 个'},
      ],
      'totalQuantity': 100,
      'preparedQuantity': 100,
      'deliveryTime': '',
      'distance': '',
      'driverName': '张小龙',
      'driverStatus': '正在前往仓库取货',
    },
  ];

  final List<String> _filters = ['全部 (3)', '备货中', '待派单', '已派单'];

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
              child: SingleChildScrollView(
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
          const Text(
            '备货中',
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
          _buildTabItem('待接单 (5)', 0),
          _buildTabItem('备货中 (3)', 1),
          _buildTabItem('已派单 (8)', 2),
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
    return Column(
      children: _preparingOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final isPreparing = status == 'preparing';
    final isPendingDispatch = status == 'pending_dispatch';
    final isDispatched = status == 'dispatched';

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
                      color: order['statusColor'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '订单 #${order['id']}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge(
                    text: order['statusText'] as String,
                    type: isPreparing
                        ? BadgeType.info
                        : isPendingDispatch
                            ? BadgeType.warning
                            : BadgeType.success,
                    fontSize: 10,
                  ),
                  if (order['waitTime'].toString().isNotEmpty) ...[
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
                        '已等待 ${order['waitTime']}',
                        style: AppTextStyles.captionSmall,
                      ),
                    ),
                  ],
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
                      order['customer'] as String,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '地址: ${order['address']}',
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
                ...(order['products'] as List<Map<String, dynamic>>).map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['name'] as String,
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          '× ${product['quantity']}',
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '备货进度: ${order['preparedQuantity']}/${order['totalQuantity']} 已完成',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isDispatched && (order['driverName'] as String).isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
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
                          order['driverName'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order['driverStatus'] as String,
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
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
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '预约配送',
                          style: AppTextStyles.captionSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['deliveryTime'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isDispatched ? '配送距离' : '预计配送时长',
                          style: AppTextStyles.captionSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDispatched
                              ? order['distance'] as String
                              : order['deliveryDuration'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  void _onPrintOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在打印备货单...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onSelectDriver(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('选择司机功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
