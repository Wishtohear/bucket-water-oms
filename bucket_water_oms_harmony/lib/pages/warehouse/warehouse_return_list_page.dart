import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';

class WarehouseReturnListPage extends StatefulWidget {
  const WarehouseReturnListPage({super.key});

  @override
  State<WarehouseReturnListPage> createState() => _WarehouseReturnListPageState();
}

class _WarehouseReturnListPageState extends State<WarehouseReturnListPage> {
  int _selectedTabIndex = 0;
  final List<Map<String, dynamic>> _returnOrders = [
    {
      'id': 'RT2026042101',
      'waitTime': '8分钟',
      'driverName': '张小龙',
      'driverCode': 'DRV-2024-001',
      'todayDeliveries': '8 单',
      'orderId': '850018',
      'deliveryTime': '14:25',
      'reportBucketCount': 68,
      'oweBucketCount': 2,
      'replenishRequest': '18.9L×20 桶',
      'status': 'pending',
      'statusColor': AppColors.error,
    },
    {
      'id': 'RT2026042102',
      'waitTime': '15分钟',
      'driverName': '刘师傅',
      'driverCode': 'DRV-2024-003',
      'todayDeliveries': '6 单',
      'orderId': '850016',
      'deliveryTime': '13:40',
      'reportBucketCount': 45,
      'oweBucketCount': 0,
      'replenishRequest': '',
      'status': 'pending',
      'statusColor': AppColors.warning,
    },
    {
      'id': 'RT2026042103',
      'waitTime': '3分钟',
      'driverName': '陈司机',
      'driverCode': 'DRV-2024-005',
      'todayDeliveries': '5 单',
      'orderId': '850015',
      'deliveryTime': '13:15',
      'reportBucketCount': 30,
      'oweBucketCount': 5,
      'replenishRequest': '',
      'status': 'pending',
      'statusColor': AppColors.purple,
    },
  ];

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
                    _buildReturnList(),
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
            '回仓核对',
            style: AppTextStyles.h3,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '3 待核对',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          _buildTabItem('待核对 (3)', 0),
          _buildTabItem('已核对 (12)', 1),
          _buildTabItem('差异记录', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
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
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(
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
    );
  }

  Widget _buildReturnList() {
    return Column(
      children: _returnOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReturnCard(order),
        );
      }).toList(),
    );
  }

  Widget _buildReturnCard(Map<String, dynamic> order) {
    final hasOweBucket = (order['oweBucketCount'] as int) > 0;
    final hasReplenish = (order['replenishRequest'] as String).isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      borderColor: order['statusColor'] as Color,
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
                    '回仓申请 #${order['id']}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '等待 ${order['waitTime']}',
                  style: AppTextStyles.captionSmall,
                ),
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
                    const SizedBox(height: 2),
                    Text(
                      '工号: ${order['driverCode']} | 今日配送 ${order['todayDeliveries']}',
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '配送订单',
                      style: AppTextStyles.captionSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${order['orderId']}',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.borderLight,
                ),
                Column(
                  children: [
                    Text(
                      '送达时间',
                      style: AppTextStyles.captionSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['deliveryTime'] as String,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '司机上报回收空桶',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                Text(
                  '${order['reportBucketCount']} 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasOweBucket
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      hasOweBucket
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: hasOweBucket ? AppColors.warning : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '其中欠桶',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                Text(
                  '${order['oweBucketCount']} 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: hasOweBucket ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (hasReplenish) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping,
                        color: AppColors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '申请补货',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Text(
                    order['replenishRequest'] as String,
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onCheckBucket(order),
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
                    child: Text(
                      '核对空桶',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _onPrintReturn(order),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.print,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCheckBucket(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('进入空桶核对流程...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onPrintReturn(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在打印回仓单...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
