import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/station_bucket_service.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';

class BucketExchangePage extends StatefulWidget {
  const BucketExchangePage({super.key});

  @override
  State<BucketExchangePage> createState() => _BucketExchangePageState();
}

class _BucketExchangePageState extends State<BucketExchangePage> {
  final StationBucketService _bucketService = StationBucketService();

  int _selectedFilter = 0;
  bool _isLoading = true;
  String? _errorMessage;
  final List<String> _filterOptions = ['全部', '回桶', '欠桶'];

  StationBucketInfo? _bucketInfo;
  BucketDepositPolicy? _depositPolicy;
  MonthlyBucketStats? _monthlyStats;
  List<BucketTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final stationId = appState.stationId;

      if (stationId != null) {
        final bucketInfo = await _bucketService.getBucketInfo(stationId);
        final depositPolicy = await _bucketService.getDepositPolicy(stationId);
        final monthlyStats = await _bucketService.getMonthlyStats(stationId);
        final transactions =
            await _bucketService.getBucketTransactions(stationId);

        if (mounted) {
          setState(() {
            _bucketInfo = bucketInfo;
            _depositPolicy = depositPolicy;
            _monthlyStats = monthlyStats;
            _transactions = transactions;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = '无法获取水站ID';
          });
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载数据失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  List<BucketTransaction> get _filteredTransactions {
    if (_selectedFilter == 0) return _transactions;
    if (_selectedFilter == 1) {
      return _transactions.where((r) => r.type == 'return').toList();
    }
    if (_selectedFilter == 2) {
      return _transactions.where((r) => r.type == 'owe').toList();
    }
    return _transactions;
  }

  Future<void> _payDeposit() async {
    final appState = context.read<AppState>();
    final stationId = appState.stationId;

    if (stationId == null || _bucketInfo == null) return;

    final oweBuckets = _bucketInfo!.oweBuckets ?? 0;
    final depositPerBucket = _bucketInfo!.depositPerBucket ?? 40.0;
    final totalAmount = oweBuckets * depositPerBucket;

    if (oweBuckets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前没有欠桶，无需补缴')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认补缴押金'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('补缴金额：¥${totalAmount.toStringAsFixed(2)}'),
            Text('补缴数量：$oweBuckets个'),
            const SizedBox(height: 8),
            const Text('将跳转到微信支付'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _bucketService.payDeposit(
        stationId,
        bucketCount: oweBuckets,
        amount: totalAmount,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '补缴成功！\n已补缴押金 ¥${totalAmount.toStringAsFixed(2)}\n当前欠桶：0个',
            ),
          ),
        );
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('补缴失败，请稍后重试')),
        );
      }
    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _buildContent(),
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(_errorMessage!,
              style:
                  AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('重新加载')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
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
    );
  }

  Widget _buildSummaryCard() {
    final bucketInfo = _bucketInfo;

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
                  Text(
                    '${bucketInfo?.depositBucketNum ?? 100} 个',
                    style: const TextStyle(
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
                child: const Icon(Icons.info_outline,
                    color: Colors.white, size: 28),
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
                      Text(
                        '${bucketInfo?.oweBuckets ?? 0} 个',
                        style: const TextStyle(
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
                      Text(
                        '¥${(bucketInfo?.owedDeposit ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
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
    final bucketInfo = _bucketInfo;
    final depositPolicy = _depositPolicy;
    final oweBuckets = bucketInfo?.oweBuckets ?? 0;
    final threshold = depositPolicy?.owedThreshold ?? 10;
    final percentage =
        threshold > 0 ? (oweBuckets / threshold * 100).clamp(0, 100) : 0;
    final depositPerBucket = bucketInfo?.depositPerBucket ?? 40.0;
    final owedDeposit = oweBuckets * depositPerBucket;

    if (oweBuckets == 0) {
      return const SizedBox.shrink();
    }

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
                child:
                    const Icon(Icons.error, color: AppColors.error, size: 28),
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
                              '您当前欠桶$oweBuckets个，已达到阈值$threshold个的${percentage.toStringAsFixed(0)}%',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                              Text('欠桶押金金额', style: AppTextStyles.body2),
                              Text(
                                '¥${owedDeposit.toStringAsFixed(2)}',
                                style: AppTextStyles.subtitle2
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('每桶押金', style: AppTextStyles.body2),
                              Text(
                                '¥${depositPerBucket.toStringAsFixed(2)}',
                                style: AppTextStyles.subtitle2
                                    .copyWith(fontWeight: FontWeight.bold),
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
    final depositPolicy = _depositPolicy;

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
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.purple, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '押金政策',
                    style: AppTextStyles.subtitle2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text('您的水站押金设置', style: AppTextStyles.captionSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPolicyRow('每桶押金金额',
              '¥${(depositPolicy?.depositPerBucket ?? 40.0).toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildPolicyRow('欠桶阈值', '${depositPolicy?.owedThreshold ?? 10}个'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('超阈值处理',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  depositPolicy?.overThresholdAction ?? '限制下单',
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
        Text(label,
            style:
                AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style:
                AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.bold)),
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
              Text('空桶流水',
                  style: AppTextStyles.subtitle2
                      .copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(3, (index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
          if (_filteredTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('暂无记录',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.textSecondary)),
              ),
            )
          else
            ..._filteredTransactions
                .map((record) => _buildTransactionItem(record)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BucketTransaction record) {
    Color color;
    Color bgColor;
    IconData iconData;

    switch (record.type) {
      case 'return':
        color = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.1);
        iconData = Icons.arrow_downward;
        break;
      case 'owe':
        color = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
        iconData = Icons.warning;
        break;
      default:
        color = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.1);
        iconData = Icons.account_balance_wallet;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white, size: 20),
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
                          record.title ?? '空桶',
                          style: AppTextStyles.subtitle2
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(record.subtitle ?? '',
                            style: AppTextStyles.captionSmall),
                      ],
                    ),
                    Text(
                      record.amount ?? '',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.formattedTime,
                        style: AppTextStyles.captionSmall
                            .copyWith(color: AppColors.textTertiary)),
                    Text(record.driver ?? '',
                        style: AppTextStyles.captionSmall),
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
    final stats = _monthlyStats;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('月度统计',
              style: AppTextStyles.subtitle2
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('本月回桶', '${stats?.returned ?? 0}个',
                    AppColors.success, AppColors.success.withOpacity(0.1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('本月欠桶', '${stats?.owed ?? 0}个',
                    AppColors.warning, AppColors.warning.withOpacity(0.1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('净回桶', '${stats?.netReturned ?? 0}个',
                    AppColors.purple, AppColors.purple.withOpacity(0.1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsRow(
              '本月净回桶', '+${stats?.netReturned ?? 0}个', AppColors.success),
          const SizedBox(height: 8),
          _buildStatsRow(
              '历史累计回桶', '${stats?.totalReturned ?? 0}个', AppColors.textPrimary),
          const SizedBox(height: 8),
          _buildStatsRow(
              '历史累计欠桶', '${stats?.totalOwed ?? 0}个', AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.captionSmall.copyWith(color: textColor)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.captionSmall
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.subtitle2
                .copyWith(color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
