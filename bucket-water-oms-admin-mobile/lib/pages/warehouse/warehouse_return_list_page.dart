import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/phone_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../models/warehouse_return_model.dart';
import '../../services/warehouse_return_service.dart';
import 'warehouse_return_check_page.dart';

class WarehouseReturnListPage extends StatefulWidget {
  const WarehouseReturnListPage({super.key});

  @override
  State<WarehouseReturnListPage> createState() =>
      _WarehouseReturnListPageState();
}

class _WarehouseReturnListPageState extends State<WarehouseReturnListPage> {
  int _selectedTabIndex = 0;
  final WarehouseReturnService _returnService = WarehouseReturnService();

  List<ReturnCheckModel> _returnOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReturnList();
  }

  Future<void> _loadReturnList() async {
    setState(() => _isLoading = true);
    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId != null && warehouseId.isNotEmpty) {
        final status = _getStatusByIndex(_selectedTabIndex);
        final list = await _returnService.getReturnList(
          warehouseId,
          status: status,
        );
        setState(() {
          _returnOrders = list;
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
            content: Text('加载回仓列表失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getStatusByIndex(int index) {
    switch (index) {
      case 0:
        return 'pending';
      case 1:
        return 'checked';
      case 2:
        return 'disputed';
      default:
        return 'pending';
    }
  }

  Future<void> _onCheckBucket(ReturnCheckModel order) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WarehouseReturnCheckPage(returnId: order.id ?? order.returnNo),
      ),
    ).then((_) => _loadReturnList());
  }

  Future<void> _onRefresh() async {
    await _loadReturnList();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _loadReturnList();
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
                            _buildReturnListFromAPI(),
                            const SizedBox(height: 100),
                          ],
                        ),
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
              '${_returnOrders.length} 待核对',
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
          _buildTabItem('待核对', 0),
          _buildTabItem('已核对', 1),
          _buildTabItem('差异记录', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return Expanded(
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

  Widget _buildReturnListFromAPI() {
    return Column(
      children: _returnOrders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReturnCardFromAPI(order),
        );
      }).toList(),
    );
  }

  Widget _buildReturnCardFromAPI(ReturnCheckModel order) {
    final hasOweBucket = (order.owedBuckets ?? 0) > 0;
    final hasReplenish = (order.replenishmentRequest ?? '').isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      borderColor: _getStatusColor(order.status ?? ''),
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
                      color: _getStatusColor(order.status ?? ''),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '回仓申请 #${order.returnNo ?? order.id}',
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
                  '等待 ${order.waitTimeText}',
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
                      order.driverName ?? '未知司机',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '工号: ${order.driverCode ?? '未知'} | 今日配送',
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final phone = order.phone;
                  if (phone != null && phone.isNotEmpty) {
                    PhoneUtils.makePhoneCall(phone, context: context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('暂无联系电话'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
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
                      '#${order.orderNo ?? order.orderId ?? '未知'}',
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
                      _formatTime(order.deliveryTime),
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
                  '${order.reportedBuckets ?? 0} 个',
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
                      color:
                          hasOweBucket ? AppColors.warning : AppColors.success,
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
                  '${order.owedBuckets ?? 0} 个',
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
                    order.replenishmentRequest ?? '',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.error;
      case 'checked':
        return AppColors.success;
      case 'disputed':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _onPrintReturn(ReturnCheckModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在打印回仓单...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
