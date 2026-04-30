import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class WarehouseReturnCheckPage extends StatefulWidget {
  const WarehouseReturnCheckPage({super.key});

  @override
  State<WarehouseReturnCheckPage> createState() =>
      _WarehouseReturnCheckPageState();
}

class _WarehouseReturnCheckPageState extends State<WarehouseReturnCheckPage> {
  final TextEditingController _actualCountController = TextEditingController();

  final Map<String, dynamic> _returnData = {
    'returnId': 'RT2026042101',
    'driverName': '张小龙',
    'driverCode': 'DRV-2024-001',
    'orderId': '850018',
    'deliveryTime': '14:25',
    'reportBucketCount': 68,
    'oweBucketCount': 2,
    'replenishRequest': '18.9L×20 桶',
    'replenishStock': '充足 (150桶)',
  };

  int _actualCount = 0;

  @override
  void initState() {
    super.initState();
    _actualCountController.addListener(() {
      setState(() {
        _actualCount = int.tryParse(_actualCountController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _actualCountController.dispose();
    super.dispose();
  }

  int get _difference {
    return _actualCount - (_returnData['reportBucketCount'] as int);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDriverInfoCard(),
                  const SizedBox(height: 12),
                  _buildBucketCheckCard(),
                  const SizedBox(height: 12),
                  _buildDifferenceCard(),
                  const SizedBox(height: 12),
                  _buildReplenishCard(),
                  const SizedBox(height: 12),
                  _buildActionsCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '空桶核对',
              style: AppTextStyles.h3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '待核对',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
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
                      _returnData['driverName'] as String,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '工号: ${_returnData['driverCode']} | 回仓单号: #${_returnData['returnId']}',
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '配送订单',
                        style: AppTextStyles.captionSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${_returnData['orderId']}',
                        style: AppTextStyles.subtitle2.copyWith(
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '送达时间',
                        style: AppTextStyles.captionSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _returnData['deliveryTime'] as String,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBucketCheckCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '空桶清点',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '司机上报回收空桶',
                      style: AppTextStyles.subtitle2,
                    ),
                    Text(
                      '${_returnData['reportBucketCount']} 个',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '包含订单配送时的空桶回收',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '其中欠桶',
                      style: AppTextStyles.subtitle2,
                    ),
                    Text(
                      '${_returnData['oweBucketCount']} 个',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '客户无法退回的空桶',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '仓库实收空桶',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '*',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _actualCountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTextStyles.h2.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '请输入仓库实际清点的空桶数量',
                    style: AppTextStyles.captionSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceCard() {
    final difference = _difference;
    final hasDifference = difference != 0;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '差异分析',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '司机上报',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${_returnData['reportBucketCount']} 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '仓库实收',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${_actualCount} 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasDifference
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '差异数量',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${difference.abs()} 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: hasDifference ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '差异 = 司机上报 - 仓库实收。正数由司机承担赔偿，负数需司机说明原因。',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplenishCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '补货信息',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      color: AppColors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '申请补货',
                      style: AppTextStyles.subtitle2,
                    ),
                  ],
                ),
                Text(
                  _returnData['replenishRequest'] as String,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '补货仓库库存',
                  style: AppTextStyles.caption,
                ),
                Text(
                  _returnData['replenishStock'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '核对操作',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.check,
            label: '确认入库',
            color: AppColors.success,
            onTap: () => _onConfirmInbound(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.warning_amber_rounded,
            label: '记录差异',
            color: AppColors.error,
            outlined: true,
            onTap: () => _onRecordDifference(),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.print,
            label: '打印回仓单',
            color: AppColors.textSecondary,
            outlined: true,
            onTap: () => _onPrintReturn(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : color,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: color) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: outlined ? color : AppColors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                color: outlined ? color : AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirmInbound() {
    if (_actualCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入仓库实收空桶数量'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认入库'),
        content: const Text('确认空桶数量一致，入库成功？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('入库成功'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _onRecordDifference() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录差异'),
        content: const Text('确认存在差异，将生成赔偿记录？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('差异记录已生成'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _onPrintReturn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在打印回仓单...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
