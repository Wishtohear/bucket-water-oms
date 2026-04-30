import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class OwnerStatementPage extends StatelessWidget {
  const OwnerStatementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildDetailCard(),
                    const SizedBox(height: 16),
                    _buildActions(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Text(
            '月度对账单',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '2026年4月',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                    '期末余额 (截止今日)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥ 7,500.00',
                    style: AppTextStyles.statNumber.copyWith(
                      fontSize: 32,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('期初余额', '¥ 2,500'),
              _buildStatItem('本月进货', '¥ 15,000'),
              _buildStatItem('本月回款', '¥ 10,000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '进货明细',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '共10笔记录',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.water_drop,
            iconColor: AppColors.primary,
            title: '桶装水 × 100 桶',
            subtitle: '04-18 11:20 · 订单: #800',
            amount: '¥ 800.00',
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.local_drink,
            iconColor: AppColors.success,
            title: '瓶装水 × 50 桶',
            subtitle: '04-15 09:30 · 订单: #750',
            amount: '¥ 1,250.00',
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.water_drop,
            iconColor: AppColors.primary,
            title: '桶装水 × 200 桶',
            subtitle: '04-12 16:45 · 订单: #720',
            amount: '¥ 1,600.00',
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_down),
              label: const Text('查看全部20笔明细'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
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
              Text(
                subtitle,
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        AppButton(
          text: '确认对账单无误',
          type: AppButtonType.primary,
          isFullWidth: true,
          height: 56,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        AppButton(
          text: '对账单有争议',
          type: AppButtonType.outline,
          isFullWidth: true,
          height: 56,
          onPressed: () {},
        ),
      ],
    );
  }
}
