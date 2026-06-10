import '../core/network/api_client.dart';

class AdminExportService {
  static final AdminExportService _instance = AdminExportService._internal();
  factory AdminExportService() => _instance;
  AdminExportService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<String?> exportReceivables({
    String? stationId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (stationId != null) queryParams['stationId'] = stationId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    try {
      final response = await _apiClient.get(
        '/admin/finance/export/receivables',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportPredeposits({
    String? stationId,
  }) async {
    final queryParams = <String, String>{};
    if (stationId != null) queryParams['stationId'] = stationId;

    try {
      final response = await _apiClient.get(
        '/admin/finance/export/predeposits',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportDriverDeliveryReport({
    String? startDate,
    String? endDate,
    String? driverId,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (driverId != null) queryParams['driverId'] = driverId;

    try {
      final response = await _apiClient.get(
        '/admin/reports/driver-delivery/export',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportStationPurchaseReport({
    String? startDate,
    String? endDate,
    String? stationId,
    String? area,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (stationId != null) queryParams['stationId'] = stationId;
    if (area != null) queryParams['area'] = area;

    try {
      final response = await _apiClient.get(
        '/admin/reports/station-purchase/export',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportInTransitBuckets() async {
    try {
      final response = await _apiClient.get('/admin/reports/in-transit-buckets/export');

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportDrivers({
    String? status,
    String? warehouseId,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (warehouseId != null) queryParams['warehouseId'] = warehouseId;

    try {
      final response = await _apiClient.get(
        '/admin/drivers/export',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportDeliveryReport({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    try {
      final response = await _apiClient.get(
        '/admin/drivers/delivery-report/export',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportProducts({
    String? category,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;

    try {
      final response = await _apiClient.get(
        '/admin/products/export',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exportAuditLogs({
    String? actionType,
    String? startDate,
    String? endDate,
    String? operatorId,
  }) async {
    final queryParams = <String, String>{};
    if (actionType != null) queryParams['actionType'] = actionType;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (operatorId != null) queryParams['operatorId'] = operatorId;

    try {
      final response = await _apiClient.get(
        '/admin/system/audit-logs/export',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['url']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

enum ExportType {
  receivables('应收款报表', 'receivables'),
  predeposits('预存金报表', 'predeposits'),
  driverDelivery('司机配送报表', 'driver_delivery'),
  stationPurchase('水站进货报表', 'station_purchase'),
  inTransitBuckets('在途空桶报表', 'in_transit_buckets'),
  drivers('司机列表', 'drivers'),
  products('商品列表', 'products'),
  auditLogs('审计日志', 'audit_logs');

  final String label;
  final String value;

  const ExportType(this.label, this.value);
}
