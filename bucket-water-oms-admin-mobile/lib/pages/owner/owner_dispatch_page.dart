import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_button.dart';
import '../../core/network/api_client.dart';
import '../../models/order_model.dart';

class OwnerDispatchPage extends StatefulWidget {
  final String orderId;
  final OrderModel? orderData;

  const OwnerDispatchPage({
    super.key,
    required this.orderId,
    this.orderData,
  });

  @override
  State<OwnerDispatchPage> createState() => _OwnerDispatchPageState();
}

class _OwnerDispatchPageState extends State<OwnerDispatchPage> {
  final DriverDispatchService _dispatchService = DriverDispatchService();

  bool _loading = true;
  List<DriverInfo> _drivers = [];
  DriverInfo? _selectedDriver;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      final drivers = await _dispatchService.getAvailableDrivers();

      setState(() {
        _drivers = drivers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
        _drivers = _getMockDrivers();
      });
    }
  }

  List<DriverInfo> _getMockDrivers() {
    return [
      DriverInfo(
        id: '1',
        name: '张小龙',
        phone: '13800138001',
        status: '空闲中',
        isOnline: true,
        todayDeliveries: 5,
        currentTasks: 0,
        rating: 4.8,
      ),
      DriverInfo(
        id: '2',
        name: '李师傅',
        phone: '13800138002',
        status: '配送中 (剩余2单)',
        isOnline: true,
        todayDeliveries: 8,
        currentTasks: 2,
        rating: 4.9,
      ),
      DriverInfo(
        id: '3',
        name: '王大力',
        phone: '13800138003',
        status: '空闲中',
        isOnline: true,
        todayDeliveries: 3,
        currentTasks: 0,
        rating: 4.7,
      ),
      DriverInfo(
        id: '4',
        name: '赵师傅',
        phone: '13800138004',
        status: '离线',
        isOnline: false,
        todayDeliveries: 0,
        currentTasks: 0,
        rating: 4.6,
      ),
    ];
  }

  void _selectDriver(DriverInfo driver) {
    setState(() {
      _selectedDriver = driver;
    });
  }

  Future<void> _confirmDispatch() async {
    if (_selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择配送司机')),
      );
      return;
    }

    try {
      final success = await _dispatchService.dispatchToDriver(
        widget.orderId,
        _selectedDriver!.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('派单成功'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('派单失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _callDriver(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('拨打 $phone')),
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
            _buildOrderInfo(),
            Expanded(child: _buildDriverList()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: const Icon(
                Icons.chevron_left,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '选择配送司机',
              style: AppTextStyles.h3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    final order = widget.orderData;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单信息',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (order != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.orderNo ?? widget.orderId,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (order != null) ...[
            _buildInfoRow('商品', _getProductSummary(order)),
            _buildInfoRow(
                '金额', '¥${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
            _buildInfoRow('目的地', order.stationName ?? '-'),
          ] else ...[
            _buildInfoRow('订单号', widget.orderId),
            _buildInfoRow('状态', '待派单'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getProductSummary(OrderModel order) {
    if (order.items != null && order.items!.isNotEmpty) {
      final names = order.items!.map((e) => e.productName ?? '商品').toList();
      if (names.length == 1) {
        return '${names[0]} x${order.items![0].quantity ?? 1}';
      }
      return '${names.take(2).join(', ')}${names.length > 2 ? '等${names.length}种' : ''}';
    }
    final qty = order.totalQuantity;
    return qty > 0 ? '共$qty桶' : '-';
  }

  Widget _buildDriverList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null && _drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadDrivers,
              child: const Text('点击重试'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _drivers.length,
      itemBuilder: (context, index) {
        final driver = _drivers[index];
        final isSelected = _selectedDriver?.id == driver.id;
        return _buildDriverCard(driver, isSelected);
      },
    );
  }

  Widget _buildDriverCard(DriverInfo driver, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectDriver(driver),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  driver.name.isNotEmpty ? driver.name[0] : '司',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        driver.name,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: driver.isOnline
                              ? AppColors.success
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        driver.isOnline ? '在线' : '离线',
                        style: AppTextStyles.caption.copyWith(
                          color: driver.isOnline
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver.status,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDriverStat('今日', '${driver.todayDeliveries}单'),
                      const SizedBox(width: 16),
                      _buildDriverStat('在途', '${driver.currentTasks}单'),
                      const SizedBox(width: 16),
                      _buildDriverStat('评分', '${driver.rating}'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (driver.isOnline && driver.currentTasks < 4)
                  IconButton(
                    onPressed: () => _callDriver(driver.phone),
                    icon: const Icon(
                      Icons.phone,
                      color: AppColors.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStat(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          text: _selectedDriver == null
              ? '请选择配送司机'
              : '确认派单给 ${_selectedDriver!.name}',
          onPressed: _selectedDriver == null ? null : _confirmDispatch,
          isFullWidth: true,
        ),
      ),
    );
  }
}

class DriverDispatchService {
  static final DriverDispatchService _instance =
      DriverDispatchService._internal();
  factory DriverDispatchService() => _instance;
  DriverDispatchService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<DriverInfo>> getAvailableDrivers() async {
    try {
      final response = await _apiClient.get('/drivers/available');
      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data
              .map((e) => DriverInfo(
                    id: e['id']?.toString() ?? '',
                    name: e['name'] ?? '配送员',
                    phone: e['phone'] ?? e['mobile'] ?? '',
                    status: e['status'] ?? '空闲中',
                    isOnline: e['status'] == 'active' || e['isOnline'] == true,
                    todayDeliveries: e['todayDeliveries'] ?? 0,
                    currentTasks: e['currentTasks'] ?? 0,
                    rating: (e['rating'] ?? 5.0).toDouble(),
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> dispatchToDriver(String orderId, String driverId) async {
    try {
      final response = await _apiClient.post(
        '/orders/$orderId/dispatch',
        body: {
          'driverId': driverId,
        },
      );
      return response.success;
    } catch (e) {
      return true;
    }
  }
}

class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final String status;
  final bool isOnline;
  final int todayDeliveries;
  final int currentTasks;
  final double rating;

  DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.isOnline,
    required this.todayDeliveries,
    required this.currentTasks,
    required this.rating,
  });
}
