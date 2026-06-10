class DriverTaskModel {
  final String? id;
  final String? taskNo;
  final String? orderId;
  final String? orderNo;
  final String? status;
  final String? stationId;
  final String? stationName;
  final String? contactName;
  final String? contactPhone;
  final String? deliveryAddress;
  final double? longitude;
  final double? latitude;
  final double? distance;
  final int? sequence;
  final bool? isCheckedIn;
  final DateTime? checkInTime;
  final double? checkInLongitude;
  final double? checkInLatitude;
  final String? checkInAddress;
  final int? historicalOwedBuckets;
  final int? depositBuckets;
  final int? currentReturnBuckets;
  final int? currentOwedBuckets;
  final List<TaskItemModel>? items;
  final int? totalQuantity;
  final double? amount;
  final String? paymentType;
  final DateTime? estimatedDeliveryTime;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DriverTaskProgress? progress;

  DriverTaskModel({
    this.id,
    this.taskNo,
    this.orderId,
    this.orderNo,
    this.status,
    this.stationId,
    this.stationName,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.longitude,
    this.latitude,
    this.distance,
    this.sequence,
    this.isCheckedIn,
    this.checkInTime,
    this.checkInLongitude,
    this.checkInLatitude,
    this.checkInAddress,
    this.historicalOwedBuckets,
    this.depositBuckets,
    this.currentReturnBuckets,
    this.currentOwedBuckets,
    this.items,
    this.totalQuantity,
    this.amount,
    this.paymentType,
    this.estimatedDeliveryTime,
    this.createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.progress,
  });

  factory DriverTaskModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverTaskModel();
    }
    
    String? taskId = json['id']?.toString();
    if ((taskId == null || taskId.isEmpty) && json['orderId'] != null) {
      taskId = json['orderId'].toString();
    }
    
    final bucketReturn = json['bucketReturn'];
    int? currentReturnBuckets;
    int? currentOwedBuckets;
    int? historicalOwedBuckets;
    if (bucketReturn != null && bucketReturn is Map) {
      currentReturnBuckets = bucketReturn['returnedQty'] ?? bucketReturn['currentReturnBuckets'];
      currentOwedBuckets = bucketReturn['owedQty'] ?? bucketReturn['currentOwedBuckets'];
      historicalOwedBuckets = bucketReturn['totalOwed'] ?? bucketReturn['historicalOwedBuckets'];
    }
    
    return DriverTaskModel(
      id: taskId,
      taskNo: json['taskNo'] ?? json['no'],
      orderId: json['orderId']?.toString(),
      orderNo: json['orderNo'],
      status: json['status'],
      stationId: json['stationId']?.toString(),
      stationName: json['stationName'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      deliveryAddress: json['deliveryAddress'] ?? json['address'],
      longitude: _parseDouble(json['longitude'] ?? json['lng']),
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      distance: _parseDouble(json['distance']),
      sequence: _parseInt(json['sequence']),
      isCheckedIn: json['isCheckedIn'] ?? json['checkedIn'],
      checkInTime: json['checkInTime'] != null
          ? DateTime.tryParse(json['checkInTime'].toString())
          : null,
      checkInLongitude: _parseDouble(json['checkInLongitude']),
      checkInLatitude: _parseDouble(json['checkInLatitude']),
      checkInAddress: json['checkInAddress'],
      historicalOwedBuckets: historicalOwedBuckets ?? _parseInt(json['historicalOwedBuckets']),
      depositBuckets: _parseInt(json['depositBuckets']),
      currentReturnBuckets: currentReturnBuckets ?? _parseInt(json['currentReturnBuckets']),
      currentOwedBuckets: currentOwedBuckets ?? _parseInt(json['currentOwedBuckets']),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => TaskItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      totalQuantity: _parseInt(json['totalQuantity']) ?? _parseInt(json['quantity']),
      amount: _parseDouble(json['amount']),
      paymentType: json['paymentType'],
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.tryParse(json['estimatedDeliveryTime'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.tryParse(json['pickedUpAt'].toString())
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
      progress: json['progress'] != null
          ? DriverTaskProgress.fromJson(json['progress'] as Map<String, dynamic>?)
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return '待取货';
      case 'picked_up':
        return '已取货';
      case 'delivering':
        return '配送中';
      case 'delivered':
        return '已送达';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      case 'returned':
        return '已退货';
      default:
        return status ?? '未知';
    }
  }

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }

  String get sequenceText => sequence != null ? '第$sequence单' : '';

  String get amountText =>
      amount != null ? '¥${amount!.toStringAsFixed(2)}' : '¥0.00';
  String get quantityText => '${totalQuantity ?? 0} 桶';

  bool get isDeliverable =>
      status == 'pending' || status == 'picked_up' || status == 'delivering';
  bool get canStartDelivery => status == 'pending' || status == 'picked_up';
  bool get canConfirmDelivery =>
      status == 'delivering' && (isCheckedIn == true);
}

class TaskItemModel {
  final String? productId;
  final String? productName;
  final String? productSpec;
  final int? quantity;
  final int? deliveredQuantity;
  final double? unitPrice;

