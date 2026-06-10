class NotificationModel {
  final int? id;
  final int? userId;
  final String? type;
  final String? title;
  final String? content;
  final String? relatedId;
  final bool? isRead;
  final DateTime? readTime;
  final DateTime? createTime;

  NotificationModel({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.content,
    this.relatedId,
    this.isRead,
    this.readTime,
    this.createTime,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      type: json['type'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      relatedId: json['relatedId'] as String?,
      isRead: json['isRead'] as bool?,
      readTime: json['readTime'] != null ? DateTime.tryParse(json['readTime'].toString()) : null,
      createTime: json['createTime'] != null ? DateTime.tryParse(json['createTime'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
      'relatedId': relatedId,
      'isRead': isRead,
      'readTime': readTime?.toIso8601String(),
      'createTime': createTime?.toIso8601String(),
    };
  }

  String get typeText {
    switch (type) {
      case 'order_status':
        return '订单状态';
      case 'statement_ready':
        return '对账单';
      case 'bucket_warning':
        return '欠桶预警';
      case 'payment_reminder':
        return '付款提醒';
      case 'system_notice':
        return '系统通知';
      default:
        return '通知';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'order_status':
        return '📦';
      case 'statement_ready':
        return '📄';
      case 'bucket_warning':
        return '⚠️';
      case 'payment_reminder':
        return '💰';
      case 'system_notice':
        return '🔔';
      default:
        return '📢';
    }
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? content,
    String? relatedId,
    bool? isRead,
    DateTime? readTime,
    DateTime? createTime,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      readTime: readTime ?? this.readTime,
      createTime: createTime ?? this.createTime,
    );
  }
}

class NotificationUnreadCount {
  final int count;

  NotificationUnreadCount({required this.count});

  factory NotificationUnreadCount.fromJson(Map<String, dynamic> json) {
    return NotificationUnreadCount(
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}
