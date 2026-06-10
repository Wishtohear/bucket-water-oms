class StationModel {
  final String? id;
  final String? name;
  final String? code;
  final String? address;
  final String? contactName;
  final String? contactPhone;
  final String? warehouseId;
  final String? warehouseName;
  final String? region;
  final String? status;
  final double? balance;
  final double? creditLimit;
  final double? usedCredit;
  final int? totalBarrels;
  final int? emptyBarrels;
  final int? debtBarrels;
  final String? billingCycle;
  final double? prepaidAmount;
  final int? barrelThreshold;
  final double? barrelDeposit;
  final Map<String, dynamic>? pricing;
  final DateTime? createdAt;
  final int? orderCount;
  final int? monthOrderCount;
  final int? monthBarrels;
  final double? monthAmount;
  final int? returnBarrels;
  final String? stationType;
  final String? remark;
  final String? area;
  final int? depositBucketNum;
  final double? initialBalance;
  final double? latitude;
  final double? longitude;

  StationModel({
    this.id,
    this.name,
    this.code,
    this.address,
    this.contactName,
    this.contactPhone,
    this.warehouseId,
    this.warehouseName,
    this.region,
    this.status,
    this.balance,
    this.creditLimit,
    this.usedCredit,
    this.totalBarrels,
    this.emptyBarrels,
    this.debtBarrels,
    this.billingCycle,
    this.prepaidAmount,
    this.barrelThreshold,
    this.barrelDeposit,
    this.pricing,
    this.createdAt,
    this.orderCount,
    this.monthOrderCount,
    this.monthBarrels,
    this.monthAmount,
    this.returnBarrels,
    this.stationType,
    this.remark,
    this.area,
    this.depositBucketNum,
    this.initialBalance,
    this.latitude,
    this.longitude,
  });

  factory StationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StationModel();

    Map<String, dynamic>? pricesMap;
    if (json['prices'] is List) {
      final pricesList = json['prices'] as List;
      pricesMap = {};
      for (var item in pricesList) {
        if (item is Map<String, dynamic>) {
          final productName =
              item['productName'] ?? item['product_name'] ?? '商品';
          final price = _parseDouble(item['price']) ?? 0.0;
          pricesMap[productName] = price;
        }
      }
    }

    return StationModel(
      id: json['id']?.toString(),
      name: json['name'],
      code: json['code'],
      address: json['address'],
      contactName:
          json['contactName'] ?? json['contact_name'] ?? json['contact'],
      contactPhone:
          json['contactPhone'] ?? json['contact_phone'] ?? json['phone'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName:
          json['warehouseName'] ?? json['warehouse_name'] ?? json['warehouse'],
      region: json['region'],
      status: json['status'],
      balance:
          _parseDouble(json['balance']) ?? _parseDouble(json['depositBalance']),
      creditLimit: _parseDouble(json['creditLimit']) ??
          _parseDouble(json['credit_limit']),
      usedCredit:
          _parseDouble(json['usedCredit']) ?? _parseDouble(json['used_credit']),
      totalBarrels: json['totalBarrels'] ??
          json['total_barrels'] ??
          json['depositBucketNum'],
      emptyBarrels: json['emptyBarrels'] ?? json['empty_barrels'],
      debtBarrels:
          json['debtBarrels'] ?? json['debt_barrels'] ?? json['owedBucketNum'],
      billingCycle:
          json['billingCycle'] ?? json['billing_cycle'] ?? json['paymentType'],
      prepaidAmount: _parseDouble(json['prepaidAmount']) ??
          _parseDouble(json['prepaid_amount']) ??
          _parseDouble(json['minDeposit']),
      barrelThreshold: json['barrelThreshold'] ??
          json['barrel_threshold'] ??
          json['owedThreshold'],
      barrelDeposit: _parseDouble(json['barrelDeposit']) ??
          _parseDouble(json['barrel_deposit']) ??
          _parseDouble(json['bucketDepositAmount']),
      pricing: pricesMap,
      createdAt: json['createdAt'] != null ||
              json['created_at'] != null ||
              json['createTime'] != null
          ? DateTime.tryParse(json['createdAt'] ??
              json['created_at'] ??
              json['createTime'] ??
              '')
          : null,
      orderCount: json['orderCount'] ?? json['order_count'],
      monthOrderCount: json['monthOrderCount'] ??
          json['month_order_count'] ??
          json['monthlyOrders'],
      monthBarrels: json['monthBarrels'] ??
          json['month_barrels'] ??
          json['monthlyBuckets'],
      monthAmount: _parseDouble(json['monthAmount']) ??
          _parseDouble(json['month_amount']) ??
          _parseDouble(json['monthlyAmount']),
      returnBarrels: json['returnBarrels'] ??
          json['return_barrels'] ??
          json['monthlyReturnBuckets'],
      stationType: json['stationType'] ?? json['station_type'],
      remark: json['remark'],
      area: json['area'],
      depositBucketNum: json['depositBucketNum'] ?? json['deposit_bucket_num'],
      initialBalance: _parseDouble(json['initialBalance']) ??
          _parseDouble(json['initial_balance']),
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'warehouseId': warehouseId,
      'region': region,
      'status': status,
      'billingCycle': billingCycle,
      'prepaidAmount': prepaidAmount,
      'barrelThreshold': barrelThreshold,
      'barrelDeposit': barrelDeposit,
      'pricing': pricing,
      'stationType': stationType,
      'remark': remark,
      'area': area,
      'depositBucketNum': depositBucketNum,
      'initialBalance': initialBalance,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get statusText {
    switch (status) {
      case 'active':
      case 'normal':
        return '正常运营';
      case 'suspended':
      case '欠费停供':
        return '欠费停供';
      case 'closed':
      case 'cancelled':
        return '已注销';
      default:
        return status ?? '未知';
    }
  }

  bool get isNormal => status == 'active' || status == 'normal';
  bool get isSuspended => status == 'suspended' || status == '欠费停供';
  bool get isClosed => status == 'closed' || status == 'cancelled';
}

class DriverModel {
  final String? id;
  final String? name;
  final String? code;
  final String? phone;
  final String? avatar;
  final String? region;
  final String? status;
  final String? onlineStatus;
  final int? todayDeliveries;
  final int? monthDeliveries;
  final DateTime? joinDate;
  final DateTime? lastActiveAt;
  final String? warehouseId;
  final String? warehouseName;
  final String? idCard;
  final String? vehicleInfo;
  final String? remark;

  DriverModel({
    this.id,
    this.name,
    this.code,
    this.phone,
    this.avatar,
    this.region,
    this.status,
    this.onlineStatus,
    this.todayDeliveries,
    this.monthDeliveries,
    this.joinDate,
    this.lastActiveAt,
    this.warehouseId,
    this.warehouseName,
    this.idCard,
    this.vehicleInfo,
    this.remark,
  });

  factory DriverModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DriverModel();
    return DriverModel(
      id: json['id']?.toString(),
      name: json['name'],
      code: json['code'],
      phone: json['phone'],
      avatar: json['avatar'],
      region: json['region'],
      status: json['status'],
      onlineStatus: json['onlineStatus'] ?? json['online_status'],
      todayDeliveries: json['todayDeliveries'] ?? json['today_deliveries'],
      monthDeliveries: json['monthDeliveries'] ?? json['month_deliveries'],
      joinDate: json['joinDate'] != null || json['join_date'] != null
          ? DateTime.tryParse(json['joinDate'] ?? json['join_date'])
          : null,
      lastActiveAt: json['lastActiveAt'] != null ||
              json['last_active_at'] != null
          ? DateTime.tryParse(json['lastActiveAt'] ?? json['last_active_at'])
          : null,
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      idCard: json['idCard'] ?? json['id_card'],
      vehicleInfo: json['vehicleInfo'] ?? json['vehicle_info'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'region': region,
      'status': status,
      'idCard': idCard,
      'vehicleInfo': vehicleInfo,
      'remark': remark,
    };
  }

  String get statusText {
    if (onlineStatus == 'online_delivering' || onlineStatus == '配送中') {
      return '在线配送中';
    } else if (onlineStatus == 'online_idle' || onlineStatus == '待命') {
      return '在线待命';
    } else if (onlineStatus == 'offline' || onlineStatus == '离线') {
      return '离线';
    } else if (onlineStatus == 'resting' || onlineStatus == '休息中') {
      return '休息中';
    }
    return onlineStatus ?? '未知';
  }
}

class WarehouseModel {
  final String? id;
  final String? name;
  final String? code;
  final String? address;
  final String? contact;
  final String? contactPhone;
  final String? status;
  final int? productStock;
  final int? emptyBarrelStock;
  final int? stationCount;
  final int? todayInbound;
  final int? todayOutbound;
  final int? warningLevel;
  final String? coverageArea;
  final String? type;

  WarehouseModel({
    this.id,
    this.name,
    this.code,
    this.address,
    this.contact,
    this.contactPhone,
    this.status,
    this.productStock,
    this.emptyBarrelStock,
    this.stationCount,
    this.todayInbound,
    this.todayOutbound,
    this.warningLevel,
    this.coverageArea,
    this.type,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WarehouseModel();
    return WarehouseModel(
      id: json['id']?.toString(),
      name: json['name'],
      code: json['code'],
      address: json['address'],
      contact: json['contact'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      status: json['status'],
      productStock: json['productStock'] ?? json['product_stock'],
      emptyBarrelStock: json['emptyBarrelStock'] ?? json['empty_barrel_stock'],
      stationCount: json['stationCount'] ?? json['station_count'],
      todayInbound: json['todayInbound'] ?? json['today_inbound'],
      todayOutbound: json['todayOutbound'] ?? json['today_outbound'],
      warningLevel: json['warningLevel'] ?? json['warning_level'],
      coverageArea: json['coverageArea'] ?? json['coverage_area'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'contact': contact,
      'contactPhone': contactPhone,
      'status': status,
      'coverageArea': coverageArea,
      'type': type,
    };
  }

  String get statusText {
    switch (status) {
      case 'active':
      case 'normal':
        return '正常运营';
      case 'warning':
        return '库存预警';
      case 'suspended':
        return '暂停运营';
      default:
        return status ?? '未知';
    }
  }

  bool get hasWarning => warningLevel != null && warningLevel! > 0;
}

class ProductModel {
  final String? id;
  final String? name;
  final String? code;
  final String? category;
  final double? price;
  final String? unit;
  final String? status;
  final String? imageUrl;
  final String? description;

  ProductModel({
    this.id,
    this.name,
    this.code,
    this.category,
    this.price,
    this.unit,
    this.status,
    this.imageUrl,
    this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductModel();
    return ProductModel(
      id: json['id']?.toString(),
      name: json['name'],
      code: json['code'],
      category: json['category'],
      price: _parseDouble(json['price']),
      unit: json['unit'],
      status: json['status'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'price': price,
      'unit': unit,
      'status': status,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}

class OrderItem {
  final String? id;
  final String? orderNo;
  final double? amount;
  final DateTime? createdAt;

  OrderItem({
    this.id,
    this.orderNo,
    this.amount,
    this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderItem();
    return OrderItem(
      id: json['id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      amount: _parseDouble(json['amount']),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,
    );
  }
}

class RegionModel {
  final String? id;
  final String? code;
  final String? name;
  final String? parentId;
  final String? parentCode;
  final int? level;
  final List<RegionModel>? children;

  RegionModel({
    this.id,
    this.code,
    this.name,
    this.parentId,
    this.parentCode,
    this.level,
    this.children,
  });

  factory RegionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RegionModel();
    return RegionModel(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name'],
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      parentCode: json['parentCode']?.toString() ?? json['parent_code']?.toString(),
      level: json['level'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((e) => RegionModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'parentId': parentId,
      'parentCode': parentCode,
      'level': level,
    };
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
