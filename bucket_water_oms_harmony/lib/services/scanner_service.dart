import '../core/network/api_client.dart';

class ScanResult {
  final String code;
  final String? orderId;
  final String? barrelId;
  final ScanType type;

  ScanResult({
    required this.code,
    this.orderId,
    this.barrelId,
    required this.type,
  });

  factory ScanResult.fromCode(String code) {
    if (code.startsWith('ORDER:')) {
      return ScanResult(
        code: code,
        orderId: code.substring(6),
        type: ScanType.order,
      );
    } else if (code.startsWith('BARREL:')) {
      return ScanResult(
        code: code,
        barrelId: code.substring(7),
        type: ScanType.barrel,
      );
    } else {
      return ScanResult(
        code: code,
        type: ScanType.unknown,
      );
    }
  }
}

enum ScanType { order, barrel, unknown }

class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<bool> validateBarrelCode(String barrelCode) async {
    try {
      final response = await _apiClient.get(
        '/barrels/validate/$barrelCode',
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> recordBarrelScan(
    String barrelCode, {
    required String orderId,
    required String driverId,
    required ScanAction action,
  }) async {
    try {
      final response = await _apiClient.post(
        '/barrels/scan',
        body: {
          'barrelCode': barrelCode,
          'orderId': orderId,
          'driverId': driverId,
          'action': action.name,
        },
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateOrderCode(String orderCode) async {
    try {
      final response = await _apiClient.get(
        '/orders/validate/$orderCode',
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getOrderByScanCode(String orderCode) async {
    try {
      final response = await _apiClient.get(
        '/orders/scan/$orderCode',
      );
      if (response.success) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

enum ScanAction { pickup, deliver, returnBarrel }
