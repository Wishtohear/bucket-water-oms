import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_bottom_bar.dart';

class InventoryManagePage extends StatefulWidget {
  const InventoryManagePage({super.key});

  @override
  State<InventoryManagePage> createState() => _InventoryManagePageState();
}

class _InventoryManagePageState extends State<InventoryManagePage> {
  int _currentIndex = 3;
  
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'name': '18.9L 桶装矿泉水',
      'spec': '18.9L/桶',
      'stock': 850,
      'warningThreshold': 100,
      'isLowStock': false,
      'lastLog': '入库 100 桶',
      'lastLogDate': '04-19 09:30',
      'lastLogOperator': '张三',
    },
    {
      'name': '11.3L 迷你桶装水',
      'spec': '11.3L/桶',
      'stock': 320,
      'warningThreshold': 50,
      'isLowStock': false,
      'lastLog': '出库 20 桶',
      'lastLogDate': '04-19 10:15',
      'lastLogOperator': '李四',
    },
    {
      'name': '550ml 瓶装水(24瓶/箱)',
      'spec': '550ml*24',
      'stock': 110,
      'warningThreshold': 20,
      'isLowStock': false,
      'lastLog': '出库 5 箱',
      'lastLogDate': '04-18 16:20',
      'lastLogOperator': '王五',
    },
  ];

  final List<Map<String, dynamic>> _recentLogs = [
    {
      'type': 'inbound',
      'color': AppColors.primary,
      'product': '18.9L 桶装水',
      'action': '入库',
      'quantity': 100,
      'unit': '桶', 
      'date': '04-19 09:30',
      'operator': '张三',
    },
    {
      'type': 'outbound',
      'color': AppColors.error,
      'product': '11.3L 迷你桶装水',
      'action': '损耗出库',
      'quantity': 2,
      'unit': '桶',
      'date': '04-18 16:20',
      'operator': '备注: 运输破损',
    },
  ];

  int get _totalStock {
    int total = 0;
    for (var item in _inventoryItems) {
      total += item['stock'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          _buildOrderContent(),
          _buildStatementContent(),
          _buildInventoryContent(),
        ],
      ),
      bottomNavigationBar: OwnerBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return const Center(child: Text('首页'));
  }

  Widget _buildOrderContent() {
    return const Center(child: Text('订单'));
  }

  Widget _buildStatementContent() {
    return const Center(child: Text('财务'));
  }

  Widget _buildInventoryContent() {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildInventoryList(),
                    const SizedBox(height: 16),
                    _buildRecentLogsCard(),
                    const SizedBox(height: 100),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '库存管理',
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '在库总桶数',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalStock',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '在途入库',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '200',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.add_circle_outline,
          iconColor: AppColors.primary,
          label: '商品入库',
        ),
        _buildActionButton(
          icon: Icons.remove_circle_outline,
          iconColor: AppColors.error,
          label: '损耗出库',
        ),
        _buildActionButton(
          icon: Icons.refresh,
          iconColor: AppColors.warning,
          label: '库存盘点',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '商品列表',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._inventoryItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInventoryItem(item),
          );
        }),
      ],
    );
  }

  Widget _buildInventoryItem(Map<String, dynamic> item) {
    final isLowStock = item['isLowStock'] as bool;

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
                Text(
                  item['name'] as String,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '规格: ${item['spec']}',
                  style: AppTextStyles.captionSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '库存: ${item['stock']} ${item['spec'].toString().split('/')[1]}',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '库存预警: ${item['warningThreshold']}',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '查看日志',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildRecentLogsCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近动态',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentLogs.map((log) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: log['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${log['product']} ${log['action']} ${log['quantity']} ${log['unit']}',
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${log['date']} · 操作人: ${log['operator']}',
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
