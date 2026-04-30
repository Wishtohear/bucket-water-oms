import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/components/status_badge.dart';
import '../../services/customer_service.dart';
import '../../models/customer_model.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<CustomerModel> _customers = [];
  
  final List<String> _filterTabs = ['全部客户', '欠费客户', '欠桶客户', '活跃客户'];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final customerService = CustomerService();

      List<CustomerModel> customers = [];
      if (appState.userId != null) {
        customers = await customerService.getCustomers(
          stationId: appState.stationId,
          keyword: _searchController.text.isNotEmpty ? _searchController.text : null,
        );
      }

      if (mounted) {
        setState(() {
          _customers = _filterCustomers(customers);
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
          _errorMessage = '加载客户列表失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> customers) {
    switch (_selectedTab) {
      case 1:
        return customers.where((c) => (c.balance ?? 0) < 0).toList();
      case 2:
        return customers.where((c) => (c.owedBarrels ?? 0) > 0).toList();
      case 3:
        return customers.where((c) => (c.ticketCount ?? 0) > 0).toList();
      default:
        return customers;
    }
  }

  void _showPhoneDialog(String phone, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Text('拨打电话: ${phone.replaceAll('*', '0')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('拨打 ${phone.replaceAll('*', '0')}')),
              );
            },
            child: const Text('拨打'),
          ),
        ],
      ),
    );
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
              child: _buildCustomerList(),
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
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '客户管理',
                style: AppTextStyles.h3,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('新增客户'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: AppTextStyles.buttonSmall,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchTextField(
            controller: _searchController,
            hintText: '搜索客户姓名、电话或地址',
            borderRadius: 20,
          ),
          const SizedBox(height: 12),
          _buildFilterTabs(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filterTabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                _filterTabs[index],
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCustomerList() {
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
              onPressed: _loadCustomers,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无客户数据',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCustomers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCustomerCard(customer),
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    BadgeType badgeType;
    switch (customer.typeText) {
      case '常客':
        badgeType = BadgeType.primary;
        break;
      case '欠费':
        badgeType = BadgeType.error;
        break;
      default:
        badgeType = BadgeType.info;
    }

    final balance = customer.balance ?? 0;
    final isNegativeBalance = balance < 0;
    final owedBarrels = customer.owedBarrels ?? 0;
    final hasOwedBarrels = owedBarrels > 0;

    final avatarColors = [
      const Color(0xFFEBF5FF),
      const Color(0xFFE6FFED),
      const Color(0xFFFFF7E6),
      const Color(0xFFF5F5F5),
    ];
    final avatarColor = avatarColors[customer.id.hashCode % avatarColors.length];

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
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
                      customer.name ?? '未知客户',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.maskedPhone,
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: customer.typeText,
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '账户余额',
                    isNegativeBalance
                        ? '-¥ ${balance.abs().toStringAsFixed(2)}'
                        : '¥ ${balance.toStringAsFixed(2)}',
                    isNegativeBalance ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _buildStatItem(
                    '剩余水票',
                    '${customer.ticketCount ?? 0} 张',
                    AppColors.textPrimary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _buildStatItem(
                    '欠桶数',
                    '$owedBarrels 个',
                    hasOwedBarrels ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textTertiary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        customer.address ?? '暂无地址',
                        style: AppTextStyles.captionSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPhoneDialog(
                      customer.phone ?? '',
                      customer.name ?? '未知客户',
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '详情',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
