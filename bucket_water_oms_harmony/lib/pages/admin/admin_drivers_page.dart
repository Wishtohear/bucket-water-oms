import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_button.dart';
import 'admin_driver_detail_page.dart';

class AdminDriversPage extends StatefulWidget {
  const AdminDriversPage({super.key});

  @override
  State<AdminDriversPage> createState() => _AdminDriversPageState();
}

class _AdminDriversPageState extends State<AdminDriversPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = '全部状态';
  String _selectedArea = '全部区域';
  int _currentPage = 1;
  int _totalPages = 2;

  final List<Map<String, dynamic>> _drivers = [
    {
      'name': '张小龙',
      'id': 'DRV-2024-001',
      'phone': '138-0000-1001',
      'area': '中心城区',
      'status': '在线配送中',
      'statusColor': AppColors.success,
      'todayDeliveries': 12,
      'joinDate': '2024-03-15',
      'avatar': null,
    },
    {
      'name': '刘师傅',
      'id': 'DRV-2024-003',
      'phone': '138-0000-1003',
      'area': '城西区',
      'status': '在线待命',
      'statusColor': AppColors.success,
      'todayDeliveries': 8,
      'joinDate': '2024-05-20',
      'avatar': null,
    },
    {
      'name': '陈司机',
      'id': 'DRV-2024-005',
      'phone': '138-0000-1005',
      'area': '城南区',
      'status': '休息中',
      'statusColor': AppColors.warning,
      'todayDeliveries': 5,
      'joinDate': '2024-06-10',
      'avatar': null,
    },
    {
      'name': '王力',
      'id': 'DRV-2024-007',
      'phone': '138-0000-1007',
      'area': '城北区',
      'status': '离线',
      'statusColor': AppColors.textSecondary,
      'todayDeliveries': 10,
      'joinDate': '2024-01-08',
      'avatar': null,
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
          '司机管理',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.person_add_outlined, color: AppColors.primary),
            onPressed: _showAddDriverDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildDriversList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.bgCard,
      child: Column(
        children: [
          AppTextField(
            controller: _searchController,
            hintText: '搜索司机姓名、工号、电话...',
            prefixIcon: Icons.search,
            suffixIcon: GestureDetector(
              onTap: () {
                _searchController.clear();
              },
              child: const Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: '在线状态',
                  value: _selectedStatus,
                  items: ['全部状态', '在线', '离线', '休息中'],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: '负责区域',
                  value: _selectedArea,
                  items: ['全部区域', '中心城区', '城西区', '城南区', '城北区'],
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '重置',
                  type: AppButtonType.outline,
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedStatus = '全部状态';
                      _selectedArea = '全部区域';
                    });
                  },
                  height: 44,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '查询',
                  type: AppButtonType.primary,
                  onPressed: () {
                    _performSearch();
                  },
                  height: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: AppTextStyles.body2),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDriversList() {
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
            itemCount: _drivers.length,
            itemBuilder: (context, index) {
              return _buildDriverCard(_drivers[index]);
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
            label: '司机总数',
            value: '20',
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '在线司机',
            value: '12',
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '配送中',
            value: '8',
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '本月完成',
            value: '2,580 单',
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
                    '司机信息',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '工号',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '联系电话',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '负责区域',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
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
                Expanded(
                  child: Text(
                    '今日配送',
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
          ..._drivers.map((driver) => _buildTableRow(driver)),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> driver) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDriverDetailPage(driver: driver),
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
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: driver['statusColor'] as Color,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
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
                          driver['name'],
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '入职: ${driver['joinDate']}',
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
            Expanded(
              child: Text(
                driver['id'],
                style: AppTextStyles.body2.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              child: Text(
                driver['phone'],
                style: AppTextStyles.body2,
              ),
            ),
            Expanded(
              child: Text(
                driver['area'],
                style: AppTextStyles.body2,
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (driver['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: driver['statusColor'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        driver['status'],
                        style: AppTextStyles.captionSmall.copyWith(
                          color: driver['statusColor'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${driver['todayDeliveries']} 单',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
                          builder: (_) => AdminDriverDetailPage(driver: driver),
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textSecondary),
                    onSelected: (value) {
                      switch (value) {
                        case 'dispatch':
                          _showComingSoon('派单');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'dispatch',
                        child: Text('派单'),
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

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '共 ${_drivers.length * _totalPages} 名司机记录',
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
            '业绩排行',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRankItem(1, '张小龙', '312 单', AppColors.success),
          const SizedBox(height: 12),
          _buildRankItem(2, '刘师傅', '280 单', AppColors.primary),
          const SizedBox(height: 12),
          _buildRankItem(3, '陈司机', '265 单', AppColors.purple),
          const SizedBox(height: 12),
          _buildRankItem(4, '王力', '245 单', AppColors.orange),
          const SizedBox(height: 12),
          _buildRankItem(5, '赵师傅', '230 单', AppColors.teal),
        ],
      ),
    );
  }

  Widget _buildRankItem(int rank, String name, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: rank <= 3 ? color : AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: AppTextStyles.captionSmall.copyWith(
                color: rank <= 3 ? AppColors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.body2,
          ),
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

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDriverDetailPage(driver: driver),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: driver['statusColor'] as Color,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['name'],
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        driver['id'],
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (driver['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: driver['statusColor'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        driver['status'],
                        style: AppTextStyles.captionSmall.copyWith(
                          color: driver['statusColor'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                        '联系电话',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        driver['phone'],
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
                        '负责区域',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        driver['area'],
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
                        '今日配送',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${driver['todayDeliveries']} 单',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                          builder: (_) => AdminDriverDetailPage(driver: driver),
                        ),
                      );
                    },
                    height: 36,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: '派单',
                    type: AppButtonType.primary,
                    onPressed: () => _showComingSoon('派单'),
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

  void _performSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('搜索完成'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddDriverDialog() {
    _showComingSoon('新增司机');
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
