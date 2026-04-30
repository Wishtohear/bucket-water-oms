import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class AdminStationDetailPage extends StatelessWidget {
  final Map<String, dynamic> station;

  const AdminStationDetailPage({
    super.key,
    required this.station,
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
          '水站详情',
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
            _buildAccountInfo(),
            const SizedBox(height: 16),
            _buildPolicyConfig(),
            const SizedBox(height: 16),
            _buildOperationData(),
            const SizedBox(height: 16),
            _buildRecentOrders(),
            const SizedBox(height: 16),
            _buildStaffAccounts(),
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
                  Icons.store,
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
                      station['name'] ?? '未知水站',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建时间: 2024-01-15',
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  station['status'] ?? '正常运营',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: station['statusColor'] ?? AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('联系人', station['contact'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('联系电话', station['phone'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('详细地址', station['address'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('负责仓库', '中心仓库 A库区'),
          const SizedBox(height: 12),
          _buildInfoRow('服务区域', '滨江区全域'),
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

  Widget _buildAccountInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '账户与财务',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '调整余额',
                type: AppButtonType.outline,
                onPressed: () => _showComingSoon('调整余额'),
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildAccountCard('预存金余额', '¥ ${(station['balance'] ?? 0).toStringAsFixed(2)}', AppColors.primary, Icons.account_balance_wallet)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('信用额度', '¥ 10,000.00', AppColors.purple, Icons.credit_card)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('押金桶数量', '200 个', AppColors.warning, Icons.inventory_2)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('当前欠桶', '${station['debtBuckets']} 个', AppColors.error, Icons.warning_amber)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildAccountCard('预存金余额', '¥ ${(station['balance'] ?? 0).toStringAsFixed(2)}', AppColors.primary, Icons.account_balance_wallet)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAccountCard('信用额度', '¥ 10,000.00', AppColors.purple, Icons.credit_card)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildAccountCard('押金桶数量', '200 个', AppColors.warning, Icons.inventory_2)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAccountCard('当前欠桶', '${station['debtBuckets']} 个', AppColors.error, Icons.warning_amber)),
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
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欠桶预警',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '当前欠桶数(${station['debtBuckets']})超过阈值(30)，请及时补缴押金',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.error.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyConfig() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '销售政策配置',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '修改政策',
                type: AppButtonType.outline,
                onPressed: () => _showComingSoon('修改政策'),
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildPolicyItem('账期类型', '月结')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPolicyItem('预存金要求', '¥ 5,000.00')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPolicyItem('欠桶阈值', '30 个')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPolicyItem('每桶押金', '¥ 20.00')),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildPolicyItem('账期类型', '月结')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPolicyItem('预存金要求', '¥ 5,000.00')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildPolicyItem('欠桶阈值', '30 个')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPolicyItem('每桶押金', '¥ 20.00')),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            '独立定价',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceItem('18L 桶装纯净水', '¥ 8.00 / 桶'),
          const SizedBox(height: 8),
          _buildPriceItem('11.3L 迷你桶装水', '¥ 6.00 / 桶'),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String product, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product,
            style: AppTextStyles.body2,
          ),
          Text(
            price,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationData() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '运营数据 (本月)',
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
                    Expanded(child: _buildOperationItem(Icons.shopping_cart, '订单总数', '156 单', AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOperationItem(Icons.inventory_2, '进货桶数', '4,280 桶', AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOperationItem(Icons.attach_money, '进货金额', '¥ 38,520.00', AppColors.purple)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOperationItem(Icons.replay, '回桶数量', '4,100 个', AppColors.orange)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildOperationItem(Icons.shopping_cart, '订单总数', '156 单', AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOperationItem(Icons.inventory_2, '进货桶数', '4,280 桶', AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildOperationItem(Icons.attach_money, '进货金额', '¥ 38,520.00', AppColors.purple)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOperationItem(Icons.replay, '回桶数量', '4,100 个', AppColors.orange)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperationItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
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
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    final orders = [
      {'id': 'ORD2026041901', 'time': '2026-04-19 14:20', 'amount': '2,400.00', 'status': '已完成'},
      {'id': 'ORD2026041803', 'time': '2026-04-18 10:15', 'amount': '1,800.00', 'status': '已完成'},
      {'id': 'ORD2026041705', 'time': '2026-04-17 16:30', 'amount': '3,200.00', 'status': '配送中'},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近订单',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showComingSoon('查看全部'),
                child: Text(
                  '查看全部',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.map((order) => _buildOrderItem(order)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order['id']}',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order['time'],
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥ ${order['amount']}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: order['status'] == '已完成'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'],
                  style: AppTextStyles.captionSmall.copyWith(
                    color: order['status'] == '已完成'
                        ? AppColors.success
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAccounts() {
    final staff = [
      {'name': '张小美 (店长)', 'phone': '138****2222', 'status': '正常'},
      {'name': '李晓丽', 'phone': '139****3333', 'status': '正常'},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '店员账号',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '管理账号',
                type: AppButtonType.outline,
                onPressed: () => _showComingSoon('管理账号'),
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...staff.map((s) => _buildStaffItem(s)),
        ],
      ),
    );
  }

  Widget _buildStaffItem(Map<String, dynamic> staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff['name'],
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  staff['phone'],
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              staff['status'],
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
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
