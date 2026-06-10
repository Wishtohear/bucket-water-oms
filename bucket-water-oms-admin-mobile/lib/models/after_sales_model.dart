class AfterSalesModel {
  final String? id;
  final String? afterSalesNo;
  final String? type;
  final String? orderId;
  final String? orderNo;
  final String? stationId;
  final String? stationName;
  final String? stationAddress;
  final String? phone;
  final String? status;
  final String? reason;
  final String? handleResult;
  final List<AfterSalesItem>? items;
  final String? handlerId;
  final String? handlerName;
  final DateTime? createdAt;
  final DateTime? processedAt;
  final DateTime? updatedAt;

  AfterSalesModel({
    this.id,
    this.afterSalesNo,
    this.type,
    this.orderId,
    this.orderNo,
    this.stationId,
    this.stationName,
    this.stationAddress,
    this.phone,
    this.status,
    this.reason,
    this.handleResult,
    this.items,
    this.handlerId,
    this.handlerName,
    this.createdAt,
    this.processedAt,
    this.updatedAt,
  });

  factory AfterSalesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AfterSalesModel();
    }
    return AfterSalesModel(
      id: json['id']?.toString() ?? json['afterSalesId']?.toString(),
      afterSalesNo:
          json['afterSalesNo'] ?? json['after_sales_no'] ?? json['code'],
      type: json['type'],
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      orderNo: json['orderNo'] ?? json['order_no'],
      stationId:
          json['stationId']?.toString() ?? json['station_id']?.toString(),
      stationName: json['stationName'] ?? json['station_name'],
      stationAddress: json['stationAddress'] ?? json['station_address'],
      phone: json['phone'] ?? json['contactPhone'] ?? json['contact_phone'],
      status: json['status'],
      reason: json['reason'],
      handleResult: json['handleResult'] ?? json['handle_result'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => AfterSalesItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      handlerId:
          json['handlerId']?.toString() ?? json['handler_id']?.toString(),
      handlerName: json['handlerName'] ?? json['handler_name'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['createTime'] != null
              ? DateTime.tryParse(json['createTime'].toString())
              : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : json['handledAt'] != null
              ? DateTime.tryParse(json['handledAt'].toString())
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (afterSalesNo != null) 'afterSalesNo': afterSalesNo,
      if (type != null) 'type': type,
      if (orderId != null) 'orderId': orderId,
      if (orderNo != null) 'orderNo': orderNo,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (stationAddress != null) 'stationAddress': stationAddress,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (handleResult != null) 'handleResult': handleResult,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (handlerId != null) 'handlerId': handlerId,
      if (handlerName != null) 'handlerName': handlerName,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (processedAt != null) 'processedAt': processedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get typeText {
    switch (type) {
      case 'replenish':
      case '补货':
        return '补货申请';
      case 'quality':
      case '质量':
        return '质量问题';
      case 'return':
      case '退货':
        return '退货申请';
      case 'exchange':
      case '换货':
        return '换货申请';
      default:
        return type ?? '未知';
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
      case '待处理':
        return '待处理';
      case 'processing':
      case '处理中':
        return '处理中';
      case 'completed':
      case '已完成':
        return '已完成';
      case 'rejected':
      case '已拒绝':
        return '已拒绝';
      default:
        return status ?? '未知';
    }
  }

  bool get isPending => status == 'pending' || status == '待处理';
  bool get isProcessing => status == 'processing' || status == '处理中';
  bool get isCompleted => status == 'completed' || status == '已完成';

  String get waitTimeText {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟';
    if (diff.inHours < 24) return '${diff.inHours}小时';
    return '${diff.inDays}天';
  }
}

class AfterSalesItem {
  final String? productId;
  final String? productName;
  final String? productSpec;
  final int? quantity;
  final String? issue;
  final String? issueType;

  AfterSalesItem({
    this.productId,
    this.productName,
    this.productSpec,
    this.quantity,
    this.issue,
    this.issueType,
  });

  factory AfterSalesItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AfterSalesItem();
    }
    return AfterSalesItem(
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString(),
      productName: json['productName'] ?? json['product_name'] ?? json['name'],
      productSpec: json['productSpec'] ?? json['product_spec'] ?? json['spec'],
      quantity: json['quantity'],
      issue: json['issue'],
      issueType: json['issueType'] ?? json['issue_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (productSpec != null) 'productSpec': productSpec,
      if (quantity != null) 'quantity': quantity,
      if (issue != null) 'issue': issue,
      if (issueType != null) 'issueType': issueType,
    };
  }

  String get issueText {
    if (issue != null) return issue!;
    switch (issueType) {
      case 'missing':
      case '缺少':
        return '缺少 $quantity 桶';
      case 'quality':
      case '质量':
        return '质量问题 $quantity 桶';
      default:
        return quantity != null ? '问题 $quantity 桶' : '';
    }
  }
}

class AfterSalesRequest {
  final String orderId;
  final String type;
  final String reason;
  final List<AfterSalesItemRequest> items;
  final String? remark;

  AfterSalesRequest({
    required this.orderId,
    required this.type,
    required this.reason,
    required this.items,
    this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'type': type,
      'reason': reason,
      'items': items.map((e) => e.toJson()).toList(),
      if (remark != null) 'remark': remark,
    };
  }
}

class AfterSalesItemRequest {
  final String productId;
  final int quantity;
  final String? issueType;
  final String? issue;

  AfterSalesItemRequest({
    required this.productId,
    required this.quantity,
    this.issueType,
    this.issue,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (issueType != null) 'issueType': issueType,
      if (issue != null) 'issue': issue,
    };
  }
}

class AfterSalesProcessRequest {
  final String afterSalesId;
  final String result;
  final String? remark;

  AfterSalesProcessRequest({
    required this.afterSalesId,
    required this.result,
    this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'afterSalesId': afterSalesId,
      'result': result,
      if (remark != null) 'remark': remark,
    };
  }
}
