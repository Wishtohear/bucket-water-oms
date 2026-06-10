class StationInfoModel {
  final String? id;
  final String? name;
  final String? address;
  final String? contactName;
  final String? contactPhone;
  final double? balance;
  final double? creditLimit;
  final double? usedCredit;
  final double? depositPerBucket;
  final int? totalBuckets;
  final int? oweBuckets;
  final String? paymentType;
  final int? paymentDays;
  final DateTime? createdAt;

  StationInfoModel({
    this.id,
    this.name,
    this.address,
    this.contactName,
    this.contactPhone,
    this.balance,
    this.creditLimit,
    this.usedCredit,
    this.depositPerBucket,
    this.totalBuckets,
    this.oweBuckets,
    this.paymentType,
    this.paymentDays,
    this.createdAt,
  });

  factory StationInfoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationInfoModel();
    return StationInfoModel(
      id: json['id']?.toString(),
      name: json['name'],
      address: json['address'],
      contactName: json['contactName'] ?? json['contact_name'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      balance: _parseDouble(json['balance']),
      creditLimit: _parseDouble(json['creditLimit'] ?? json['credit_limit']),
      usedCredit: _parseDouble(json['usedCredit'] ?? json['used_credit']),
      depositPerBucket: _parseDouble(json['depositPerBucket'] ?? json['deposit_per_bucket']),
      totalBuckets: json['totalBuckets'] ?? json['total_buckets'] ?? json['totalBuckets'],
      oweBuckets: json['oweBuckets'] ?? json['owe_buckets'] ?? json['oweBuckets'],
      paymentType: json['paymentType'] ?? json['payment_type'],
      paymentDays: json['paymentDays'] ?? json['payment_days'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'balance': balance,
        'creditLimit': creditLimit,
        'usedCredit': usedCredit,
        'depositPerBucket': depositPerBucket,
        'totalBuckets': totalBuckets,
        'oweBuckets': oweBuckets,
        'paymentType': paymentType,
        'paymentDays': paymentDays,
        'createdAt': createdAt?.toIso8601String(),
      };

  double get availableCredit => (creditLimit ?? 0) - (usedCredit ?? 0);

  double get depositAmount => (depositPerBucket ?? 0) * (oweBuckets ?? 0);

  String get paymentTypeText {
    switch (paymentType) {
      case 'monthly':
        return '月结';
      case 'prepaid':
        return '预付款';
      case 'credit':
        return '信用支付';
      default:
        return paymentType ?? '月结';
    }
  }
}

class StationInventoryModel {
  final String? id;
  final String? stationId;
  final List<InventoryItemModel>? items;
  final int? totalCount;
  final DateTime? updatedAt;

  StationInventoryModel({
    this.id,
    this.stationId,
    this.items,
    this.totalCount,
    this.updatedAt,
  });

  factory StationInventoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationInventoryModel();
    return StationInventoryModel(
      id: json['id']?.toString(),
      stationId: json['stationId']?.toString() ?? json['station_id']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => InventoryItemModel.fromJson(e))
              .toList()
          : null,
      totalCount: json['totalCount'] ?? json['total_count'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stationId': stationId,
        'items': items?.map((e) => e.toJson()).toList(),
        'totalCount': totalCount,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class InventoryItemModel {
  final String? productId;
  final String? productName;
  final String? productSpec;
  final String? productImage;
  final int? stock;
  final double? price;
  final String? warehouseId;
  final String? warehouseName;
  final String? status;

  InventoryItemModel({
    this.productId,
    this.productName,
    this.productSpec,
    this.productImage,
    this.stock,
    this.price,
    this.warehouseId,
    this.warehouseName,
    this.status,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryItemModel();
    return InventoryItemModel(
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'] ?? json['name'],
      productSpec: json['productSpec'] ?? json['product_spec'] ?? json['spec'],
      productImage: json['productImage'] ?? json['product_image'] ?? json['image'],
      stock: json['stock'],
      price: _parseDouble(json['price']),
      warehouseId: json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'productSpec': productSpec,
        'productImage': productImage,
        'stock': stock,
        'price': price,
        'warehouseId': warehouseId,
        'warehouseName': warehouseName,
        'status': status,
      };

  String get stockStatus {
    if (stock == null || stock! <= 0) return '缺货';
    if (stock! < 50) return '不足';
    return '充足';
  }
}

class RechargeRequest {
  final double amount;
  final String? paymentMethod;
  final String? giftAmount;

  RechargeRequest({
    required this.amount,
    this.paymentMethod,
    this.giftAmount,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (giftAmount != null) 'giftAmount': giftAmount,
      };
}

class RechargeResponse {
  final String? orderId;
  final String? status;
  final String? message;
  final double? actualAmount;
  final double? giftAmount;

  RechargeResponse({
    this.orderId,
    this.status,
    this.message,
    this.actualAmount,
    this.giftAmount,
  });

  factory RechargeResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RechargeResponse();
    return RechargeResponse(
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      status: json['status'],
      message: json['message'],
      actualAmount: _parseDouble(json['actualAmount'] ?? json['actual_amount']),
      giftAmount: _parseDouble(json['giftAmount'] ?? json['gift_amount']),
    );
  }
}

class DepositRequest {
  final int bucketCount;
  final String? paymentMethod;

  DepositRequest({
    required this.bucketCount,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'bucketCount': bucketCount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };
}

class DepositResponse {
  final String? orderId;
  final String? status;
  final String? message;
  final double? amount;
  final int? bucketCount;

  DepositResponse({
    this.orderId,
    this.status,
    this.message,
    this.amount,
    this.bucketCount,
  });

  factory DepositResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DepositResponse();
    return DepositResponse(
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      status: json['status'],
      message: json['message'],
      amount: _parseDouble(json['amount']),
      bucketCount: json['bucketCount'] ?? json['bucket_count'],
    );
  }
}

class SalesPolicyModel {
  final String? id;
  final String? stationId;
  final String? policyName;
  final String? policyType;
  final List<PolicyRuleModel>? rules;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  SalesPolicyModel({
    this.id,
    this.stationId,
    this.policyName,
    this.policyType,
    this.rules,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory SalesPolicyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SalesPolicyModel();
    return SalesPolicyModel(
      id: json['id']?.toString(),
      stationId: json['stationId']?.toString() ?? json['station_id']?.toString(),
      policyName: json['policyName'] ?? json['policy_name'],
      policyType: json['policyType'] ?? json['policy_type'],
      rules: json['rules'] != null
          ? (json['rules'] as List)
              .map((e) => PolicyRuleModel.fromJson(e))
              .toList()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stationId': stationId,
        'policyName': policyName,
        'policyType': policyType,
        'rules': rules?.map((e) => e.toJson()).toList(),
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'status': status,
      };
}

class PolicyRuleModel {
  final String? productId;
  final String? productName;
  final double? unitPrice;
  final double? minQuantity;
  final double? discountRate;
  final double? tierPrice;
  final String? priceType;

  PolicyRuleModel({
    this.productId,
    this.productName,
    this.unitPrice,
    this.minQuantity,
    this.discountRate,
    this.tierPrice,
    this.priceType,
  });

  factory PolicyRuleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PolicyRuleModel();
    return PolicyRuleModel(
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'],
      unitPrice: _parseDouble(json['unitPrice'] ?? json['unit_price']),
      minQuantity: _parseDouble(json['minQuantity'] ?? json['min_quantity']),
      discountRate: _parseDouble(json['discountRate'] ?? json['discount_rate']),
      tierPrice: _parseDouble(json['tierPrice'] ?? json['tier_price']),
      priceType: json['priceType'] ?? json['price_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'minQuantity': minQuantity,
        'discountRate': discountRate,
        'tierPrice': tierPrice,
        'priceType': priceType,
      };

  String get priceTypeText {
    switch (priceType) {
      case 'monthly':
        return '月结价';
      case 'tiered':
        return '阶梯价';
      case 'discount':
        return '折扣价';
      default:
        return priceType ?? '标准价';
    }
  }
}

class RechargeGiftModel {
  final double? amount;
  final double? gift;

  RechargeGiftModel({
    this.amount,
    this.gift,
  });

  factory RechargeGiftModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RechargeGiftModel();
    return RechargeGiftModel(
      amount: _parseDouble(json['amount']),
      gift: _parseDouble(json['gift']),
    );
  }

  static List<RechargeGiftModel> defaultGifts() {
    return [
      RechargeGiftModel(amount: 1000, gift: 10),
      RechargeGiftModel(amount: 2000, gift: 30),
      RechargeGiftModel(amount: 5000, gift: 100),
      RechargeGiftModel(amount: 10000, gift: 250),
      RechargeGiftModel(amount: 20000, gift: 600),
    ];
  }

  double calculateGift(double rechargeAmount) {
    double gift = 0;
    for (var rule in defaultGifts()) {
      if (rechargeAmount >= (rule.amount ?? 0)) {
        gift = rule.gift ?? 0;
      }
    }
    return gift;
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
