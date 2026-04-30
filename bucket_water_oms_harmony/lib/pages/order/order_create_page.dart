import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';

class OrderCreatePage extends StatefulWidget {
  const OrderCreatePage({super.key});

  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends State<OrderCreatePage> {
  bool _includeEmptyBucketReturn = true;
  int _product1Quantity = 50;
  int _product2Quantity = 20;
  final TextEditingController _remarkController = TextEditingController();
  
  final Map<String, dynamic> _deliveryInfo = {
    'name': '张老板',
    'phone': '138****8888',
    'address': '广西壮族自治区桂林市秀峰区XX路XX号张记旗舰水站',
  };

  final List<Map<String, dynamic>> _products = [
    {
      'name': '18.9L 经典桶装水',
      'price': 8.00,
      'unit': '桶',
      'quantity': 50,
    },
    {
      'name': '11.3L 迷你桶装水',
      'price': 6.00,
      'unit': '桶',
      'quantity': 20,
    },
  ];

  double get _productTotal {
    double total = 0;
    for (var product in _products) {
      total += (product['price'] as double) * (product['quantity'] as int);
    }
    return total;
  }

  double get _deliveryFee => 0.00;
  double get _ticketDiscount => 50.00;
  double get _totalAmount => _productTotal + _deliveryFee - _ticketDiscount;
  int get _totalQuantity {
    int total = 0;
    for (var product in _products) {
      total += product['quantity'] as int;
    }
    return total;
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
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
                  _buildDeliveryInfoCard(),
                  const SizedBox(height: 12),
                  _buildProductListCard(),
                  const SizedBox(height: 12),
                  _buildEmptyBucketServiceCard(),
                  const SizedBox(height: 12),
                  _buildPriceDetailCard(),
                  const SizedBox(height: 12),
                  _buildRemarkCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            '确认订单',
            style: AppTextStyles.h3,
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _deliveryInfo['name'] as String,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _deliveryInfo['phone'] as String,
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _deliveryInfo['address'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildProductListCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '商品清单',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_products.length, (index) {
            final product = _products[index];
            return _buildProductItem(product, index);
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
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
                  product['name'] as String,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '规格：${product['unit']}',
                  style: AppTextStyles.captionSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${(product['price'] as double).toStringAsFixed(2)}',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if ((product['quantity'] as int) > 0) {
                                product['quantity'] = (product['quantity'] as int) - 1;
                              }
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.bgInput,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${product['quantity']}',
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              product['quantity'] = (product['quantity'] as int) + 1;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 16,
                            ),
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

  Widget _buildEmptyBucketServiceCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '空桶回收',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '预计归还 ${70} 个',
                    style: AppTextStyles.captionSmall,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 8),
              Switch(
                value: _includeEmptyBucketReturn,
                onChanged: (value) {
                  setState(() {
                    _includeEmptyBucketReturn = value;
                  });
                },
                activeColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetailCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          _buildPriceRow('商品总额', '¥${_productTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildPriceRow('配送费', '¥${_deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildPriceRow('水票抵扣', '-¥${_ticketDiscount.toStringAsFixed(2)}', isDiscount: true),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '应付金额',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '¥${_totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
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
            color: isDiscount ? AppColors.error : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarkCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: TextField(
        controller: _remarkController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: '备注说明：如有特殊派送要求请在此留言...',
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textPlaceholder,
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: AppColors.bgInput,
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
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
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '总计 $_totalQuantity 件商品',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                '¥${_totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _onSubmitOrder(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '提交订单',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmitOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认下单'),
        content: Text('确认要提交订单，总金额 ¥${_totalAmount.toStringAsFixed(2)} 吗？'),
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
                  content: Text('订单提交成功'),
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
