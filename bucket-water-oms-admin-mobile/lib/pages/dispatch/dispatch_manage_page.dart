import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';

class DispatchManagePage extends StatefulWidget {
  const DispatchManagePage({super.key});

  @override
  State<DispatchManagePage> createState() => _DispatchManagePageState();
}

class _DispatchManagePageState extends State<DispatchManagePage> {
  int _selectedTab = 0;
  final int _currentBottomIndex = 0;

  final List<Map<String, dynamic>> _pendingOrders = [
    {
      'id': '850021',
      'isUrgent': true,
      'product': '18.9L 桶装水 × 5 桶',
      'customer': '王大拿',
      'phone': '138****8888',
      'address': '幸福小区12号楼2单元301',
      'distance': '1.2km',
    },
    {
      'id': '850022',
      'isUrgent': false,
      'product': '550ml 瓶装水 × 2 箱',
      'customer': '李美丽',
      'phone': '135****6666',
      'address': '阳光嘉园8号楼1单元1502',
      'distance': '3.5km',
    },
  ];

  final List<Map<String, dynamic>> _drivers = [
    {
      'name': '张小龙',
      'status': '空闲中',
      'statusColor': AppColors.success,
      'distance': '0.5km',
      'isOnline': true,
    },
    {
      'name': '刘师傅',
      'status': '配送中 (剩余2单)',
      'statusColor': AppColors.primary,
      'distance': '',
      'isOnline': true,
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
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: OwnerBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) => _onBottomTabTapped(index),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            '配送调度',
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
          _buildTabItem('待分派 (5)', 0),
          _buildTabItem('配送中 (12)', 1),
          _buildTabItem('已送达', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapPlaceholder(),
          const SizedBox(height: 20),
          _buildPendingOrdersSection(),
          const SizedBox(height: 20),
          _buildDriverStatusSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      borderColor: AppColors.primary.withOpacity(0.2),
      child: Stack(
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: AppColors.bgInput,
                child: const Center(
                  child: Icon(
                    Icons.map,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '查看实时位置分布',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '待分派订单',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _pendingOrders.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCard(_pendingOrders[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isUrgent = order['isUrgent'] as bool;
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
                      color: isUrgent ? AppColors.warning : AppColors.primary,
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
              StatusBadge(
                text: isUrgent ? '紧急' : '普通',
                type: isUrgent ? BadgeType.warning : BadgeType.info,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isUrgent ? Icons.water_drop : Icons.local_drink,
                  color: isUrgent ? AppColors.primary : AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['product'],
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '客户: ${order['customer']} | ${order['phone']}',
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
            ],
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
              Expanded(
                child: Text(
                  '${order['address']} (距此 ${order['distance']})',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '立即派单',
                  onPressed: () => _onDispatchOrder(order),
                  fontSize: 12,
                  height: 36,
                ),
              ),
              const SizedBox(width: 8),
              AppIconButton(
                icon: Icons.phone,
                onPressed: () => _onCallCustomer(order),
                backgroundColor: AppColors.bgInput,
                iconColor: AppColors.textSecondary,
                size: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusSection() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '配送员状态',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '在线 3 / 4',
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _drivers.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDriverItem(_drivers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverItem(Map<String, dynamic> driver) {
    final borderColor = driver['statusColor'] as Color;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgInput,
            ),
            child: const Icon(
              Icons.person,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver['name'],
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                driver['statusColor'] == AppColors.success
                    ? '${driver['status']} · 距离 ${driver['distance']}'
                    : driver['status'],
                style: AppTextStyles.captionSmall.copyWith(
                  color: driver['statusColor'],
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  void _onBottomTabTapped(int index) {
    // Handle bottom navigation
  }

  void _onDispatchOrder(Map<String, dynamic> order) {
    // Handle dispatch order
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('派单'),
        content: Text('确定要为订单 #${order['id']} 派单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Dispatch order logic
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _onCallCustomer(Map<String, dynamic> order) {
    // Handle call customer
  }
}
