import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/driver_service.dart';
import '../../core/network/api_client.dart';

class DriverWarehouseReturnPage extends StatefulWidget {
  const DriverWarehouseReturnPage({super.key});

  @override
  State<DriverWarehouseReturnPage> createState() =>
      _DriverWarehouseReturnPageState();
}

class _DriverWarehouseReturnPageState extends State<DriverWarehouseReturnPage> {
  final DriverService _driverService = DriverService();
  final TextEditingController _bucketCountController = TextEditingController();

  int _currentBarrels = 0;
  int _returnBarrels = 0;
  bool _isNewStationDelivery = false;
  List<StationSelectItem> _stations = [];
  List<StationDeliveryItem> _selectedStations = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bucketCountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final driverInfo = await _driverService.getDriverInfo(null);
      setState(() {
        _currentBarrels = (driverInfo.bucketOnWay ?? 0);
        _returnBarrels = _currentBarrels;
        _bucketCountController.text = _currentBarrels.toString();
      });
      await _loadStations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStations() async {
    try {
      final response = await ApiClient().get(
        '/drivers/stations',
        headers: {'X-Driver-Id': ApiConfig.getDriverId()},
      );

      if (response.success && response.data != null) {
        final List<dynamic> stationsData = response.data as List<dynamic>;
        setState(() {
          _stations = stationsData.map((data) {
            return StationSelectItem.fromJson(data as Map<String, dynamic>);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('加载水站列表失败: $e');
    }
  }

  void _onBucketCountChanged(String value) {
    final count = int.tryParse(value) ?? 0;
    setState(() {
      _returnBarrels = count;
      if (_returnBarrels == 0) {
        _isNewStationDelivery = true;
      } else {
        _isNewStationDelivery = false;
        _selectedStations.clear();
      }
    });
  }

  void _toggleStation(StationSelectItem station) {
    final stationIdStr = station.stationId?.toString();
    if (stationIdStr == null) return;

    setState(() {
      final index =
          _selectedStations.indexWhere((s) => s.stationId == stationIdStr);
      if (index >= 0) {
        _selectedStations.removeAt(index);
      } else {
        _selectedStations.add(StationDeliveryItem(
          stationId: stationIdStr,
          stationName: station.name ?? '未知水站',
          bucketCount: 1,
        ));
      }
    });
  }

  void _updateStationBucketCount(String stationId, int count) {
    setState(() {
      final index =
          _selectedStations.indexWhere((s) => s.stationId == stationId);
      if (index >= 0) {
        _selectedStations[index].bucketCount = count;
      }
    });
  }

  Future<void> _submitReturn() async {
    if (_isSubmitting) return;

    final warehouseId = ApiConfig.getWarehouseId();
    if (warehouseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法获取仓库信息，请重新登录'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_returnBarrels == 0 && _isNewStationDelivery) {
      if (_selectedStations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请至少选择一个水站进行派送'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      final hasInvalidCount = _selectedStations.any((s) => s.bucketCount <= 0);
      if (hasInvalidCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('每个水站的派送桶数必须大于0'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final stationDeliveries = _selectedStations.map((s) {
        return {
          'stationId': s.stationId,
          'bucketCount': s.bucketCount,
        };
      }).toList();

      await _driverService.warehouseReturn(
        null,
        bucketReturn: _returnBarrels,
        warehouseId: warehouseId,
        isNewStationDelivery: _isNewStationDelivery,
        stationDeliveries: stationDeliveries,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('回仓申请提交成功'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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
          '回仓申请与清点',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCurrentCargoCard(),
                  const SizedBox(height: 16),
                  _buildReturnForm(),
                  if (_returnBarrels == 0) ...[
                    const SizedBox(height: 16),
                    _buildNewStationDeliverySection(),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentCargoCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '当前车上空桶',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_currentBarrels 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.primary,
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
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildCargoItem('18.9L 桶装水空桶', (_currentBarrels * 0.7).round()),
                const Divider(),
                _buildCargoItem(
                    '11.3L 迷你桶装水空桶', (_currentBarrels * 0.2).round()),
                const Divider(),
                _buildCargoItem('其他规格空桶', (_currentBarrels * 0.1).round()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2),
          Text(
            '$count 个',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnForm() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '回仓清点',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '请在仓库管理员处进行空桶清点核对',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('回桶数量', style: AppTextStyles.body2),
          const SizedBox(height: 8),
          TextField(
            controller: _bucketCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请输入回桶数量',
              filled: true,
              fillColor: AppColors.bgInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: _onBucketCountChanged,
          ),
          if (_returnBarrels == 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '回桶数量为0时，您可以选择为新水站派送',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            text: _isSubmitting ? '提交中...' : '提交回仓申请',
            type: AppButtonType.primary,
            isFullWidth: true,
            height: 56,
            isLoading: _isSubmitting,
            onPressed: _submitReturn,
          ),
        ],
      ),
    );
  }

  Widget _buildNewStationDeliverySection() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '新水站派送',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '可选择多个水站',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '当回桶数量为0时，可以选择为水站派送空桶，欠桶数将累加水站的当前欠桶数',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (_stations.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('暂无水站数据'),
              ),
            )
          else
            ..._stations.map((station) {
              final isSelected = _selectedStations
                  .any((s) => s.stationId == station.stationId);
              return _buildStationItem(station, isSelected);
            }),
          if (_selectedStations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择的派送明细',
                    style: AppTextStyles.subtitle2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedStations
                      .map((item) => _buildDeliveryDetailItem(item)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('总计派送',
                          style: AppTextStyles.body2
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '${_selectedStations.fold(0, (sum, s) => sum + s.bucketCount)} 个',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStationItem(StationSelectItem station, bool isSelected) {
    return InkWell(
      onTap: () => _toggleStation(station),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name ?? '未知水站',
                    style: AppTextStyles.subtitle2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.address ?? '暂无地址',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(
                        '当前欠桶: ${station.owedBucketNum ?? 0}',
                        station.isOverThreshold == true
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      if (station.bucketDepositPerUnit != null)
                        _buildTag(
                          '押金: ¥${station.bucketDepositPerUnit!.toStringAsFixed(0)}/桶',
                          AppColors.textSecondary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: color, fontSize: 10),
      ),
    );
  }

  Widget _buildDeliveryDetailItem(StationDeliveryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.stationName,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () {
              if (item.bucketCount > 1) {
                _updateStationBucketCount(item.stationId, item.bucketCount - 1);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${item.bucketCount}',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () {
              _updateStationBucketCount(item.stationId, item.bucketCount + 1);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            '个',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class StationSelectItem {
  final int? stationId;
  final String? name;
  final String? address;
  final String? phone;
  final int? owedBucketNum;
  final int? owedThreshold;
  final double? bucketDepositPerUnit;
  final bool? isOverThreshold;

  StationSelectItem({
    this.stationId,
    this.name,
    this.address,
    this.phone,
    this.owedBucketNum,
    this.owedThreshold,
    this.bucketDepositPerUnit,
    this.isOverThreshold,
  });

  factory StationSelectItem.fromJson(Map<String, dynamic> json) {
    return StationSelectItem(
      stationId: json['stationId'] is int
          ? json['stationId']
          : int.tryParse(json['stationId']?.toString() ?? '0'),
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      owedBucketNum: json['owedBucketNum'],
      owedThreshold: json['owedThreshold'],
      bucketDepositPerUnit: json['bucketDepositPerUnit'] is double
          ? json['bucketDepositPerUnit']
          : double.tryParse(json['bucketDepositPerUnit']?.toString() ?? '0'),
      isOverThreshold: json['isOverThreshold'],
    );
  }
}

class StationDeliveryItem {
  final String stationId;
  final String stationName;
  int bucketCount;

  StationDeliveryItem({
    required this.stationId,
    required this.stationName,
    required this.bucketCount,
  });
}
