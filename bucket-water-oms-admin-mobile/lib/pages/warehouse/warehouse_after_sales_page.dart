import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/phone_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';
import '../../models/after_sales_model.dart';
import '../../services/after_sales_service.dart';
import 'warehouse_after_sales_detail_page.dart';

class WarehouseAfterSalesPage extends StatefulWidget {
  const WarehouseAfterSalesPage({super.key});

  @override
  State<WarehouseAfterSalesPage> createState() =>
      _WarehouseAfterSalesPageState();
}

class _WarehouseAfterSalesPageState extends State<WarehouseAfterSalesPage> {
  int _selectedTabIndex = 0;
  final AfterSalesService _afterSalesService = AfterSalesService();

  List<AfterSalesModel> _afterSalesList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAfterSalesList();
  }

  Future<void> _loadAfterSalesList() async {
    setState(() => _isLoading = true);
    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId != null && warehouseId.isNotEmpty) {
        final status = _getStatusByIndex(_selectedTabIndex);
        final list = await _afterSalesService.getWarehouseAfterSalesList(
          warehouseId,
          status: status,
        );
        setState(() {
          _afterSalesList = list;
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
            content: Text('加载售后列表失败: $e'),
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
        return 'processing';
      case 2:
        return 'completed';
      default:
        return 'pending';
    }
  }

  Future<void> _onRefresh() async {
    await _loadAfterSalesList();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _loadAfterSalesList();
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
                            _buildAfterSalesListFromAPI(),
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
            '售后处理',
            style: AppTextStyles.h3,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_afterSalesList.length} 待处理',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.warning,
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
          _buildTabItem('待处理', 0),
          _buildTabItem('处理中', 1),
          _buildTabItem('已完成', 2),
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

  Widget _buildAfterSalesListFromAPI() {
    return Column(
      children: _afterSalesList.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAfterSalesCardFromAPI(item),
        );
      }).toList(),
    );
  }

  Widget _buildAfterSalesCardFromAPI(AfterSalesModel item) {
    final isPending = item.isPending;
    final isReplenish = item.type == 'replenish' || item.type == '补货';
    final typeColor = _getTypeColor(item.type ?? '');

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      borderColor: isPending ? typeColor.withOpacity(0.3) : null,
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
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '售后单 #${item.afterSalesNo ?? item.id}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge(
                    text: item.typeText,
                    type: isReplenish ? BadgeType.warning : BadgeType.error,
                    fontSize: 10,
                  ),
                  if (item.waitTimeText.isNotEmpty) ...[
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
                        '等待 ${item.waitTimeText}',
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
                      item.stationName ?? '未知水站',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '地址: ${item.stationAddress ?? '暂无地址'}',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '关联订单: #${item.orderNo ?? item.orderId ?? '未知'}',
                  style: AppTextStyles.captionSmall,
                ),
                const SizedBox(height: 8),
                if (item.items != null && item.items!.isNotEmpty) ...[
                  ...item.items!.map((issue) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            issue.productName ?? '未知产品',
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            issue.issueText,
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  Text(
                    '暂无问题明细',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if ((item.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: typeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '原因: ${item.reason}',
                      style: AppTextStyles.caption.copyWith(
                        color: typeColor == AppColors.error
                            ? const Color(0xFFB45309)
                            : typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if ((item.handleResult ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '处理结果: ${item.handleResult}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onProcessOrder(item),
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
                      child: Text(
                        '处理申请',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onViewDetail(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '查看详情',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  final phone = item.phone;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone,
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'replenish':
      case '补货':
        return AppColors.warning;
      case 'quality':
      case '质量':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  void _onProcessOrder(AfterSalesModel item) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('处理售后单 #${item.afterSalesNo ?? item.id}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onViewDetail(AfterSalesModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WarehouseAfterSalesDetailPage(
            afterSalesId: item.id ?? item.afterSalesNo),
      ),
    ).then((_) => _loadAfterSalesList());
  }
}
