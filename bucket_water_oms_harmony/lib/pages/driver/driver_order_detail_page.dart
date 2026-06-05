import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../services/driver_service.dart';
import '../../services/order_service.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/scanner_widget.dart';

class DriverOrderDetailPage extends StatefulWidget {
  final String orderId;

  const DriverOrderDetailPage({super.key, required this.orderId});

  @override
  State<DriverOrderDetailPage> createState() => _DriverOrderDetailPageState();
}

class _DriverOrderDetailPageState extends State<DriverOrderDetailPage> {
  final TextEditingController _deliveryQuantityController =
      TextEditingController();
  final TextEditingController _returnBarrelController =
      TextEditingController();
  final List<String> _scannedBarrels = [];

  final OrderService _orderService = OrderService();
  final DriverService _driverService = DriverService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  @override
  void dispose() {
    _deliveryQuantityController.dispose();
    _returnBarrelController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _orderService.getOrderDetail(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _deliveryQuantityController.text = (order.totalQuantity).toString();
        _returnBarrelController.text = (order.returnedBuckets ?? 0).toString();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '加载订单失败：${e.toString()}';
      });
    }
  }

  int get _shortageBarrel {
    final delivery = int.tryParse(_deliveryQuantityController.text) ?? 0;
    final returnBarrel = int.tryParse(_returnBarrelController.text) ?? 0;
    return delivery - returnBarrel;
  }

  bool get _canStartDelivery {
    final status = _order?.status;
    return status == 'pending' || status == 'assigned' || status == 'confirmed';
  }

  bool get _canConfirmDelivery {
    final status = _order?.status;
    return status == 'picked_up' ||
        status == 'processing' ||
        status == 'delivering';
  }

  bool get _isCompleted {
    final status = _order?.status;
    return status == 'delivered' || status == 'completed';
  }

  Future<void> _handleStartDelivery() async {
    if (_isSubmitting || _order == null) return;
    setState(() => _isSubmitting = true);

    try {
      final updated =
          await _driverService.startDelivery(_order!.id ?? widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已开始配送'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError('开始配送失败：${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showError('开始配送失败：${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleConfirmDelivery() {
    if (_order == null) return;

    final delivery =
        int.tryParse(_deliveryQuantityController.text) ?? 0;
    final returnBarrel =
        int.tryParse(_returnBarrelController.text) ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认送达'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确认订单 ${_order!.orderNo ?? _order!.id} 已完成配送？'),
            const SizedBox(height: 12),
            Text('实送数量：$delivery 桶',
                style: AppTextStyles.caption),
            Text('回收空桶：$returnBarrel 个',
                style: AppTextStyles.caption),
            if (_shortageBarrel > 0) ...[
              const SizedBox(height: 4),
              Text('欠桶数量：${_shortageBarrel} 个',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.warning)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitDelivery();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDelivery() async {
    if (_isSubmitting || _order == null) return;
    setState(() => _isSubmitting = true);

    final delivery =
        int.tryParse(_deliveryQuantityController.text) ?? 0;
    final returnBarrel =
        int.tryParse(_returnBarrelController.text) ?? 0;

    try {
      final updated = await _driverService.deliverOrder(
        _order!.id ?? widget.orderId,
        photos: _scannedBarrels.isEmpty ? null : List.of(_scannedBarrels),
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _deliveryQuantityController.text =
            (updated.totalQuantity > 0 ? updated.totalQuantity : delivery)
                .toString();
        _returnBarrelController.text =
            (updated.returnedBuckets ?? returnBarrel).toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('订单已确认完成'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError('配送签收失败：${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showError('配送签收失败：${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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

  void _handleCallCustomer() {
    final phone = _order?.contactPhone;
    if (phone == null || phone.isEmpty) {
      _showError('该订单未提供联系电话');
      return;
    }
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制联系电话：$phone'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleOpenMap() {
    final address = _order?.deliveryAddress;
    if (address == null || address.isEmpty) {
      _showError('该订单未提供配送地址');
      return;
    }
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('地址已复制：$address'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleUploadPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('签收照片功能开发中，请使用扫码录入'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '未完成';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  List<Map<String, dynamic>> _buildStatusSteps() {
    final order = _order;
    if (order == null) return [];
    final createdAt = order.createdAt;
    final pickedUpAt = order.deliveredAt;
    return [
      {
        'title': '待配送',
        'time': createdAt != null ? _formatDateTime(createdAt) : '未开始',
        'isCompleted':
            createdAt != null && (order.status != null && order.status != ''),
        'icon': Icons.check,
      },
      {
        'title': '配送中',
        'time': (order.status == 'picked_up' ||
                order.status == 'processing' ||
                order.status == 'delivering' ||
                order.status == 'delivered' ||
                order.status == 'completed')
            ? _formatDateTime(createdAt)
            : '未完成',
        'isCompleted': order.status == 'picked_up' ||
            order.status == 'processing' ||
            order.status == 'delivering' ||
            order.status == 'delivered' ||
            order.status == 'completed',
        'icon': Icons.local_shipping,
      },
      {
        'title': '已送达',
        'time': pickedUpAt != null ? _formatDateTime(pickedUpAt) : '未完成',
        'isCompleted': order.status == 'delivered' || order.status == 'completed',
        'icon': Icons.home,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: _buildHeader(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _order == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: _buildHeader(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: AppColors.error.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(_errorMessage ?? '订单数据加载失败',
                  style: AppTextStyles.body1
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOrderDetail,
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

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

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        '订单详情 ${_order?.orderNo ?? _order?.id ?? ''}',
        style: AppTextStyles.h3,
      ),
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: _scanOrderCode,
          icon: Container(
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
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDeliveryProgress() {
    final steps = _buildStatusSteps();

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
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (step['time'] as String).isNotEmpty
                              ? step['time'] as String
                              : '未完成',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
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
    final order = _order!;
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
                        order.contactName ?? '联系人待补充',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.contactPhone ?? '电话待补充',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: _handleCallCustomer,
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
                        order.deliveryAddress ?? '地址待补充',
                        style: AppTextStyles.subtitle2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.remark?.isNotEmpty == true
                            ? '备注：${order.remark}'
                            : '订单号：${order.orderNo ?? order.id ?? '-'}',
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
            onTap: _handleOpenMap,
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
    final order = _order!;
    final products = order.items ?? const <OrderItemModel>[];

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
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '该订单暂无商品明细',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ...products.map((product) {
              final name = product.productName ?? '桶装水';
              final spec = product.productSpec;
              final displayName =
                  spec != null && spec.isNotEmpty ? '$name ($spec)' : name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '× ${product.quantity ?? 0} 桶',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (products.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合计', style: AppTextStyles.caption),
                  Text(
                    '共 ${order.totalQuantity} 桶',
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
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
                    onTap: _handleUploadPhoto,
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
      child: SafeArea(
        top: false,
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
              child: _buildPrimaryActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    String label;
    VoidCallback? onTap;
    Color background = AppColors.primary;
    bool showLoader = _isSubmitting;

    if (_isCompleted) {
      label = '订单已完成';
      onTap = () => Navigator.pop(context);
      background = AppColors.textSecondary;
    } else if (_canStartDelivery) {
      label = '开始配送';
      onTap = _isSubmitting ? null : _handleStartDelivery;
    } else if (_canConfirmDelivery) {
      label = '确认送达';
      onTap = _isSubmitting ? null : _handleConfirmDelivery;
    } else {
      label = '当前状态：${_order?.statusText ?? '-'}';
      onTap = () => Navigator.pop(context);
      background = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap == null
              ? null
              : [
                  BoxShadow(
                    color: background.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: showLoader
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
