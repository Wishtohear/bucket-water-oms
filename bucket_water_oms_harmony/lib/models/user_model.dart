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
    final user = json['user'] as Map<String, dynamic>?;
    return LoginResponse(
      token: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      userId: user?['id']?.toString() ?? json['userId']?.toString(),
      userName: user?['name'] ?? json['userName'],
      role: user?['role'] ?? json['role'],
      stationId: user?['stationId']?.toString() ?? json['stationId']?.toString(),
      stationName: user?['stationName'] ?? json['stationName'],
      driverId: user?['driverId']?.toString() ?? json['driverId']?.toString(),
      warehouseId: user?['warehouseId']?.toString() ?? json['warehouseId']?.toString(),
      avatar: user?['avatar'] ?? json['avatar'],
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
