import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/components/status_badge.dart';

/// 仓库入库管理页面
/// 
/// 根据原型文件 warehouse_inbound.html 实现，包含以下功能：
/// - 入库单列表展示（采购入库、调拨入库、盘点入库三种类型）
/// - 搜索过滤功能
/// - 新增入库单功能
/// - 入库单详情查看
/// - 入库单确认功能
class WarehouseInboundPage extends StatefulWidget {
  const WarehouseInboundPage({super.key});

  @override
  State<WarehouseInboundPage> createState() => _WarehouseInboundPageState();
}

class _WarehouseInboundPageState extends State<WarehouseInboundPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // 模拟数据列表
  final List<_InboundRecord> _records = [
    _InboundRecord(
      code: 'RK2026041901',
      productName: '18.9L 桶装水 (农夫)',
      quantity: 500,
      handler: '王管理',
      status: InboundStatus.pending,
      createdAt: DateTime(2026, 4, 19, 10, 30),
    ),
    _InboundRecord(
      code: 'RK2026041805',
      productName: '11.3L 迷你桶 (景田)',
      quantity: 200,
      handler: '王管理',
      status: InboundStatus.completed,
      createdAt: DateTime(2026, 4, 18, 15, 45),
    ),
    _InboundRecord(
      code: 'RK2026041801',
      productName: '18.9L 桶装水 (怡宝)',
      quantity: 300,
      handler: '李仓管',
      status: InboundStatus.completed,
      createdAt: DateTime(2026, 4, 18, 09, 20),
    ),
    _InboundRecord(
      code: 'RK2026041708',
      productName: '空桶 (标准版)',
      quantity: 100,
      handler: '张管理',
      status: InboundStatus.pending,
      createdAt: DateTime(2026, 4, 17, 14, 15),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
              child: SingleChildScrollView(
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
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  /// 构建页面头部
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

  /// 构建标签切换栏
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

  /// 构建搜索栏
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
              onTap: () {
                // 筛选功能
              },
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

  /// 构建入库列表
  Widget _buildInboundList() {
    return Column(
      children: _records.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInboundCard(record),
        );
      }).toList(),
    );
  }

  /// 构建入库卡片
  Widget _buildInboundCard(_InboundRecord record) {
    final isPending = record.status == InboundStatus.pending;
    
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
          onTap: () {
            // 查看详情
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：单号 + 状态
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '单号: ${record.code}',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.productName,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge(
                      text: isPending ? '待核验' : '已入库',
                      type: isPending ? BadgeType.warning : BadgeType.success,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 信息区：入库数量 + 经办人
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
                            '${record.quantity} 桶',
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
                            record.handler,
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 分割线
                Container(
                  height: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 12),
                // 底部：时间 + 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateTime(record.createdAt),
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
                          onTap: () {
                            // 查看详情
                          },
                        ),
                        if (isPending) ...[
                          const SizedBox(width: 8),
                          _buildActionButton(
                            text: '确认入库',
                            isPrimary: true,
                            onTap: () {
                              _showConfirmDialog(record);
                            },
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

  /// 构建操作按钮
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
            color: isPrimary ? AppColors.primary : AppColors.primary,
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

  /// 构建浮动添加按钮
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
          onTap: () {
            // 新增入库单
          },
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

  /// 显示确认入库对话框
  void _showConfirmDialog(_InboundRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认入库'),
        content: Text('确认入库单 ${record.code} 已完成？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 确认入库逻辑
              Navigator.pop(context);
              setState(() {
                final index = _records.indexOf(record);
                if (index != -1) {
                  _records[index] = _InboundRecord(
                    code: record.code,
                    productName: record.productName,
                    quantity: record.quantity,
                    handler: record.handler,
                    status: InboundStatus.completed,
                    createdAt: record.createdAt,
                  );
                }
              });
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

/// 入库状态枚举
enum InboundStatus {
  pending,  // 待核验
  completed, // 已入库
}

/// 入库记录数据模型
class _InboundRecord {
  final String code;           // 单号
  final String productName;    // 产品名称
  final int quantity;          // 入库数量
  final String handler;        // 经办人
  final InboundStatus status;  // 状态
  final DateTime createdAt;    // 创建时间

  const _InboundRecord({
    required this.code,
    required this.productName,
    required this.quantity,
    required this.handler,
    required this.status,
    required this.createdAt,
  });
}
