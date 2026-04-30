import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class BucketExchangePage extends StatefulWidget {
  const BucketExchangePage({super.key});

  @override
  State<BucketExchangePage> createState() => _BucketExchangePageState();
}

class _BucketExchangePageState extends State<BucketExchangePage> {
  int _selectedFilter = 0;
  final List<String> _filterOptions = ['全部', '回桶', '欠桶'];

  final List<Map<String, dynamic>> _transactionRecords = [
    {
      'type': 'return',
      'title': '回桶',
      'subtitle': '订单#202604180082配送完成',
      'amount': '+50个',
      'time': '04-18 14:30',
      'driver': '王力',
      'color': AppColors.success,
      'bgColor': AppColors.success.withOpacity(0.1),
    },
    {
      'type': 'owe',
      'title': '欠桶',
      'subtitle': '订单#202604180082客户无桶可退',
      'amount': '+8个',
      'time': '04-18 14:30',
      'driver': '王力',
      'color': AppColors.warning,
      'bgColor': AppColors.warning.withOpacity(0.1),
    },
    {
      'type': 'deposit',
      'title': '补缴押金',
      'subtitle': '因欠桶达到阈值，主动补缴',
      'amount': '¥800.00',
      'time': '04-10 16:20',
      'driver': '微信支付',
      'color': AppColors.primary,
      'bgColor': AppColors.primary.withOpacity(0.1),
    },
    {
      'type': 'return',
      'title': '回桶',
      'subtitle': '订单#202604150075配送完成',
      'amount': '+70个',
      'time': '04-15 10:30',
      'driver': '李明',
      'color': AppColors.success,
      'bgColor': AppColors.success.withOpacity(0.1),
    },
    {
      'type': 'deposit',
      'title': '开户押金',
      'subtitle': '水站开户，初始押金',
      'amount': '¥4,000.00',
      'time': '03-01 09:00',
      'driver': '初始开户',
      'color': AppColors.primary,
      'bgColor': AppColors.primary.withOpacity(0.1),
    },
  ];

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedFilter == 0) return _transactionRecords;
    if (_selectedFilter == 1) {
      return _transactionRecords.where((r) => r['type'] == 'return').toList();
    }
    if (_selectedFilter == 2) {
      return _transactionRecords.where((r) => r['type'] == 'owe').toList();
    }
    return _transactionRecords;
  }

  void _payDeposit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认补缴押金'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('补缴金额：¥320.00'),
            Text('补缴数量：8个'),
            SizedBox(height: 8),
            Text('将跳转到微信支付'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '补缴成功！\n已补缴押金 ¥320.00\n当前欠桶：0个',
                  ),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildWarningAlert(),
                    const SizedBox(height: 16),
                    _buildDepositPolicy(),
                    const SizedBox(height: 16),
                    _buildTransactionList(),
                    const SizedBox(height: 16),
                    _buildMonthlyStats(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '空桶往来',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF722ED1), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '100 个',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前欠桶',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '8 个',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欠桶押金',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '¥320.00',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningAlert() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.05),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.error,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '欠桶预警',
                              style: AppTextStyles.subtitle2.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '您当前欠桶8个，已达到阈值10个的80%',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '需补缴',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '欠桶押金金额',
                                style: AppTextStyles.body2,
                              ),
                              Text(
                                '¥320.00',
                                style: AppTextStyles.subtitle2.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '每桶押金',
                                style: AppTextStyles.body2,
                              ),
                              Text(
                                '¥40.00',
                                style: AppTextStyles.subtitle2.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _payDeposit,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '立即补缴押金',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildDepositPolicy() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '押金政策',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '您的水站押金设置',
                    style: AppTextStyles.captionSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPolicyRow('每桶押金金额', '¥40.00'),
          const Divider(height: 24),
          _buildPolicyRow('欠桶阈值', '10个'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '超阈值处理',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '限制下单',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '空桶流水',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(3, (index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.purple.withOpacity(0.1)
                            : AppColors.bgInput,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filterOptions[index],
                        style: AppTextStyles.captionSmall.copyWith(
                          color: isSelected
                              ? AppColors.purple
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_filteredRecords.length, (index) {
            final record = _filteredRecords[index];
            return _buildTransactionItem(record);
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> record) {
    IconData iconData;
    switch (record['type']) {
      case 'return':
        iconData = Icons.arrow_downward;
        break;
      case 'owe':
        iconData = Icons.warning;
        break;
      default:
        iconData = Icons.account_balance_wallet;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: record['bgColor'] as Color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: record['color'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['title'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record['subtitle'] as String,
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                    Text(
                      record['amount'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: record['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record['time'] as String,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      record['driver'] as String,
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '月度统计',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '本月回桶',
                  '120个',
                  AppColors.success,
                  AppColors.success.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '本月欠桶',
                  '20个',
                  AppColors.warning,
                  AppColors.warning.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '净回桶',
                  '100个',
                  AppColors.purple,
                  AppColors.purple.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsRow('本月净回桶', '+100个', AppColors.success),
          const SizedBox(height: 8),
          _buildStatsRow('历史累计回桶', '500个', AppColors.textPrimary),
          const SizedBox(height: 8),
          _buildStatsRow('历史累计欠桶', '400个', AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
