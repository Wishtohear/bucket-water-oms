class WarehouseStats {
  final int? totalInbound;
  final int? totalOutbound;
  final int? totalInventory;
  final int? pendingOrders;
  final int? completedOrders;

  WarehouseStats({
    this.totalInbound,
    this.totalOutbound,
    this.totalInventory,
    this.pendingOrders,
    this.completedOrders,
  });

  factory WarehouseStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseStats();
    }
    return WarehouseStats(
      totalInbound: json['totalInbound'],
      totalOutbound: json['totalOutbound'],
      totalInventory: json['totalInventory'],
      pendingOrders: json['pendingOrders'],
      completedOrders: json['completedOrders'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (totalInbound != null) 'totalInbound': totalInbound,
      if (totalOutbound != null) 'totalOutbound': totalOutbound,
      if (totalInventory != null) 'totalInventory': totalInventory,
      if (pendingOrders != null) 'pendingOrders': pendingOrders,
      if (completedOrders != null) 'completedOrders': completedOrders,
    };
  }
}

class WarehouseDashboardModel {
  final int? todayInbound;
  final int? todayOutbound;
  final int? totalInventory;
  final int? lowStockWarnings;
  final List<WarehouseTask>? recentTasks;
  final List<WarehouseAlert>? inventoryWarnings;
  final List<WarehouseNotification>? notifications;

  WarehouseDashboardModel({
    this.todayInbound,
    this.todayOutbound,
    this.totalInventory,
    this.lowStockWarnings,
    this.recentTasks,
    this.inventoryWarnings,
    this.notifications,
  });

  factory WarehouseDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseDashboardModel();
    }
    return WarehouseDashboardModel(
      todayInbound: json['todayInbound'],
      todayOutbound: json['todayOutbound'],
      totalInventory: json['totalInventory'],
      lowStockWarnings: json['lowStockWarnings'],
      recentTasks: json['recentTasks'] != null
          ? (json['recentTasks'] as List)
              .map((e) => WarehouseTask.fromJson(e))
              .toList()
          : null,
      inventoryWarnings: json['inventoryWarnings'] != null
          ? (json['inventoryWarnings'] as List)
              .map((e) => WarehouseAlert.fromJson(e))
              .toList()
          : null,
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((e) => WarehouseNotification.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (todayInbound != null) 'todayInbound': todayInbound,
      if (todayOutbound != null) 'todayOutbound': todayOutbound,
      if (totalInventory != null) 'totalInventory': totalInventory,
      if (lowStockWarnings != null) 'lowStockWarnings': lowStockWarnings,
      if (recentTasks != null)
        'recentTasks': recentTasks!.map((e) => e.toJson()).toList(),
      if (inventoryWarnings != null)
        'inventoryWarnings': inventoryWarnings!.map((e) => e.toJson()).toList(),
      if (notifications != null)
        'notifications': notifications!.map((e) => e.toJson()).toList(),
    };
  }

  int get todayInboundCount => todayInbound ?? 0;
  int get todayOutboundCount => todayOutbound ?? 0;
  int get pendingOrders =>
      recentTasks?.where((t) => t.status == 'pending').length ?? 0;
  int get lowStockProducts => lowStockWarnings ?? 0;
}

class WarehouseTask {
  final String? taskId;
  final String? taskNo;
  final String? type;
  final String? typeText;
  final String? status;
  final String? statusText;
  final String? customerName;
  final int? quantity;
  final String? createdAt;

  WarehouseTask({
    this.taskId,
    this.taskNo,
    this.type,
    this.typeText,
    this.status,
    this.statusText,
    this.customerName,
    this.quantity,
    this.createdAt,
  });

  factory WarehouseTask.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseTask();
    }
    return WarehouseTask(
      taskId: json['taskId']?.toString(),
      taskNo: json['taskNo'],
      type: json['type'],
      typeText: json['typeText'],
      status: json['status'],
      statusText: json['statusText'],
      customerName: json['customerName'],
      quantity: json['quantity'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) 'taskId': taskId,
      if (taskNo != null) 'taskNo': taskNo,
      if (type != null) 'type': type,
      if (typeText != null) 'typeText': typeText,
      if (status != null) 'status': status,
      if (statusText != null) 'statusText': statusText,
      if (customerName != null) 'customerName': customerName,
      if (quantity != null) 'quantity': quantity,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  String get displayText {
    return taskNo ?? taskId ?? '';
  }

  String get statusDisplayText {
    return statusText ?? status ?? '';
  }
}

class WarehouseAlert {
  final String? productId;
  final String? productName;
  final int? currentStock;
  final int? safeStock;
  final String? warehouseName;

  WarehouseAlert({
    this.productId,
    this.productName,
    this.currentStock,
    this.safeStock,
    this.warehouseName,
  });

  factory WarehouseAlert.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseAlert();
    }
    return WarehouseAlert(
      productId: json['productId']?.toString(),
      productName: json['productName'],
      currentStock: json['currentStock'],
      safeStock: json['safeStock'],
      warehouseName: json['warehouseName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (currentStock != null) 'currentStock': currentStock,
      if (safeStock != null) 'safeStock': safeStock,
      if (warehouseName != null) 'warehouseName': warehouseName,
    };
  }

  String get displayText {
    return productName ?? '未知商品';
  }

  String get warningText {
    return '库存不足 ($currentStock)';
  }
}

class WarehouseNotification {
  final String? id;
  final String? title;
  final String? content;
  final String? type;
  final String? createdAt;

  WarehouseNotification({
    this.id,
    this.title,
    this.content,
    this.type,
    this.createdAt,
  });

  factory WarehouseNotification.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WarehouseNotification();
    }
    return WarehouseNotification(
      id: json['id']?.toString(),
      title: json['title'],
      content: json['content'],
      type: json['type'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
