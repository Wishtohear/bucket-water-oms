import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_button.dart';
import 'admin_warehouse_detail_page.dart';

class AdminWarehousesPage extends StatefulWidget {
  const AdminWarehousesPage({super.key});

  @override
  State<AdminWarehousesPage> createState() => _AdminWarehousesPageState();
}

class _AdminWarehousesPageState extends State<AdminWarehousesPage> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  int _totalPages = 2;

  final List<Map<String, dynamic>> _warehouses = [
    {
      'name': '中心仓库 (总库)',
      'location': '杭州市江干区九堡镇',
      'manager': '李经理',
      'phone': '138-0000-2001',
      'capacity': 50000,
      'currentStock': 42500,
      'status': '正常运营',
      'statusColor': AppColors.success,
    },
    {
      'name': '西区分仓',
      'location': '杭州市西湖区留下镇',
      'manager': '张主管',
      'phone': '138-0000-2002',
      'capacity': 30000,
      'currentStock': 28500,
      'status': '正常运营',
      'statusColor': AppColors.success,
    },
    {
      'name': '南区分仓',
      'location': '杭州市滨江区长河镇',
      'manager': '王主管',
      'phone': '138-0000-2003',
      'capacity': 25000,
      'currentStock': 24500,
      'status': '库存告警',
      'statusColor': AppColors.warning,
    },
    {
      'name': '北区分仓',
      'location': '杭州市拱墅区康桥镇',
      'manager': '赵主管',
      'phone': '138-0000-2004',
      'capacity': 20000,
      'currentStock': 12800,
      'status': '正常运营',
      'statusColor': AppColors.success,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '仓库管理',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: _showAddWarehouseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildWarehousesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.bgCard,
      child: AppTextField(
        controller: _searchController,
        hintText: '搜索仓库名称、负责人、电话...',
        prefixIcon: Icons.search,
        suffixIcon: GestureDetector(
          onTap: () {
            _searchController.clear();
          },
          child: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildWarehousesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        _buildStatsRow(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTable(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummary(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildStatsRow(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _warehouses.length,
            itemBuilder: (context, index) {
              return _buildWarehouseCard(_warehouses[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatChip(
            label: '仓库总数',
            value: '4',
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '总容量',
            value: '125,000',
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '当前库存',
            value: '108,300',
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.subtitle1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '仓库信息',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '负责人',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '库容使用',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '状态',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 80),
              ],
            ),
          ),
          ..._warehouses.map((warehouse) => _buildTableRow(warehouse)),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> warehouse) {
    final usageRate = (warehouse['currentStock'] / warehouse['capacity'] * 100).round();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminWarehouseDetailPage(warehouse: warehouse),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warehouse,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse['name'],
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          warehouse['location'],
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                    warehouse['manager'],
                    style: AppTextStyles.body2,
                  ),
                  Text(
                    warehouse['phone'],
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${warehouse['currentStock']}/${warehouse['capacity']}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: warehouse['currentStock'] / warehouse['capacity'],
                    backgroundColor: AppColors.bgInput,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      usageRate > 90 ? AppColors.error : usageRate > 70 ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$usageRate%',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (warehouse['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    warehouse['status'],
                    style: AppTextStyles.captionSmall.copyWith(
                      color: warehouse['statusColor'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminWarehouseDetailPage(warehouse: warehouse),
                        ),
                      );
                    },
                    child: Text(
                      '详情',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '共 ${_warehouses.length * _totalPages} 个仓库记录',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
              ),
              ...List.generate(
                _totalPages > 5 ? 5 : _totalPages,
                (index) {
                  final page = index + 1;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _currentPage == page
                              ? AppColors.primary
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _currentPage == page
                                ? AppColors.primary
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$page',
                            style: AppTextStyles.body2.copyWith(
                              color: _currentPage == page
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '库存预警',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '南区分仓库存告警',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '当前库存接近容量上限，请及时调配',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.warning.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '本周入库统计',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryItem('生产入库', '8,500 桶', AppColors.success),
          const SizedBox(height: 8),
          _buildSummaryItem('调拨入库', '1,200 桶', AppColors.primary),
          const SizedBox(height: 8),
          _buildSummaryItem('退货入库', '580 桶', AppColors.purple),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2,
        ),
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseCard(Map<String, dynamic> warehouse) {
    final usageRate = (warehouse['currentStock'] / warehouse['capacity'] * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminWarehouseDetailPage(warehouse: warehouse),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warehouse,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warehouse['name'],
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        warehouse['location'],
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (warehouse['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    warehouse['status'],
                    style: AppTextStyles.captionSmall.copyWith(
                      color: warehouse['statusColor'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        '负责人',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        warehouse['manager'],
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '联系电话',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        warehouse['phone'],
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '库容使用',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$usageRate%',
                      style: AppTextStyles.captionSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: usageRate > 90 ? AppColors.error : usageRate > 70 ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: warehouse['currentStock'] / warehouse['capacity'],
                  backgroundColor: AppColors.bgInput,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    usageRate > 90 ? AppColors.error : usageRate > 70 ? AppColors.warning : AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${warehouse['currentStock']} / ${warehouse['capacity']}',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '详情',
                    type: AppButtonType.outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminWarehouseDetailPage(warehouse: warehouse),
                        ),
                      );
                    },
                    height: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWarehouseDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('新增仓库功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
