import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/components/status_badge.dart';

class WarehouseOrderDetailPage extends StatefulWidget {
  const WarehouseOrderDetailPage({super.key});

  @override
  State<WarehouseOrderDetailPage> createState() => _WarehouseOrderDetailPageState();
}

class _WarehouseOrderDetailPageState extends State<WarehouseOrderDetailPage> {
  final Map<String, dynamic> _orderData = {
    'orderNumber': '850021',
    'createTime': '2026-04-21 09:30',
    'stationName': '张记旗舰水站',
    'stationCode': 'WS-2024-0158',
    'address': '桂林市秀峰区XX路XX号张记旗舰水站',
    'distance': '1.2km',
    'deliveryTime': '25分钟',
    'isUrgent': true,
    'products': [
      {
        'name': '18.9L 桶装水 (农夫)',
        'price': 35.00,
        'quantity': 50,
        'total': 1750.00,
        'icon': Icons.water_drop,
        'color': AppColors.primary,
      },
      {
        'name': '11.3L 迷你桶 (景田)',
        'price': 25.00,
        'quantity': 20,
        'total': 500.00,
        'icon': Icons.local_drink,
        'color': AppColors.success,
      },
      {
        'name': '550ml 瓶装水',
        'price': 30.00,
        'quantity': 5,
        'total': 150.00,
        'icon': Icons.water,
        'color': AppColors.warning,
      },
    ],
    'productTotal': 2400.00,
    'bucketDeposit': 500.00,
    'orderTotal': 2900.00,
    'paymentMethod': '预存金扣款',
    'accountBalance': 5680.00,
    'creditStatus': '充足',
    'depositBucketCount': 200,
    'currentOweBucket': 15,
    'oweBucketDeposit': 300,
    'recoverBucketEstimate': '约 50-70 个空桶',
    'stockCheck': [
      {'name': '18.9L 桶装水 (农夫)', 'status': '充足', 'count': '500桶'},
      {'name': '11.3L 迷你桶 (景田)', 'status': '充足', 'count': '240桶'},
      {'name': '550ml 瓶装水', 'status': '充足', 'count': '300箱'},
    ],
    'remark': '请安排下午3点前送达，客户急需用水。另外请多带些空桶，上次欠的桶较多。',
  };

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
                  _buildOrderInfoCard(),
                  const SizedBox(height: 12),
                  _buildProductListCard(),
                  const SizedBox(height: 12),
                  _buildPaymentInfoCard(),
                  const SizedBox(height: 12),
                  _buildBucketInfoCard(),
                  const SizedBox(height: 12),
                  _buildStockCheckCard(),
                  const SizedBox(height: 12),
                  _buildRemarkCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(),
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
              '订单详情',
              style: AppTextStyles.h3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '紧急',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '订单编号',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${_orderData['orderNumber']}',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '下单时间',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _orderData['createTime'],
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store,
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
                        _orderData['stationName'],
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '水站编号: ${_orderData['stationCode']}',
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
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orderData['address'],
                      style: AppTextStyles.subtitle2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '距仓库 ${_orderData['distance']} | 预计配送 ${_orderData['deliveryTime']}',
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

  Widget _buildProductListCard() {
    final products = _orderData['products'] as List<Map<String, dynamic>>;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品明细',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...products.map((product) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (product['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      product['icon'] as IconData,
                      color: product['color'] as Color,
                      size: 24,
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
                        const SizedBox(height: 2),
                        Text(
                          '单价: ¥${(product['price'] as double).toStringAsFixed(2)}/桶',
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '× ${product['quantity']}',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '¥ ${(product['total'] as double).toStringAsFixed(2)}',
                        style: AppTextStyles.captionSmall,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '商品总价',
                style: AppTextStyles.caption,
              ),
              Text(
                '¥ ${(_orderData['productTotal'] as double).toStringAsFixed(2)}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '空桶押金 (预收)',
                style: AppTextStyles.caption,
              ),
              Text(
                '¥ ${(_orderData['bucketDeposit'] as double).toStringAsFixed(2)}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单总额',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥ ${(_orderData['orderTotal'] as double).toStringAsFixed(2)}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.error,
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

  Widget _buildPaymentInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付信息',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('支付方式', _orderData['paymentMethod'] as String),
          const SizedBox(height: 12),
          _buildInfoRow(
            '水站账户余额',
            '¥ ${(_orderData['accountBalance'] as double).toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildInfoRow('账户可用额度', _orderData['creditStatus'] as String),
        ],
      ),
    );
  }

  Widget _buildBucketInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '空桶往来',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('水站押金桶数', '${_orderData['depositBucketCount']} 个'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '当前欠桶数',
                style: AppTextStyles.caption,
              ),
              Row(
                children: [
                  Text(
                    '${_orderData['currentOweBucket']} 个',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '需补缴 ¥${_orderData['oweBucketDeposit']}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('本次配送需回收', _orderData['recoverBucketEstimate'] as String),
        ],
      ),
    );
  }

  Widget _buildStockCheckCard() {
    final stockCheck = _orderData['stockCheck'] as List<Map<String, dynamic>>;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '库存检查',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...stockCheck.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['name'] as String,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '库存充足 (${item['count']})',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildRemarkCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '订单备注',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _orderData['remark'] as String,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onRejectOrder(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  '拒单',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _onAcceptOrder(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '确认接单',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRejectOrder() {
    Navigator.pop(context);
  }

  void _onAcceptOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('接单确认'),
        content: const Text('确定要接收此订单吗？'),
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
                  content: Text('订单已接收'),
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
}
