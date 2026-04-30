import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/scanner_widget.dart';

class DriverOrderDetailPage extends StatefulWidget {
  const DriverOrderDetailPage({super.key});

  @override
  State<DriverOrderDetailPage> createState() => _DriverOrderDetailPageState();
}

class _DriverOrderDetailPageState extends State<DriverOrderDetailPage> {
  final TextEditingController _deliveryQuantityController = TextEditingController(text: '70');
  final TextEditingController _returnBarrelController = TextEditingController(text: '65');
  final List<String> _scannedBarrels = [];

  // Mock data for demonstration
  final Map<String, dynamic> _orderData = {
    'orderNumber': '#1',
    'customerName': '张老板',
    'customerPhone': '138****8888',
    'address': '桂林市秀峰区XX路XX号张记旗舰水站',
    'appointmentTime': '2026-04-19 14:00',
    'products': [
      {'name': '18.9L 桶装水', 'quantity': 50},
      {'name': '11.3L 桶装水', 'quantity': 20},
    ],
    'deliveryQuantity': 70,
    'returnBarrel': 65,
    'statusSteps': [
      {'title': '待配送', 'time': '2026-04-19 10:00', 'isCompleted': true, 'icon': Icons.check},
      {'title': '配送中', 'time': '2026-04-19 11:30', 'isCompleted': true, 'icon': Icons.local_shipping},
      {'title': '已送达', 'time': '', 'isCompleted': false, 'icon': Icons.home},
    ],
  };

  @override
  void dispose() {
    _deliveryQuantityController.dispose();
    _returnBarrelController.dispose();
    super.dispose();
  }

  int get _shortageBarrel {
    final delivery = int.tryParse(_deliveryQuantityController.text) ?? 0;
    final returnBarrel = int.tryParse(_returnBarrelController.text) ?? 0;
    return delivery - returnBarrel;
  }

  void _handleConfirmDelivery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认送达'),
        content: Text('确认订单 ${_orderData['orderNumber']} 已完成配送？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('订单已确认完成')),
              );
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarrelCode() async {
    final code = await showScanDialog(
      context,
      title: '扫描桶条码',
      hint: '请扫描桶上的条码',
      onScanned: (String code) {},
    );

    if (code != null && code.isNotEmpty && mounted) {
      setState(() {
        if (!_scannedBarrels.contains(code)) {
          _scannedBarrels.add(code);
        }
        _returnBarrelController.text = _scannedBarrels.length.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已扫描: $code'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _scanOrderCode() async {
    final code = await showScanDialog(
      context,
      title: '扫描订单二维码',
      hint: '请扫描订单上的二维码',
      onScanned: (String code) {},
    );

    if (code != null && code.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('订单码: $code'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
                  _buildDeliveryProgress(),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(),
                  const SizedBox(height: 16),
                  _buildProductInfo(),
                  const SizedBox(height: 16),
                  _buildConfirmationForm(),
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
          Expanded(
            child: Text(
              '订单详情 ${_orderData['orderNumber']}',
              style: AppTextStyles.h3,
            ),
          ),
          GestureDetector(
            onTap: _scanOrderCode,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryProgress() {
    final steps = _orderData['statusSteps'] as List<Map<String, dynamic>>;

    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '配送进度',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isCompleted = step['isCompleted'] as bool;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? step['icon'] as IconData : Icons.circle,
                        color: AppColors.white,
                        size: isCompleted ? 18 : 8,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['time'].isNotEmpty ? step['time'] : '未完成',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: isCompleted ? AppColors.textSecondary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _orderData['customerName'] as String,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _orderData['customerPhone'] as String,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Call phone action
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
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
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
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
                        _orderData['address'] as String,
                        style: AppTextStyles.subtitle2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '预约时间: ${_orderData['appointmentTime']}',
                        style: AppTextStyles.captionSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Navigate to map
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.navigation,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '查看地图位置',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final products = _orderData['products'] as List<Map<String, dynamic>>;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品信息',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...products.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product['name'] as String,
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '× ${product['quantity']} 桶',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildConfirmationForm() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '实收确认',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: '配送数量',
                  controller: _deliveryQuantityController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: '回收空桶',
                            controller: _returnBarrelController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _scanBarrelCode,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_scannedBarrels.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '已扫描 ${_scannedBarrels.length} 个桶',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '欠桶数量: $_shortageBarrel 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '签收照片',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Upload photo action
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textTertiary,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '上传照片',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://modao.cc/agent-py/media/generated_images/2026-04-19/8c9f0c9ea0e54aad8c7fa97da245e18a.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
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
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '取消',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textSecondary,
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
              onTap: _handleConfirmDelivery,
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
                  '确认送达',
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
}
