import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/warehouse_service.dart';
import '../../models/warehouse_models.dart';

class WarehouseBucketOutboundPage extends StatefulWidget {
  const WarehouseBucketOutboundPage({super.key});

  @override
  State<WarehouseBucketOutboundPage> createState() =>
      _WarehouseBucketOutboundPageState();
}

class _WarehouseBucketOutboundPageState
    extends State<WarehouseBucketOutboundPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WarehouseService _warehouseService = WarehouseService();

  final List<String> _tabs = ['司机领用', '调拨出库', '损耗出库'];
  final List<String> _typeFilters = ['driver_pickup', 'transfer_out', 'damage'];

  bool _isLoading = true;
  bool _isInventoryLoading = true;
  String? _errorMessage;
  List<OutboundModel> _outboundList = [];
  String _currentFilter = 'driver_pickup';

  Map<String, int> _inventorySummary = {
    '18.9L标准桶': 0,
    '11.3L迷你桶': 0,
    '其他规格': 0,
  };
  int _todayOutboundCount = 0;
  int _today189Outbound = 0;
  int _today113Outbound = 0;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentFilter = _typeFilters[_tabController.index];
    });
    _loadOutboundList();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadInventorySummary(),
      _loadOutboundList(),
    ]);
  }

  Future<void> _loadInventorySummary() async {
    if (!mounted) return;

    setState(() => _isInventoryLoading = true);

    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId.isEmpty) {
        setState(() => _isInventoryLoading = false);
        return;
      }

      final inventory = await _warehouseService.getInventory(warehouseId);

      if (mounted) {
        final summary = <String, int>{
          '18.9L标准桶': 0,
          '11.3L迷你桶': 0,
          '其他规格': 0,
        };

        for (final item in inventory) {
          final name = item.productName ?? '';
          if (name.contains('18.9') || name.contains('标准')) {
            summary['18.9L标准桶'] =
                (summary['18.9L标准桶'] ?? 0) + (item.stock ?? 0);
          } else if (name.contains('11.3') || name.contains('迷你')) {
            summary['11.3L迷你桶'] =
                (summary['11.3L迷你桶'] ?? 0) + (item.stock ?? 0);
          } else {
            summary['其他规格'] = (summary['其他规格'] ?? 0) + (item.stock ?? 0);
          }
        }

        setState(() {
          _inventorySummary = summary;
          _lastUpdateTime = DateTime.now();
          _isInventoryLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[BucketOutbound] 加载库存概览失败: $e');
      if (mounted) {
        setState(() {
          _isInventoryLoading = false;
        });
      }
    }
  }

  Future<void> _loadOutboundList() async {
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

      final list = await _warehouseService.getOutboundList(
        warehouseId,
        status: null,
      );

      if (mounted) {
        final filteredList =
            list.where((item) => item.type == _currentFilter).toList();

        int pendingCount = 0;
        int today189 = 0;
        int today113 = 0;

        for (final item in filteredList) {
          if (item.isPending) pendingCount++;
          if (item.isConfirmed && item.confirmTime != null) {
            final today = DateTime.now();
            if (item.confirmTime!.year == today.year &&
                item.confirmTime!.month == today.month &&
                item.confirmTime!.day == today.day) {
              today189 += (item.totalQuantity ?? 0);
            }
          }
        }

        setState(() {
          _outboundList = filteredList;
          _todayOutboundCount = pendingCount;
          _today189Outbound = today189;
          _today113Outbound = today113;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[BucketOutbound] 加载出库列表失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载出库列表失败';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmOutbound(String outboundId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认出库'),
        content: const Text('确认空桶已出库？'),
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

    if (confirmed != true) return;

    try {
      await _warehouseService.confirmOutbound(outboundId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('出库确认成功'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadData();
      }
    } catch (e) {
      debugPrint('[BucketOutbound] 确认出库失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('确认出库失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectOutbound(String outboundId) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝出库'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '拒绝原因',
            hintText: '请输入拒绝原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('确认拒绝'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('拒绝功能开发中'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      debugPrint('[BucketOutbound] 拒绝出库失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('创建出库功能开发中'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '空桶出库',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.subtitle2.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInventorySummary(),
            const SizedBox(height: 20),
            _buildOutboundListTitle(),
            const SizedBox(height: 12),
            _buildOutboundList(),
            const SizedBox(height: 20),
            _buildTodayStats(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '空桶库存概览',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              if (_lastUpdateTime != null)
                Text(
                  '最后更新: ${_formatTime(_lastUpdateTime!)}',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInventoryItem(
                  '18.9L标准桶', _inventorySummary['18.9L标准桶'] ?? 0),
              const SizedBox(width: 12),
              _buildInventoryItem(
                  '11.3L迷你桶', _inventorySummary['11.3L迷你桶'] ?? 0),
              const SizedBox(width: 12),
              _buildInventoryItem('其他规格', _inventorySummary['其他规格'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Text(
              '个',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutboundListTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '领用申请',
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: _loadOutboundList,
          child: const Text('刷新'),
        ),
      ],
    );
  }

  Widget _buildOutboundList() {
    if (_outboundList.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 16,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                '暂无出库记录',
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
      children: _outboundList.map((outbound) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOutboundCard(outbound),
        );
      }).toList(),
    );
  }

  Widget _buildOutboundCard(OutboundModel outbound) {
    final isPending = outbound.isPending;
    final isCompleted = outbound.isConfirmed;
    final isPreparing = outbound.status == 'preparing';

    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = AppColors.primary;
      statusText = '待出库';
    } else if (isPreparing) {
      statusColor = AppColors.purple;
      statusText = '备货中';
    } else if (isCompleted) {
      statusColor = AppColors.success;
      statusText = '已完成';
    } else {
      statusColor = AppColors.textTertiary;
      statusText = outbound.statusText ?? '未知';
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: isPending ? AppColors.primary.withOpacity(0.3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isPending)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    outbound.creator ?? '未知司机',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (outbound.id != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        outbound.id!.substring(0, 8),
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                if (outbound.items != null && outbound.items!.isNotEmpty)
                  ...outbound.items!.take(2).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.productName ?? '未知商品',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '× ${item.quantity ?? 0} 个',
                              style: AppTextStyles.captionSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        outbound.createTime != null ? '申请时间' : '',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        outbound.createTime != null
                            ? _formatTime(outbound.createTime!)
                            : '',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(outbound),
              ),
              const SizedBox(width: 8),
              if (isCompleted || isPreparing)
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('打印功能开发中'),
                      ),
                    );
                  },
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bgPage,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.print_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(OutboundModel outbound) {
    if (outbound.isPending) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _confirmOutbound(outbound.id ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                '确认出库',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _rejectOutbound(outbound.id ?? ''),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              elevation: 0,
            ),
            child: const Text(
              '拒绝',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    } else if (outbound.isPreparing) {
      return ElevatedButton(
        onPressed: () => _confirmOutbound(outbound.id ?? ''),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: const Text(
          '完成出库',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgPage,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(
          '已完成',
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildTodayStats() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日出库统计',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('出库单数', '$_todayOutboundCount', AppColors.primary),
              const SizedBox(width: 12),
              _buildStatItem(
                  '18.9L出库', '$_today189Outbound', AppColors.success),
              const SizedBox(width: 12),
              _buildStatItem('11.3L出库', '$_today113Outbound', AppColors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.subtitle1.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
