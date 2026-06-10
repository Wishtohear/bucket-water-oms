import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/warehouse_service.dart';
import '../../models/warehouse_models.dart';

class WarehouseBucketInboundPage extends StatefulWidget {
  const WarehouseBucketInboundPage({super.key});

  @override
  State<WarehouseBucketInboundPage> createState() =>
      _WarehouseBucketInboundPageState();
}

class _WarehouseBucketInboundPageState extends State<WarehouseBucketInboundPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WarehouseService _warehouseService = WarehouseService();

  final List<String> _tabs = ['司机回桶', '清洗入库', '调拨入库'];
  final List<String> _typeFilters = ['driver_return', 'clean', 'transfer_in'];

  bool _isLoading = true;
  String? _errorMessage;
  List<InboundModel> _inboundList = [];
  String _currentFilter = 'driver_return';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInboundList();
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
    _loadInboundList();
  }

  Future<void> _loadInboundList() async {
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

      final list = await _warehouseService.getInboundList(
        warehouseId,
        status: null,
      );

      if (mounted) {
        final filteredList = _currentFilter == 'all'
            ? list
            : list.where((item) => item.type == _currentFilter).toList();

        setState(() {
          _inboundList = filteredList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[BucketInbound] 加载入库列表失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载入库列表失败';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmInbound(String inboundId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认入库'),
        content: const Text('确认空桶已验收入库？'),
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
      await _warehouseService.confirmInbound(inboundId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('入库确认成功'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadInboundList();
      }
    } catch (e) {
      debugPrint('[BucketInbound] 确认入库失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('确认入库失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectInbound(String inboundId) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝入库'),
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
      await _warehouseService.rejectInbound(inboundId, reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已拒绝入库'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadInboundList();
      }
    } catch (e) {
      debugPrint('[BucketInbound] 拒绝入库失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拒绝入库失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showInboundDetail(InboundModel inbound) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(inbound),
    );
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
              content: Text('创建入库功能开发中'),
            ),
          );
        },
        backgroundColor: AppColors.success,
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
      child: const Row(
        children: [
          Expanded(
            child: Text(
              '空桶入库',
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
    if (_inboundList.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _loadInboundList,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _inboundList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInboundCard(_inboundList[index]),
          );
        },
      ),
    );
  }

  Widget _buildInboundCard(InboundModel inbound) {
    final isPending = inbound.isPending;
    final statusColor = isPending ? AppColors.success : AppColors.primary;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: isPending ? AppColors.success.withOpacity(0.3) : null,
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
                    '单号: ${inbound.inboundNo ?? inbound.id ?? '未知'}',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inbound.typeText ?? '未知类型',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
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
                  inbound.statusDisplayText,
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
                if (inbound.items != null && inbound.items!.isNotEmpty)
                  ...inbound.items!.take(2).map((item) => Padding(
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
                if (inbound.totalQuantity != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '共计 ${inbound.totalQuantity} 个空桶',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          '来源: ${inbound.typeText}',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
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
              if (inbound.creator != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '送货司机',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inbound.creator!,
                        style: AppTextStyles.captionSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (inbound.createTime != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '送达时间',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(inbound.createTime!),
                        style: AppTextStyles.captionSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                inbound.createTime != null
                    ? _formatDateTime(inbound.createTime!)
                    : '',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showInboundDetail(inbound),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '查看详情',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isPending) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _confirmInbound(inbound.id ?? ''),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '确认入库',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSheet(InboundModel inbound) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '入库详情',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('单号', inbound.inboundNo ?? '未知'),
                _buildDetailRow('类型', inbound.typeText ?? '未知类型'),
                _buildDetailRow('状态', inbound.statusDisplayText),
                _buildDetailRow('送货司机', inbound.creator ?? '未知'),
                if (inbound.checker != null)
                  _buildDetailRow('验收人', inbound.checker!),
                if (inbound.checkTime != null)
                  _buildDetailRow('验收时间', _formatDateTime(inbound.checkTime!)),
                if (inbound.remark != null)
                  _buildDetailRow('备注', inbound.remark!),
                const SizedBox(height: 16),
                if (inbound.items != null && inbound.items!.isNotEmpty) ...[
                  Text(
                    '商品明细',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...inbound.items!.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.productName ?? '未知商品',
                              style: AppTextStyles.body2,
                            ),
                            Text(
                              '× ${item.quantity ?? 0} 个',
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (inbound.isPending) {
                            _rejectInbound(inbound.id ?? '');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('拒绝'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: inbound.isPending
                            ? () {
                                Navigator.pop(context);
                                _confirmInbound(inbound.id ?? '');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('确认入库'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
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
            '暂无入库记录',
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
            onPressed: _loadInboundList,
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

  String _formatDateTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
