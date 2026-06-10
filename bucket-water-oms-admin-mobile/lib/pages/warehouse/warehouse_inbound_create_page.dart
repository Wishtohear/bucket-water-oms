import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../models/warehouse_models.dart';
import '../../models/admin_models.dart';
import '../../services/warehouse_inbound_service.dart';
import '../../services/admin_product_service.dart';
import '../../shared/widgets/app_card.dart';

class WarehouseInboundCreatePage extends StatefulWidget {
  const WarehouseInboundCreatePage({super.key});

  @override
  State<WarehouseInboundCreatePage> createState() =>
      _WarehouseInboundCreatePageState();
}

class _WarehouseInboundCreatePageState
    extends State<WarehouseInboundCreatePage> {
  final WarehouseInboundService _inboundService = WarehouseInboundService();
  final AdminProductService _productService = AdminProductService();

  int _selectedTypeIndex = 0;
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _relatedOrderController = TextEditingController();

  List<ProductModel> _products = [];
  final List<InboundItemModel> _items = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _inboundTypes = [
    {
      'value': 'production',
      'label': '生产入库',
      'icon': Icons.factory,
      'color': AppColors.primary
    },
    {
      'value': 'purchase',
      'label': '采购入库',
      'icon': Icons.shopping_cart,
      'color': AppColors.success
    },
    {
      'value': 'transfer_in',
      'label': '调拨入库',
      'icon': Icons.swap_horiz,
      'color': AppColors.warning
    },
    {
      'value': 'return',
      'label': '退货入库',
      'icon': Icons.replay,
      'color': Colors.purple
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _items.add(InboundItemModel());
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _remarkController.dispose();
    _relatedOrderController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _productService.getProducts(pageSize: 100);
      if (mounted) {
        setState(() {
          _products = response.products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取产品列表失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  int get _totalQuantity {
    return _items.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  void _addItem() {
    setState(() {
      _items.add(InboundItemModel());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('至少需要一条入库产品'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _updateItemProduct(int index, String? productId) {
    if (productId == null) return;
    setState(() {
      _items[index] = InboundItemModel(
        productId: productId,
        productName: _products
            .firstWhere(
              (p) => p.id == productId,
              orElse: () => ProductModel(),
            )
            .name,
        quantity: _items[index].quantity ?? 1,
      );
    });
  }

  void _updateItemQuantity(int index, String value) {
    final quantity = int.tryParse(value) ?? 0;
    setState(() {
      _items[index] = InboundItemModel(
        productId: _items[index].productId,
        productName: _items[index].productName,
        quantity: quantity > 0 ? quantity : 1,
      );
    });
  }

  Future<void> _submitInbound() async {
    if (_sourceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入来源'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final validItems = _items
        .where((item) =>
            item.productId != null &&
            item.productId!.isNotEmpty &&
            (item.quantity ?? 0) > 0)
        .toList();

    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少添加一个入库产品'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final warehouseId = ApiConfig.getWarehouseId();
      if (warehouseId == null || warehouseId.isEmpty) {
        throw Exception('未找到仓库信息');
      }

      final request = CreateInboundRequest(
        type: _inboundTypes[_selectedTypeIndex]['value'],
        source: _sourceController.text,
        relatedOrderNo: _relatedOrderController.text.isNotEmpty
            ? _relatedOrderController.text
            : null,
        remark:
            _remarkController.text.isNotEmpty ? _remarkController.text : null,
        items: validItems
            .map((item) => CreateInboundItem(
                  productId: item.productId!,
                  quantity: item.quantity ?? 0,
                ))
            .toList(),
      );

      await _inboundService.createInbound(warehouseId, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('入库单创建成功'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 12),
                    _buildSourceSection(),
                    const SizedBox(height: 12),
                    _buildProductsSection(),
                    const SizedBox(height: 12),
                    _buildRemarkSection(),
                    const SizedBox(height: 12),
                    _buildSummary(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              '新增入库',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '入库类型',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_inboundTypes.length, (index) {
              final type = _inboundTypes[index];
              final isSelected = _selectedTypeIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTypeIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type['color'] as Color).withOpacity(0.1)
                        : AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? type['color'] as Color
                          : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? type['color'] as Color
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type['label'] as String,
                        style: AppTextStyles.body2.copyWith(
                          color: isSelected
                              ? type['color'] as Color
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '来源信息',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _sourceController,
            label: '来源',
            hint: '如：一号车间、XX供应商',
            isRequired: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _relatedOrderController,
            label: '关联订单',
            hint: '关联订单号（可选）',
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body2,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.textPlaceholder,
            ),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '入库产品',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '添加产品',
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
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '暂无可用产品',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(_items.length, (index) {
                return _buildProductItem(index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final item = index < _items.length ? _items[index] : null;
    final selectedProductId = item?.productId;

    return Container(
      margin: EdgeInsets.only(bottom: index < _items.length - 1 ? 16 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '产品',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedProductId,
                        hint: Text(
                          '选择产品',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textPlaceholder,
                          ),
                        ),
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                        items: _products.map((product) {
                          return DropdownMenuItem(
                            value: product.id,
                            child: Text(
                              product.name ?? '',
                              style: AppTextStyles.body2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _updateItemProduct(index, value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_items.length > 1) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数量（桶）',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(
                        text: item?.quantity?.toString() ?? '1',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: AppTextStyles.body2,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: AppColors.bgCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _updateItemQuantity(index, value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '单位',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '桶',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
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

  Widget _buildRemarkSection() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '备注',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _remarkController,
            maxLines: 3,
            style: AppTextStyles.body2,
            decoration: InputDecoration(
              hintText: '请输入备注信息（可选）',
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.textPlaceholder,
              ),
              filled: true,
              fillColor: AppColors.bgInput,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '汇总信息',
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            '入库产品',
            '${_items.where((item) => item.productId != null && item.productId!.isNotEmpty).length} 种',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            '总数量',
            '$_totalQuantity 桶',
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isPrimary = false}) {
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
          style: isPrimary
              ? AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '取消',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitInbound,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '提交入库',
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
