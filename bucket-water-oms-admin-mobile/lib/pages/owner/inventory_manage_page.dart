import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/station_service.dart';
import '../../models/station_model.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';

class InventoryManagePage extends StatefulWidget {
  const InventoryManagePage({super.key});

  @override
  State<InventoryManagePage> createState() => _InventoryManagePageState();
}

class _InventoryManagePageState extends State<InventoryManagePage> {
  final StationService _stationService = StationService();

  bool _isLoading = true;
  String? _errorMessage;
  List<InventoryItemModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final inventory = await _stationService.getInventory();

      if (mounted) {
        setState(() {
          _products = inventory?.items ?? [];
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
          _errorMessage = '加载数据失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  int get _totalStock {
    int total = 0;
    for (var item in _products) {
      total += item.stock ?? 0;
    }
    return total;
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chevron_left, size: 24, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('库存管理', style: AppTextStyles.h3),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('重新加载')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildProductList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('在库总桶数', style: AppTextStyles.captionSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: 4),
                Text('$_totalStock', style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('可订货商品', style: AppTextStyles.captionSmall.copyWith(color: AppColors.success)),
                const SizedBox(height: 4),
                Text('${_products.length}', style: AppTextStyles.h2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            iconColor: AppColors.primary,
            label: '去下单',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.history,
            iconColor: AppColors.warning,
            label: '进货记录',
            onTap: () {},
          ),
        ),
        Expanded(
          child: _buildActionButton(
            icon: Icons.refresh,
            iconColor: AppColors.success,
            label: '刷新',
            onTap: _loadData,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.captionSmall.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('商品列表', style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold)),
              Text('共${_products.length}个商品', style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('暂无可订货商品', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
            ),
          )
        else
          ..._products.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductCard(item),
            );
          }),
      ],
    );
  }

  Widget _buildProductCard(InventoryItemModel item) {
    final stockStatus = item.stockStatus;
    final isLowStock = stockStatus == '不足' || stockStatus == '缺货';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName ?? '未知商品',
                        style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stockStatus,
                          style: AppTextStyles.captionSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('规格: ${item.productSpec ?? '-'}', style: AppTextStyles.captionSmall),
                Text('仓库: ${item.warehouseName ?? '-'}', style: AppTextStyles.captionSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('库存: ${item.stock ?? 0}', style: AppTextStyles.subtitle2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Text('¥${(item.price ?? 0).toStringAsFixed(2)}/桶', style: AppTextStyles.subtitle2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
