import '../core/network/api_client.dart';

class AdminSystemService {
  static final AdminSystemService _instance = AdminSystemService._internal();
  factory AdminSystemService() => _instance;
  AdminSystemService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<AdminListResponse> getAdmins({
    String? role,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (role != null && role.isNotEmpty) {
      queryParams['role'] = role;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/admin/system/admins',
      queryParams: queryParams,
    );

    if (response.success) {
      final data = response.data;
      List<AdminModel> admins = [];
      int total = 0;

      if (data != null) {
        if (data is List) {
          admins = data.map((e) => AdminModel.fromJson(e as Map<String, dynamic>)).toList();
          total = admins.length;
        } else if (data is Map<String, dynamic>) {
          if (data['list'] != null) {
            admins = (data['list'] as List)
                .map((e) => AdminModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          total = data['total'] ?? admins.length;
        }
      }

      return AdminListResponse(
        admins: admins,
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

  Future<AdminModel> getAdminDetail(String adminId) async {
    final response = await _apiClient.get('/admin/system/admins/$adminId');

    if (response.success && response.data != null) {
      return AdminModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<AdminModel> createAdmin(AdminModel admin, {String? password}) async {
    final body = admin.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await _apiClient.post(
      '/admin/system/admins',
      body: body,
    );

    if (response.success && response.data != null) {
      return AdminModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<AdminModel> updateAdmin(String adminId, AdminModel admin, {String? password}) async {
    final body = admin.toJson();
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await _apiClient.put(
      '/admin/system/admins/$adminId',
      body: body,
    );

    if (response.success && response.data != null) {
      return AdminModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    final response = await _apiClient.delete('/admin/system/admins/$adminId');

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<bool> enableAdmin(String adminId) async {
    final response = await _apiClient.patch('/admin/system/admins/$adminId/enable');

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<bool> disableAdmin(String adminId) async {
    final response = await _apiClient.patch('/admin/system/admins/$adminId/disable');

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<String> resetAdminPassword(String adminId) async {
    final response = await _apiClient.post('/admin/system/admins/$adminId/reset-password');

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['newPassword'] ?? data['password'] ?? '123456';
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    final response = await _apiClient.get('/admin/system/settings/all');

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<BasicSettings> getBasicSettings() async {
    final response = await _apiClient.get('/admin/system/configs/basic');

    if (response.success && response.data != null) {
      return BasicSettings.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateBasicSettings(BasicSettings settings) async {
    final response = await _apiClient.patch(
      '/admin/system/configs/basic',
      body: settings.toJson(),
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<StatementSettings> getStatementSettings() async {
    final response = await _apiClient.get('/admin/system/configs/statement');

    if (response.success && response.data != null) {
      return StatementSettings.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateStatementSettings(StatementSettings settings) async {
    final response = await _apiClient.patch(
      '/admin/system/configs/statement',
      body: settings.toJson(),
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<NotificationSettings> getNotificationSettings() async {
    final response = await _apiClient.get('/admin/system/configs/notifications');

    if (response.success && response.data != null) {
      return NotificationSettings.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    final response = await _apiClient.patch(
      '/admin/system/configs/notifications',
      body: settings.toJson(),
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }

  Future<InventorySettings> getInventorySettings() async {
    final response = await _apiClient.get('/admin/system/configs/inventory');

    if (response.success && response.data != null) {
      return InventorySettings.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
  }

  Future<bool> updateInventorySettings(InventorySettings settings) async {
    final response = await _apiClient.patch(
      '/admin/system/configs/inventory',
      body: settings.toJson(),
    );

    if (!response.success) {
      throw ApiException(
        response.message ?? '服务器错误',
        statusCode: response.code,
      );
    }
    return true;
  }
}

class AdminListResponse {
  final List<AdminModel> admins;
  final int total;
  final int page;
  final int pageSize;

  AdminListResponse({
    required this.admins,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;
}

class AdminModel {
  final String? id;
  final String? name;
  final String? username;
  final String? phone;
  final String? role;
  final String? roleName;
  final String? permissions;
  final String? avatar;
  final String? status;
  final DateTime? lastLogin;
  final DateTime? createTime;
  final String? remark;

  AdminModel({
    this.id,
    this.name,
    this.username,
    this.phone,
    this.role,
    this.roleName,
    this.permissions,
    this.avatar,
    this.status,
    this.lastLogin,
    this.createTime,
    this.remark,
  });

  factory AdminModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AdminModel();
    return AdminModel(
      id: json['id']?.toString(),
      name: json['name'],
      username: json['username'],
      phone: json['phone'],
      role: json['role'],
      roleName: json['roleName'] ?? json['role_name'],
      permissions: json['permissions'],
      avatar: json['avatar'],
      status: json['status'],
      lastLogin: json['lastLogin'] != null || json['last_login'] != null
          ? DateTime.tryParse(json['lastLogin'] ?? json['last_login'] ?? '')
          : null,
      createTime: json['createTime'] != null || json['create_time'] != null
          ? DateTime.tryParse(json['createTime'] ?? json['create_time'] ?? '')
          : null,
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'phone': phone,
      'role': role,
      'permissions': permissions,
      'status': status,
      'remark': remark,
    };
  }

  String get roleText {
    switch (role) {
      case 'super_admin':
        return '超级管理员';
      case 'finance_admin':
        return '财务管理员';
      case 'warehouse_admin':
        return '仓库管理员';
      case 'operations_admin':
        return '运营管理员';
      default:
        return roleName ?? role ?? '未知';
    }
  }

  String get statusText {
    switch (status) {
      case 'active':
        return '正常';
      case 'inactive':
        return '禁用';
      default:
        return status ?? '未知';
    }
  }

  bool get isActive => status == 'active';
}

class BasicSettings {
  final String? systemName;
  final String? contactPhone;
  final String? contactEmail;
  final String? logo;

  BasicSettings({
    this.systemName,
    this.contactPhone,
    this.contactEmail,
    this.logo,
  });

  factory BasicSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BasicSettings();
    return BasicSettings(
      systemName: json['systemName'] ?? json['system_name'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      contactEmail: json['contactEmail'] ?? json['contact_email'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemName': systemName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'logo': logo,
    };
  }
}

class StatementSettings {
  final int? statementDay;
  final List<String>? notifyMethods;
  final int? notifyBeforeDays;

  StatementSettings({
    this.statementDay,
    this.notifyMethods,
    this.notifyBeforeDays,
  });

  factory StatementSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StatementSettings();
    return StatementSettings(
      statementDay: json['statementDay'] ?? json['statement_day'],
      notifyMethods: json['notifyMethods'] != null
          ? List<String>.from(json['notifyMethods'])
          : null,
      notifyBeforeDays: json['notifyBeforeDays'] ?? json['notify_before_days'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statementDay': statementDay,
      'notifyMethods': notifyMethods,
      'notifyBeforeDays': notifyBeforeDays,
    };
  }
}

class NotificationSettings {
  final bool? orderStatusNotify;
  final bool? stockWarningNotify;
  final bool? bucketOwedNotify;
  final bool? statementGeneratedNotify;

  NotificationSettings({
    this.orderStatusNotify,
    this.stockWarningNotify,
    this.bucketOwedNotify,
    this.statementGeneratedNotify,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationSettings();
    return NotificationSettings(
      orderStatusNotify: json['orderStatusNotify'] ?? json['order_status_notify'],
      stockWarningNotify: json['stockWarningNotify'] ?? json['stock_warning_notify'],
      bucketOwedNotify: json['bucketOwedNotify'] ?? json['bucket_owed_notify'],
      statementGeneratedNotify: json['statementGeneratedNotify'] ?? json['statement_generated_notify'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderStatusNotify': orderStatusNotify,
      'stockWarningNotify': stockWarningNotify,
      'bucketOwedNotify': bucketOwedNotify,
      'statementGeneratedNotify': statementGeneratedNotify,
    };
  }
}

class InventorySettings {
  final int? stockWarningThreshold;
  final bool? autoReorder;

  InventorySettings({
    this.stockWarningThreshold,
    this.autoReorder,
  });

  factory InventorySettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventorySettings();
    return InventorySettings(
      stockWarningThreshold: json['stockWarningThreshold'] ?? json['stock_warning_threshold'],
      autoReorder: json['autoReorder'] ?? json['auto_reorder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockWarningThreshold': stockWarningThreshold,
      'autoReorder': autoReorder,
    };
  }
}
