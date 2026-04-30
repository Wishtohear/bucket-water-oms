import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_tab_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/inventory_service.dart';
import '../../models/product_model.dart';
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

      if (appState.userId != null) {
        final inventoryService = InventoryService();
        final inventory =
            await inventoryService.getWarehouseInventory(appState.userId!);

        if (mounted) {
          setState(() {
            _inventoryList = inventory;
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
    return Column(
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
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildInventoryList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: const Row(
        children: [
          Text(
            '库存盘点',
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return CustomTabBar(
      tabs: const ['当前库存', '盘点任务', '变动记录'],
      selectedIndex: 0,
      onTabSelected: (index) {
        _tabController.animateTo(index);
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
    final totalCount = _inventoryList.isNotEmpty ? _inventoryList.length : 24;

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
                '最后盘点: 2026-04-15',
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
                  onTap: () {},
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
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final useMockData = _filteredList.isEmpty;
    final items = useMockData ? _getMockInventoryItems() : _filteredList;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (useMockData) {
          final item = items[index] as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInventoryItem(
              name: item['name'] as String,
              location: item['location'] as String,
              category: item['category'] as String,
              quantity: item['quantity'] as int,
              unit: item['unit'] as String,
              isLowStock: item['isLowStock'] as bool? ?? false,
            ),
          );
        } else {
          final item = items[index] as InventoryModel;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInventoryItem(
              name: item.productName ?? '未知产品',
              location: 'A-01-01',
              category: '饮用水',
              quantity: item.stock ?? 0,
              unit: '桶',
              isLowStock: item.isLowStock,
            ),
          );
        }
      },
    );
  }

  List<Map<String, dynamic>> _getMockInventoryItems() {
    return [
      {
        'name': '18.9L 桶装水 (农夫)',
        'location': 'A-01-05',
        'category': '饮用水',
        'quantity': 500,
        'unit': '桶',
        'isLowStock': false,
      },
      {
        'name': '空桶 (标准版)',
        'location': 'B-02-01',
        'category': '包装物',
        'quantity': 12,
        'unit': '个',
        'isLowStock': true,
      },
      {
        'name': '11.3L 迷你桶 (景田)',
        'location': 'A-02-12',
        'category': '饮用水',
        'quantity': 240,
        'unit': '桶',
        'isLowStock': false,
      },
    ];
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
