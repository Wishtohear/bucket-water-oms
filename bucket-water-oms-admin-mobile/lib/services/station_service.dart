import '../core/network/api_client.dart';
import '../models/station_model.dart';

class StationService {
  static final StationService _instance = StationService._internal();
  factory StationService() => _instance;
  StationService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<StationInfoModel> getStationInfo() async {
    final response = await _apiClient.get('/stations/info');

    if (response.success && response.data != null) {
      return StationInfoModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取水站信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<StationInventoryModel> getInventory() async {
    final response = await _apiClient.get('/stations/inventory');

    if (response.success && response.data != null) {
      return StationInventoryModel.fromJson(
          response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取库存失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<ProductPriceModel>> getProductPrices() async {
    final response = await _apiClient.get('/stations/product-prices');

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => ProductPriceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        response.message ?? '获取商品价格失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<InventoryItemModel>> getAvailableProducts() async {
    final response = await _apiClient.get('/stations/inventory');

    if (response.success && response.data != null) {
      final inventory =
          StationInventoryModel.fromJson(response.data as Map<String, dynamic>);
      return inventory.items ?? [];
    } else {
      throw ApiException(
        response.message ?? '获取商品列表失败',
        statusCode: response.code,
      );
    }
  }

  Future<RechargeResponse> recharge(RechargeRequest request) async {
    final response = await _apiClient.post(
      '/stations/recharge',
      body: request.toJson(),
    );

    if (response.success) {
      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return RechargeResponse.fromJson(response.data);
        }
      }
      return RechargeResponse(
        status: 'success',
        message: '充值申请已提交',
        actualAmount: request.amount,
        giftAmount: request.giftAmount != null
            ? double.tryParse(request.giftAmount!)
            : _calculateGift(request.amount),
      );
    } else {
      throw ApiException(
        response.message ?? '充值失败',
        statusCode: response.code,
      );
    }
  }

  Future<DepositResponse> payDeposit(DepositRequest request) async {
    final response = await _apiClient.post(
      '/stations/deposit',
      body: request.toJson(),
    );

    if (response.success) {
      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return DepositResponse.fromJson(response.data);
        }
      }
      final stationInfo = await getStationInfo();
      final depositAmount =
          (stationInfo.depositPerBucket ?? 40) * request.bucketCount;
      return DepositResponse(
        status: 'success',
        message: '押金补缴申请已提交',
        amount: depositAmount,
        bucketCount: request.bucketCount,
      );
    } else {
      throw ApiException(
        response.message ?? '押金补缴失败',
        statusCode: response.code,
      );
    }
  }

  Future<SalesPolicyModel?> getSalesPolicy() async {
    final response = await _apiClient.get('/stations/policy');

    if (response.success && response.data != null) {
      return SalesPolicyModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _apiClient.get('/auth/profile');

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    } else {
      throw ApiException(
        response.message ?? '获取个人信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '/auth/profile',
      body: data,
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '更新个人信息失败',
        statusCode: response.code,
      );
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    if (response.success) {
      return true;
    } else {
      throw ApiException(
        response.message ?? '修改密码失败',
        statusCode: response.code,
      );
    }
  }

  double calculateGiftAmount(double amount) {
    if (amount >= 20000) return 600;
    if (amount >= 10000) return 250;
    if (amount >= 5000) return 100;
    if (amount >= 2000) return 30;
    if (amount >= 1000) return 10;
    return 0;
  }

  double _calculateGift(double amount) {
    if (amount >= 20000) return 600;
    if (amount >= 10000) return 250;
    if (amount >= 5000) return 100;
    if (amount >= 2000) return 30;
    if (amount >= 1000) return 10;
    return 0;
  }
}

class StationDashboardService {
  static final StationDashboardService _instance =
      StationDashboardService._internal();
  factory StationDashboardService() => _instance;
  StationDashboardService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<StationDashboardModel> getDashboard() async {
    final response = await _apiClient.get('/stations/dashboard');

    if (response.success && response.data != null) {
      return StationDashboardModel.fromJson(
          response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取仪表盘数据失败',
        statusCode: response.code,
      );
    }
  }
}

class StationDashboardModel {
  final String? stationId;
  final String? stationName;
  final String? contact;
  final String? contactPhone;
  final String? address;
  final double? accountBalance;
  final double? creditLimit;
  final double? usedCredit;
  final double? availableCredit;
  final int? owedBucketNum;
  final int? owedThreshold;
  final bool? overThreshold;
  final int? totalBuckets;
  final int? billingCycle;
  final List<RecentOrderModel>? recentOrders;
  final List<NotificationItemModel>? notifications;

  StationDashboardModel({
    this.stationId,
    this.stationName,
    this.contact,
    this.contactPhone,
    this.address,
    this.accountBalance,
    this.creditLimit,
    this.usedCredit,
    this.availableCredit,
    this.owedBucketNum,
    this.owedThreshold,
    this.overThreshold,
    this.totalBuckets,
    this.billingCycle,
    this.recentOrders,
    this.notifications,
  });

  factory StationDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationDashboardModel();
    return StationDashboardModel(
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      contact: json['contact'],
      contactPhone: json['contactPhone'],
      address: json['address'],
      accountBalance: _parseDouble(json['accountBalance']),
      creditLimit: _parseDouble(json['creditLimit']),
      usedCredit: _parseDouble(json['usedCredit']),
      availableCredit: _parseDouble(json['availableCredit']),
      owedBucketNum: json['owedBucketNum'],
      owedThreshold: json['owedThreshold'],
      overThreshold: json['overThreshold'],
      totalBuckets: json['totalBuckets'],
      billingCycle: json['billingCycle'],
      recentOrders: json['recentOrders'] != null
          ? (json['recentOrders'] as List)
              .map((e) => RecentOrderModel.fromJson(e))
              .toList()
          : null,
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((e) => NotificationItemModel.fromJson(e))
              .toList()
          : null,
    );
  }

  String get accountBalanceText => accountBalance?.toStringAsFixed(2) ?? '0.00';
  double get usedCreditValue => usedCredit ?? 0;
  double get creditLimitValue => creditLimit ?? 0;
  int get owedBucketCount => owedBucketNum ?? 0;
}

class RecentOrderModel {
  final String? orderId;
  final String? orderNo;
  final String? status;
  final String? statusText;
  final String? totalAmount;
  final int? totalQuantity;
  final DateTime? createdAt;

