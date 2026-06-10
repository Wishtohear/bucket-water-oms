import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/driver_service.dart';

class DriverBarrelPage extends StatefulWidget {
  const DriverBarrelPage({super.key});

  @override
  State<DriverBarrelPage> createState() => _DriverBarrelPageState();
}

class _DriverBarrelPageState extends State<DriverBarrelPage> {
  bool _isLoading = true;
  DriverInfoData? _driverInfo;
  List<BarrelRecordData> _barrelRecords = [];
  final DriverService _driverService = DriverService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverId = ApiConfig.getDriverId();

      if (driverId != null && driverId.isNotEmpty) {
        final infoFuture = _driverService.getDriverInfo(driverId);
        final recordsFuture = _driverService.getBarrelRecords(driverId);

        final results = await Future.wait([infoFuture, recordsFuture]);

        setState(() {
          _driverInfo = results[0] as DriverInfoData;
          _barrelRecords = results[1] as List<BarrelRecordData>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF722ED1), Color(0xFF9254DE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '空桶管理',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people, color: AppColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatCard(),
                    const SizedBox(height: 16),
                    _buildWarningCard(),
                    const SizedBox(height: 16),
                    _buildPayDepositCard(),
                    const SizedBox(height: 16),
                    _buildRecordList(),
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

  Widget _buildStatCard() {
    final depositBuckets = _driverInfo?.depositBuckets ?? 0;
    final owedBuckets = _driverInfo?.owedBuckets ?? 0;
    final bucketThreshold = 10;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF722ED1), Color(0xFF9254DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF722ED1).withOpacity(0.3),
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
              Text(
                '押金桶统计',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              Text(
                _formatDate(DateTime.now()),
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: '押金桶总数',
                  value: '$depositBuckets',
                  unit: '个',
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '当前欠桶',
                  value: '$owedBuckets',
                  unit: '个',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '预警阈值',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$bucketThreshold 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.white,
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

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.statNumber.copyWith(
                fontSize: 32,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    final owedBuckets = _driverInfo?.owedBuckets ?? 0;
    final bucketThreshold = 10;
    final isWarning = owedBuckets >= bucketThreshold;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      backgroundColor:
          isWarning ? AppColors.warning.withOpacity(0.1) : AppColors.bgCard,
      borderColor: isWarning ? AppColors.warning.withOpacity(0.3) : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isWarning
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
              color: isWarning ? AppColors.warning : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWarning ? '欠桶预警' : '注意事项',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWarning
                      ? '当前欠桶 $owedBuckets 个，已超过预警阈值 $bucketThreshold 个，请及时处理'
                      : '请及时回收空桶，保持合理的空桶库存',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayDepositCard() {
    final owedBuckets = _driverInfo?.owedBuckets ?? 0;
    final depositPrice = _driverInfo?.depositPrice ?? 20.0;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.payment,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '补缴押金',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '需补缴 ($owedBuckets 个)',
                  style: AppTextStyles.body2,
                ),
                Text(
                  '¥${(owedBuckets * depositPrice).toStringAsFixed(2)}',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.error,
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

  Widget _buildRecordList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '往来记录',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                '查看全部',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_barrelRecords.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.history,
                    size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text(
                  '暂无往来记录',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...(_barrelRecords.take(5).map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: record.isReturn
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        record.isReturn
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: record.isReturn
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.stationName ?? '水站',
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '订单 ${record.orderNo ?? ""} · ${record.date}',
                            style: AppTextStyles.captionSmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${record.quantity}个',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: record.isReturn
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          })),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
