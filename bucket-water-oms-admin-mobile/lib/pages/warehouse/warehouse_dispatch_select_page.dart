import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/warehouse_service.dart';

class WarehouseDispatchSelectPage extends StatefulWidget {
  final String orderId;
  final String? orderNo;
  final String? stationName;
  final String? distance;
  final String? estimatedTime;
  final String? productInfo;

  const WarehouseDispatchSelectPage({
    super.key,
    required this.orderId,
    this.orderNo,
    this.stationName,
    this.distance,
    this.estimatedTime,
    this.productInfo,
  });

  @override
  State<WarehouseDispatchSelectPage> createState() =>
      _WarehouseDispatchSelectPageState();
}

class _WarehouseDispatchSelectPageState
    extends State<WarehouseDispatchSelectPage> {
  final WarehouseService _warehouseService = WarehouseService();

  bool _isLoading = true;
  String? _errorMessage;
  List<DispatchDriverModel> _drivers = [];
  DispatchDriverModel? _selectedDriver;
  bool _isDispatching = false;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId.isEmpty) {
        setState(() {
          _errorMessage = '未登录仓库账号';
          _isLoading = false;
        });
        return;
      }

      final drivers = await _warehouseService.getRecommendedDriversWithDetails(
        warehouseId,
        orderId: widget.orderId,
      );

      if (mounted) {
        setState(() {
          _drivers = drivers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[DispatchSelect] 加载司机失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载司机列表失败';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDispatch() async {
    if (_selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择要派单的司机'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isDispatching = true);

    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId.isEmpty) {
        throw Exception('未登录仓库账号');
      }

      await _warehouseService.dispatchAndAutoOutbound(
        widget.orderId,
        warehouseId,
        driverId: _selectedDriver!.driverId ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('派单成功，订单已自动出库'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('[DispatchSelect] 派单失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('派单失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDispatching = false);
      }
    }
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
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
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '选择配送司机',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadDrivers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfo(),
            const SizedBox(height: 20),
            _buildDriverListTitle(),
            const SizedBox(height: 12),
            _buildDriverList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '订单编号',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.orderNo ?? '#${widget.orderId}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '配送目的地',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.stationName ?? '未知水站',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgPage,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('配送距离', widget.distance ?? '未知'),
                const SizedBox(height: 8),
                _buildInfoRow('预计配送时长', widget.estimatedTime ?? '未知'),
                const SizedBox(height: 8),
                _buildInfoRow('商品数量', widget.productInfo ?? '未知'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          style: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverListTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '可用司机 (${_drivers.length})',
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: _loadDrivers,
          child: const Text('刷新'),
        ),
      ],
    );
  }

  Widget _buildDriverList() {
    if (_drivers.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 16,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                '暂无可用司机',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _drivers.asMap().entries.map((entry) {
        final index = entry.key;
        final driver = entry.value;
        final isRecommended = index == 0 && (driver.recommendScore ?? 0) > 0;
        final isSelected = _selectedDriver?.driverId == driver.driverId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDriverCard(driver, isRecommended, isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildDriverCard(
    DispatchDriverModel driver,
    bool isRecommended,
    bool isSelected,
  ) {
    final isBusy = (driver.currentTaskCount ?? 0) >= 4;

    return Opacity(
      opacity: isBusy ? 0.6 : 1.0,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        borderColor: isSelected ? AppColors.primary : null,
        child: Column(
          children: [
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '推荐',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              children: [
                _buildDriverAvatar(driver),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name ?? '未知司机',
                                  style: AppTextStyles.subtitle2.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '工号: ${driver.code ?? '未知'}',
                                  style: AppTextStyles.captionSmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isBusy)
                            IconButton(
                              onPressed: () => _makePhoneCall(driver.phone),
                              icon: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${driver.rating?.toStringAsFixed(1) ?? '0.0'}分',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '|',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${driver.totalDeliveries ?? 0}单',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDriverStats(driver, isBusy),
            if (!isBusy) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDriver = driver;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.primary : AppColors.white,
                    foregroundColor:
                        isSelected ? AppColors.white : AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.primary,
                        width: isSelected ? 0 : 1,
                      ),
                    ),
                  ),
                  child: Text(
                    isSelected ? '已选择' : '选择此司机',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
            if (isBusy)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '当前任务已满 (${driver.currentTaskCount}单)，暂不可派单',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverAvatar(DispatchDriverModel driver) {
    final isAvailable = (driver.currentTaskCount ?? 0) < 4;
    final statusColor = isAvailable ? AppColors.success : AppColors.warning;

    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: statusColor,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: driver.currentLat != null
                ? Image.network(
                    'https://modao.cc/agent-py/media/generated_images/2026-04-19/2566b5396b094ab1a625df1e2a348bad.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgPage,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.bgPage,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textTertiary,
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: Center(
              child: Text(
                isAvailable ? '空' : '${driver.currentTaskCount ?? 0}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverStats(DispatchDriverModel driver, bool isBusy) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '当前位置',
            _formatDistance(driver.distanceToWarehouse),
            AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            '当前任务',
            '${driver.currentTaskCount ?? 0} 单',
            (driver.currentTaskCount ?? 0) > 0
                ? AppColors.warning
                : AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            '今日已完成',
            '${driver.todayCompletedCount ?? 0} 单',
            AppColors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.captionSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '未知';
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '加载失败',
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDrivers,
            icon: const Icon(Icons.refresh),
            label: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _selectedDriver != null && !_isDispatching
              ? _confirmDispatch
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.textTertiary.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isDispatching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Text(
                  _selectedDriver != null ? '确认派单 (自动出库)' : '请选择司机',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}
