import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class DriverStatementPage extends StatelessWidget {
  const DriverStatementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DriverStatementContent();
  }
}

class _DriverStatementContent extends StatelessWidget {
  const _DriverStatementContent();

  final double _pendingAmount = 4850.00;
  final double _baseSalary = 3000.00;
  final double _deliveryCommission = 1850.00;
  final int _completedOrders = 125;
  final int _totalBarrels = 3200;
  final int _goodRating = 99;

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择月份',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('2026年04月'),
                  trailing: const Icon(Icons.check, color: AppColors.primary),
                  onTap: () => Navigator.pop(sheetContext),
                ),
                ListTile(
                  title: const Text('2026年03月'),
                  onTap: () => Navigator.pop(sheetContext),
                ),
                ListTile(
                  title: const Text('2026年02月'),
                  onTap: () => Navigator.pop(sheetContext),
                ),
                ListTile(
                  title: const Text('2026年01月'),
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出明细...')),
    );
  }

  void _viewAllDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看全部明细...')),
    );
  }

  void _confirmStatement(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认对账'),
        content: const Text('确认本月对账无误后，将进入结算流程。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('对账确认成功'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('反馈争议'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请描述您有争议的问题：'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '请输入争议内容...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('争议反馈已提交'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildPerformanceStats(),
                const SizedBox(height: 16),
                _buildSettlementDetails(context),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '月度对账单',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '2026年04月',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '本月待结结算金额',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '导出明细',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '¥ ${_pendingAmount.toStringAsFixed(2)}',
            style: AppTextStyles.statNumber.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基本工资',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥ ${_baseSalary.toStringAsFixed(0)}',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '配送提成 (本月)',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥ ${_deliveryCommission.toStringAsFixed(0)}',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
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

  Widget _buildPerformanceStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '完成订单',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_completedOrders ',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: '单',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '送水总数',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_totalBarrels ',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      TextSpan(
                        text: '桶',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '好评率',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_goodRating%',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementDetails(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: AppColors.borderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '结算明细',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            title: '配送提成 - 04-18',
            subtitle: '完成 8 单 · 共 250 桶',
            amount: '+¥ 125.00',
            isPositive: true,
          ),
          _buildDetailRow(
            title: '配送提成 - 04-17',
            subtitle: '完成 10 单 · 共 300 桶',
            amount: '+¥ 150.00',
            isPositive: true,
          ),
          _buildDetailRow(
            title: '奖励 - 优质服务奖励',
            subtitle: '上周零投诉特别奖励',
            amount: '+¥ 200.00',
            isPositive: true,
            isBlue: true,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => _viewAllDetails(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textTertiary,
              ),
              child: Text(
                '查看全部明细',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
    bool isBlue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: isBlue ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: '确认本月对账无误',
          type: AppButtonType.primary,
          height: 52,
          isFullWidth: true,
          onPressed: () => _confirmStatement(context),
        ),
        const SizedBox(height: 12),
        AppButton(
          text: '反馈有争议',
          type: AppButtonType.outline,
          height: 52,
          isFullWidth: true,
          onPressed: () => _showDisputeDialog(context),
        ),
      ],
    );
  }
}
