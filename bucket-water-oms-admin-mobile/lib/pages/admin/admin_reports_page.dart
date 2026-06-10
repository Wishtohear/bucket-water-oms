import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/admin_report_service.dart' show AdminReportService;
import '../../models/report_models.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  ReportStatsResponse? _stats;
  List<SalesTrendData> _salesTrend = [];
  List<ProductDistributionData> _productDistribution = [];
  List<StationRankingData> _stationRankings = [];
  DailySalesResponse? _dailySales;

  String _selectedPeriod = 'week';
  int _currentPage = 1;
  final int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reportService = AdminReportService();

      final statsFuture = reportService.getStats();
      final trendFuture = reportService.getSalesTrend(period: _selectedPeriod);
      final distributionFuture = reportService.getProductDistribution();
      final rankingsFuture = reportService.getStationRankings(limit: 5);
      final dailyFuture = reportService.getDailySales(
        page: _currentPage,
        pageSize: _pageSize,
      );

      final results = await Future.wait([
        statsFuture,
        trendFuture,
        distributionFuture,
        rankingsFuture,
        dailyFuture,
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as ReportStatsResponse;
          _salesTrend = results[1] as List<SalesTrendData>;
          _productDistribution = results[2] as List<ProductDistributionData>;
          _stationRankings = results[3] as List<StationRankingData>;
          _dailySales = results[4] as DailySalesResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '报表统计',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.textPrimary),
            onPressed: _exportReport,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '销售概况'),
                Tab(text: '销售趋势'),
                Tab(text: '水站排行'),
                Tab(text: '销售明细'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildTrendTab(),
        _buildRankingsTab(),
        _buildDailyTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    if (_stats == null) {
      return const Center(child: Text('暂无数据'));
    }

    final stats = _stats!;
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: '今日销售额',
                    value: '¥${stats.todaySales.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    iconColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: '今日订单',
                    value: '${stats.todayOrders}',
                    icon: Icons.shopping_cart,
                    iconColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: '活跃水站',
                    value: '${stats.activeStations}/${stats.totalStations}',
                    icon: Icons.store,
                    iconColor: AppColors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: '在线司机',
                    value: '${stats.onlineDrivers}/${stats.totalDrivers}',
                    icon: Icons.local_shipping,
                    iconColor: AppColors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDistributionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '产品销量构成',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '按品类统计占比',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (_productDistribution.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  '暂无数据',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: _productDistribution
                  .map((item) => _buildDistributionItem(item))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDistributionItem(ProductDistributionData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.productName,
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: item.percentage / 100,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '销售趋势',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'week', label: Text('周')),
                    ButtonSegment(value: 'month', label: Text('月')),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (value) {
                    setState(() {
                      _selectedPeriod = value.first;
                    });
                    _loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_salesTrend.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 64,
                        color: AppColors.textTertiary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无趋势数据',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildTrendChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final maxAmount = _salesTrend
        .map((e) => e.amount)
        .fold(0.0, (max, amount) => amount > max ? amount : max);

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _salesTrend.map((item) {
          final heightPercentage = maxAmount > 0 ? item.amount / maxAmount : 0.0;
          final height = heightPercentage * 160;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '¥${item.amount.toStringAsFixed(0)}',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: height.clamp(20.0, 160.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.date.length > 5 ? item.date.substring(5) : item.date,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankingsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stationRankings.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '水站订货排行 TOP 5',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (index > _stationRankings.length) {
            return const SizedBox.shrink();
          }
          return _buildRankingItem(_stationRankings[index - 1]);
        },
      ),
    );
  }

  Widget _buildRankingItem(StationRankingData item) {
    final maxAmount = _stationRankings.isNotEmpty
        ? _stationRankings.first.salesAmount
        : 1.0;
    final percentage = maxAmount > 0 ? item.salesAmount / maxAmount : 0.0;

    Color rankColor;
    switch (item.rank) {
      case 1:
        rankColor = AppColors.orange;
        break;
      case 2:
        rankColor = AppColors.textSecondary;
        break;
      case 3:
        rankColor = AppColors.orange.withOpacity(0.6);
        break;
      default:
        rankColor = AppColors.primary.withOpacity(0.3);
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.rank}',
                style: AppTextStyles.subtitle2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.stationName,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppColors.borderLight,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '¥${item.salesAmount.toStringAsFixed(0)}',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    if (_dailySales == null || _dailySales!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无日报数据',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dailySales!.items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '销售明细日报',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '共 ${_dailySales!.totalOrders} 条记录',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    onPressed: _exportDailySales,
                  ),
                ],
              ),
            );
          }
          if (index > _dailySales!.items.length) {
            return const SizedBox.shrink();
          }
          return _buildDailyItem(_dailySales!.items[index - 1]);
        },
      ),
    );
  }

  Widget _buildDailyItem(DailySalesItem item) {
    final isToday = item.date == _getTodayDate();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.date,
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '今日',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '¥${item.salesAmount.toStringAsFixed(2)}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDailyStat(
                label: '订货桶数',
                value: '${item.barrelCount}',
              ),
              const SizedBox(width: 24),
              _buildDailyStat(
                label: '空桶回收',
                value: '${item.emptyBarrelReturn}',
              ),
              const SizedBox(width: 24),
              _buildDailyStat(
                label: '订单数',
                value: '${item.orderCount}',
              ),
              const Spacer(),
              if (item.newStations > 0)
                Text(
                  '+${item.newStations}家水站',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStat({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('报表导出功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _exportDailySales() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('日报导出功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
