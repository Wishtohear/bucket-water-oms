import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../core/config/api_config.dart';
import '../models/push_notification_model.dart';

class SseService {
  static final SseService _instance = SseService._internal();
  factory SseService() => _instance;
  SseService._internal();

  HttpClient? _client;
  HttpClientResponse? _response;
  StreamSubscription? _subscription;
  bool _isConnecting = false;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  final _notificationController = StreamController<PushNotification>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<PushNotification> get notificationStream => _notificationController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _isConnected;

  String? _currentUserId;
  String? _currentRole;

  Future<void> connect(String userId, String role) async {
    if (_isConnecting || _isConnected) {
      return;
    }

    _currentUserId = userId;
    _currentRole = role;
    _isConnecting = true;
    _connectionStatusController.add(false);

    try {
      await _establishConnection();
    } catch (e) {
      print('[SSE] 连接失败: $e');
      _isConnecting = false;
      _isConnected = false;
      _connectionStatusController.add(false);
      _errorController.add('SSE连接失败: $e');
    }
  }

  Future<void> _establishConnection() async {
    await _closeConnection();
    
    final baseUrl = ApiConfig.baseUrl;
    final uri = Uri.parse('$baseUrl/notifications/subscribe').replace(
      queryParameters: {
        'userId': _currentUserId ?? '',
        'role': _currentRole ?? '',
      },
    );
    
    print('[SSE] 开始连接 SSE...');
    print('[SSE] URL: $uri');
    print('[SSE] Host: ${uri.host}:${uri.port}');
    
    _client = HttpClient();
    _client!.connectionTimeout = const Duration(seconds: 10);
    
    try {
      final request = await _client!.openUrl('GET', uri);
      
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');
      request.headers.set('Connection', 'keep-alive');
      
      if (ApiConfig.getToken().isNotEmpty) {
        request.headers.set('Authorization', 'Bearer ${ApiConfig.getToken()}');
      }
      
      print('[SSE] HTTP 请求已发送，等待响应...');
      
      _response = await request.close();
      
      print('[SSE] 收到响应，状态码: ${_response!.statusCode}');
      print('[SSE] 响应头: ${_response!.headers}');
      
      if (_response!.statusCode != 200) {
        final body = await _readResponseBody();
        print('[SSE] 响应体: $body');
        print('[SSE] 状态码不是200，连接失败');
        _isConnecting = false;
        _isConnected = false;
        _connectionStatusController.add(false);
        throw Exception('SSE连接失败: HTTP ${_response!.statusCode}');
      }
      
      print('[SSE] 状态码200，连接成功！');
      _isConnecting = false;
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStatusController.add(true);
      
      _startHeartbeat();
      _listenToStream();
    } catch (e) {
      print('[SSE] 连接异常: $e');
      rethrow;
    }
  }
  
  Future<String> _readResponseBody() async {
    final completer = Completer<String>();
    final buffer = StringBuffer();
    
    _response!.listen(
      (data) {
        buffer.write(utf8.decode(data));
      },
      onDone: () {
        completer.complete(buffer.toString());
      },
      onError: (e) {
        completer.complete('');
      },
    );
    
    return completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => buffer.toString(),
    );
  }

  void _listenToStream() {
    String buffer = '';

    _subscription = _response!.listen(
      (data) {
        final text = utf8.decode(data);
        print('[SSE] 收到原始数据: "$text"');
        buffer += text;
        print('[SSE] Buffer累计长度: ${buffer.length}');

        while (buffer.contains('\n\n')) {
          final eventEnd = buffer.indexOf('\n\n');
          final eventBlock = buffer.substring(0, eventEnd);
          buffer = buffer.substring(eventEnd + 2);
          print('[SSE] 解析事件块: "$eventBlock"');

          _processEventBlock(eventBlock);
        }
        
        if (buffer.contains('\n') && !buffer.contains('\n\n')) {
          print('[SSE] 收到不完整数据，等待更多数据...');
        }
      },
      onError: (error) {
        print('[SSE] Stream错误: $error');
        _handleConnectionError(error.toString());
      },
      onDone: () {
        print('[SSE] Stream结束');
        _handleConnectionClosed();
      },
    );
  }
  
  Future<void> _closeConnection() async {
    await _subscription?.cancel();
    _subscription = null;
    _response = null;
    _client?.close();
    _client = null;
  }

  void _processEventBlock(String block) {
    String? eventName;
    String? eventData;

    for (final line in block.split('\n')) {
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        eventData = line.substring(5).trim();
      }
    }

    print('[SSE] 解析事件: eventName=$eventName, eventData=$eventData');

    if (eventName != null && eventName == 'connected') {
      print('[SSE] 收到连接确认事件!');
      _isConnecting = false;
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStatusController.add(true);
      return;
    }

    if (eventName != null && eventData != null && eventName != 'heartbeat' && eventName != 'ping') {
      try {
        final jsonData = jsonDecode(eventData) as Map<String, dynamic>;
        final notification = PushNotification.fromJson(jsonData, eventName);
        _notificationController.add(notification);
      } catch (e) {
        print('SSE数据解析失败: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      if (_isConnected && _currentUserId != null) {
        try {
          await _sendHeartbeat();
        } catch (e) {
          print('心跳发送失败: $e');
        }
      }
    });
  }

  Future<void> _sendHeartbeat() async {
    if (_client == null) {
      print('[SSE] _client 为 null，无法发送心跳');
      return;
    }
    
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/heartbeat')
          .replace(queryParameters: {'userId': _currentUserId ?? ''});
      
      final request = await _client!.openUrl('POST', uri);
      request.headers.set('Authorization', 'Bearer ${ApiConfig.getToken()}');
      request.write('');
      
      final response = await request.close().timeout(const Duration(seconds: 5));
      print('[SSE] 心跳响应: ${response.statusCode}');
    } catch (e) {
      print('[SSE] 心跳发送异常: $e');
    }
  }

  void _handleConnectionError(String error) {
    _isConnected = false;
    _isConnecting = false;
    _connectionStatusController.add(false);
    _errorController.add('SSE连接错误: $error');
    _scheduleReconnect();
  }

  void _handleConnectionClosed() {
    _isConnected = false;
    _isConnecting = false;
    _connectionStatusController.add(false);

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _errorController.add('SSE重连次数已达上限，请检查网络连接');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectDelay.inSeconds * _reconnectAttempts);

    Future.delayed(delay, () {
      if (!_isConnected && !_isConnecting && _currentUserId != null) {
        connect(_currentUserId!, _currentRole ?? '');
      }
    });
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    await _closeConnection();
    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = _maxReconnectAttempts;
    _connectionStatusController.add(false);
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionStatusController.close();
    _errorController.close();
  }

  Future<Map<String, dynamic>?> getConnectionStatus() async {
    if (_currentUserId == null) return null;

    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/status')
          .replace(queryParameters: {'userId': _currentUserId ?? ''});

      final request = await httpClient.openUrl('GET', uri);
      request.headers.set('Authorization', 'Bearer ${ApiConfig.getToken()}');
      
      final response = await request.close().timeout(const Duration(seconds: 5));
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('获取连接状态失败: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getOnlineStats() async {
    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/online-stats');

      final request = await httpClient.openUrl('GET', uri);
      request.headers.set('Authorization', 'Bearer ${ApiConfig.getToken()}');
      
      final response = await request.close().timeout(const Duration(seconds: 5));
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('获取在线统计失败: $e');
    }
    return null;
  }
}
