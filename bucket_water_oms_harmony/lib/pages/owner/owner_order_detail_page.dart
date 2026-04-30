import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class OwnerOrderDetailPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? orderData;

  const OwnerOrderDetailPage({
    super.key,
    this.orderId = '202604210001',
    this.orderData,
  });

  @override
  State<OwnerOrderDetailPage> createState() => _OwnerOrderDetailPageState();
}

class _OwnerOrderDetailPageState extends State<OwnerOrderDetailPage> {
  final List<Map<String, dynamic>> _deliverySteps = [
    {
      'title': '订单已提交',
      'subtitle': '等待仓库接单审查',
      'time': '今天 09:30',
      'isCompleted': true,
      'isActive': false,
    },
    {
      'title': '仓库已接单',
      'subtitle': '仓库：桂林配送中心A仓',
      'time': '今天 10:45',
      'isCompleted': true,
      'isActive': false,
    },
    {
      'title': '已出库配送',
      'subtitle': '司机：王力 (139****1234)',
      'time': '今天 11:20',
      'isCompleted': true,
      'isActive': false,
    },
    {
      'title': '配送中',
      'subtitle': '正在送往水站，距离您 1.2km',
      'time': '今天 13:40',
      'isCompleted': false,
      'isActive': true,
    },
    {
      'title': '已完成签收',
      'subtitle': '等待司机确认送达',
      'time': '预计 14:30',
      'isCompleted': false,
      'isActive': false,
    },
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': '18.9L 经典桶装水',
      'image': 'https://modao.cc/agent-py/media/generated_images/2026-04-19/a334311da7854958a4c575d1ed971989.jpg',
      'price': '¥8.00/桶',
      'quantity': '× 50桶',
      'total': '¥400.00',
    },
    {
      'name': '11.3L 迷你桶装水',
      'image': 'https://modao.cc/agent-py/media/generated_images/2026-04-19/d946652deb254808b0f7b16e4dfad2a3.jpg',
      'price': '¥6.00/桶',
      'quantity': '× 20桶',
      'total': '¥120.00',
    },
  ];

  void _contactWarehouse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在联系仓库...')),
    );
  }

  void _contactDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在联系司机...')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildOrderStatusCard(),
                    const SizedBox(height: 16),
                    _buildDeliveryProgress(),
                    const SizedBox(height: 16),
                    _buildDriverInfo(),
                    const SizedBox(height: 16),
                    _buildDeliveryAddress(),
                    const SizedBox(height: 16),
                    _buildProductList(),
                    const SizedBox(height: 16),
                    _buildPaymentInfo(),
                    const SizedBox(height: 16),
                    _buildEmptyBucketReturn(),
                    const SizedBox(height: 16),
                    _buildOrderInfo(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '订单详情',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '订单状态',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '配送中',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '订单号: ${widget.orderId}',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '预计送达',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '今天 14:30',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '司机电话',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '139****1234',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildDeliveryProgress() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '配送进度',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Positioned(
                left: 15,
                top: 16,
                bottom: 16,
                child: Container(
                  width: 2,
                  color: AppColors.borderLight,
                ),
              ),
              ...List.generate(_deliverySteps.length, (index) {
                final step = _deliverySteps[index];
                return _buildStepItem(step, index);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step, int index) {
    final isCompleted = step['isCompleted'] as bool;
    final isActive = step['isActive'] as bool;
    final isLast = index == _deliverySteps.length - 1;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : (isActive ? AppColors.primary : AppColors.bgInput),
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: AppColors.primary, width: 3)
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check : (isActive ? Icons.circle : Icons.circle),
              color: Colors.white,
              size: isActive ? 12 : 16,
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
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (isCompleted || isActive)
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      step['time'] as String,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step['subtitle'] as String,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '配送司机',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '王力',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '负责区域：桂林市秀峰区、叠彩区',
                      style: AppTextStyles.captionSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '今日完成 8 单',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '评分 4.9',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.success,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _contactWarehouse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '拨打电话',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _contactDriver,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.message,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '发送短信',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '配送地址',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '张记旗舰水站',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '张老板 138****8888',
                      style: AppTextStyles.captionSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '广西壮族自治区桂林市秀峰区XX路XX号',
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '商品明细',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_products.length, (index) {
            final product = _products[index];
            return Container(
              padding: const EdgeInsets.only(bottom: 12),
              margin: EdgeInsets.only(bottom: index < _products.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                border: index < _products.length - 1
                    ? const Border(
                        bottom: BorderSide(color: AppColors.borderLight),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(product['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['price'] as String,
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        product['quantity'] as String,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['total'] as String,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '支付信息',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('商品总额', '¥520.00'),
          const SizedBox(height: 8),
          _buildPaymentRow('配送费', '¥0.00'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '支付方式',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '月结',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '应付金额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                '¥520.00',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
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
          style: AppTextStyles.body2,
        ),
      ],
    );
  }

  Widget _buildEmptyBucketReturn() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.autorenew,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '空桶回收',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBucketRow('本次应回桶数', '70个'),
          const SizedBox(height: 8),
          _buildBucketRow('上次欠桶', '8个'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '本次总回桶',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                '70个',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '配送完成后，系统将自动更新您的空桶往来记录',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketRow(String label, String value) {
    return Row(
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '订单信息',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('下单时间', '2026-04-21 09:30'),
          const SizedBox(height: 8),
          _buildInfoRow('接单仓库', '桂林配送中心A仓'),
          const SizedBox(height: 8),
          _buildInfoRow('仓库电话', '0773-1234567'),
          const SizedBox(height: 8),
          _buildInfoRow('备注', '请小心搬运'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _contactWarehouse,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Text(
                    '联系仓库',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _contactDriver,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    '联系司机',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
