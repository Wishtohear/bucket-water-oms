import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class DriverBarrelPage extends StatelessWidget {
  const DriverBarrelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DriverBarrelContent();
  }
}

class _DriverBarrelContent extends StatelessWidget {
  const _DriverBarrelContent();

  void _showDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('补缴押金'),
        content: const Text('确定要补缴押金 ¥160 (8个×¥20) 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('押金补缴成功')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildDepositButton(context),
                    const SizedBox(height: 16),
                    _buildRecordsCard(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '空桶往来',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '2026-04-20',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF40A9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '押金桶总数',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '100',
                        style: AppTextStyles.statNumber.copyWith(
                          fontSize: 32,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '个',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '当前欠桶',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '8 个',
                        style: AppTextStyles.subtitle1.copyWith(
                          color: const Color(0xFFFFE0B2),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '欠桶阈值',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '10 个',
                        style: AppTextStyles.subtitle1.copyWith(
                          color: AppColors.white,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D4F).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFE0B2),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '⚠️ 距离阈值还差 2 个，请及时回桶或补缴押金',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositButton(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          _showDepositDialog(context);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '立即补缴押金 ¥160 (8个×¥20)',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近往来记录',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.filter_list,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecordItem(
            icon: Icons.arrow_downward,
            iconColor: AppColors.success,
            iconBgColor: AppColors.success.withOpacity(0.1),
            title: '配送回收 (张记水站)',
            subtitle: '04-18 14:20 · #ORD0892',
            value: '+45个',
            valueColor: AppColors.success,
            balance: '余额: 8个',
          ),
          const SizedBox(height: 20),
          _buildRecordItem(
            icon: Icons.arrow_upward,
            iconColor: AppColors.error,
            iconBgColor: AppColors.error.withOpacity(0.1),
            title: '订单带走 (李家水铺)',
            subtitle: '04-15 09:30 · #ORD0850',
            value: '-100个',
            valueColor: AppColors.error,
            balance: '余额: 53个',
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () {
                _showMoreRecords(context);
              },
              icon: const Icon(Icons.keyboard_arrow_down),
              label: const Text('查看更早的记录'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String value,
    required Color valueColor,
    required String balance,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.subtitle2.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              balance,
              style: AppTextStyles.captionSmall,
            ),
          ],
        ),
      ],
    );
  }

  void _showMoreRecords(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '更早的往来记录',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildRecordItem(
              icon: Icons.arrow_downward,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              title: '配送回收 (东门店)',
              subtitle: '04-10 10:15 · #ORD0801',
              value: '+30个',
              valueColor: AppColors.success,
              balance: '余额: 153个',
            ),
            const SizedBox(height: 16),
            _buildRecordItem(
              icon: Icons.arrow_upward,
              iconColor: AppColors.error,
              iconBgColor: AppColors.error.withOpacity(0.1),
              title: '订单带走 (西街水店)',
              subtitle: '04-05 16:40 · #ORD0755',
              value: '-50个',
              valueColor: AppColors.error,
              balance: '余额: 123个',
            ),
            const SizedBox(height: 16),
            _buildRecordItem(
              icon: Icons.arrow_downward,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withOpacity(0.1),
              title: '仓库回收',
              subtitle: '04-01 08:00 · #RET0021',
              value: '+20个',
              valueColor: AppColors.success,
              balance: '余额: 173个',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
