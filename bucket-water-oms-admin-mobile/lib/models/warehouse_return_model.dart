class ReturnCheckModel {
  final String? id;
  final String? returnNo;
  final String? driverId;
  final String? driverName;
  final String? driverCode;
  final String? phone;
  final String? warehouseId;
  final String? warehouseName;
  final String? orderId;
  final String? orderNo;
  final int? bucketReturned;
  final int? actualBucketQty;
  final int? difference;
  final String? differenceReason;
  final String? status;
  final String? statusText;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? checkedAt;

  final DateTime? deliveryTime;
  final int? reportedBuckets;
  final int? confirmedBuckets;
  final int? owedBuckets;
  final String? replenishmentRequest;
  final String? handlerId;
  final String? handlerName;

  ReturnCheckModel({
    this.id,
    this.returnNo,
    this.driverId,
    this.driverName,
    this.driverCode,
    this.phone,
    this.warehouseId,
    this.warehouseName,
    this.orderId,
    this.orderNo,
    this.bucketReturned,
    this.actualBucketQty,
    this.difference,
    this.differenceReason,
    this.status,
    this.statusText,
    this.remark,
    this.createdAt,
    this.checkedAt,
    this.deliveryTime,
    this.reportedBuckets,
    this.confirmedBuckets,
    this.owedBuckets,
    this.replenishmentRequest,
    this.handlerId,
    this.handlerName,
  });

  factory ReturnCheckModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReturnCheckModel();
    }
    return ReturnCheckModel(
      id: json['id']?.toString(),
      returnNo: json['returnNo'] ?? json['code'],
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      driverName: json['driverName'] ?? json['driver_name'],
      driverCode: json['driverCode'] ?? json['driver_code'],
      phone: json['phone'] ?? json['driverPhone'] ?? json['driver_phone'],
      warehouseId:
          json['warehouseId']?.toString() ?? json['warehouse_id']?.toString(),
      warehouseName: json['warehouseName'] ?? json['warehouse_name'],
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      bucketReturned: json['bucketReturned'] ?? json['bucket_returned'],
      actualBucketQty: json['actualBucketQty'] ?? json['actual_bucket_qty'],
      difference: json['difference'],
      differenceReason: json['differenceReason'] ?? json['difference_reason'],
      status: json['status'],
      statusText: json['statusText'] ?? json['status_text'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      checkedAt: json['checkedAt'] != null
          ? DateTime.tryParse(json['checkedAt'].toString())
          : null,
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.tryParse(json['deliveryTime'].toString())
          : null,
      reportedBuckets: json['reportedBuckets'] ??
          json['reportBucketCount'] ??
          json['bucketReturned'],
      confirmedBuckets: json['confirmedBuckets'] ?? json['actualBucketQty'],
      owedBuckets: json['owedBuckets'] ?? json['difference'],
      replenishmentRequest: json['replenishmentRequest'],
      handlerId: json['handlerId']?.toString(),
      handlerName: json['handlerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (returnNo != null) 'returnNo': returnNo,
      if (driverId != null) 'driverId': driverId,
      if (driverName != null) 'driverName': driverName,
      if (driverCode != null) 'driverCode': driverCode,
      if (orderId != null) 'orderId': orderId,
      if (orderNo != null) 'orderNo': orderNo,
      if (bucketReturned != null) 'bucketReturned': bucketReturned,
      if (actualBucketQty != null) 'actualBucketQty': actualBucketQty,
      if (difference != null) 'difference': difference,
      if (differenceReason != null) 'differenceReason': differenceReason,
      if (status != null) 'status': status,
      if (remark != null) 'remark': remark,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (checkedAt != null) 'checkedAt': checkedAt!.toIso8601String(),
    };
  }

  String get statusDisplayText {
    if (statusText != null) return statusText!;
    switch (status) {
      case 'pending':
        return '待核对';
      case 'checked':
        return '已核对';
      case 'confirmed':
        return '已确认';
      case 'disputed':
        return '有差异';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending';
  bool get isChecked => status == 'checked' || status == 'confirmed';
  bool get hasDispute => (difference ?? owedBuckets ?? 0) > 0;

  String get waitTimeText {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟';
    if (diff.inHours < 24) return '${diff.inHours}小时';
    return '${diff.inDays}天';
  }
}

class ReturnCheckRequest {
  final String returnId;
  final int confirmedBuckets;
  final int? owedBuckets;
  final String? replenishmentRequest;
  final String? remark;

  ReturnCheckRequest({
    required this.returnId,
    required this.confirmedBuckets,
    this.owedBuckets,
    this.replenishmentRequest,
    this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'returnId': returnId,
      'confirmedBuckets': confirmedBuckets,
      if (owedBuckets != null) 'owedBuckets': owedBuckets,
      if (replenishmentRequest != null)
        'replenishmentRequest': replenishmentRequest,
      if (remark != null) 'remark': remark,
    };
  }
}
