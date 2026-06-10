import 'package:flutter/material.dart';
import 'admin_home_page.dart';
import 'admin_login_page.dart';
import 'admin_stations_page.dart';
import 'admin_station_detail_page.dart';
import 'admin_station_edit_page.dart';
import 'admin_drivers_page.dart';
import 'admin_driver_detail_page.dart';
import 'admin_driver_edit_page.dart';
import 'admin_warehouses_page.dart';
import 'admin_warehouse_detail_page.dart';
import 'admin_warehouse_edit_page.dart';
import 'admin_settings_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_policies_page.dart';
import 'admin_inventory_page.dart';
import 'admin_finance_page.dart';
import 'admin_reports_page.dart';
import 'admin_audit_logs_page.dart';

class AdminRoutes {
  static const String home = '/admin';
  static const String login = '/admin/login';
  static const String stations = '/admin/stations';
  static const String stationDetail = '/admin/stations/detail';
  static const String stationEdit = '/admin/stations/edit';
  static const String stationCreate = '/admin/stations/create';
  static const String drivers = '/admin/drivers';
  static const String driverDetail = '/admin/drivers/detail';
  static const String driverEdit = '/admin/drivers/edit';
  static const String driverCreate = '/admin/drivers/create';
  static const String warehouses = '/admin/warehouses';
  static const String warehouseDetail = '/admin/warehouses/detail';
  static const String warehouseEdit = '/admin/warehouses/edit';
  static const String warehouseCreate = '/admin/warehouses/create';
  static const String auditLogs = '/admin/audit-logs';
  static const String settings = '/admin/settings';
  static const String orders = '/admin/orders';
  static const String orderDetail = '/admin/orders/detail';
  static const String products = '/admin/products';
  static const String productDetail = '/admin/products/detail';
  static const String policies = '/admin/policies';
  static const String inventory = '/admin/inventory';
  static const String finance = '/admin/finance';
  static const String reports = '/admin/reports';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());
      case stations:
        return MaterialPageRoute(builder: (_) => const AdminStationsPage());
      case stationDetail:
        final routeArgs = routeSettings.arguments as Map<String, dynamic>?;
        final stationId = routeArgs?['id']?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => AdminStationDetailPage(stationId: stationId),
        );
      case stationEdit:
        final routeArgs = routeSettings.arguments as Map<String, dynamic>?;
        final stationId = routeArgs?['id']?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => AdminStationEditPage(stationId: stationId),
        );
      case stationCreate:
        return MaterialPageRoute(
          builder: (_) => const AdminStationEditPage(),
        );
      case drivers:
        return MaterialPageRoute(builder: (_) => const AdminDriversPage());
      case driverDetail:
        final routeArgs = routeSettings.arguments as Map<String, dynamic>?;
        final driverId = routeArgs?['id']?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => AdminDriverDetailPage(driverId: driverId),
        );
      case driverEdit:
        final routeArgs = routeSettings.arguments as Map<String, dynamic>?;
        final driverId = routeArgs?['id']?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => AdminDriverEditPage(driverId: driverId),
        );
      case driverCreate:
        return MaterialPageRoute(
          builder: (_) => const AdminDriverEditPage(),
        );
      case warehouses:
        return MaterialPageRoute(builder: (_) => const AdminWarehousesPage());
      case warehouseDetail:
        final routeArgs = routeSettings.arguments as Map<String, dynamic>?;
        final warehouseId = routeArgs?['id']?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => AdminWarehouseDetailPage(warehouseId: warehouseId),
        );
      case warehouseEdit:
        final routeArgs = routeSettings.arguments as Map<String, dynamic>?;
        final warehouseId = routeArgs?['id']?.toString() ?? '';
        return MaterialPageRoute(
          builder: (_) => AdminWarehouseEditPage(warehouseId: warehouseId),
        );
      case warehouseCreate:
        return MaterialPageRoute(
          builder: (_) => const AdminWarehouseEditPage(),
        );
      case auditLogs:
        return MaterialPageRoute(builder: (_) => const AdminAuditLogsPage());
      case settings:
        return MaterialPageRoute(builder: (_) => AdminSettingsPage());
      case orders:
        return MaterialPageRoute(builder: (_) => AdminOrdersPage());
      case products:
        return MaterialPageRoute(builder: (_) => AdminProductsPage());
      case policies:
        return MaterialPageRoute(builder: (_) => AdminPoliciesPage());
      case inventory:
        return MaterialPageRoute(builder: (_) => AdminInventoryPage());
      case finance:
        return MaterialPageRoute(builder: (_) => AdminFinancePage());
      case reports:
        return MaterialPageRoute(builder: (_) => AdminReportsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const AdminHomePage(),
        );
    }
  }

  static void navigateToStationDetail(BuildContext context, String stationId) {
    Navigator.pushNamed(context, stationDetail, arguments: {'id': stationId});
  }

  static void navigateToStationEdit(BuildContext context, String stationId) {
    Navigator.pushNamed(context, stationEdit, arguments: {'id': stationId});
  }

  static void navigateToStationCreate(BuildContext context) {
    Navigator.pushNamed(context, stationCreate);
  }

  static void navigateToDriverDetail(BuildContext context, String driverId) {
    Navigator.pushNamed(context, driverDetail, arguments: {'id': driverId});
  }

  static void navigateToDriverEdit(BuildContext context, String driverId) {
    Navigator.pushNamed(context, driverEdit, arguments: {'id': driverId});
  }

  static void navigateToDriverCreate(BuildContext context) {
    Navigator.pushNamed(context, driverCreate);
  }

  static void navigateToWarehouseDetail(
      BuildContext context, String warehouseId) {
    Navigator.pushNamed(context, warehouseDetail,
        arguments: {'id': warehouseId});
  }

  static void navigateToWarehouseEdit(BuildContext context, String warehouseId) {
    Navigator.pushNamed(context, warehouseEdit, arguments: {'id': warehouseId});
  }

  static void navigateToWarehouseCreate(BuildContext context) {
    Navigator.pushNamed(context, warehouseCreate);
  }

  static void navigateToAuditLogs(BuildContext context) {
    Navigator.pushNamed(context, auditLogs);
  }

  static void navigateToStations(BuildContext context) {
    Navigator.pushNamed(context, stations);
  }

  static void navigateToDrivers(BuildContext context) {
    Navigator.pushNamed(context, drivers);
  }

  static void navigateToWarehouses(BuildContext context) {
    Navigator.pushNamed(context, warehouses);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settings);
  }

  static void navigateToOrders(BuildContext context) {
    Navigator.pushNamed(context, orders);
  }

  static void navigateToProducts(BuildContext context) {
    Navigator.pushNamed(context, products);
  }

  static void navigateToPolicies(BuildContext context) {
    Navigator.pushNamed(context, policies);
  }

  static void navigateToInventory(BuildContext context) {
    Navigator.pushNamed(context, inventory);
  }

  static void navigateToFinance(BuildContext context) {
    Navigator.pushNamed(context, finance);
  }

  static void navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, reports);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }
}
