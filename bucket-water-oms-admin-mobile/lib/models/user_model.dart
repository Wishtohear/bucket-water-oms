class LoginRequest {
  final String phone;
  final String password;
  final String role;

  LoginRequest({
    required this.phone,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
        'role': role,
      };
}

class LoginResponse {
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? userName;
  final String? role;
  final String? stationId;
  final String? stationName;
  final String? driverId;
  final String? warehouseId;
  final String? avatar;

  LoginResponse({
    this.token,
    this.refreshToken,
    this.userId,
    this.userName,
    this.role,
    this.stationId,
    this.stationName,
    this.driverId,
    this.warehouseId,
    this.avatar,
  });

  factory LoginResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LoginResponse();
    }
    
    // 支持多种响应格式，与PC端analyzeResponse函数保持一致
    // 尝试从多个可能的位置获取token
    String? tokenValue;
    
    // 按优先级尝试获取token
    if (json['accessToken'] != null && json['accessToken'].toString().length > 10) {
      tokenValue = json['accessToken']?.toString();
    } else if (json['token'] != null && json['token'].toString().length > 10) {
      tokenValue = json['token']?.toString();
    } else if (json['idToken'] != null && json['idToken'].toString().length > 10) {
      tokenValue = json['idToken']?.toString();
    } else if (json['data'] != null && json['data'] is Map) {
      // 检查嵌套的data对象
      final data = json['data'] as Map<String, dynamic>;
      tokenValue = data['accessToken']?.toString() ?? 
                   data['token']?.toString() ??
                   ((data['idToken']?.toString().length ?? 0) > 10 ? data['idToken']?.toString() : null);
    }
    
    // 尝试获取用户信息（支持嵌套的user对象）
    Map<String, dynamic>? user;
    if (json['user'] != null && json['user'] is Map) {
      user = json['user'] as Map<String, dynamic>;
    } else if (json['data'] != null && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      if (data['user'] != null && data['user'] is Map) {
        user = data['user'] as Map<String, dynamic>;
      } else {
        // data本身就是用户信息
        user = data;
      }
    }
    
    return LoginResponse(
      token: tokenValue,
      refreshToken: json['refreshToken']?.toString() ?? 
                    json['data']?['refreshToken']?.toString(),
      userId: user?['id']?.toString() ?? 
              user?['userId']?.toString() ?? 
              json['userId']?.toString() ??
              json['id']?.toString(),
      userName: user?['name']?.toString() ?? 
                user?['userName']?.toString() ??
                json['userName']?.toString() ??
                json['username']?.toString(),
      role: user?['role']?.toString() ?? 
            json['role']?.toString() ??
            json['userType']?.toString(),
      stationId: user?['stationId']?.toString() ?? 
                 json['stationId']?.toString(),
      stationName: user?['stationName']?.toString() ?? 
                   json['stationName']?.toString(),
      driverId: user?['driverId']?.toString() ?? 
                json['driverId']?.toString(),
      warehouseId: user?['warehouseId']?.toString() ?? 
                   json['warehouseId']?.toString(),
      avatar: user?['avatar']?.toString() ?? 
              json['avatar']?.toString(),
    );
  }

  String? get id {
    switch (role) {
      case 'station':
        return stationId;
      case 'driver':
        return driverId;
      case 'warehouse':
        return warehouseId;
      default:
        return userId;
    }
  }
}