  TaskItemModel({
    this.productId,
    this.productName,
    this.productSpec,
    this.quantity,
    this.deliveredQuantity,
    this.unitPrice,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TaskItemModel();
    }
    return TaskItemModel(
      productId: json['productId']?.toString(),
      productName: json['productName'] ?? json['name'],
      productSpec: json['productSpec'] ?? json['spec'],
      quantity: json['quantity'],
      deliveredQuantity: json['deliveredQuantity'],
      unitPrice: _parseDouble(json['unitPrice']),
    );
  }

  String get quantityText =>
      '${deliveredQuantity ?? quantity ?? 0} / ${quantity ?? 0}';
}

class DriverTaskProgress {
  final bool? orderCreated;
  final bool? orderConfirmed;
  final bool? dispatched;
  final bool? startedDelivery;
  final bool? arrived;
  final bool? delivered;
  final DateTime? orderCreatedTime;
  final DateTime? orderConfirmedTime;
  final DateTime? dispatchedTime;
  final DateTime? startedDeliveryTime;
  final DateTime? arrivedTime;
  final DateTime? deliveredTime;

  DriverTaskProgress({
    this.orderCreated,
    this.orderConfirmed,
    this.dispatched,
    this.startedDelivery,
    this.arrived,
    this.delivered,
    this.orderCreatedTime,
    this.orderConfirmedTime,
    this.dispatchedTime,
    this.startedDeliveryTime,
    this.arrivedTime,
    this.deliveredTime,
  });

  factory DriverTaskProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DriverTaskProgress();
    }
    return DriverTaskProgress(
      orderCreated: json['orderCreated'] ?? json['created'],
      orderConfirmed: json['orderConfirmed'] ?? json['confirmed'],
      dispatched: json['dispatched'],
      startedDelivery: json['startedDelivery'] ?? json['started'],
      arrived: json['arrived'],
      delivered: json['delivered'],
      orderCreatedTime: json['orderCreatedTime'] != null
          ? DateTime.tryParse(json['orderCreatedTime'].toString())
          : null,
      orderConfirmedTime: json['orderConfirmedTime'] != null
          ? DateTime.tryParse(json['orderConfirmedTime'].toString())
          : null,
      dispatchedTime: json['dispatchedTime'] != null
          ? DateTime.tryParse(json['dispatchedTime'].toString())
          : null,
      startedDeliveryTime: json['startedDeliveryTime'] != null
          ? DateTime.tryParse(json['startedDeliveryTime'].toString())
          : null,
      arrivedTime: json['arrivedTime'] != null
          ? DateTime.tryParse(json['arrivedTime'].toString())
          : null,
      deliveredTime: json['deliveredTime'] != null
          ? DateTime.tryParse(json['deliveredTime'].toString())
          : null,
    );
  }

  int get currentStep {
    if (delivered == true) return 5;
    if (arrived == true) return 4;
    if (startedDelivery == true) return 3;
    if (dispatched == true) return 2;
    if (orderConfirmed == true) return 1;
    return 0;
  }
}

class DriverDeliveryConfirm {
  final String? orderId;
  final String? taskId;
  final Map<String, int>? productQuantities;
  final int? returnBuckets;
  final int? owedBuckets;
  final List<String>? photos;
  final String? signType;
  final String? signature;
  final String? smsCode;
  final String? verificationCode;
  final String? bossCode;
  final String? confirmCode;
  final String? remark;

  DriverDeliveryConfirm({
    this.orderId,
    this.taskId,
    this.productQuantities,
    this.returnBuckets,
    this.owedBuckets,
    this.photos,
    this.signType,
    this.signature,
    this.smsCode,
    this.verificationCode,
    this.bossCode,
    this.confirmCode,
    this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) 'orderId': orderId,
      if (taskId != null) 'taskId': taskId,
      if (productQuantities != null) 'productQuantities': productQuantities,
      if (returnBuckets != null) 'returnBuckets': returnBuckets,
      if (owedBuckets != null) 'owedBuckets': owedBuckets,
      if (photos != null) 'photos': photos,
      if (signType != null) 'signType': signType,
      if (signature != null) 'signature': signature,
      if (smsCode != null) 'smsCode': smsCode,
      if (verificationCode != null) 'verificationCode': verificationCode,
      if (bossCode != null) 'bossCode': bossCode,
      if (confirmCode != null) 'confirmCode': confirmCode,
      if (remark != null) 'remark': remark,
    };
  }
}

class DriverCheckIn {
  final String? orderId;
  final String? taskId;
  final double? longitude;
  final double? latitude;
  final String? address;
  final double? accuracy;
  final String? checkInType;
  final String? photoUrl;
  final double? distance;
  final bool? isWithinTolerance;

  DriverCheckIn({
    this.orderId,
    this.taskId,
    this.longitude,
    this.latitude,
    this.address,
    this.accuracy,
    this.checkInType,
    this.photoUrl,
    this.distance,
    this.isWithinTolerance,
  });

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) 'orderId': orderId,
      if (taskId != null) 'taskId': taskId,
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'latitude': latitude,
      if (address != null) 'address': address,
      if (accuracy != null) 'accuracy': accuracy,
      if (checkInType != null) 'checkInType': checkInType,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (distance != null) 'distance': distance,
      if (isWithinTolerance != null) 'isWithinTolerance': isWithinTolerance,
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

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
