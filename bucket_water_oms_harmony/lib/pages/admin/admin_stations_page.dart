import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_button.dart';
import 'admin_station_detail_page.dart';

class AdminStationsPage extends StatefulWidget {
  const AdminStationsPage({super.key});

  @override
  State<AdminStationsPage> createState() => _AdminStationsPageState();
}

class _AdminStationsPageState extends State<AdminStationsPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = '全部状态';
  String _selectedBalance = '全部';
  int _currentPage = 1;
  int _totalPages = 5;

  final List<Map<String, dynamic>> _stations = [
    {
      'name': '滨江花园水站',
      'address': '杭州市滨江区网商路699号',
      'contact': '张大山',
      'phone': '138-0000-1111',
      'balance': 12500.00,
      'debtBuckets': 45,
      'status': '正常运营',
      'statusColor': AppColors.success,
    },
    {
      'name': '西湖灵隐路水站',
      'address': '杭州市西湖区灵隐路12号',
      'contact': '李小美',
      'phone': '139-1111-2222',
      'balance': -1200.00,
      'debtBuckets': 120,
      'status': '欠费停供',
      'statusColor': AppColors.error,
    },
    {
      'name': '上城湖滨水站',
      'address': '杭州市上城区延安路328号',
      'contact': '王富贵',
      'phone': '137-2222-3333',
      'balance': 5800.00,
      'debtBuckets': 0,
      'status': '正常运营',
      'statusColor': AppColors.success,
    },
    {
      'name': '萧山经开区水站',
      'address': '杭州市萧山区经开大道128号',
      'contact': '赵小军',
      'phone': '136-3333-4444',
      'balance': 8900.00,
      'debtBuckets': 20,
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
          '水站管理',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: _showAddStationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildStationsList(),
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
            hintText: '搜索水站名称、联系人、电话...',
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
                  label: '账户状态',
                  value: _selectedStatus,
                  items: ['全部状态', '正常运营', '欠费停供', '已注销'],
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
                  label: '余额筛选',
                  value: _selectedBalance,
                  items: ['全部', '余额充足', '余额不足', '账户欠费'],
                  onChanged: (value) {
                    setState(() {
                      _selectedBalance = value!;
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
                      _selectedBalance = '全部';
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
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
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

  Widget _buildStationsList() {
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
            itemCount: _stations.length,
            itemBuilder: (context, index) {
              return _buildStationCard(_stations[index]);
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
            label: '水站总数',
            value: '128',
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '正常运营',
            value: '105',
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            label: '欠费停供',
            value: '18',
            color: AppColors.error,
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
                    '水站信息',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '联系人',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '账户余额',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '欠桶数量',
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
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
          ..._stations.map((station) => _buildTableRow(station)),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> station) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminStationDetailPage(station: station),
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
                      Icons.store,
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
                          station['name'],
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          station['address'],
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
                    station['contact'],
                    style: AppTextStyles.body2,
                  ),
                  Text(
                    station['phone'],
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '¥ ${station['balance'].toStringAsFixed(2)}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: station['balance'] < 0 ? AppColors.error : AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: Text(
                '${station['debtBuckets']} 个',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: station['debtBuckets'] > 30 ? AppColors.warning : AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (station['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    station['status'],
                    style: AppTextStyles.captionSmall.copyWith(
                      color: station['statusColor'],
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
                          builder: (_) => AdminStationDetailPage(station: station),
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
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditDialog(station);
                          break;
                        case 'orders':
                          _showComingSoon('查看订单');
                          break;
                        case 'policy':
                          _showComingSoon('配置政策');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('编辑'),
                      ),
                      const PopupMenuItem(
                        value: 'orders',
                        child: Text('查看订单'),
                      ),
                      const PopupMenuItem(
                        value: 'policy',
                        child: Text('配置政策'),
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
            '共 ${_stations.length * _totalPages} 家水站记录',
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
            '汇总统计',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            icon: Icons.account_balance_wallet,
            label: '总预存金额',
            value: '¥ 1,280,450.00',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.warning_amber,
            label: '待收欠款',
            value: '¥ 330,250.00',
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.inventory_2,
            label: '待回收空桶',
            value: '2,580 个',
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.trending_up,
            label: '本月新增',
            value: '8 家',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminStationDetailPage(station: station),
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
                    Icons.store,
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
                        station['name'],
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        station['address'],
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
                    color: (station['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    station['status'],
                    style: AppTextStyles.captionSmall.copyWith(
                      color: station['statusColor'],
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
                        '联系人',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${station['contact']} ${station['phone']}',
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
                        '账户余额',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '¥ ${station['balance'].toStringAsFixed(2)}',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: station['balance'] < 0 ? AppColors.error : AppColors.success,
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
                        '欠桶数量',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${station['debtBuckets']} 个',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: station['debtBuckets'] > 30 ? AppColors.warning : AppColors.textPrimary,
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
                          builder: (_) => AdminStationDetailPage(station: station),
                        ),
                      );
                    },
                    height: 36,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: '编辑',
                    type: AppButtonType.primary,
                    onPressed: () => _showEditDialog(station),
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

  void _showAddStationDialog() {
    _showComingSoon('新增水站');
  }

  void _showEditDialog(Map<String, dynamic> station) {
    _showComingSoon('编辑水站');
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
