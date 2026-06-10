import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/station_statement_service.dart';
import '../../services/station_service.dart';
import '../../models/monthly_statement_model.dart';
import '../../models/station_model.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';
import 'owner_orders_page.dart';

class OwnerStatementPage extends StatefulWidget {
  const OwnerStatementPage({super.key});

  @override
  State<OwnerStatementPage> createState() => _OwnerStatementPageState();
}

class _OwnerStatementPageState extends State<OwnerStatementPage> {
  final StationStatementService _statementService = StationStatementService();
  final StationService _stationService = StationService();

  bool _isLoading = true;
  String? _errorMessage;
  List<MonthlyStatementModel> _statements = [];
  MonthlyStatementModel? _selectedStatement;
  StationInfoModel? _stationInfo;
  int _currentIndex = 0;

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
      final appState = context.read<AppState>();
      final stationId = appState.stationId;

      if (stationId != null && stationId.isNotEmpty) {
        try {
          final statements = await _statementService.getMonthlyStatements(
            stationId: stationId,
          );
          final stationInfo = await _stationService.getStationInfo();

          if (mounted) {
            setState(() {
              _statements = statements;
              _stationInfo = stationInfo;
              if (statements.isNotEmpty && _currentIndex < statements.length) {
                _selectedStatement = statements[_currentIndex];
              }
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
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '无法获取水站ID';
            _isLoading = false;
          });
        }
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

  Future<void> _selectMonth(int index) async {
    if (index >= 0 && index < _statements.length) {
      setState(() {
        _currentIndex = index;
        _selectedStatement = _statements[index];
      });
    }
  }

  Future<void> _confirmStatement() async {
    if (_selectedStatement == null) return;

    final confirmed = await _statementService.confirmMonthlyStatement(
      stationId: _stationInfo?.id ?? '',
      statementId: _selectedStatement!.id ?? '',
    );

    if (confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('对账单已确认')),
      );
      _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('确认失败，请稍后重试')),
      );
    }
  }

  Future<void> _disputeStatement() async {
    if (_selectedStatement == null) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => _DisputeDialog(),
    );

    if (result != null && result.isNotEmpty) {
      final disputed = await _statementService.disputeMonthlyStatement(
        stationId: _stationInfo?.id ?? '',
        statementId: _selectedStatement!.id ?? '',
        reason: result,
      );

      if (disputed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已提交异议')),
        );
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交失败，请稍后重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(topPadding),
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

  Widget _buildHeader(double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '月度对账单',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statements.isNotEmpty &&
                            _currentIndex < _statements.length
                        ? _statements[_currentIndex].yearMonth
                        : null,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: AppColors.white),
                    dropdownColor: AppColors.primary,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.white),
                    items: _statements.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.yearMonth,
                        child: Text(
                          s.formattedMonth,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final index =
                            _statements.indexWhere((s) => s.yearMonth == value);
                        if (index != -1) {
                          _selectMonth(index);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_statements.isNotEmpty && _currentIndex < _statements.length) ...[
            const SizedBox(height: 16),
            _buildBalanceOverview(_statements[_currentIndex]),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceOverview(MonthlyStatementModel statement) {
    final closingBalance = statement.closingBalance ?? 0.0;
    final totalAmount = statement.totalAmount ?? 0.0;
    final paymentReceived = statement.paymentReceived ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '期末待结',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${closingBalance.toStringAsFixed(2)}',
                    style: AppTextStyles.statNumber.copyWith(
                      fontSize: 28,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(statement.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statement.statusText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('本月进货', '¥${totalAmount.toStringAsFixed(0)}'),
              Container(
                  width: 1,
                  height: 30,
                  color: AppColors.white.withOpacity(0.3)),
              _buildMiniStat('已回款', '¥${paymentReceived.toStringAsFixed(0)}'),
              Container(
                  width: 1,
                  height: 30,
                  color: AppColors.white.withOpacity(0.3)),
              _buildMiniStat('订单数', '${statement.totalOrders ?? 0}'),
              Container(
                  width: 1,
                  height: 30,
                  color: AppColors.white.withOpacity(0.3)),
              _buildMiniStat('总桶数', '${statement.totalBuckets ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.success;
      case 'paid':
        return AppColors.primary;
      case 'disputed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(_errorMessage!,
              style:
                  AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('重新加载')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_statements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('暂无对账单',
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedStatement != null) ...[
              _buildOrderDetailsCard(),
              const SizedBox(height: 16),
              _buildProductSummaryCard(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    final statement = _selectedStatement!;
    final orders = statement.orders ?? [];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单明细',
                style: AppTextStyles.subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '共${statement.totalOrders ?? 0}笔订单',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '暂无订单记录',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...orders.take(5).map((order) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderItem(order),
              );
            }),
          if (orders.length > 5)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerOrdersPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.keyboard_arrow_down),
                label: Text('查看全部${orders.length}笔订单'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(MonthlyOrderSummary order) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getOrderStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt,
            color: _getOrderStatusColor(order.status),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNo ?? '',
                style: AppTextStyles.subtitle2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${order.formattedDate} · ${order.items ?? ''}',
                style: AppTextStyles.captionSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              order.amountText,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getOrderStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getOrderStatusText(order.status),
                style: AppTextStyles.captionSmall.copyWith(
                  color: _getOrderStatusColor(order.status),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getOrderStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending_review':
        return AppColors.warning;
      case 'dispatched':
        return AppColors.primary;
      case 'delivering':
        return AppColors.teal;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getOrderStatusText(String? status) {
    switch (status) {
      case 'pending_review':
        return '待审核';
      case 'reviewed':
        return '已接单';
      case 'dispatched':
        return '已派单';
      case 'delivering':
        return '配送中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      case 'rejected':
        return '已拒单';
      default:
        return status ?? '';
    }
  }

  Widget _buildProductSummaryCard() {
    final statement = _selectedStatement!;
    final products = statement.products ?? [];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '商品汇总',
                style: AppTextStyles.subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '共${products.length}种商品',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '暂无商品记录',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...products.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProductItem(product),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProductItem(MonthlyProductSummary product) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.water_drop,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName ?? '',
                style: AppTextStyles.subtitle2
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${product.quantity ?? 0}桶',
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ),
        Text(
          '¥${product.subtotal?.toStringAsFixed(2) ?? '0.00'}',
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final statement = _selectedStatement;
    final isPending = statement?.status == 'pending';

    return Column(
      children: [
        AppButton(
          text: '确认对账单无误',
          type: AppButtonType.primary,
          isFullWidth: true,
          height: 56,
          onPressed: isPending ? _confirmStatement : null,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: '对账单有争议',
          type: AppButtonType.outline,
          isFullWidth: true,
          height: 56,
          onPressed: isPending ? _disputeStatement : null,
        ),
      ],
    );
  }
}

class _DisputeDialog extends StatefulWidget {
  @override
  State<_DisputeDialog> createState() => _DisputeDialogState();
}

class _DisputeDialogState extends State<_DisputeDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('提交异议'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: '请输入异议原因...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('提交'),
        ),
      ],
    );
  }
}
