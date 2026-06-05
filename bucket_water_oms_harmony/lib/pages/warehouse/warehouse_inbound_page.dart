import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/components/status_badge.dart';
import '../../services/warehouse_service.dart';

class WarehouseInboundPage extends StatefulWidget {
  const WarehouseInboundPage({super.key});

  @override
  State<WarehouseInboundPage> createState() => _WarehouseInboundPageState();
}

class _WarehouseInboundPageState extends State<WarehouseInboundPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];

  static const _tabTypes = ['purchase', 'transfer', 'stocktake'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final warehouseService = WarehouseService();
      const warehouseId = '0';
      final records =
          await warehouseService.getInboundList(warehouseId);

      if (mounted) {
        setState(() {
          _allRecords = records;
          _isLoading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        _showErrorSnackbar('加载入库单失败: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _applyFilter() {
    final type = _tabTypes[_selectedTabIndex];
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredRecords = _allRecords.where((record) {
        final recordType = (record['type'] ?? '').toString();
        final matchesType =
            _selectedTabIndex == 0 ? true : recordType == type;
        if (!matchesType) return false;
        if (query.isEmpty) return true;
        final code = (record['inboundNo'] ?? record['code'] ?? '')
            .toString()
            .toLowerCase();
        final handler = (record['operator'] ?? record['handler'] ?? '')
            .toString()
            .toLowerCase();
        return code.contains(query) || handler.contains(query);
      }).toList();
    });
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '';
    DateTime? dateTime;
    if (value is DateTime) {
      dateTime = value;
    } else if (value is String) {
      dateTime = DateTime.tryParse(value);
    } else if (value is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (dateTime == null) return value.toString();
    final y = dateTime.year.toString();
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return '待核验';
      case 'confirmed':
        return '已入库';
      case 'rejected':
        return '已拒绝';
      case 'completed':
        return '已完成';
      default:
        return status ?? '未知';
    }
  }

  BadgeType _getStatusBadgeType(String? status) {
    switch (status) {
      case 'pending':
        return BadgeType.warning;
      case 'confirmed':
      case 'completed':
        return BadgeType.success;
      case 'rejected':
        return BadgeType.error;
      default:
        return BadgeType.info;
    }
  }

  String _getProductSummary(Map<String, dynamic> record) {
    final items = record['items'] as List?;
    if (items != null && items.isNotEmpty) {
      final first = items.first as Map<String, dynamic>;
      final name = first['productName'] ?? first['name'] ?? '商品';
      final qty = first['quantity'] ?? 0;
      return '$name × $qty';
    }
    final name = record['productName'] ?? '商品';
    final qty = record['quantity'] ?? 0;
    return '$name × $qty';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildInboundList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
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
      child: const Row(
        children: [
          Text(
            '入库管理',
            style: AppTextStyles.subtitle1,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['采购入库', '调拨入库', '盘点入库'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                _applyFilter();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index == _selectedTabIndex
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: index == _selectedTabIndex
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: index == _selectedTabIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: AppTextStyles.body2,
              decoration: InputDecoration(
                hintText: '搜索入库单号/经办人',
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textPlaceholder,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _showFilterSnackbar(),
              borderRadius: BorderRadius.circular(16),
              child: const Icon(
                Icons.filter_list,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请使用顶部标签切换入库类型'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInboundList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无入库记录',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击右下角按钮创建新的入库单',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredRecords.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInboundCard(record),
        );
      }).toList(),
    );
  }

  Widget _buildInboundCard(Map<String, dynamic> record) {
    final status = record['status']?.toString();
    final isPending = status == 'pending';
    final code = (record['inboundNo'] ?? record['code'] ?? record['id'] ?? '')
        .toString();
    final handler =
        (record['operator'] ?? record['handler'] ?? record['operatorName'] ?? '')
            .toString();
    final quantity = record['quantity'] ?? record['totalQuantity'] ?? 0;
    final createdAt = record['createdAt'] ?? record['createTime'];
    final productSummary = _getProductSummary(record);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showInboundDetail(record),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '单号: $code',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            productSummary,
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      text: _getStatusText(status),
                      type: _getStatusBadgeType(status),
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '入库数量',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$quantity 桶',
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
                            '经办人',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            handler.isEmpty ? '未知' : handler,
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateTime(createdAt),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          text: '查看详情',
                          isPrimary: false,
                          onTap: () => _showInboundDetail(record),
                        ),
                        if (isPending) ...[
                          const SizedBox(width: 8),
                          _buildActionButton(
                            text: '确认入库',
                            isPrimary: true,
                            onTap: () => _showConfirmDialog(record),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.captionSmall.copyWith(
            color: isPrimary ? AppColors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _showCreateInboundDialog,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showCreateInboundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建入库单'),
        content: const Text('入库单创建功能正在开发中，请通过管理后台创建。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showInboundDetail(Map<String, dynamic> record) {
    final code = (record['inboundNo'] ?? record['code'] ?? record['id'] ?? '')
        .toString();
    final status = _getStatusText(record['status']?.toString());
    final handler =
        (record['operator'] ?? record['handler'] ?? '').toString();
    final quantity = record['quantity'] ?? record['totalQuantity'] ?? 0;
    final type = record['type']?.toString() ?? '';
    final source = record['source']?.toString() ?? '';
    final remark = record['remark']?.toString() ?? '暂无';
    final createdAt = _formatDateTime(record['createdAt'] ?? record['createTime']);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '入库详情',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('入库单号', code),
            _buildDetailRow('入库类型', _getTypeText(type)),
            _buildDetailRow('当前状态', status),
            _buildDetailRow('入库数量', '$quantity 桶'),
            _buildDetailRow('经办人', handler.isEmpty ? '未知' : handler),
            if (source.isNotEmpty) _buildDetailRow('来源', source),
            _buildDetailRow('创建时间', createdAt),
            _buildDetailRow('备注', remark),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: AppColors.borderLight,
            ),
            const SizedBox(height: 12),
            Text(
              '商品明细',
              style: AppTextStyles.subtitle2,
            ),
            const SizedBox(height: 8),
            ..._buildDetailItems(record),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailItems(Map<String, dynamic> record) {
    final items = record['items'] as List?;
    if (items == null || items.isEmpty) {
      return [
        Text('暂无明细', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
      ];
    }
    return items.map<Widget>((item) {
      if (item is! Map) return const SizedBox.shrink();
      final name = item['productName'] ?? item['name'] ?? '商品';
      final qty = item['quantity'] ?? 0;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name.toString(),
                style: AppTextStyles.body2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '× $qty',
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'purchase':
        return '采购入库';
      case 'transfer':
        return '调拨入库';
      case 'stocktake':
        return '盘点入库';
      case 'driver_return':
        return '司机回桶';
      case 'clean':
        return '清洗入库';
      default:
        return type.isEmpty ? '未知' : type;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog(Map<String, dynamic> record) async {
    final code = (record['inboundNo'] ?? record['code'] ?? record['id'] ?? '')
        .toString();
    final id = record['id']?.toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认入库'),
        content: Text('确认入库单 $code 已完成？'),
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

    if (confirmed != true || !mounted || id == null) return;

    try {
      final warehouseService = WarehouseService();
      final success =
          await warehouseService.checkInbound(id, approved: true);

      if (success && mounted) {
        _showSuccessSnackbar('入库单 $code 已确认');
        await _loadData();
      } else if (mounted) {
        _showErrorSnackbar('确认入库失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('确认入库失败: $e');
      }
    }
  }
}
