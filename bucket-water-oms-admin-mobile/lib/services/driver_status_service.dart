import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

enum DriverStatusType { online, offline, breakTime }

class DriverStatusData {
  final DriverStatusType status;
  final DateTime? lastHeartbeat;
  final bool isAutomaticOffline;
  final double? longitude;
  final double? latitude;
  final String? address;
  final int activeTaskCount;

  DriverStatusData({
    required this.status,
    this.lastHeartbeat,
    this.isAutomaticOffline = false,
    this.longitude,
    this.latitude,
    this.address,
    this.activeTaskCount = 0,
  });

  factory DriverStatusData.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? json['onlineStatus'] as String?;
    final status = _stringToStatusType(statusStr);

    return DriverStatusData(
      status: status,
      lastHeartbeat: json['lastOnlineTime'] != null
          ? DateTime.tryParse(json['lastOnlineTime'] as String)
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'] as String)
              : DateTime.now()),
      isAutomaticOffline: json['isAutomaticOffline'] as bool? ?? false,
      longitude: (json['longitude'] ?? json['lng'] ?? json['currentLng']) as double?,
      latitude: (json['latitude'] ?? json['lat'] ?? json['currentLat']) as double?,
      address: json['address'] as String?,
      activeTaskCount: json['activeTaskCount'] as int? ?? 0,
    );
  }

  static DriverStatusType _stringToStatusType(String? status) {
    switch (status) {
      case 'online':
        return DriverStatusType.online;
      case 'offline':
        return DriverStatusType.offline;
      case 'break':
        return DriverStatusType.breakTime;
      default:
        return DriverStatusType.offline;
    }
  }
}

class DriverStatusService extends ChangeNotifier {
  static final DriverStatusService _instance = DriverStatusService._internal();
  factory DriverStatusService() => _instance;
  DriverStatusService._internal();

  final ApiClient _apiClient = ApiClient();

  DriverStatusData? _currentStatus;
  Timer? _heartbeatTimer;
  Timer? _failureMonitorTimer;
  Timer? _locationUpdateTimer;
  int _consecutiveFailures = 0;
  bool _isProcessing = false;
  String? _driverId;

  static const Duration heartbeatInterval = Duration(minutes: 5);
  static const Duration failureCheckInterval = Duration(minutes: 1);
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  static const int maxConsecutiveFailures = 10;

  DriverStatusData? get currentStatus => _currentStatus;
  DriverStatusType get currentStatusType => _currentStatus?.status ?? DriverStatusType.offline;
  bool get isOnline => _currentStatus?.status == DriverStatusType.online;
  bool get isOffline => _currentStatus?.status == DriverStatusType.offline;
  bool get isOnBreak => _currentStatus?.status == DriverStatusType.breakTime;
  bool get isProcessing => _isProcessing;

  String get statusText {
    switch (currentStatusType) {
      case DriverStatusType.online:
        return '在线';
      case DriverStatusType.offline:
        return '离线';
      case DriverStatusType.breakTime:
        return '休息中';
    }
  }

  void initDriver(String driverId) {
    _driverId = driverId;
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (_driverId == null) return;

    try {
      final response = await _apiClient.get(
        '/drivers/status',
        headers: {'X-Driver-Id': _driverId!},
      );

      if (response.success && response.data != null) {
        _currentStatus = DriverStatusData.fromJson(response.data as Map<String, dynamic>);
        notifyListeners();

        if (_currentStatus!.status == DriverStatusType.online) {
          _startHeartbeat();
        }
      }
    } catch (e) {
      debugPrint('加载司机状态失败: $e');
      _currentStatus = DriverStatusData(
        status: DriverStatusType.offline,
        lastHeartbeat: DateTime.now(),
        isAutomaticOffline: true,
      );
      notifyListeners();
    }
  }

