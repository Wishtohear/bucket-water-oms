import 'package:flutter/material.dart';
import 'admin_home_page.dart';
import 'admin_login_page.dart';
import 'admin_stations_page.dart';
import 'admin_station_detail_page.dart';
import 'admin_drivers_page.dart';
import 'admin_driver_detail_page.dart';
import 'admin_warehouses_page.dart';
import 'admin_warehouse_detail_page.dart';
import 'admin_settings_page.dart';

class AdminRoutes {
  static const String home = '/admin';
  static const String login = '/admin/login';
  static const String stations = '/admin/stations';
  static const String stationDetail = '/admin/stations/detail';
  static const String drivers = '/admin/drivers';
  static const String driverDetail = '/admin/drivers/detail';
  static const String warehouses = '/admin/warehouses';
  static const String warehouseDetail = '/admin/warehouses/detail';
  static const String settings = '/admin/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());
      case stations:
        return MaterialPageRoute(builder: (_) => const AdminStationsPage());
      case stationDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminStationDetailPage(station: args ?? {}),
        );
      case drivers:
        return MaterialPageRoute(builder: (_) => const AdminDriversPage());
      case driverDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminDriverDetailPage(driver: args ?? {}),
        );
      case warehouses:
        return MaterialPageRoute(builder: (_) => const AdminWarehousesPage());
      case warehouseDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminWarehouseDetailPage(warehouse: args ?? {}),
        );
      case AdminRoutes.settings:
        return MaterialPageRoute(builder: (_) => const AdminSettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const AdminHomePage(),
        );
    }
  }

  static void navigateToStationDetail(BuildContext context, Map<String, dynamic> station) {
    Navigator.pushNamed(context, stationDetail, arguments: station);
  }

  static void navigateToDriverDetail(BuildContext context, Map<String, dynamic> driver) {
    Navigator.pushNamed(context, driverDetail, arguments: driver);
  }

  static void navigateToWarehouseDetail(BuildContext context, Map<String, dynamic> warehouse) {
    Navigator.pushNamed(context, warehouseDetail, arguments: warehouse);
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

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }
}
