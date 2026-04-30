import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class AdminWarehouseDetailPage extends StatelessWidget {
  final Map<String, dynamic> warehouse;

  const AdminWarehouseDetailPage({
    super.key,
    required this.warehouse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '仓库详情',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _showComingSoon('编辑'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 16),
            _buildInventoryOverview(),
            const SizedBox(height: 16),
            _buildInventoryList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warehouse,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse['name'] ?? '未知仓库',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建时间: 2024-01-01',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (warehouse['statusColor'] as Color?)?.withOpacity(0.1) ?? AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  warehouse['status'] ?? '正常运营',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: warehouse['statusColor'] ?? AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('负责人', warehouse['manager'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('联系电话', warehouse['phone'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('详细地址', warehouse['location'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('仓库容量', '${warehouse['capacity']} 单位'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryOverview() {
    final usageRate = ((warehouse['currentStock'] as int) / (warehouse['capacity'] as int) * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '库存概览',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildOverviewCard(
                        '当前库存',
                        '${warehouse['currentStock']}',
                        '单位',
                        AppColors.primary,
                        Icons.inventory_2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewCard(
                        '库容使用率',
                        '$usageRate',
                        '%',
                        usageRate > 90 ? AppColors.error : usageRate > 70 ? AppColors.warning : AppColors.success,
                        Icons.pie_chart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewCard(
                        '今日入库',
                        '1,250',
                        '单位',
                        AppColors.success,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewCard(
                        '今日出库',
                        '980',
                        '单位',
                        AppColors.orange,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildOverviewCard(
                            '当前库存',
                            '${warehouse['currentStock']}',
                            '单位',
                            AppColors.primary,
                            Icons.inventory_2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOverviewCard(
                            '库容使用率',
                            '$usageRate',
                            '%',
                            usageRate > 90 ? AppColors.error : usageRate > 70 ? AppColors.warning : AppColors.success,
                            Icons.pie_chart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildOverviewCard(
                            '今日入库',
                            '1,250',
                            '单位',
                            AppColors.success,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOverviewCard(
                            '今日出库',
                            '980',
                            '单位',
                            AppColors.orange,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '库容使用情况',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${warehouse['currentStock']} / ${warehouse['capacity']}',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: warehouse['currentStock'] / warehouse['capacity'],
                  backgroundColor: AppColors.bgCard,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    usageRate > 90 ? AppColors.error : usageRate > 70 ? AppColors.warning : AppColors.success,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String label, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.h3.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    final items = [
      {'name': '18L 桶装纯净水', 'category': '桶装水', 'stock': 12500, 'safeStock': 2000, 'status': '充足'},
      {'name': '550ml 瓶装矿泉水 (24瓶/箱)', 'category': '瓶装水', 'stock': 840, 'safeStock': 1000, 'status': '告警'},
      {'name': '4.5L 家庭装纯净水 (4桶/箱)', 'category': '一次性桶装水', 'stock': 2100, 'safeStock': 500, 'status': '充足'},
      {'name': '空桶回收', 'category': '周转用品', 'stock': 4200, 'safeStock': 1000, 'status': '充足'},
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    '产品名称',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    '当前库存',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  child: Text(
                    '安全库存',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  child: Text(
                    '状态',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildInventoryRow(item)),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(Map<String, dynamic> item) {
    final statusColor = item['status'] == '充足' ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['category'],
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item['stock']}',
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${item['safeStock']}',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['status'],
                  style: AppTextStyles.captionSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    // ignore: avoid_print
    print('$feature 功能开发中');
  }
}
