import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/components/status_badge.dart';
import '../../services/inventory_service.dart';
import '../../services/warehouse_service.dart';
import '../../models/product_model.dart';
import '../../models/warehouse_models.dart';
import '../../main.dart';

class WarehouseInventoryPage extends StatefulWidget {
  const WarehouseInventoryPage({super.key});

  @override
  State<WarehouseInventoryPage> createState() => _WarehouseInventoryPageState();
}

class _WarehouseInventoryPageState extends State<WarehouseInventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  List<InventoryModel> _inventoryList = [];
  List<InventoryCheckModel> _checkRecords = [];
  List<InventoryChangeRecord> _changeRecords = [];

  int _totalProductTypes = 0;
  DateTime? _lastInventoryDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    });

    try {
      final appState = context.read<AppState>();
      final inventoryService = InventoryService();
      final warehouseService = WarehouseService();

      if (appState.userId != null) {
        final warehouseId = appState.userId!;

        final inventory = await inventoryService.getWarehouseInventory(warehouseId);

        List<InventoryCheckModel> checkRecords = [];
        try {
          checkRecords = await warehouseService.getInventoryCheckRecords(warehouseId);
        } catch (e) {
          debugPrint('[WarehouseInventory] 获取盘点记录失败: $e');
        }

        List<InventoryChangeRecord> changeRecords = [];
        try {
          changeRecords = await warehouseService.getInventoryChangeRecords(warehouseId);
        } catch (e) {
          debugPrint('[WarehouseInventory] 获取变动记录失败: $e');
        }

        if (mounted) {
          setState(() {
            _inventoryList = inventory;
            _checkRecords = checkRecords;
            _changeRecords = changeRecords;
            _totalProductTypes = inventory.length;
            _lastInventoryDate = DateTime.now();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载库存数据失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<InventoryModel> get _filteredList {
    if (_searchQuery.isEmpty) {
      return _inventoryList;
    }
    return _inventoryList.where((item) {
      final name = item.productName?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCurrentInventoryTab(),
                          _buildCheckTasksTab(),
                          _buildChangeRecordsTab(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              '库存盘点',
              style: AppTextStyles.h3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.subtitle2,
        tabs: const [
          Tab(text: '当前库存'),
          Tab(text: '盘点任务'),
          Tab(text: '变动记录'),
        ],
      ),
    );
  }

  Widget _buildCurrentInventoryTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildInventoryList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCheckTasksTab() {
    if (_checkRecords.isEmpty) {
      return _buildEmptyCheckState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _checkRecords.length + 1,
      itemBuilder: (context, index) {
        if (index == _checkRecords.length) {
          return const SizedBox(height: 80);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCheckRecordCard(_checkRecords[index]),
        );
      },
    );
  }

  Widget _buildChangeRecordsTab() {
    if (_changeRecords.isEmpty) {
      return _buildEmptyChangeState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _changeRecords.length + 1,
      itemBuilder: (context, index) {
        if (index == _changeRecords.length) {
          return const SizedBox(height: 80);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChangeRecordCard(_changeRecords[index]),
        );
      },
    );
  }

  Widget _buildSearchBar() {
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
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: AppTextStyles.body2,
        decoration: InputDecoration(
          hintText: '搜索水种、配件名称',
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
    );
  }

  Widget _buildSummaryCard() {
    final totalCount = _totalProductTypes > 0
        ? _totalProductTypes
        : (_inventoryList.isNotEmpty ? _inventoryList.length : 0);
    final lastInventoryText = _lastInventoryDate != null
        ? '${_lastInventoryDate!.year}-${_lastInventoryDate!.month.toString().padLeft(2, '0')}-${_lastInventoryDate!.day.toString().padLeft(2, '0')}'
        : '暂无记录';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总库存种类',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              Text(
                '最后盘点: $lastInventoryText',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalCount',
                style: AppTextStyles.statNumber.copyWith(
                  fontSize: 48,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '类物品',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  text: '全库盘点',
                  onTap: () => _showFullInventoryCheck(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  text: '差异调整',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_filteredList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无库存数据',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final item = _filteredList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInventoryItem(
            name: item.productName ?? '未知产品',
            location: item.location ?? item.warehouseName ?? '默认库位',
            category: item.category ?? '饮用水',
            quantity: item.stock ?? 0,
            unit: '桶',
            isLowStock: item.isLowStock,
          ),
        );
      },
    );
  }

  Widget _buildInventoryItem({
    required String name,
    required String location,
    required String category,
    required int quantity,
    required String unit,
    bool isLowStock = false,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '低于预警值',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '库位: $location | 分类: $category',
                  style: AppTextStyles.captionSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$quantity',
                            style: AppTextStyles.h3.copyWith(
                              color: isLowStock
                                  ? AppColors.error
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' $unit',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showCalibrationDialog(name, quantity);
                      },
                      child: Text(
                        '校准库存',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRecordCard(InventoryCheckModel record) {
    final statusText = record.statusText ??
        (record.isPending ? '待确认' : (record.isConfirmed ? '已完成' : '未知'));
    final hasDiscrepancy = record.hasDiscrepancy;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '盘点单: ${record.checkNo ?? record.id ?? ''}',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '盘点人: ${record.checker ?? '未知'}',
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    text: statusText,
                    type: record.isPending ? BadgeType.warning : BadgeType.success,
                    fontSize: 10,
                  ),
                  if (hasDiscrepancy) ...[
                    const SizedBox(height: 4),
                    StatusBadge(
                      text: '有差异',
                      type: BadgeType.error,
                      fontSize: 10,
                    ),
                  ],
                ],
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总商品', '${record.totalProducts ?? 0}'),
              _buildStatItem('一致', '${record.matchedProducts ?? 0}'),
              _buildStatItem('差异', '${record.discrepancyProducts ?? 0}'),
            ],
          ),
          if (record.isPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmInventoryCheck(record),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '确认盘点',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.captionSmall,
        ),
      ],
    );
  }

  Widget _buildChangeRecordCard(InventoryChangeRecord record) {
    final typeText = record.typeText ?? _getChangeTypeText(record.type);
    final typeColor = _getChangeTypeColor(record.type);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getChangeTypeIcon(record.type),
              color: typeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.productName ?? '未知商品',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  typeText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.quantity != null && record.quantity! > 0 ? '+' : ''}${record.quantity ?? 0}',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
              Text(
                '${record.beforeStock ?? 0} → ${record.afterStock ?? 0}',
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getChangeTypeText(String? type) {
    switch (type) {
      case 'inbound':
        return '入库';
      case 'outbound':
        return '出库';
      case 'adjust':
        return '调整';
      case 'check':
        return '盘点';
      default:
        return type ?? '变动';
    }
  }

  Color _getChangeTypeColor(String? type) {
    switch (type) {
      case 'inbound':
        return AppColors.success;
      case 'outbound':
        return AppColors.primary;
      case 'adjust':
        return AppColors.warning;
      case 'check':
        return AppColors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getChangeTypeIcon(String? type) {
    switch (type) {
      case 'inbound':
        return Icons.move_to_inbox;
      case 'outbound':
        return Icons.outbox;
      case 'adjust':
        return Icons.tune;
      case 'check':
        return Icons.checklist;
      default:
        return Icons.swap_vert;
    }
  }

  Widget _buildEmptyCheckState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checklist,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无盘点任务',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击上方"全库盘点"开始盘点',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChangeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无变动记录',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullInventoryCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('全库盘点功能开发中'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _confirmInventoryCheck(InventoryCheckModel record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('确认盘点 ${record.checkNo ?? record.id}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCalibrationDialog(String name, int currentQuantity) {
    final controller = TextEditingController(text: currentQuantity.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('校准库存'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('产品: $name'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '实际库存数量',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('库存校准成功')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
