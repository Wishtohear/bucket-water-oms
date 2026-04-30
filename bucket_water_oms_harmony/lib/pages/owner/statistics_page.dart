import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedTimeRange = 0;
  final List<String> _timeRanges = ['今日', '本周', '本月', '全年'];
  
  final Map<String, dynamic> _statsData = {
    'totalRevenue': 3850.00,
    'revenueChange': 12.5,
    'orderCount': 48,
    'orderChange': -2.1,
  };

  final List<Map<String, dynamic>> _productRanking = [
    {'rank': 1, 'name': '18.9L 经典桶装水', 'quantity': 320, 'unit': '桶'},
    {'rank': 2, 'name': '11.3L 迷你桶装水', 'quantity': 125, 'unit': '桶'},
    {'rank': 3, 'name': '550ml 瓶装水', 'quantity': 85, 'unit': '瓶'},
  ];

  final Map<String, dynamic> _customerData = {
    'total': 1248,
    'oldRate': 75,
    'newRate': 25,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTimeFilter(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildKeyMetricsCard(),
                    const SizedBox(height: 16),
                    _buildRevenueTrendCard(),
                    const SizedBox(height: 16),
                    _buildProductRankingCard(),
                    const SizedBox(height: 16),
                    _buildCustomerDistributionCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            '经营看板',
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_timeRanges.length, (index) {
          final isSelected = _selectedTimeRange == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeRange = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _timeRanges[index],
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeyMetricsCard() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            icon: Icons.attach_money,
            iconColor: AppColors.primary,
            label: '总营收(元)',
            value: '¥ ${(_statsData['totalRevenue'] as double).toStringAsFixed(2)}',
            change: _statsData['revenueChange'] as double,
            isPositiveChange: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricItem(
            icon: Icons.shopping_cart_outlined,
            iconColor: AppColors.success,
            label: '订单数(笔)',
            value: '${_statsData['orderCount']}',
            change: (_statsData['orderChange'] as double).abs(),
            isPositiveChange: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double change,
    required bool isPositiveChange,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositiveChange
                    ? AppColors.success
                    : AppColors.error,
                size: 14,
              ),
              Text(
                ' ${change.toStringAsFixed(1)}% 较昨日',
                style: AppTextStyles.captionSmall.copyWith(
                  color: isPositiveChange ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '营收趋势',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.24, AppColors.primary),
                _buildBar(0.16, AppColors.primary),
                _buildBar(0.32, AppColors.primary),
                _buildBar(0.36, AppColors.primary),
                _buildBar(0.28, AppColors.primary),
                _buildBar(0.20, AppColors.primary),
                _buildBar(0.40, AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('04-13', style: AppTextStyles.captionSmall),
              Text('04-14', style: AppTextStyles.captionSmall),
              Text('04-15', style: AppTextStyles.captionSmall),
              Text('04-16', style: AppTextStyles.captionSmall),
              Text('04-17', style: AppTextStyles.captionSmall),
              Text('04-18', style: AppTextStyles.captionSmall),
              Text(
                '04-19',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 24,
      height: 140 * height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildProductRankingCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '产品热销榜',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._productRanking.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.warning.withOpacity(0.2)
                          : AppColors.bgInput,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${product['rank']}',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: index == 0
                              ? AppColors.warning
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product['name'] as String,
                      style: AppTextStyles.subtitle2,
                    ),
                  ),
                  Text(
                    '${product['quantity']} ${product['unit']}',
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
    );
  }

  Widget _buildCustomerDistributionCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '新老客户占比',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgInput,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '总客户',
                        style: AppTextStyles.captionSmall,
                      ),
                      Text(
                        '${_customerData['total']}',
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    color: AppColors.primary,
                    label: '老客户',
                    rate: _customerData['oldRate'] as int,
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(
                    color: AppColors.primary.withOpacity(0.3),
                    label: '新客户',
                    rate: _customerData['newRate'] as int,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required int rate}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label $rate%',
          style: AppTextStyles.captionSmall,
        ),
      ],
    );
  }
}
