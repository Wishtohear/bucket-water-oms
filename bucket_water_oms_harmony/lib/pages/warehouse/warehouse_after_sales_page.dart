import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';

class WarehouseAfterSalesPage extends StatefulWidget {
  const WarehouseAfterSalesPage({super.key});

  @override
  State<WarehouseAfterSalesPage> createState() => _WarehouseAfterSalesPageState();
}

class _WarehouseAfterSalesPageState extends State<WarehouseAfterSalesPage> {
  int _selectedTabIndex = 0;
  final List<Map<String, dynamic>> _afterSalesList = [
    {
      'id': 'AS2026042101',
      'type': 'replenish',
      'typeText': '补货申请',
      'typeColor': AppColors.warning,
      'waitTime': '30分钟',
      'customer': '张记旗舰水站',
      'address': '桂林市秀峰区XX路XX号',
      'orderId': '850018',
      'issues': [
        {'name': '18.9L 桶装水', 'problem': '缺少 3 桶'},
        {'name': '11.3L 迷你桶', 'problem': '缺少 2 桶'},
      ],
      'reason': '配送时数量不足，水站投诉',
      'status': 'pending',
      'result': '',
    },
    {
      'id': 'AS2026042102',
      'type': 'quality',
      'typeText': '质量问题',
      'typeColor': AppColors.error,
      'waitTime': '45分钟',
      'customer': '王记纯净水站',
      'address': '桂林市象山区XX路XX号',
      'orderId': '850015',
      'issues': [
        {'name': '18.9L 桶装水', 'problem': '质量问题 5 桶'},
      ],
      'reason': '客户反映水质有异味，要求更换',
      'status': 'pending',
      'result': '',
    },
    {
      'id': 'AS2026042003',
      'type': 'replenish',
      'typeText': '已完成',
      'typeColor': AppColors.success,
      'waitTime': '',
      'customer': '李老板水站',
      'address': '桂林市七星区XX路XX号',
      'orderId': '850010',
      'issues': [
        {'name': '空桶回收', 'problem': '缺少 3 个'},
      ],
      'reason': '',
      'status': 'completed',
      'result': '已补发 3 个空桶',
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
                    _buildAfterSalesList(),
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
              '2 待处理',
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
          _buildTabItem('待处理 (2)', 0),
          _buildTabItem('处理中 (1)', 1),
          _buildTabItem('已完成 (15)', 2),
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

  Widget _buildAfterSalesList() {
    return Column(
      children: _afterSalesList.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAfterSalesCard(item),
        );
      }).toList(),
    );
  }

  Widget _buildAfterSalesCard(Map<String, dynamic> item) {
    final isPending = item['status'] == 'pending';
    final isReplenish = item['type'] == 'replenish';
    final typeColor = item['typeColor'] as Color;

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
                    '售后单 #${item['id']}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge(
                    text: item['typeText'] as String,
                    type: isReplenish ? BadgeType.warning : BadgeType.error,
                    fontSize: 10,
                  ),
                  if (item['waitTime'].toString().isNotEmpty) ...[
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
                        '等待 ${item['waitTime']}',
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
                      item['customer'] as String,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '地址: ${item['address']}',
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
                  '关联订单: #${item['orderId']}',
                  style: AppTextStyles.captionSmall,
                ),
                const SizedBox(height: 8),
                ...(item['issues'] as List<Map<String, dynamic>>).map((issue) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          issue['name'] as String,
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          issue['problem'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          if (item['reason'].toString().isNotEmpty) ...[
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
                      '原因: ${item['reason']}',
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
          if (item['result'].toString().isNotEmpty) ...[
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
                    '处理结果: ${item['result']}',
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
                onTap: () {},
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

  void _onProcessOrder(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('处理售后单 #${item['id']}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onViewDetail(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看售后单 #${item['id']}详情...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
