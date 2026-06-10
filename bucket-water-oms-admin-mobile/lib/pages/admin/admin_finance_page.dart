import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/admin_finance_service.dart';
import '../../models/admin_models.dart';

class AdminFinancePage extends StatefulWidget {
  const AdminFinancePage({super.key});

  @override
  State<AdminFinancePage> createState() => _AdminFinancePageState();
}

class _AdminFinancePageState extends State<AdminFinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  FinanceOverviewResponse? _financeOverview;
  List<FinanceStatementModel> _statements = [];

  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final financeService = AdminFinanceService();

      final overviewFuture = financeService.getFinanceOverview();
      final statementsFuture = financeService.getStatements(
        page: _currentPage,
        pageSize: _pageSize,
      );

      final results = await Future.wait([overviewFuture, statementsFuture]);

      if (mounted) {
        setState(() {
          _financeOverview = results[0] as FinanceOverviewResponse;
          final statementsResponse = results[1] as FinanceStatementListResponse;
          _statements = statementsResponse.statements;
          _totalPages = (statementsResponse.total / _pageSize).ceil();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载财务数据失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '财务管理',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.textPrimary),
            onPressed: _showExportDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle:
                  AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '往来对账'),
                Tab(text: '水站结算'),
                Tab(text: '充值记录'),
                Tab(text: '费用报销'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
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
            onPressed: _loadData,
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSummaryCards(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStatementsTab(),
              _buildSettlementTab(),
              _buildRechargeTab(),
              _buildExpenseTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final overview = _financeOverview;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  label: '本月总应收',
                  value:
                      '¥${(overview?.totalReceivable ?? 0).toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  iconColor: AppColors.primary,
                  textColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  label: '本月已回款',
                  value: '¥${(overview?.totalPaid ?? 0).toStringAsFixed(2)}',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  textColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  label: '待审核争议',
                  value: '${overview?.pendingStatements ?? 0} 笔',
                  icon: Icons.warning_amber_outlined,
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  label: '总欠额',
                  value: '¥${(overview?.totalUnpaid ?? 0).toStringAsFixed(2)}',
                  icon: Icons.money_off,
                  iconColor: AppColors.orange,
                  textColor: AppColors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementsTab() {
    if (_statements.isEmpty) {
      return _buildEmptyState('暂无对账数据');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _statements.length + 1,
        itemBuilder: (context, index) {
          if (index == _statements.length) {
            return _buildLoadMoreButton();
          }
          return _buildStatementItem(_statements[index]);
        },
      ),
    );
  }

  Widget _buildSettlementTab() {
    final settlements =
        _statements.where((s) => s.status == 'settled').toList();
    if (settlements.isEmpty) {
      return _buildEmptyState('暂无结算数据');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settlements.length,
      itemBuilder: (context, index) {
        return _buildStatementItem(settlements[index]);
      },
    );
  }

  Widget _buildRechargeTab() {
    return _buildEmptyState('充值记录功能开发中');
  }

  Widget _buildExpenseTab() {
    return _buildEmptyState('费用报销功能开发中');
  }

  Widget _buildStatementItem(FinanceStatementModel statement) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => _showStatementDetail(statement),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  statement.stationName ?? '未知水站',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(statement.status ?? ''),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  label: '交易金额',
                  value: '¥${(statement.totalAmount ?? 0).toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  label: '当前余额',
                  value: '¥${(statement.unpaidAmount ?? 0).toStringAsFixed(2)}',
                  valueColor: (statement.unpaidAmount ?? 0) > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatPeriod(statement),
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
      case 'settled':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = '已确认';
        break;
      case 'pending':
      case '待确认':
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        text = '待确认';
        break;
      case 'disputed':
      case '争议':
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = '有争议';
        break;
      case 'overdue':
      case '逾期':
        bgColor = AppColors.orange.withOpacity(0.1);
        textColor = AppColors.orange;
        text = '已逾期';
        break;
      default:
        bgColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (_currentPage >= _totalPages) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: TextButton(
          onPressed: () {
            setState(() {
              _currentPage++;
            });
            _loadData();
          },
          child: const Text('加载更多'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPeriod(FinanceStatementModel statement) {
    final startDate = statement.startDate;
    final endDate = statement.endDate;

    if (startDate == null || endDate == null) {
      return '账期未知';
    }

    return '${_formatDate(startDate)} ~ ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showStatementDetail(FinanceStatementModel statement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStatementDetailSheet(statement),
    );
  }

  Widget _buildStatementDetailSheet(FinanceStatementModel statement) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '对账单详情',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('基本信息', [
                    {'label': '水站名称', 'value': statement.stationName ?? '-'},
                    {'label': '账期', 'value': _formatPeriod(statement)},
                    {
                      'label': '状态',
                      'value': _getStatusText(statement.status ?? '')
                    },
                  ]),
                  const SizedBox(height: 24),
                  _buildDetailSection('金额信息', [
                    {
                      'label': '交易金额',
                      'value':
                          '¥${(statement.totalAmount ?? 0).toStringAsFixed(2)}'
                    },
                    {
                      'label': '已付金额',
                      'value':
                          '¥${(statement.paidAmount ?? 0).toStringAsFixed(2)}'
                    },
                    {
                      'label': '未付金额',
                      'value':
                          '¥${(statement.unpaidAmount ?? 0).toStringAsFixed(2)}'
                    },
                  ]),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                if (statement.status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDispute(statement),
                      child: const Text('处理争议'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmStatement(statement),
                      child: const Text('确认对账'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('关闭'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label'] ?? '',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item['value'] ?? '-',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
      case 'settled':
        return '已确认';
      case 'pending':
        return '待确认';
      case 'disputed':
        return '有争议';
      case 'overdue':
        return '已逾期';
      default:
        return status;
    }
  }

  Future<void> _confirmStatement(FinanceStatementModel statement) async {
    try {
      final financeService = AdminFinanceService();
      await financeService.confirmStatement(statement.id ?? '');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('对账单确认成功'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('对账单确认失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDispute(FinanceStatementModel statement) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('处理争议'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: '请输入解决方案',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'confirmed'),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final financeService = AdminFinanceService();
        await financeService.confirmStatement(statement.id ?? '');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('争议处理成功'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('争议处理失败: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导出报表',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              icon: Icons.receipt_long,
              title: '对账单导出',
              subtitle: '导出所有对账记录',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('对账单导出');
              },
            ),
            _buildExportOption(
              icon: Icons.account_balance,
              title: '财务报表导出',
              subtitle: '导出财务统计数据',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('财务报表导出');
              },
            ),
            _buildExportOption(
              icon: Icons.payments_outlined,
              title: '应收款导出',
              subtitle: '导出应收款明细',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('应收款导出');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.captionSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能开发中'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
