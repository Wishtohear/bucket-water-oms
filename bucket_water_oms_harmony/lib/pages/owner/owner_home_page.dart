import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_bottom_bar.dart';
import '../../shared/components/quick_action_button.dart';
import '../../shared/components/stat_card.dart';
import '../../shared/components/status_badge.dart';
import '../../services/dashboard_service.dart';
import '../../services/inventory_service.dart';
import '../../models/dashboard_model.dart';
import '../../models/product_model.dart';
import '../../core/network/api_client.dart';
import '../../main.dart';
import 'owner_orders_page.dart';
import 'owner_statement_page.dart';
import 'owner_profile_page.dart';
import 'recharge_page.dart';
import 'bucket_exchange_page.dart';
import '../order/order_create_page.dart';
import '../customer/customer_list_page.dart';
import '../ticket/ticket_manage_page.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  DashboardModel? _dashboardData;
  List<ProductModel> _productList = [];

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
      final dashboardService = DashboardService();
      final dashboardData = await dashboardService.getDashboardData();

      final inventoryService = InventoryService();
      final products = await inventoryService.getProducts();

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _productList = products;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const OwnerOrdersPage(),
          const OwnerStatementPage(),
          const OwnerProfilePage(),
        ],
      ),
      bottomNavigationBar: OwnerBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: AppColors.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadData, child: const Text('重新加载')),
          ],
        ),
      );
    }

    final appState = context.watch<AppState>();

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(appState),
          _buildTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNotificationBanner(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildBanner(),
                    const SizedBox(height: 16),
                    _buildFinancialCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildQuickFunctions(),
                    const SizedBox(height: 16),
                    _buildProductSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appState.currentStationName.isNotEmpty
                  ? appState.currentStationName
                  : '张记旗舰水站',
              style:
                  AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textSecondary,
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.textSecondary,
            onPressed: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          _buildTabItem('首页', isSelected: true),
          _buildTabItem('订单',
              isSelected: false,
              onTap: () => setState(() => _currentIndex = 1)),
          _buildTabItem('我的',
              isSelected: false,
              onTap: () => setState(() => _currentIndex = 3)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label,
      {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OwnerStatementPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.campaign, color: AppColors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '对账提醒',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '您2026年3月份对账单已生成，请及时确认',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {},
        decoration: InputDecoration(
          hintText: '搜索水种、水票、空桶服务',
          hintStyle:
              AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1890FF), Color(0xFF40A9FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.6),
                    AppColors.primary.withOpacity(0.2),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '夏季清凉大促',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '预存水票8折起',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    final balance = _dashboardData?.accountBalanceText ?? '12,500.00';
    final creditUsed = _dashboardData?.usedCredit?.toString() ?? '0';
    final creditTotal = _dashboardData?.creditLimit?.toString() ?? '5,000';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('账户余额 (元)', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      balance,
                      style: AppTextStyles.statNumber.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RechargePage()));
                      },
                      child: Text(
                        '立即充值',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.borderLight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('信用额度', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$creditUsed / $creditTotal',
                              style: AppTextStyles.subtitle2
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Text('剩余额度', style: AppTextStyles.captionSmall),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.borderLight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('支付方式', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text('月结',
                          style: AppTextStyles.subtitle2
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('账期: 30天', style: AppTextStyles.captionSmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmptyBucketWarning(),
        ],
      ),
    );
  }

  Widget _buildEmptyBucketWarning() {
    final emptyBarrels = _dashboardData?.emptyBarrels ?? 8;

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BucketExchangePage()));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '累计欠桶: $emptyBarrels 个',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '超过10个将限制下单',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.error.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '补缴押金',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.wallet,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            label: '充值',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RechargePage())),
          ),
          _buildQuickActionItem(
            icon: Icons.description,
            iconColor: AppColors.success,
            backgroundColor: AppColors.success.withOpacity(0.1),
            label: '对账',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OwnerStatementPage())),
          ),
          _buildQuickActionItem(
            icon: Icons.inventory_2,
            iconColor: AppColors.purple,
            backgroundColor: AppColors.purple.withOpacity(0.1),
            label: '空桶',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BucketExchangePage())),
          ),
          _buildQuickActionItem(
            icon: Icons.settings,
            iconColor: AppColors.textSecondary,
            backgroundColor: AppColors.bgInput,
            label: '设置',
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFunctions() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快捷功能',
            style:
                AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFunctionItem(
                  icon: Icons.shopping_cart,
                  iconColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  label: '一键下单',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OrderCreatePage())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFunctionItem(
                  icon: Icons.search,
                  iconColor: AppColors.success,
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  label: '订单查询',
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFunctionItem(
                  icon: Icons.people,
                  iconColor: AppColors.indigo,
                  backgroundColor: AppColors.indigo.withOpacity(0.1),
                  label: '客户管理',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerListPage())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFunctionItem(
                  icon: Icons.confirmation_number,
                  iconColor: AppColors.rose,
                  backgroundColor: AppColors.rose.withOpacity(0.1),
                  label: '水票管理',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TicketManagePage())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    final products =
        _productList.isNotEmpty ? _productList : _getMockProducts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '可订货商品',
              style:
                  AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrderCreatePage())),
              child: Row(
                children: [
                  Text(
                    '全部商品',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...products.take(3).map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductCard(product),
            )),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final stockStatus = '充足';

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const OrderCreatePage())),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.water_drop,
                      color: AppColors.primary, size: 32),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stockStatus == '充足'
                          ? AppColors.success
                          : AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stockStatus,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '18.9L 经典桶装水',
                    style: AppTextStyles.subtitle2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '仓库A: 库存充足',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '¥ ${product.price ?? '8.00'}',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('/桶 (月结价)', style: AppTextStyles.captionSmall),
                      const SizedBox(width: 8),
                      if (stockStatus == '促销')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '阶梯价',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  List<ProductModel> _getMockProducts() {
    return [
      ProductModel(id: '1', name: '18.9L 经典桶装水', price: 8.0),
      ProductModel(id: '2', name: '11.3L 迷你桶装水', price: 6.0),
      ProductModel(id: '3', name: '瓶装水 550ml×24', price: 25.0),
    ];
  }
}