  RecentOrderModel({
    this.orderId,
    this.orderNo,
    this.status,
    this.statusText,
    this.totalAmount,
    this.totalQuantity,
    this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecentOrderModel();
    return RecentOrderModel(
      orderId: json['orderId']?.toString(),
      orderNo: json['orderNo'],
      status: json['status'],
      statusText: json['statusText'],
      totalAmount: json['totalAmount']?.toString(),
      totalQuantity: json['totalQuantity'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class NotificationItemModel {
  final String? id;
  final String? title;
  final String? content;
  final String? type;
  final DateTime? createdAt;
  final bool? isRead;

  NotificationItemModel({
    this.id,
    this.title,
    this.content,
    this.type,
    this.createdAt,
    this.isRead,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationItemModel();
    return NotificationItemModel(
      id: json['id']?.toString(),
      title: json['title'],
      content: json['content'],
      type: json['type'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isRead: json['isRead'] ?? json['is_read'],
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class ProductPriceModel {
  final int? productId;
  final String? productName;
  final double? unitPrice;
  final int? minOrderQuantity;
  final TierPriceInfo? tierPrice;

  ProductPriceModel({
    this.productId,
    this.productName,
    this.unitPrice,
    this.minOrderQuantity,
    this.tierPrice,
  });

  factory ProductPriceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductPriceModel();
    return ProductPriceModel(
      productId: json['productId'],
      productName: json['productName'],
      unitPrice: _parseDouble(json['unitPrice']),
      minOrderQuantity: json['minOrderQuantity'],
      tierPrice: json['tierPrice'] != null
          ? TierPriceInfo.fromJson(json['tierPrice'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TierPriceInfo {
  final double? price;
  final int? minQuantity;

  TierPriceInfo({
    this.price,
    this.minQuantity,
  });

  factory TierPriceInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TierPriceInfo();
    return TierPriceInfo(
      price: _parseDouble(json['price']),
      minQuantity: json['minQuantity'],
    );
  }
}
