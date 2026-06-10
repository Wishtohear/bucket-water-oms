import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/push_notification_model.dart';
import '../services/sse_service.dart';
import '../services/local_notification_service.dart';

class SseStore extends ChangeNotifier {
  final SseService _sseService = SseService();
  final LocalNotificationService _notificationService =
      LocalNotificationService();

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _lastError;
  List<PushNotification> _notifications = [];
  List<PushNotification> _unreadNotifications = [];
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  StreamSubscription<PushNotification>? _notificationSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _errorSubscription;

  SseStore() {
    _initListeners();
    _initNotificationService();
  }

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  List<PushNotification> get notifications => List.unmodifiable(_notifications);
  List<PushNotification> get unreadNotifications =>
      List.unmodifiable(_unreadNotifications);
  int get unreadCount => _unreadNotifications.length;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> _initNotificationService() async {
    await _notificationService.initialize();
  }

  void _initListeners() {
    _notificationSubscription = _sseService.notificationStream.listen(
      _onNotification,
      onError: (error) {
        _lastError = error.toString();
        notifyListeners();
      },
    );

    _connectionSubscription = _sseService.connectionStatusStream.listen(
      (connected) {
        print('[SseStore] 收到连接状态更新: connected=$connected');
        _isConnected = connected;
        _isConnecting = false;
        if (connected) {
          _lastError = null;
        }
        print('[SseStore] 更新状态: _isConnected=$_isConnected, _isConnecting=$_isConnecting');
        notifyListeners();
        print('[SseStore] notifyListeners() 已调用');
      },
      onError: (error) {
        print('[SseStore] 连接状态错误: $error');
        _lastError = error.toString();
        notifyListeners();
      },
    );

    _errorSubscription = _sseService.errorStream.listen(
      (error) {
        print('[SseStore] 收到错误: $error');
        _lastError = error;
        notifyListeners();
      },
    );
  }

  Future<void> _onNotification(PushNotification notification) async {
    _notifications.insert(0, notification);
    _unreadNotifications.insert(0, notification);
    notifyListeners();

    await _notificationService.showPushNotification(notification);
  }

  Future<bool> requestNotificationPermissions() async {
    return await _notificationService.requestPermissions();
  }

  Future<void> connect(String userId, String role) async {
    if (_isConnected || _isConnecting) {
      print('[SseStore] 连接跳过: _isConnected=$_isConnected, _isConnecting=$_isConnecting');
      return;
    }

    print('[SseStore] 开始连接: userId=$userId, role=$role');
    _isConnecting = true;
    _lastError = null;
    notifyListeners();

    print('[SseStore] 调用 _sseService.connect()');
    await _sseService.connect(userId, role);
    print('[SseStore] _sseService.connect() 完成');
  }

  Future<void> disconnect() async {
    await _sseService.disconnect();
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }

  void markAsRead(PushNotification notification) {
    _unreadNotifications.remove(notification);
    notifyListeners();
  }

  void markAllAsRead() {
    _unreadNotifications.clear();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadNotifications.clear();
    _notificationService.cancelAllNotifications();
    notifyListeners();
  }

  List<PushNotification> getNotificationsByEvent(String event) {
    return _notifications.where((n) => n.event == event).toList();
  }

  List<PushNotification> getOrderNotifications() {
    return _notifications.where((n) => n.isOrderRelated).toList();
  }

  List<PushNotification> getDeliveryTaskNotifications() {
    return _notifications.where((n) => n.isDeliveryTask).toList();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _notificationService.setSoundEnabled(enabled);
    notifyListeners();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    _notificationService.setVibrationEnabled(enabled);
    notifyListeners();
  }

  Future<bool> testNotification() async {
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '测试通知',
      body: '消息推送功能测试成功！',
    );
    return true;
  }

  Future<bool> isNotificationPermissionGranted() async {
    return await _notificationService.isNotificationPermissionGranted();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _sseService.dispose();
    _notificationService.dispose();
    super.dispose();
  }
}