  Future<bool> goOnline() async {
    if (_driverId == null) return false;
    if (_isProcessing) return false;
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/drivers/online',
        headers: {'X-Driver-Id': _driverId!},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _currentStatus = DriverStatusData.fromJson(data);
        _consecutiveFailures = 0;
        _startHeartbeat();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('上线失败: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> goOffline() async {
    if (_driverId == null) return false;
    if (_isProcessing) return false;
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/drivers/offline',
        headers: {'X-Driver-Id': _driverId!},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _currentStatus = DriverStatusData.fromJson(data);
        _stopTimers();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('下线失败: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> goOnBreak() async {
    if (_driverId == null) return false;
    if (_isProcessing) return false;
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/drivers/break',
        headers: {'X-Driver-Id': _driverId!},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _currentStatus = DriverStatusData.fromJson(data);
        _stopHeartbeat();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('休息模式失败: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> updateLocation({
    required double longitude,
    required double latitude,
    String? address,
  }) async {
    if (_driverId == null) return false;

    try {
      final response = await _apiClient.post(
        '/drivers/location',
        body: {
          'longitude': longitude,
          'latitude': latitude,
          if (address != null) 'address': address,
        },
        headers: {'X-Driver-Id': _driverId!},
      );

      if (response.success) {
        _currentStatus = _currentStatus?.copyWith(
          longitude: longitude,
          latitude: latitude,
          address: address,
          lastHeartbeat: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('位置更新失败: $e');
      return false;
    }
  }

  Future<bool> checkIn({
    required String orderId,
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
  }) async {
    if (_driverId == null) return false;

    try {
      final response = await _apiClient.post(
        '/drivers/check-in',
        body: {
          'orderId': orderId,
          'lat': latitude,
          'lng': longitude,
          if (address != null) 'address': address,
          if (accuracy != null) 'accuracy': accuracy,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        headers: {'X-Driver-Id': _driverId!},
      );

      return response.success;
    } catch (e) {
      debugPrint('打卡失败: $e');
      return false;
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) async {
      await _sendHeartbeat();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _startFailureMonitor() {
    _stopFailureMonitor();
    _failureMonitorTimer = Timer.periodic(failureCheckInterval, (_) {
      _checkFailureStatus();
    });
  }

  void _stopFailureMonitor() {
    _failureMonitorTimer?.cancel();
    _failureMonitorTimer = null;
  }

  void _stopTimers() {
    _stopHeartbeat();
    _stopFailureMonitor();
    _stopLocationUpdate();
  }

  void _stopLocationUpdate() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    if (_currentStatus?.status != DriverStatusType.online) {
      _stopHeartbeat();
      return;
    }

    try {
      final response = await _apiClient.post(
        '/drivers/status',
        body: {'onlineStatus': 'online'},
        headers: {'X-Driver-Id': _driverId!},
      );

      if (response.success) {
        _consecutiveFailures = 0;
        _currentStatus = _currentStatus?.copyWith(
          lastHeartbeat: DateTime.now(),
        );
        notifyListeners();
      } else {
        _handleHeartbeatFailure();
      }
    } catch (e) {
      _handleHeartbeatFailure();
    }
  }

  void _handleHeartbeatFailure() {
    _consecutiveFailures++;

    if (_consecutiveFailures >= maxConsecutiveFailures) {
      _triggerAutomaticOffline();
    }
  }

  void _checkFailureStatus() {
    if (_currentStatus?.status == DriverStatusType.online &&
        _consecutiveFailures >= maxConsecutiveFailures) {
      _triggerAutomaticOffline();
    }
  }

  Future<void> _triggerAutomaticOffline() async {
    _stopTimers();

    _currentStatus = DriverStatusData(
      status: DriverStatusType.offline,
      lastHeartbeat: DateTime.now(),
      isAutomaticOffline: true,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}

extension DriverStatusDataCopyWith on DriverStatusData {
  DriverStatusData copyWith({
    DriverStatusType? status,
    DateTime? lastHeartbeat,
    bool? isAutomaticOffline,
    double? longitude,
    double? latitude,
    String? address,
    int? activeTaskCount,
  }) {
    return DriverStatusData(
      status: status ?? this.status,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      isAutomaticOffline: isAutomaticOffline ?? this.isAutomaticOffline,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      address: address ?? this.address,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
    );
  }
}
