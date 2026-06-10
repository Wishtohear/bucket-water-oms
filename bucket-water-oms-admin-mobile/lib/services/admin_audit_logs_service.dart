import '../core/network/api_client.dart';

class AdminAuditLogsService {
  static final AdminAuditLogsService _instance = AdminAuditLogsService._internal();
  factory AdminAuditLogsService() => _instance;
  AdminAuditLogsService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<AuditLogListResponse> getAuditLogs({
    int? userId,
    String? username,
    String? action,
    String? module,
    String? entityType,
    String? entityId,
    String? startTime,
    String? endTime,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (userId != null) queryParams['userId'] = userId.toString();
    if (username != null && username.isNotEmpty) queryParams['username'] = username;
    if (action != null && action.isNotEmpty) queryParams['action'] = action;
    if (module != null && module.isNotEmpty) queryParams['module'] = module;
    if (entityType != null && entityType.isNotEmpty) queryParams['entityType'] = entityType;
    if (entityId != null && entityId.isNotEmpty) queryParams['entityId'] = entityId;
    if (startTime != null && startTime.isNotEmpty) queryParams['startTime'] = startTime;
    if (endTime != null && endTime.isNotEmpty) queryParams['endTime'] = endTime;

    final response = await _apiClient.get(
      '/admin/audit-logs',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<AuditLogModel> logs = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          logs = data.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
          total = logs.length;
        } else if (data is Map<String, dynamic>) {
          if (data['records'] != null) {
            logs = (data['records'] as List)
                .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (data['list'] != null) {
            logs = (data['list'] as List)
                .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? logs.length;
        }
      }

      return AuditLogListResponse(
        logs: logs,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<List<AuditLogModel>> getRecentLogs({int limit = 10}) async {
    final response = await _apiClient.get(
      '/admin/audit-logs/recent',
      queryParams: {'limit': limit.toString()},
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<AuditLogModel?> getAuditLogById(int logId) async {
    final response = await _apiClient.get('/admin/audit-logs/$logId');

    if (response.success && response.data != null) {
      return AuditLogModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<int> getDebugCount() async {
    final response = await _apiClient.get('/admin/audit-logs/debug/count');

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['count'] ?? 0;
      } else if (data is int) {
        return data;
      }
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> deleteAllLogs() async {
    final response = await _apiClient.delete('/admin/audit-logs');

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }
}

class AuditLogListResponse {
  final List<AuditLogModel> logs;
  final int total;
  final int page;
  final int pageSize;

  AuditLogListResponse({
    required this.logs,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

class AuditLogModel {
  final String? id;
  final String? userId;
  final String? username;
  final String? userRole;
  final String? action;
  final String? module;
  final String? entityType;
  final String? entityId;
  final String? entityName;
  final String? method;
  final String? requestUrl;
  final String? requestMethod;
  final String? ipAddress;
  final String? requestParams;
  final int? responseStatus;
  final String? errorMessage;
  final DateTime? createTime;

  AuditLogModel({
    this.id,
    this.userId,
    this.username,
    this.userRole,
    this.action,
    this.module,
    this.entityType,
    this.entityId,
    this.entityName,
    this.method,
    this.requestUrl,
    this.requestMethod,
    this.ipAddress,
    this.requestParams,
    this.responseStatus,
    this.errorMessage,
    this.createTime,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AuditLogModel();
    return AuditLogModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      username: json['username'],
      userRole: json['userRole'] ?? json['user_role'],
      action: json['action'],
      module: json['module'],
      entityType: json['entityType'] ?? json['entity_type'],
      entityId: json['entityId']?.toString() ?? json['entity_id']?.toString(),
      entityName: json['entityName'] ?? json['entity_name'],
      method: json['method'],
      requestUrl: json['requestUrl'] ?? json['request_url'],
      requestMethod: json['requestMethod'] ?? json['request_method'],
      ipAddress: json['ipAddress'] ?? json['ip_address'],
      requestParams: json['requestParams'] ?? json['request_params'],
      responseStatus: json['responseStatus'] ?? json['response_status'],
      errorMessage: json['errorMessage'] ?? json['error_message'],
      createTime: json['createTime'] != null || json['create_time'] != null
          ? DateTime.tryParse(json['createTime'] ?? json['create_time'] ?? '')
          : null,
    );
  }

  String get actionText {
    switch (action) {
      case 'login':
        return '登录';
      case 'create':
        return '创建';
      case 'update':
        return '更新';
      case 'delete':
        return '删除';
      case 'export':
        return '导出';
      case 'approve':
        return '审核通过';
      case 'reject':
        return '审核拒绝';
      case 'cancel':
        return '取消';
      default:
        return action ?? '未知';
    }
  }

  String get actionIcon {
    switch (action) {
      case 'login':
        return 'login';
      case 'create':
        return 'add_circle';
      case 'update':
        return 'edit';
      case 'delete':
        return 'delete';
      case 'export':
        return 'download';
      case 'approve':
        return 'check_circle';
      case 'reject':
        return 'cancel';
      case 'cancel':
        return 'close';
      default:
        return 'info';
    }
  }

  bool get isSuccess => responseStatus != null && responseStatus! >= 200 && responseStatus! < 300;

  String get statusText {
    if (responseStatus == null) return '未知';
    if (responseStatus! >= 200 && responseStatus! < 300) return '成功';
    if (responseStatus! >= 400 && responseStatus! < 500) return '客户端错误';
    if (responseStatus! >= 500) return '服务端错误';
    return '未知';
  }
}
