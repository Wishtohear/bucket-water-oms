import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/admin_station_service.dart';
import '../../models/admin_models.dart';
import '../../services/map_service.dart';
import '../../pages/admin/admin_routes.dart';

class AdminStationDetailPage extends StatefulWidget {
  final String stationId;

  const AdminStationDetailPage({
    super.key,
    required this.stationId,
  });

  @override
  State<AdminStationDetailPage> createState() => _AdminStationDetailPageState();
}

class _AdminStationDetailPageState extends State<AdminStationDetailPage> {
  final AdminStationService _stationService = AdminStationService();
  
  bool _isLoading = true;
  StationModel? _station;
  StationAccountModel? _account;

  @override
  void initState() {
    super.initState();
    _loadStationDetail();
  }

  Future<void> _loadStationDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final station = await _stationService.getStationDetail(widget.stationId);
      final account = await _stationService.getStationAccount(widget.stationId);

      setState(() {
        _station = station;
        _account = account;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
          '水站详情',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _station == null
              ? Center(
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
                        '加载失败，请重试',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: '重新加载',
                        type: AppButtonType.primary,
                        onPressed: _loadStationDetail,
                        height: 40,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStationDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfo(),
                        const SizedBox(height: 16),
                        _buildAccountInfo(),
                        const SizedBox(height: 16),
                        _buildPolicyConfig(),
                        const SizedBox(height: 16),
                        _buildOperationData(),
                        const SizedBox(height: 16),
                        _buildRecentOrders(),
                        const SizedBox(height: 16),
                        _buildStaffAccounts(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBasicInfo() {
    final station = _station!;
    final statusColor = _getStatusColor(station.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.store,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name ?? '未知水站',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '水站编号: ${station.code ?? '未知'} | 创建时间: ${_formatDate(station.createdAt)}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  station.statusText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('联系人', station.contactName ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('联系电话', station.contactPhone ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('详细地址', station.address ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('负责仓库', station.warehouseName ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('服务区域', station.region ?? '未知'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    final account = _account;
    final balance = account?.balance ?? _station?.balance ?? 0;
    final debtBarrels = account?.debtBarrels ?? _station?.debtBarrels ?? 0;
    final debtAmount = account?.debtAmount ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '账户与财务',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '调整余额',
                type: AppButtonType.outline,
                onPressed: () => _showComingSoon('调整余额'),
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildAccountCard('预存金余额', '¥ ${balance.toStringAsFixed(2)}', AppColors.primary, Icons.account_balance_wallet)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('信用额度', '¥ ${(account?.creditLimit ?? _station?.creditLimit ?? 0).toStringAsFixed(2)}', AppColors.purple, Icons.credit_card)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('押金桶数量', '${account?.totalBarrels ?? _station?.totalBarrels ?? 0} 个', AppColors.warning, Icons.inventory_2)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('当前欠桶', '$debtBarrels 个', AppColors.error, Icons.warning_amber)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildAccountCard('预存金余额', '¥ ${balance.toStringAsFixed(2)}', AppColors.primary, Icons.account_balance_wallet)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAccountCard('信用额度', '¥ ${(account?.creditLimit ?? _station?.creditLimit ?? 0).toStringAsFixed(2)}', AppColors.purple, Icons.credit_card)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildAccountCard('押金桶数量', '${account?.totalBarrels ?? _station?.totalBarrels ?? 0} 个', AppColors.warning, Icons.inventory_2)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAccountCard('当前欠桶', '$debtBarrels 个', AppColors.error, Icons.warning_amber)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欠桶预警',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '当前欠桶数($debtBarrels)超过阈值(${_station?.barrelThreshold ?? 30})，需补缴¥${debtAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.error.withOpacity(0.8),
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

  Widget _buildAccountCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyConfig() {
    final station = _station!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '销售政策配置',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '修改政策',
                type: AppButtonType.outline,
                onPressed: () => _showComingSoon('修改政策'),
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildPolicyItem('账期类型', station.billingCycle ?? '月结')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPolicyItem('预存金要求', '¥ ${(station.prepaidAmount ?? 0).toStringAsFixed(2)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPolicyItem('欠桶阈值', '${station.barrelThreshold ?? 30} 个')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPolicyItem('每桶押金', '¥ ${(station.barrelDeposit ?? 0).toStringAsFixed(2)}')),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildPolicyItem('账期类型', station.billingCycle ?? '月结')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPolicyItem('预存金要求', '¥ ${(station.prepaidAmount ?? 0).toStringAsFixed(2)}')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildPolicyItem('欠桶阈值', '${station.barrelThreshold ?? 30} 个')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPolicyItem('每桶押金', '¥ ${(station.barrelDeposit ?? 0).toStringAsFixed(2)}')),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            '独立定价',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (station.pricing != null && station.pricing!.isNotEmpty)
            ...station.pricing!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPriceItem(entry.key, '¥ ${(entry.value as num).toStringAsFixed(2)} / 桶'),
              );
            })
          else ...[
            _buildPriceItem('18L 桶装纯净水', '¥ 8.00 / 桶'),
            const SizedBox(height: 8),
            _buildPriceItem('11.3L 迷你桶装水', '¥ 6.00 / 桶'),
          ],
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String product, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product,
            style: AppTextStyles.body2,
          ),
          Text(
            price,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationData() {
    final station = _station!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '运营数据 (本月)',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildOperationItem(Icons.shopping_cart, '订单总数', '${station.orderCount ?? station.monthOrderCount ?? 0} 单', AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOperationItem(Icons.inventory_2, '进货桶数', '${station.monthBarrels ?? 0} 桶', AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOperationItem(Icons.attach_money, '进货金额', '¥ ${(station.monthAmount ?? 0).toStringAsFixed(2)}', AppColors.purple)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOperationItem(Icons.replay, '回桶数量', '${station.returnBarrels ?? 0} 个', AppColors.orange)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildOperationItem(Icons.shopping_cart, '订单总数', '${station.orderCount ?? station.monthOrderCount ?? 0} 单', AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOperationItem(Icons.inventory_2, '进货桶数', '${station.monthBarrels ?? 0} 桶', AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildOperationItem(Icons.attach_money, '进货金额', '¥ ${(station.monthAmount ?? 0).toStringAsFixed(2)}', AppColors.purple)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOperationItem(Icons.replay, '回桶数量', '${station.returnBarrels ?? 0} 个', AppColors.orange)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperationItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近订单',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showComingSoon('查看全部'),
                child: Text(
                  '查看全部',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '订单数据将通过API对接获取',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAccounts() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '店员账号',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: '管理账号',
                type: AppButtonType.outline,
                onPressed: () => _showComingSoon('管理账号'),
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '店员账号数据将通过API对接获取',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
      case 'normal':
        return AppColors.success;
      case 'suspended':
        return AppColors.error;
      case 'closed':
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未知';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showEditDialog() {
    AdminRoutes.navigateToStationEdit(context, widget.stationId);
  }

  void _showStationEditDialog() {
    if (_station == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationLocationEditSheet(
        station: _station!,
        onLocationUpdated: (latitude, longitude, address) async {
          try {
            final updatedStation = await _stationService.updateStationLocation(
              _station!.id!,
              latitude: latitude,
              longitude: longitude,
              address: address,
            );
            setState(() {
              _station = updatedStation;
            });
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('位置更新成功'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('位置更新失败: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        onNavigate: (lat, lng, name) {
          Navigator.pop(context);
          MapService.navigateToStation(
            context: this.context,
            lat: lat,
            lng: lng,
            stationName: name,
            address: _station!.address,
          );
        },
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class StationLocationEditSheet extends StatefulWidget {
  final StationModel station;
  final Function(double latitude, double longitude, String? address) onLocationUpdated;
  final Function(double lat, double lng, String name) onNavigate;

  const StationLocationEditSheet({
    super.key,
    required this.station,
    required this.onLocationUpdated,
    required this.onNavigate,
  });

  @override
  State<StationLocationEditSheet> createState() => _StationLocationEditSheetState();
}

class _StationLocationEditSheetState extends State<StationLocationEditSheet> {
  late double _latitude;
  late double _longitude;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.station.latitude ?? 25.2810;
    _longitude = widget.station.longitude ?? 110.2900;
    _addressController = TextEditingController(text: widget.station.address ?? '');
    _latController = TextEditingController(text: _latitude.toStringAsFixed(6));
    _lngController = TextEditingController(text: _longitude.toStringAsFixed(6));
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _updateCoordinates() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setState(() {
        _latitude = lat;
        _longitude = lng;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _getDeviceLocation();
      if (result != null) {
        final lat = result['latitude'];
        final lng = result['longitude'];
        if (lat != null && lng != null) {
          setState(() {
            _latitude = lat;
            _longitude = lng;
            _latController.text = _latitude.toStringAsFixed(6);
            _lngController.text = _longitude.toStringAsFixed(6);
          });
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, double>?> _getDeviceLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'latitude': 25.2810 + (DateTime.now().millisecond % 100) / 10000,
      'longitude': 110.2900 + (DateTime.now().millisecond % 100) / 10000,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '编辑水站位置',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.station.name ?? '水站',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '坐标信息',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            labelText: '纬度',
                            hintText: '25.281000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.north),
                          ),
                          onChanged: (_) => _updateCoordinates(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            labelText: '经度',
                            hintText: '110.290000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.east),
                          ),
                          onChanged: (_) => _updateCoordinates(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _getCurrentLocation,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(_isLoading ? '获取中...' : '获取当前位置'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '地址信息',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: '详细地址',
                      hintText: '请输入详细地址',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '坐标用于司机GPS打卡和导航定位，请确保坐标准确',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            widget.onNavigate(_latitude, _longitude, widget.station.name ?? '水站');
                          },
                          icon: const Icon(Icons.navigation),
                          label: const Text('导航测试'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onLocationUpdated(
                              _latitude,
                              _longitude,
                              _addressController.text.isEmpty ? null : _addressController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('保存位置'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
