class PolicyModel {
  final String? id;
  final String? name;
  final String? type;
  final String? description;
  final String? billingCycle;
  final double? prepaidAmount;
  final int? barrelThreshold;
  final double? barrelDeposit;
  final Map<String, dynamic>? pricing;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final int? stationCount;

  PolicyModel({
    this.id,
    this.name,
    this.type,
    this.description,
    this.billingCycle,
    this.prepaidAmount,
    this.barrelThreshold,
    this.barrelDeposit,
    this.pricing,
    this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.stationCount,
  });

  factory PolicyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PolicyModel();
    return PolicyModel(
      id: json['id']?.toString(),
      name: json['name'],
      type: json['type'],
      description: json['description'],
      billingCycle: json['billingCycle'] ?? json['billing_cycle'],
      prepaidAmount: _parseDouble(json['prepaidAmount']) ?? _parseDouble(json['prepaid_amount']),
      barrelThreshold: json['barrelThreshold'] ?? json['barrel_threshold'],
      barrelDeposit: _parseDouble(json['barrelDeposit']) ?? _parseDouble(json['barrel_deposit']),
      pricing: json['pricing'] as Map<String, dynamic>?,
      status: json['status'],
      startDate: json['startDate'] != null || json['start_date'] != null
          ? DateTime.tryParse(json['startDate'] ?? json['start_date'])
          : null,
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.tryParse(json['endDate'] ?? json['end_date'])
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,
      stationCount: json['stationCount'] ?? json['station_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'billingCycle': billingCycle,
      'prepaidAmount': prepaidAmount,
      'barrelThreshold': barrelThreshold,
      'barrelDeposit': barrelDeposit,
      'pricing': pricing,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  String get typeText {
    switch (type) {
      case 'default':
        return '默认通用';
      case 'vip':
        return 'VIP客户';
      case 'promotion':
        return '限时促销';
      case 'trial':
        return '试用期';
      default:
        return type ?? '普通';
    }
  }

  String get billingCycleText {
    switch (billingCycle) {
      case 'immediate':
        return '现结';
      case 'monthly':
        return '月结';
      case 'quarterly':
        return '季结';
      default:
        return billingCycle ?? '月结';
    }
  }

  String get statusText {
    switch (status) {
      case 'active':
        return '生效中';
      case 'inactive':
        return '已停用';
      case 'expired':
        return '已过期';
      default:
        return status ?? '未知';
    }
  }

  bool get isActive => status == 'active';
}

class ProductPricingModel {
  final String? productId;
  final String? productName;
  final double? factoryPrice;
  final double? guidePriceMin;
  final double? guidePriceMax;
  final int? stock;

  ProductPricingModel({
    this.productId,
    this.productName,
    this.factoryPrice,
    this.guidePriceMin,
    this.guidePriceMax,
    this.stock,
  });

  factory ProductPricingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductPricingModel();
    return ProductPricingModel(
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      factoryPrice: _parseDouble(json['factoryPrice']) ?? _parseDouble(json['factory_price']),
      guidePriceMin: _parseDouble(json['guidePriceMin']) ?? _parseDouble(json['guide_price_min']),
      guidePriceMax: _parseDouble(json['guidePriceMax']) ?? _parseDouble(json['guide_price_max']),
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'factoryPrice': factoryPrice,
      'guidePriceMin': guidePriceMin,
      'guidePriceMax': guidePriceMax,
    };
  }
}

class PolicyListResponse {
  final List<PolicyModel> policies;
  final int total;
  final int page;
  final int pageSize;

  PolicyListResponse({
    required this.policies,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
