import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/config/api_config.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/components/status_badge.dart';
import '../../models/order_model.dart';
import '../../services/warehouse_service.dart';
import 'warehouse_dispatch_select_page.dart';

class WarehouseOrderDetailPage extends StatefulWidget {
  final OrderModel? order;
  final String? orderId;

  const WarehouseOrderDetailPage({
    super.key,
    this.order,
    this.orderId,
  });

  @override
  State<WarehouseOrderDetailPage> createState() =>
      _WarehouseOrderDetailPageState();
}

class _WarehouseOrderDetailPageState extends State<WarehouseOrderDetailPage> {
  final WarehouseService _warehouseService = WarehouseService();
  OrderModel? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (widget.order != null) {
      setState(() {
        _order = widget.order;
        _isLoading = false;
      });
      return;
    }

    if (widget.orderId == null) {
      setState(() {
        _errorMessage = '订单ID不存在';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId.isEmpty) {
        throw Exception('未登录仓库账号');
      }

      final order = await _warehouseService.getOrderDetail(
        widget.orderId!,
        warehouseId,
      );

      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[OrderDetail] 加载订单详情失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载订单详情失败';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOrder,
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: const Center(child: Text('订单不存在')),
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
                  _buildOrderInfoCard(),
                  const SizedBox(height: 12),
                  _buildProductListCard(),
                  const SizedBox(height: 12),
                  _buildPaymentInfoCard(),
                  const SizedBox(height: 12),
                  _buildBucketInfoCard(),
                  const SizedBox(height: 12),
                  if (_order!.remark != null && _order!.remark!.isNotEmpty)
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        topPadding + 12,
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
              '订单详情',
              style: AppTextStyles.h3,
            ),
          ),
          StatusBadge(
            text: _getStatusText(_order!.status ?? ''),
            type: _getBadgeType(_order!.status ?? ''),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
      case 'PENDING':
        return '待接单';
      case 'preparing':
      case 'PREPARING':
        return '备货中';
      case 'dispatched':
      case 'DISPATCHED':
        return '配送中';
      case 'completed':
      case 'COMPLETED':
        return '已完成';
      default:
        return status ?? '未知';
    }
  }

  BadgeType _getBadgeType(String status) {
    switch (status) {
      case 'pending':
      case 'PENDING':
        return BadgeType.warning;
      case 'preparing':
      case 'PREPARING':
        return BadgeType.primary;
      case 'dispatched':
      case 'DISPATCHED':
        return BadgeType.success;
      case 'completed':
      case 'COMPLETED':
        return BadgeType.success;
      default:
        return BadgeType.info;
    }
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
                    '#${_order!.orderNo ?? _order!.id}',
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
                    _formatDateTime(_order!.createdAt),
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
                        _order!.stationName ?? '未知水站',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_order!.stationCode != null)
                        Text(
                          '水站编号: ${_order!.stationCode}',
                          style: AppTextStyles.captionSmall,
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final phone = _order!.contactPhone;
                    if (phone != null && phone.isNotEmpty) {
                      PhoneUtils.makePhoneCall(phone, context: context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('暂无联系电话'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  },
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
                      _order!.deliveryAddress ?? '暂无地址',
                      style: AppTextStyles.subtitle2,
                    ),
                    if (_order!.distance != null)
                      Text(
                        '距仓库 ${_order!.distance}',
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
    final items = _order!.items ?? [];

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
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '暂无商品信息',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            ...items.map((item) {
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.water_drop,
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
                            item.productName ?? '未知产品',
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.productSpec != null)
                            Text(
                              item.productSpec!,
                              style: AppTextStyles.captionSmall,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '× ${item.quantity ?? 0}',
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.unitPrice != null)
                          Text(
                            '¥ ${item.unitPrice!.toStringAsFixed(2)}',
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
                  '¥ ${(_order!.totalAmount ?? 0).toStringAsFixed(2)}',
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
                  '¥ ${(_order!.bucketDeposit ?? 0).toStringAsFixed(2)}',
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
                    '¥ ${(_order!.totalAmount ?? 0).toStringAsFixed(2)}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          _buildInfoRow('支付方式',
              _order!.paymentTypeText ?? _order!.paymentType ?? '预存金扣款'),
          const SizedBox(height: 12),
          if (_order!.depositBalance != null)
            _buildInfoRow(
              '水站账户余额',
              '¥ ${_order!.depositBalance!.toStringAsFixed(2)}',
              valueColor: AppColors.success,
            ),
          if (_order!.creditLimit != null && _order!.creditUsed != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              '可用额度',
              '¥ ${(_order!.creditLimit! - _order!.creditUsed!).toStringAsFixed(2)} / ¥${_order!.creditLimit!.toStringAsFixed(2)}',
            ),
          ],
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
          if (_order!.depositBucketCount != null)
            _buildInfoRow('水站押金桶数', '${_order!.depositBucketCount} 个'),
          if (_order!.owedBuckets != null) ...[
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
                      '${_order!.owedBuckets} 个',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_order!.owedBucketDeposit != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '需补缴 ¥${_order!.owedBucketDeposit}',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
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
            _order!.remark ?? '',
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
              onTap: () => _onDispatchOrder(),
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
                  '派单出库',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒单确认'),
        content: Text('确定要拒绝订单 #${_order!.orderNo ?? _order!.id} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _rejectOrder();
            },
            child: const Text('确认拒单'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectOrder() async {
    try {
      final warehouseId = ApiConfig.getWarehouseId();
      await _warehouseService.rejectOrder(
        _order!.id!,
        warehouseId,
        reason: '库存不足或其他原因',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('订单已拒绝'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拒单失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onDispatchOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('派单出库'),
        content: Text('确认要为订单 #${_order!.orderNo ?? _order!.id} 派单出库吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WarehouseDispatchSelectPage(
                    orderId: _order!.id ?? '',
                    orderNo: _order!.orderNo,
                    stationName: _order!.stationName,
                    productInfo: _order!.items != null
                        ? '${_order!.items!.length}种商品，共${_order!.totalQuantity ?? 0}桶'
                        : null,
                  ),
                ),
              ).then((result) {
                if (result == true) {
                  Navigator.pop(context);
                }
              });
            },
            child: const Text('确认派单'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知时间';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
