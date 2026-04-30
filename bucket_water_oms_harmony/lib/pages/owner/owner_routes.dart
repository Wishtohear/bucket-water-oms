import 'package:flutter/material.dart';
import '../order/order_list_page.dart';
import '../order/order_create_page.dart';
import '../customer/customer_list_page.dart';
import '../customer/customer_detail_page.dart';
import '../dispatch/dispatch_manage_page.dart';
import '../ticket/ticket_manage_page.dart';
import 'owner_home_page.dart';
import 'owner_orders_page.dart';
import 'owner_statement_page.dart';
import 'owner_profile_page.dart';
import 'owner_order_detail_page.dart';
import 'recharge_page.dart';
import 'bucket_exchange_page.dart';
import 'statistics_page.dart';
import 'inventory_manage_page.dart';

class OwnerRoutes {
  static const String home = '/owner';
  static const String orders = '/owner/orders';
  static const String orderDetail = '/owner/order-detail';
  static const String statement = '/owner/statement';
  static const String profile = '/owner/profile';
  static const String recharge = '/owner/recharge';
  static const String bucketExchange = '/owner/bucket-exchange';
  static const String orderList = '/owner/order-list';
  static const String orderCreate = '/owner/order-create';
  static const String customerList = '/owner/customer-list';
  static const String customerDetail = '/owner/customer-detail';
  static const String dispatchManage = '/owner/dispatch';
  static const String ticketManage = '/owner/ticket';
  static const String statistics = '/owner/statistics';
  static const String inventoryManage = '/owner/inventory';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const OwnerHomePage(),
        );
      case orders:
      case orderList:
        return MaterialPageRoute(
          builder: (_) => const OwnerOrdersPage(),
        );
      case orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OwnerOrderDetailPage(
            orderId: args?['orderId'] ?? '202604210001',
            orderData: args,
          ),
        );
      case statement:
        return MaterialPageRoute(
          builder: (_) => const OwnerStatementPage(),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const OwnerProfilePage(),
        );
      case recharge:
        return MaterialPageRoute(
          builder: (_) => const RechargePage(),
        );
      case bucketExchange:
        return MaterialPageRoute(
          builder: (_) => const BucketExchangePage(),
        );
      case orderCreate:
        return MaterialPageRoute(
          builder: (_) => const OrderCreatePage(),
        );
      case customerList:
        return MaterialPageRoute(
          builder: (_) => const CustomerListPage(),
        );
      case customerDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CustomerDetailPage(
            customerId: args?['customerId'] ?? '',
          ),
        );
      case dispatchManage:
        return MaterialPageRoute(
          builder: (_) => const DispatchManagePage(),
        );
      case ticketManage:
        return MaterialPageRoute(
          builder: (_) => const TicketManagePage(),
        );
      case statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsPage(),
        );
      case inventoryManage:
        return MaterialPageRoute(
          builder: (_) => const InventoryManagePage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const OwnerHomePage(),
        );
    }
  }
}
