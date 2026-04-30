import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

enum DriverStatusType { online, offline, breakTime }

class DriverStatus {
  final DriverStatusType status;
  final DateTime lastHeartbeat;
  final bool isAutomaticOffline;

  DriverStatus({
    required this.status,
    required this.lastHeartbeat,
    this.isAutomaticOffline = false,
  });

  DriverStatus copyWith({
    DriverStatusType? status,
    DateTime? lastHeartbeat,
    bool? isAutomaticOffline,
  }) {
    return DriverStatus(
      status: status ?? this.status,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      isAutomaticOffline: isAutomaticOffline ?? this.isAutomaticOffline,
    );
  }
}

class DriverStatusService extends ChangeNotifier {
  static final DriverStatusService _instance = DriverStatusService._internal();
  factory DriverStatusService() => _instance;
  DriverStatusService._internal();

  final ApiClient _apiClient = ApiClient();

  DriverStatus? _currentStatus;
  Timer? _heartbeatTimer;
  Timer? _failureMonitorTimer;
  int _consecutiveFailures = 0;
  bool _isInitializing = false;

  static const Duration heartbeatInterval = Duration(minutes: 5);
  static const Duration failureCheckInterval = Duration(minutes: 1);
  static const int maxConsecutiveFailures = 10;

  DriverStatus? get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus?.status == DriverStatusType.online;
  bool get isOffline => _currentStatus?.status == DriverStatusType.offline;
  bool get isOnBreak => _currentStatus?.status == DriverStatusType.breakTime;

  Future<void> goOnline() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      await _updateStatus(DriverStatusType.online);
      _startHeartbeat();
      _startFailureMonitor();
      _consecutiveFailures = 0;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> goOffline() async {
    _stopTimers();
    try {
      await _updateStatus(DriverStatusType.offline);
      _currentStatus = DriverStatus(
        status: DriverStatusType.offline,
        lastHeartbeat: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _currentStatus = DriverStatus(
        status: DriverStatusType.offline,
        lastHeartbeat: DateTime.now(),
        isAutomaticOffline: true,
      );
      notifyListeners();
    }
  }

  Future<void> goOnBreak() async {
    _stopTimers();
    try {
      await _updateStatus(DriverStatusType.breakTime);
      _currentStatus = DriverStatus(
        status: DriverStatusType.breakTime,
        lastHeartbeat: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _currentStatus = DriverStatus(
        status: DriverStatusType.breakTime,
        lastHeartbeat: DateTime.now(),
        isAutomaticOffline: true,
      );
      notifyListeners();
    }
  }

  Future<void> _updateStatus(DriverStatusType statusType) async {
    final statusString = _statusTypeToString(statusType);

    try {
      final response = await _apiClient.post(
        '/drivers/status',
        body: {'status': statusString},
      );

      if (response.success) {
        _currentStatus = DriverStatus(
          status: statusType,
          lastHeartbeat: DateTime.now(),
        );
        notifyListeners();
      } else {
        throw ApiException(
          response.message ?? '更新状态失败',
          statusCode: response.code,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) async {
      await _sendHeartbeat();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _startFailureMonitor() {
    _stopFailureMonitor();
    _failureMonitorTimer = Timer.periodic(failureCheckInterval, (timer) {
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
  }

  Future<void> _sendHeartbeat() async {
    if (_currentStatus?.status != DriverStatusType.online) {
      return;
    }

    try {
      final response = await _apiClient.post(
        '/drivers/status',
        body: {'status': 'online'},
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

    _currentStatus = DriverStatus(
      status: DriverStatusType.offline,
      lastHeartbeat: DateTime.now(),
      isAutomaticOffline: true,
    );

    notifyListeners();
  }

  String _statusTypeToString(DriverStatusType type) {
    switch (type) {
      case DriverStatusType.online:
        return 'online';
      case DriverStatusType.offline:
        return 'offline';
      case DriverStatusType.breakTime:
        return 'break';
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}
