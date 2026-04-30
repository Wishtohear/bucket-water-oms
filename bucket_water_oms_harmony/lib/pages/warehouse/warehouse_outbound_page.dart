import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/status_badge.dart';

class WarehouseOutboundPage extends StatefulWidget {
  const WarehouseOutboundPage({super.key});

  @override
  State<WarehouseOutboundPage> createState() => _WarehouseOutboundPageState();
}

class _WarehouseOutboundPageState extends State<WarehouseOutboundPage> {
  int _currentIndex = 2;
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<_OutboundItem> _outboundList = [
    _OutboundItem(
      code: 'CK2026041905',
      customer: '张记旗舰水站',
      status: '待拣货',
      statusType: BadgeType.primary,
      items: const [
        _OutboundProductItem(name: '18.9L 桶装水 (农夫)', quantity: 15),
        _OutboundProductItem(name: '11.3L 迷你桶 (景田)', quantity: 5),
      ],
      time: '2026-04-19 11:20',
    ),
    _OutboundItem(
      code: 'CK2026041904',
      customer: '李家村便利店',
      status: '已出库',
      statusType: BadgeType.success,
      items: const [
        _OutboundProductItem(name: '18.9L 桶装水 (怡宝)', quantity: 30),
      ],
      time: '2026-04-19 09:15',
    ),
    _OutboundItem(
      code: 'CK2026041903',
      customer: '西城区配送中心',
      status: '拣货中',
      statusType: BadgeType.warning,
      items: const [
        _OutboundProductItem(name: '18.9L 纯净水 (哇哈哈)', quantity: 50),
        _OutboundProductItem(name: '5L 瓶装水 (农夫)', quantity: 100),
      ],
      time: '2026-04-19 08:30',
    ),
    _OutboundItem(
      code: 'CK2026041902',
      customer: '东郊水业公司',
      status: '已出库',
      statusType: BadgeType.success,
      items: const [
        _OutboundProductItem(name: '18.9L 桶装水 (怡宝)', quantity: 80),
        _OutboundProductItem(name: '11.3L 迷你桶 (景田)', quantity: 40),
      ],
      time: '2026-04-19 07:45',
    ),
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
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
    if (_outboundList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _outboundList.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildOutboundCard(item),
      )).toList(),
    );
  }

  Widget _buildOutboundCard(_OutboundItem item) {
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
                _buildCardHeader(item),
                const SizedBox(height: 12),
                _buildProductList(item.items),
                const SizedBox(height: 12),
                _buildCardFooter(item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(_OutboundItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '订单号: ${item.code}',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.customer,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        StatusBadge(
          text: item.status,
          type: item.statusType,
        ),
      ],
    );
  }

  Widget _buildProductList(List<_OutboundProductItem> items) {
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

  Widget _buildCardFooter(_OutboundItem item) {
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
            Text(
              item.time,
              style: AppTextStyles.captionSmall,
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
                if (item.status == '待拣货') ...[
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
              '点击下方按钮创建新的出库单',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        onApply: (filters) {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOutboundDetail(_OutboundItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OutboundDetailSheet(item: item),
    );
  }

  void _startPicking(_OutboundItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开始拣货'),
        content: Text('确认开始为订单 ${item.code} 拣货吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _outboundList.indexOf(item);
                if (index != -1) {
                  _outboundList[index] = _OutboundItem(
                    code: item.code,
                    customer: item.customer,
                    status: '拣货中',
                    statusType: BadgeType.warning,
                    items: item.items,
                    time: item.time,
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

class _OutboundItem {
  final String code;
  final String customer;
  final String status;
  final BadgeType statusType;
  final List<_OutboundProductItem> items;
  final String time;

  const _OutboundItem({
    required this.code,
    required this.customer,
    required this.status,
    required this.statusType,
    required this.items,
    required this.time,
  });
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
  final Function(Map<String, dynamic>) onApply;

  const _FilterBottomSheet({required this.onApply});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _selectedStatus = '全部';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = ['全部', '待拣货', '拣货中', '已出库'];

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

class _OutboundDetailSheet extends StatelessWidget {
  final _OutboundItem item;

  const _OutboundDetailSheet({required this.item});

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
          _buildDetailRow('订单号', item.code),
          _buildDetailRow('客户名称', item.customer),
          _buildDetailRow('出库状态', item.status),
          _buildDetailRow('创建时间', item.time),
          const SizedBox(height: 16),
          Text(
            '商品明细',
            style: AppTextStyles.subtitle2,
          ),
          const SizedBox(height: 12),
          ...item.items.map((product) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.body2,
                ),
                Text(
                  'x ${product.quantity}',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
