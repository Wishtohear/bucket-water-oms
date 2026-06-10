import '../core/config/api_config.dart';
import '../core/network/api_client.dart';

class WarehouseAuditLogsService {
  static final WarehouseAuditLogsService _instance =
      WarehouseAuditLogsService._internal();
  factory WarehouseAuditLogsService() => _instance;
  WarehouseAuditLogsService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<OperationLogListResponse> getOperationLogs({
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
    if (username != null && username.isNotEmpty) {
      queryParams['username'] = username;
    }
    if (action != null && action.isNotEmpty) queryParams['action'] = action;
    if (module != null && module.isNotEmpty) queryParams['module'] = module;
    if (entityType != null && entityType.isNotEmpty) {
      queryParams['entityType'] = entityType;
    }
    if (entityId != null && entityId.isNotEmpty) {
      queryParams['entityId'] = entityId;
    }
    if (startTime != null && startTime.isNotEmpty) {
      queryParams['startTime'] = startTime;
    }
    if (endTime != null && endTime.isNotEmpty) {
      queryParams['endTime'] = endTime;
    }

    final warehouseId = ApiConfig.getWarehouseId();

    final response = await _apiClient.get(
      '/warehouses/operation-logs',
      queryParams: queryParams,
      headers: {
        if (warehouseId.isNotEmpty) 'X-Warehouse-Id': warehouseId,
      },
    );

    if (response.success) {
      final data = response.data;
      List<OperationLogModel> logs = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          logs = data
              .map((e) =>
                  OperationLogModel.fromJson(e as Map<String, dynamic>))
              .toList();
          total = logs.length;
        } else if (data is Map<String, dynamic>) {
          if (data['records'] != null) {
            logs = (data['records'] as List)
                .map((e) =>
                    OperationLogModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (data['list'] != null) {
            logs = (data['list'] as List)
                .map((e) =>
                    OperationLogModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? logs.length;
        }
      }

      return OperationLogListResponse(
        logs: logs,
        total: total,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw ApiException(
        response.message ?? '获取操作日志失败',
        statusCode: response.code,
      );
    }
  }

  Future<List<OperationLogModel>> getRecentLogs({int limit = 10}) async {
    final warehouseId = ApiConfig.getWarehouseId();

    final response = await _apiClient.get(
      '/warehouses/operation-logs/recent',
      queryParams: {'limit': limit.toString()},
      headers: {
        if (warehouseId.isNotEmpty) 'X-Warehouse-Id': warehouseId,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) =>
                OperationLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException(
        response.message ?? '获取最近日志失败',
        statusCode: response.code,
      );
    } else {
      throw ApiException(
        response.message ?? '获取最近日志失败',
        statusCode: response.code,
      );
    }
  }

  Future<OperationLogModel?> getLogById(int logId) async {
    final warehouseId = ApiConfig.getWarehouseId();

    final response = await _apiClient.get(
      '/warehouses/operation-logs/$logId',
      headers: {
        if (warehouseId.isNotEmpty) 'X-Warehouse-Id': warehouseId,
      },
    );

    if (response.success && response.data != null) {
      return OperationLogModel.fromJson(
          response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '获取日志详情失败',
        statusCode: response.code,
      );
    }
  }
}

class OperationLogListResponse {
  final List<OperationLogModel> logs;
  final int total;
  final int page;
  final int pageSize;

  OperationLogListResponse({
    required this.logs,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

class OperationLogModel {
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

  OperationLogModel({
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

  factory OperationLogModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OperationLogModel();
    return OperationLogModel(
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
          ? DateTime.tryParse(
              json['createTime'] ?? json['create_time'] ?? '')
          : null,
    );
  }

  String get actionText {
    switch (action) {
      case 'login':
        return '登录';
      case 'logout':
        return '登出';
      case 'create':
        return '创建';
      case 'update':
        return '更新';
      case 'delete':
        return '删除';
      case 'confirm':
        return '确认';
      case 'reject':
        return '拒绝';
      case 'receive_order':
        return '接单';
      case 'dispatch_order':
        return '派单';
      case 'inbound':
        return '入库';
      case 'outbound':
        return '出库';
      case 'check':
        return '核对';
      case 'export':
        return '导出';
      default:
        return action ?? '未知';
    }
  }

  String get moduleText {
    switch (module) {
      case 'order':
        return '订单';
      case 'inbound':
        return '入库';
      case 'outbound':
        return '出库';
      case 'inventory':
        return '库存';
      case 'return':
        return '回仓';
      case 'after_sales':
        return '售后';
      case 'dispatch':
        return '调度';
      case 'auth':
        return '认证';
      case 'settings':
        return '设置';
      default:
        return module ?? '系统';
    }
  }

  IconDataData get actionIcon {
    switch (action) {
      case 'login':
        return IconDataData(icon: 'login', color: 0xFF1890FF);
      case 'logout':
        return IconDataData(icon: 'logout', color: 0xFF8C8C8C);
      case 'create':
        return IconDataData(icon: 'add_circle', color: 0xFF52C41A);
      case 'update':
        return IconDataData(icon: 'edit', color: 0xFFFAAD14);
      case 'delete':
        return IconDataData(icon: 'delete', color: 0xFFFF4D4F);
      case 'confirm':
        return IconDataData(icon: 'check_circle', color: 0xFF52C41A);
      case 'reject':
        return IconDataData(icon: 'cancel', color: 0xFFFF4D4F);
      case 'receive_order':
        return IconDataData(icon: 'assignment', color: 0xFF1890FF);
      case 'dispatch_order':
        return IconDataData(icon: 'local_shipping', color: 0xFF722ED1);
      case 'inbound':
        return IconDataData(icon: 'move_to_inbox', color: 0xFF52C41A);
      case 'outbound':
        return IconDataData(icon: 'outbox', color: 0xFF1890FF);
      case 'check':
        return IconDataData(icon: 'checklist', color: 0xFFFAAD14);
      case 'export':
        return IconDataData(icon: 'download', color: 0xFF722ED1);
      default:
        return IconDataData(icon: 'info', color: 0xFF8C8C8C);
    }
  }

  bool get isSuccess =>
      responseStatus != null && responseStatus! >= 200 && responseStatus! < 300;

  String get statusText {
    if (responseStatus == null) return '未知';
    if (responseStatus! >= 200 && responseStatus! < 300) return '成功';
    if (responseStatus! >= 400 && responseStatus! < 500) return '客户端错误';
    if (responseStatus! >= 500) return '服务端错误';
    return '未知';
  }
}

class IconDataData {
  final String icon;
  final int color;

  IconDataData({required this.icon, required this.color});
}
