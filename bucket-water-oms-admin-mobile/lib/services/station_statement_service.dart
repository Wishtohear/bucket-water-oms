import '../core/network/api_client.dart';
import '../models/statement_model.dart';
import '../models/monthly_statement_model.dart';

class StationStatementService {
  static final StationStatementService _instance =
      StationStatementService._internal();
  factory StationStatementService() => _instance;
  StationStatementService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<StatementModel>> getStatements({
    required String stationId,
    String? status,
    int page = 1,
    int size = 20,
  }) async {
    final headers = <String, String>{
      'X-Station-Id': stationId,
    };

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) queryParams['status'] = status;

    try {
      final response = await _apiClient.get(
        '/statements',
        queryParams: queryParams,
        headers: headers,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => StatementModel.fromJson(e)).toList();
        } else if (data is Map) {
          final records = data['records'] ?? data['list'] ?? data['data'];
          if (records is List) {
            return records.map((e) => StatementModel.fromJson(e)).toList();
          }
        }
        return [];
      }
      return _getMockStatements();
    } catch (e) {
      return _getMockStatements();
    }
  }

  Future<StatementModel?> getStatement(String statementId) async {
    try {
      final response = await _apiClient.get('/statements/$statementId');

      if (response.success && response.data != null) {
        return StatementModel.fromJson(response.data);
      }
      return _getMockStatements().first;
    } catch (e) {
      return _getMockStatements().first;
    }
  }

  Future<StatementModel?> getCurrentStatement(String stationId) async {
    try {
      final headers = <String, String>{
        'X-Station-Id': stationId,
      };

      final response = await _apiClient.get(
        '/statements/current',
        headers: headers,
      );

      if (response.success && response.data != null) {
        return StatementModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> confirmStatement(String statementId, {String? stationId}) async {
    try {
      final headers = <String, String>{};
      if (stationId != null) {
        headers['X-Station-Id'] = stationId;
      }

      final response = await _apiClient.post(
        '/statements/$statementId/confirm',
        headers: headers,
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> disputeStatement(String statementId,
      {required String reason, String? stationId}) async {
    try {
      final headers = <String, String>{};
      if (stationId != null) {
        headers['X-Station-Id'] = stationId;
      }

      final response = await _apiClient.post(
        '/statements/$statementId/dispute',
        headers: headers,
        body: {'reason': reason},
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getStatementDetails(String statementId) async {
    try {
      final response = await _apiClient.get('/statements/$statementId/details');

      if (response.success && response.data != null) {
        return response.data ?? {};
      }
      return _getMockStatementDetails();
    } catch (e) {
      return _getMockStatementDetails();
    }
  }

  List<StatementModel> _getMockStatements() {
    final now = DateTime.now();
    return [
      StatementModel(
        id: '1',
        statementNo: 'ST202604',
        stationId: '1',
        stationName: '张记旗舰水站',
        status: 'pending',
        type: 'monthly',
        startDate: DateTime(now.year, now.month - 1, 1),
        endDate: DateTime(now.year, now.month, 0),
        createdAt: DateTime(now.year, now.month - 1, 1),
        totalAmount: 7500.00,
        orders: [],
        items: [
          StatementItem(
            productId: '1',
            productName: '18.9L 桶装水',
            quantity: 100,
            unitPrice: 8.00,
            subtotal: 800.00,
          ),
          StatementItem(
            productId: '2',
            productName: '11.3L 桶装水',
            quantity: 50,
            unitPrice: 6.00,
            subtotal: 300.00,
          ),
        ],
      ),
      StatementModel(
        id: '2',
        statementNo: 'ST202603',
        stationId: '1',
        stationName: '张记旗舰水站',
        status: 'confirmed',
        type: 'monthly',
        startDate: DateTime(now.year, now.month - 2, 1),
        endDate: DateTime(now.year, now.month - 1, 0),
        createdAt: DateTime(now.year, now.month - 2, 1),
        confirmedAt: DateTime(now.year, now.month - 2, 5),
        totalAmount: 8500.00,
        orders: [],
        items: [],
      ),
      StatementModel(
        id: '3',
        statementNo: 'ST202602',
        stationId: '1',
        stationName: '张记旗舰水站',
        status: 'confirmed',
        type: 'monthly',
        startDate: DateTime(now.year, now.month - 3, 1),
        endDate: DateTime(now.year, now.month - 2, 0),
        createdAt: DateTime(now.year, now.month - 3, 1),
        confirmedAt: DateTime(now.year, now.month - 3, 3),
        totalAmount: 6200.00,
        orders: [],
        items: [],
      ),
    ];
  }

  Map<String, dynamic> _getMockStatementDetails() {
    return {
      'openingBalance': 2500.00,
      'totalAmount': 7500.00,
      'paymentReceived': 10000.00,
      'closingBalance': 2500.00,
      'details': [
        {
          'date': '2026-04-18',
          'orderNo': '#800',
          'product': '18.9L 桶装水 × 100 桶',
          'amount': 800.00,
        },
        {
          'date': '2026-04-15',
          'orderNo': '#750',
          'product': '11.3L 桶装水 × 50 桶',
          'amount': 1250.00,
        },
        {
          'date': '2026-04-12',
          'orderNo': '#720',
          'product': '18.9L 桶装水 × 200 桶',
          'amount': 1600.00,
        },
      ],
    };
  }

  Future<List<MonthlyStatementModel>> getMonthlyStatements({
    required String stationId,
    int page = 1,
    int size = 6,
  }) async {
    final headers = <String, String>{
      'X-Station-Id': stationId,
    };

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };

    try {
      final response = await _apiClient.get(
        '/stations/statements',
        queryParams: queryParams,
        headers: headers,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data
              .map((e) =>
                  MonthlyStatementModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return _getMockMonthlyStatements();
    } catch (e) {
      return _getMockMonthlyStatements();
    }
  }

  Future<MonthlyStatementModel?> getCurrentMonthStatement({
    required String stationId,
  }) async {
    final headers = <String, String>{
      'X-Station-Id': stationId,
    };

    try {
      final response = await _apiClient.get(
        '/stations/statements/current',
        headers: headers,
      );

      if (response.success && response.data != null) {
        return MonthlyStatementModel.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<MonthlyStatementModel?> getStatementByMonth({
    required String stationId,
    required String yearMonth,
  }) async {
    final headers = <String, String>{
      'X-Station-Id': stationId,
    };

    try {
      final response = await _apiClient.get(
        '/stations/statements/$yearMonth',
        headers: headers,
      );

      if (response.success && response.data != null) {
        return MonthlyStatementModel.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> confirmMonthlyStatement({
    required String stationId,
    required String statementId,
  }) async {
    final headers = <String, String>{
      'X-Station-Id': stationId,
    };

    try {
      final response = await _apiClient.post(
        '/stations/statements/$statementId/confirm',
        headers: headers,
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> disputeMonthlyStatement({
    required String stationId,
    required String statementId,
    required String reason,
  }) async {
    final headers = <String, String>{
      'X-Station-Id': stationId,
    };

    try {
      final response = await _apiClient.post(
        '/stations/statements/$statementId/dispute',
        headers: headers,
        body: {'reason': reason},
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  List<MonthlyStatementModel> _getMockMonthlyStatements() {
    final now = DateTime.now();
    return [
      MonthlyStatementModel(
        id: '1_202604',
        stationId: '1',
        stationName: '张记旗舰水站',
        yearMonth: '2026-04',
        startDate: DateTime(now.year, 4, 1),
        endDate: DateTime(now.year, 4, 30),
        openingBalance: 2500.00,
        totalAmount: 7500.00,
        paymentReceived: 5000.00,
        closingBalance: 5000.00,
        totalOrders: 15,
        completedOrders: 12,
        totalBuckets: 450,
        status: 'pending',
        generatedAt: DateTime(now.year, now.month, 1),
        orders: [
          MonthlyOrderSummary(
            orderId: '1',
            orderNo: '#1001',
            orderDate: DateTime(now.year, now.month, 5),
            amount: 800.00,
            buckets: 100,
            status: 'completed',
            items: '18.9L 桶装水 × 100',
          ),
          MonthlyOrderSummary(
            orderId: '2',
            orderNo: '#1002',
            orderDate: DateTime(now.year, now.month, 10),
            amount: 1600.00,
            buckets: 200,
            status: 'completed',
            items: '18.9L 桶装水 × 200',
          ),
          MonthlyOrderSummary(
            orderId: '3',
            orderNo: '#1003',
            orderDate: DateTime(now.year, now.month, 15),
            amount: 2400.00,
            buckets: 150,
            status: 'pending',
            items: '18.9L 桶装水 × 150',
          ),
        ],
        products: [
          MonthlyProductSummary(
            productId: '1',
            productName: '18.9L 桶装水',
            quantity: 450,
            unit: '桶',
            unitPrice: 8.00,
            subtotal: 3600.00,
          ),
        ],
      ),
      MonthlyStatementModel(
        id: '1_202603',
        stationId: '1',
        stationName: '张记旗舰水站',
        yearMonth: '2026-03',
        startDate: DateTime(now.year, 3, 1),
        endDate: DateTime(now.year, 3, 31),
        openingBalance: 1000.00,
        totalAmount: 8500.00,
        paymentReceived: 7000.00,
        closingBalance: 2500.00,
        totalOrders: 20,
        completedOrders: 20,
        totalBuckets: 520,
        status: 'confirmed',
        generatedAt: DateTime(now.year, 3, 1),
        confirmedAt: DateTime(now.year, 3, 5),
        orders: [],
        products: [],
      ),
      MonthlyStatementModel(
        id: '1_202602',
        stationId: '1',
        stationName: '张记旗舰水站',
        yearMonth: '2026-02',
        startDate: DateTime(now.year, 2, 1),
        endDate: DateTime(now.year, 2, 28),
        openingBalance: 0.00,
        totalAmount: 6200.00,
        paymentReceived: 5200.00,
        closingBalance: 1000.00,
        totalOrders: 12,
        completedOrders: 12,
        totalBuckets: 380,
        status: 'confirmed',
        generatedAt: DateTime(now.year, 2, 1),
        confirmedAt: DateTime(now.year, 2, 3),
        orders: [],
        products: [],
      ),
    ];
  }
}
