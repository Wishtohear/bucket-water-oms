import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_tab_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/components/status_badge.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';

class OwnerOrdersPage extends StatefulWidget {
  const OwnerOrdersPage({super.key});

  @override
  State<OwnerOrdersPage> createState() => _OwnerOrdersPageState();
}

class _OwnerOrdersPageState extends State<OwnerOrdersPage> {
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _orders = [];

  final List<String> _tabs = ['全部', '待接单', '配送中', '已完成', '售后'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final orderService = OrderService();

      String? status;
      switch (_selectedTab) {
        case 1:
          status = 'pending';
          break;
        case 2:
          status = 'processing';
          break;
        case 3:
          status = 'completed';
          break;
        default:
          status = null;
      }

      List<OrderModel> orders = [];
      if (appState.userId != null) {
        orders = await orderService.getOrders(
          stationId: appState.stationId,
          status: status,
        );
      }

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载订单失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
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
              child: _buildOrderList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Text(
        '订单管理',
        style: AppTextStyles.h3,
      ),
    );
  }

  Widget _buildTabs() {
    return CustomTabBar(
      tabs: _tabs,
      selectedIndex: _selectedTab,
      onTabSelected: (index) {
        setState(() => _selectedTab = index);
        _loadOrders();
      },
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无订单数据',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...(_orders.map((order) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOrderCard(order),
              );
            })),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    BadgeType badgeType;
    switch (order.status) {
      case 'pending':
        badgeType = BadgeType.warning;
        break;
      case 'processing':
        badgeType = BadgeType.primary;
        break;
      case 'completed':
      case 'delivered':
        badgeType = BadgeType.success;
        break;
      default:
        badgeType = BadgeType.info;
    }

    String productText = '';
    if (order.items != null && order.items!.isNotEmpty) {
      productText = order.items!.map((item) {
        return '${item.productName ?? '未知产品'} × ${item.quantity ?? 0}';
      }).join(', ');
    } else {
      productText = '18.9L × ${order.totalQuantity}桶';
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderColor: order.status == 'processing'
          ? AppColors.primary.withOpacity(0.2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单号: ${order.orderNo ?? '未知'}',
                style: AppTextStyles.caption,
              ),
              StatusBadge(
                text: order.statusText,
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productText,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥ ${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                      style: AppTextStyles.priceSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.createdAt?.toString().substring(0, 16) ?? '',
                style: AppTextStyles.captionSmall,
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('查看明细'),
                  ),
                  const SizedBox(width: 8),
                  if (order.status == 'completed')
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('再来一单'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
