import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';
import '../../services/warehouse_service.dart';

class WarehouseOutboundPage extends StatefulWidget {
  const WarehouseOutboundPage({super.key});

  @override
  State<WarehouseOutboundPage> createState() => _WarehouseOutboundPageState();
}

class _WarehouseOutboundPageState extends State<WarehouseOutboundPage> {
  int _currentIndex = 2;
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _allOutboundList = [];
  List<Map<String, dynamic>> _filteredOutboundList = [];

  String _filterStatus = '全部';
  DateTime? _startDate;
  DateTime? _endDate;

  static const _tabTypes = ['order', 'transfer', 'return'];

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
      final list =
          await warehouseService.getOutboundList(warehouseId);

      if (mounted) {
        setState(() {
          _allOutboundList = list;
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
        _showErrorSnackbar('加载出库单失败: $e');
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
      _filteredOutboundList = _allOutboundList.where((item) {
        final itemType = (item['type'] ?? '').toString();
        final matchesType = _selectedTabIndex == 0
            ? (itemType.isEmpty || itemType == 'order')
            : itemType == type;
        if (!matchesType) return false;
        if (_filterStatus != '全部') {
          final statusText = _getStatusText(item['status']?.toString());
          if (statusText != _filterStatus) return false;
        }
        if (query.isEmpty) return true;
        final code = (item['outboundNo'] ?? item['code'] ?? '')
            .toString()
            .toLowerCase();
        final customer = (item['customer'] ?? item['stationName'] ?? '')
            .toString()
            .toLowerCase();
        return code.contains(query) || customer.contains(query);
      }).toList();
    });
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return '待拣货';
      case 'processing':
        return '拣货中';
      case 'confirmed':
      case 'completed':
      case 'shipped':
        return '已出库';
      case 'cancelled':
        return '已取消';
      default:
        return status ?? '未知';
    }
  }

  BadgeType _getStatusBadgeType(String? status) {
    switch (status) {
      case 'pending':
        return BadgeType.primary;
      case 'processing':
        return BadgeType.warning;
      case 'confirmed':
      case 'completed':
      case 'shipped':
        return BadgeType.success;
      case 'cancelled':
        return BadgeType.error;
      default:
        return BadgeType.info;
    }
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

  String _getTypeText(String? type) {
    switch (type) {
      case 'order':
        return '订单出库';
      case 'transfer':
        return '调拨出库';
      case 'return':
        return '退货出库';
      default:
        return '订单出库';
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
            _buildTabs(),
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
                      _buildOutboundList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WarehouseBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            child: const Icon(
              Icons.chevron_left,
              size: 32,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '出库管理',
              style: AppTextStyles.h3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTabIndex = index);
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
                  _getTabTitle(index),
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

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return '订单出库';
      case 1:
        return '调拨出库';
      case 2:
        return '退货出库';
      default:
        return '';
    }
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
                hintText: '搜索订单号/客户名称',
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
              onTap: _showFilterDialog,
              borderRadius: BorderRadius.circular(16),
              child: const Icon(
                Icons.tune,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutboundList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredOutboundList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _filteredOutboundList.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildOutboundCard(item),
      )).toList(),
    );
  }

  Widget _buildOutboundCard(Map<String, dynamic> item) {
    final code = (item['outboundNo'] ?? item['code'] ?? item['id'] ?? '')
        .toString();
    final customer = (item['customer'] ??
            item['stationName'] ??
            item['customerName'] ??
            '未知客户')
        .toString();
    final status = item['status']?.toString();
    final statusText = _getStatusText(status);
    final statusType = _getStatusBadgeType(status);
    final time = _formatDateTime(
        item['createdAt'] ?? item['createTime'] ?? item['outboundTime']);
    final items = _extractProductItems(item);

    return Container(
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
          onTap: () => _showOutboundDetail(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(code, customer, statusText, statusType),
                const SizedBox(height: 12),
                _buildProductList(items),
                const SizedBox(height: 12),
                _buildCardFooter(item, code, statusText, status, time),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_OutboundProductItem> _extractProductItems(Map<String, dynamic> item) {
    final raw = item['items'] as List?;
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((e) => _OutboundProductItem(
              name: (e['productName'] ?? e['name'] ?? '商品').toString(),
              quantity: (e['quantity'] is int)
                  ? e['quantity'] as int
                  : int.tryParse(e['quantity']?.toString() ?? '0') ?? 0,
            ))
        .toList();
  }

  Widget _buildCardHeader(String code, String customer, String statusText,
      BadgeType statusType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '订单号: $code',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                customer,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusBadge(
          text: statusText,
          type: statusType,
        ),
      ],
    );
  }

  Widget _buildProductList(List<_OutboundProductItem> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '暂无商品明细',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: items.map((product) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'x ${product.quantity}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildCardFooter(Map<String, dynamic> item, String code,
      String statusText, String? status, String time) {
    final isPending = status == 'pending';
    return Column(
      children: [
        Container(
          height: 1,
          color: AppColors.borderLight,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                time,
                style: AppTextStyles.captionSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () => _showOutboundDetail(item),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '查看详情',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _startPicking(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '开始拣货',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无出库记录',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '下拉刷新或切换标签查看更多',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        initialStatus: _filterStatus,
        startDate: _startDate,
        endDate: _endDate,
        onApply: (filters) {
          setState(() {
            _filterStatus = filters['status'] as String;
            _startDate = filters['startDate'] as DateTime?;
            _endDate = filters['endDate'] as DateTime?;
          });
          Navigator.pop(context);
          _applyFilter();
        },
      ),
    );
  }

  void _showOutboundDetail(Map<String, dynamic> item) {
    final code = (item['outboundNo'] ?? item['code'] ?? item['id'] ?? '')
        .toString();
    final customer = (item['customer'] ??
            item['stationName'] ??
            item['customerName'] ??
            '未知客户')
        .toString();
    final statusText = _getStatusText(item['status']?.toString());
    final type = _getTypeText(item['type']?.toString());
    final time = _formatDateTime(
        item['createdAt'] ?? item['createTime'] ?? item['outboundTime']);
    final driver = (item['driverName'] ?? item['driver'] ?? '').toString();
    final remark = (item['remark'] ?? '暂无').toString();
    final items = _extractProductItems(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '出库详情',
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
              _buildDetailRow('订单号', code),
              _buildDetailRow('客户名称', customer),
              _buildDetailRow('出库类型', type),
              _buildDetailRow('出库状态', statusText),
              _buildDetailRow('创建时间', time),
              if (driver.isNotEmpty) _buildDetailRow('司机', driver),
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
              const SizedBox(height: 12),
              if (items.isEmpty)
                Text(
                  '暂无商品明细',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                )
              else
                ...items.map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTextStyles.body2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'x ${product.quantity}',
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 20),
              AppButton(
                text: '关闭',
                type: AppButtonType.outline,
                isFullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _startPicking(Map<String, dynamic> item) async {
    final code = (item['outboundNo'] ?? item['code'] ?? item['id'] ?? '')
        .toString();
    final id = item['id']?.toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开始拣货'),
        content: Text('确认开始为订单 $code 拣货吗？'),
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
      final success = await warehouseService.confirmOutbound(id);

      if (success && mounted) {
        _showSuccessSnackbar('订单 $code 已开始拣货');
        await _loadData();
      } else if (mounted) {
        _showErrorSnackbar('操作失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('开始拣货失败: $e');
      }
    }
  }
}

class _OutboundProductItem {
  final String name;
  final int quantity;

  const _OutboundProductItem({
    required this.name,
    required this.quantity,
  });
}

class _FilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(Map<String, dynamic>) onApply;

  const _FilterBottomSheet({
    required this.onApply,
    this.initialStatus = '全部',
    this.startDate,
    this.endDate,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = ['全部', '待拣货', '拣货中', '已出库'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '筛选条件',
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
          Text(
            '出库状态',
            style: AppTextStyles.subtitle2,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((status) => GestureDetector(
              onTap: () {
                setState(() => _selectedStatus = status);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedStatus == status
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedStatus == status
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.body2.copyWith(
                    color: _selectedStatus == status
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '重置',
                  type: AppButtonType.outline,
                  onPressed: () {
                    setState(() {
                      _selectedStatus = '全部';
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '应用',
                  type: AppButtonType.primary,
                  onPressed: () {
                    widget.onApply({
                      'status': _selectedStatus,
                      'startDate': _startDate,
                      'endDate': _endDate,
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
