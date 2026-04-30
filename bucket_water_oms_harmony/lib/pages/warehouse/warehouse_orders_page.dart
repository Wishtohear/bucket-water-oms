import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';

class WarehouseOrdersPage extends StatefulWidget {
  const WarehouseOrdersPage({super.key});

  @override
  State<WarehouseOrdersPage> createState() => _WarehouseOrdersPageState();
}

class _WarehouseOrdersPageState extends State<WarehouseOrdersPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _pendingOrders = [
    {
      'id': '850021',
      'isUrgent': true,
      'priority': '紧急',
      'priorityColor': AppColors.error,
      'product': '18.9L 桶装水 × 50 桶',
      'product2': '11.3L 迷你桶 × 20 桶',
      'customer': '张记旗舰水站',
      'address': '桂林市秀峰区XX路XX号',
      'phone': '',
      'totalQuantity': 70,
      'amount': 1850.00,
      'distance': '1.2km',
      'deliveryTime': '25分钟',
      'waitTime': '12分钟',
    },
    {
      'id': '850022',
      'isUrgent': false,
      'priority': '普通',
      'priorityColor': AppColors.primary,
      'product': '18.9L 桶装水 × 30 桶',
      'product2': '',
      'customer': '王记纯净水站',
      'address': '桂林市象山区XX路XX号',
      'phone': '',
      'totalQuantity': 30,
      'amount': 750.00,
      'distance': '3.5km',
      'deliveryTime': '40分钟',
      'waitTime': '5分钟',
    },
    {
      'id': '850023',
      'isUrgent': false,
      'priority': '优先',
      'priorityColor': AppColors.warning,
      'product': '18.9L 桶装水 × 100 桶',
      'product2': '空桶回收 × 80 个',
      'customer': '李老板水站',
      'address': '桂林市七星区XX路XX号',
      'phone': '',
      'totalQuantity': 100,
      'amount': 2500.00,
      'distance': '5.8km',
      'deliveryTime': '55分钟',
      'waitTime': '8分钟',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: SingleChildScrollView(
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
    final tabs = [
      {'label': '待接单 (5)', 'index': 0},
      {'label': '备货中 (3)', 'index': 1},
      {'label': '已派单 (8)', 'index': 2},
      {'label': '已完成', 'index': 3},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTabIndex == tab['index'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = tab['index'] as int;
                });
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
                  tab['label'] as String,
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

  Widget _buildOrderList() {
    return Column(
      children: _pendingOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isUrgent = order['isUrgent'] as bool;
    final hasSecondProduct = (order['product2'] as String).isNotEmpty;

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
                      color: order['priorityColor'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '订单 #${order['id']}',
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
                    text: order['priority'] as String,
                    type: isUrgent ? BadgeType.error : BadgeType.info,
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
                      '等待 ${order['waitTime']}',
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
                    Text(
                      order['product'] as String,
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      '× ${order['totalQuantity']} 桶',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (hasSecondProduct) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['product2'] as String,
                        style: AppTextStyles.caption,
                      ),
                    ],
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
                      '共计 ${order['totalQuantity']} 桶',
                      style: AppTextStyles.captionSmall,
                    ),
                    Text(
                      '¥ ${(order['amount'] as double).toStringAsFixed(2)}',
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '距此 ${order['distance']} | 预计配送 ${order['deliveryTime']}',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
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
            ],
          ),
        ],
      ),
    );
  }

  void _onAcceptOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('接单确认'),
        content: Text('确定要接收订单 #${order['id']} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('订单 #${order['id']} 已接收'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('确认接单'),
          ),
        ],
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
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
