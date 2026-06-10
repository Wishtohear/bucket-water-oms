class PushNotification {
  final String event;
  final String title;
  final String content;
  final DateTime timestamp;
  final int? orderId;
  final String? orderNo;
  final String? status;
  final String? stationName;
  final int? stationId;
  final String? warehouseName;
  final int? warehouseId;
  final String? driverName;
  final int? driverId;
  final int? actualQty;
  final int? bucketReturned;
  final String? reason;
  final bool? accepted;
  final Map<String, dynamic>? extraData;

  PushNotification({
    required this.event,
    required this.title,
    required this.content,
    required this.timestamp,
    this.orderId,
    this.orderNo,
    this.status,
    this.stationName,
    this.stationId,
    this.warehouseName,
    this.warehouseId,
    this.driverName,
    this.driverId,
    this.actualQty,
    this.bucketReturned,
    this.reason,
    this.accepted,
    this.extraData,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json, String eventName) {
    DateTime parseTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    return PushNotification(
      event: eventName,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: parseTime(json['timestamp']),
      orderId: parseInt(json['orderId']),
      orderNo: json['orderNo'] as String?,
      status: json['status'] as String?,
      stationName: json['stationName'] as String?,
      stationId: parseInt(json['stationId']),
      warehouseName: json['warehouseName'] as String?,
      warehouseId: parseInt(json['warehouseId']),
      driverName: json['driverName'] as String?,
      driverId: parseInt(json['driverId']),
      actualQty: parseInt(json['actualQty']),
      bucketReturned: parseInt(json['bucketReturned']),
      reason: json['reason'] as String?,
      accepted: json['accepted'] as bool?,
      extraData: json,
    );
  }

  static const String eventOrderCreated = 'order_created';
  static const String eventOrderReviewed = 'order_reviewed';
  static const String eventOrderRejected = 'order_rejected';
  static const String eventOrderDispatched = 'order_dispatched';
  static const String eventOrderDelivering = 'order_delivering';
  static const String eventOrderCompleted = 'order_completed';
  static const String eventOrderCancelled = 'order_cancelled';
  static const String eventNewDeliveryTask = 'new_delivery_task';

  String get eventDisplayName {
    switch (event) {
      case eventOrderCreated:
        return '订单已提交';
      case eventOrderReviewed:
        return '订单已接单';
      case eventOrderRejected:
        return '订单已拒单';
      case eventOrderDispatched:
        return '订单已派单';
      case eventOrderDelivering:
        return '订单配送中';
      case eventOrderCompleted:
        return '订单已完成';
      case eventOrderCancelled:
        return '订单已取消';
      case eventNewDeliveryTask:
        return '新配送任务';
      default:
        return event;
    }
  }

  bool get isOrderRelated {
    return [
      eventOrderCreated,
      eventOrderReviewed,
      eventOrderRejected,
      eventOrderDispatched,
      eventOrderDelivering,
      eventOrderCompleted,
      eventOrderCancelled,
    ].contains(event);
  }

  bool get isDeliveryTask {
    return event == eventNewDeliveryTask;
  }

  @override
  String toString() {
    return 'PushNotification(event: $event, title: $title, content: $content, orderNo: $orderNo)';
  }
}

class OnlineStats {
  final int totalOnline;
  final int warehouseOnline;
  final int driverOnline;
  final int stationOnline;
  final int adminOnline;

  OnlineStats({
    required this.totalOnline,
    required this.warehouseOnline,
    required this.driverOnline,
    required this.stationOnline,
    required this.adminOnline,
  });

  factory OnlineStats.fromJson(Map<String, dynamic> json) {
    return OnlineStats(
      totalOnline: json['totalOnline'] as int? ?? 0,
      warehouseOnline: json['warehouseOnline'] as int? ?? 0,
      driverOnline: json['driverOnline'] as int? ?? 0,
      stationOnline: json['stationOnline'] as int? ?? 0,
      adminOnline: json['adminOnline'] as int? ?? 0,
    );
  }
}
