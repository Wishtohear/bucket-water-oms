import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/sse_store.dart';
import '../core/config/api_config.dart';

mixin SseConnectMixin<T extends StatefulWidget> on State<T> {
  SseStore? _sseStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sseStore = context.read<SseStore>();
    _connectSseIfNeeded();
  }

  void _connectSseIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sseStore != null && !_sseStore!.isConnected) {
        final userId = ApiConfig.getUserId();
        final role = ApiConfig.getUserRole();
        if (userId.isNotEmpty) {
          _sseStore!.connect(userId, role);
        }
      }
    });
  }

  void reconnectSse() {
    if (_sseStore != null) {
      final userId = ApiConfig.getUserId();
      final role = ApiConfig.getUserRole();
      if (userId.isNotEmpty) {
        _sseStore!.connect(userId, role);
      }
    }
  }

  void disconnectSse() {
    _sseStore?.disconnect();
  }
}

mixin SseListenerMixin<T extends StatefulWidget> on State<T> {
  SseStore? _sseStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sseStore = context.read<SseStore>();
    _sseStore?.addListener(_onSseStoreChanged);
  }

  @override
  void dispose() {
    _sseStore?.removeListener(_onSseStoreChanged);
    super.dispose();
  }

  void _onSseStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  SseStore? get sseStore => _sseStore;
}
