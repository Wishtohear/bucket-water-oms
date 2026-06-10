import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math' as math;

class MapService {
  static final Location _location = Location();

  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('位置服务未启用');
          return null;
        }
      }

      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          debugPrint('位置权限被拒绝');
          return null;
        }
      }

      if (permissionStatus == PermissionStatus.deniedForever) {
        debugPrint('位置权限被永久拒绝');
        return null;
      }

      final locationData = await _location.getLocation();

      if (locationData.latitude == null || locationData.longitude == null) {
        debugPrint('无法获取位置数据');
        return null;
      }

      return {
        'latitude': locationData.latitude!,
        'longitude': locationData.longitude!,
      };
    } catch (e) {
      debugPrint('获取位置失败: $e');
      return null;
    }
  }

  static Future<LocationData?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return null;
        }
      }

      if (permissionStatus == PermissionStatus.deniedForever) {
        return null;
      }

      return await _location.getLocation();
    } catch (e) {
      debugPrint('获取位置失败: $e');
      return null;
    }
  }

  static Future<bool> requestLocationPermission() async {
    try {
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
      }
      return permissionStatus == PermissionStatus.granted ||
          permissionStatus == PermissionStatus.grantedLimited;
    } catch (e) {
      debugPrint('请求位置权限失败: $e');
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, double>> calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) async {
    final distanceM = _calculateDistanceMeters(lat1, lng1, lat2, lng2);
    final distanceKm = distanceM / 1000;
    return {
      'distanceKm': distanceKm,
      'distanceM': distanceM,
    };
  }

  static double _calculateDistanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double calculateDistanceSync(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return _calculateDistanceMeters(lat1, lng1, lat2, lng2);
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  static void navigateToStation({
    required BuildContext context,
    required double lat,
    required double lng,
    required String stationName,
    String? address,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _NavigationBottomSheet(
        lat: lat,
        lng: lng,
        stationName: stationName,
        address: address,
      ),
    );
  }

  static void navigateWithWaypoints({
    required BuildContext context,
    required List<Waypoint> waypoints,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _WaypointNavigationBottomSheet(
        waypoints: waypoints,
      ),
    );
  }

  static Future<void> openMap({
    required double lat,
    required double lng,
    String? stationName,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isEmpty) {
        throw Exception('未安装任何地图应用');
      }

      await availableMaps.first.showMarker(
        coords: Coords(lat, lng),
        title: stationName ?? '目的地',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> openGaodeMap({
    required double lat,
    required double lng,
    String? stationName,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      final gaodeMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.amap,
        orElse: () => availableMaps.first,
      );

      await gaodeMap.showMarker(
        coords: Coords(lat, lng),
        title: stationName ?? '目的地',
      );
    } catch (e) {
      await _openMapByScheme(
          lat: lat, lng: lng, stationName: stationName, scheme: 'amap');
    }
  }

  static void navigateWithAddress({
    required BuildContext context,
    required String address,
    String? stationName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressNavigationBottomSheet(
        address: address,
        stationName: stationName,
      ),
    );
  }

  static Future<void> openGaodeMapWithAddress({
    required String address,
    String? stationName,
  }) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final encodedName = Uri.encodeComponent(stationName ?? '目的地');
      final uri = Uri.parse(
          'androidamap://keywordSearch?keywords=$encodedAddress&qiname=$encodedName&src=andr.bucketwater.oms');

      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri,
            mode: url_launcher.LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
            'https://uri.amap.com/search?keyword=$encodedAddress&src=andr.bucketwater.oms');
        await url_launcher.launchUrl(webUri,
            mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> openBaiduMapWithAddress({
    required String address,
    String? stationName,
  }) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final encodedName = Uri.encodeComponent(stationName ?? '目的地');
      final uri = Uri.parse(
          'baidumap://map/geocoder?src=andr.bucketwater.oms&address=$encodedAddress&city=&name=$encodedName');

      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri,
            mode: url_launcher.LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
            'https://map.baidu.com/search/$encodedAddress/@110.29,25.28,15z');
        await url_launcher.launchUrl(webUri,
            mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> openTencentMapWithAddress({
    required String address,
    String? stationName,
  }) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final uri = Uri.parse(
          'qqmap://map/search?keyword=$encodedAddress&src=andr.bucketwater.oms');

      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri,
            mode: url_launcher.LaunchMode.externalApplication);
      } else {
        final webUri =
            Uri.parse('https://map.qq.com/search/?keyword=$encodedAddress');
        await url_launcher.launchUrl(webUri,
            mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> openAppleMapsWithAddress({
    required String address,
    String? stationName,
  }) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final uri = Uri.parse(
          'http://maps.apple.com/?q=${stationName ?? '目的地'}&z=16&t=s&q=$encodedAddress');

      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> openBaiduMap({
    required double lat,
    required double lng,
    String? stationName,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      final baiduMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.baidu,
        orElse: () => availableMaps.first,
      );

      await baiduMap.showMarker(
        coords: Coords(lat, lng),
        title: stationName ?? '目的地',
      );
    } catch (e) {
      await _openMapByScheme(
          lat: lat, lng: lng, stationName: stationName, scheme: 'baidumap');
    }
  }

  static Future<void> openAppleMaps({
    required double lat,
    required double lng,
    String? stationName,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      final appleMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.apple,
        orElse: () => availableMaps.first,
      );

      await appleMap.showMarker(
        coords: Coords(lat, lng),
        title: stationName ?? '目的地',
      );
    } catch (e) {
      await _openMapByScheme(
          lat: lat,
          lng: lng,
          stationName: stationName,
          scheme: 'http://maps.apple.com');
    }
  }

  static Future<void> openTencentMap({
    required double lat,
    required double lng,
    String? stationName,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      final tencentMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.tencent,
        orElse: () => availableMaps.first,
      );

      await tencentMap.showMarker(
        coords: Coords(lat, lng),
        title: stationName ?? '目的地',
      );
    } catch (e) {
      await _openMapByScheme(
          lat: lat, lng: lng, stationName: stationName, scheme: 'qqmap');
    }
  }

  static Future<void> _openMapByScheme({
    required double lat,
    required double lng,
    String? stationName,
    required String scheme,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          coords: Coords(lat, lng),
          title: stationName ?? '目的地',
        );
      } else {
        throw Exception('未安装任何地图应用');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> copyAddressToClipboard(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    } else {
      throw Exception('无法拨打电话');
    }
  }

  static Future<bool> launchUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> navigateWithGaode({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startName,
    String? endName,
    String mode = 'driving',
  }) async {
    final modeMap = {
      'driving': '0',
      'walking': '1',
      'riding': '2',
      'bus': '3',
    };
    final t = modeMap[mode] ?? '0';

    final url = Uri.encodeComponent(
      'amapuri://route/plan/?sid=&slat=$startLat&slon=$startLng&sname=${startName ?? ''}&did=&dlat=$endLat&dlon=$endLng&dname=${endName ?? ''}&dev=0&t=$t',
    );

    final uri = Uri.parse(
        'androidamap://openFeature?featureName=routeplan&sourceApplication=appname&callRouter=true&router=$url');
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } else {
      await openGaodeMap(lat: endLat, lng: endLng, stationName: endName);
    }
  }

  static Future<void> navigateWithGaodeWaypoints({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required List<Waypoint> waypoints,
    String? startName,
    String? endName,
    String mode = 'driving',
  }) async {
    final modeMap = {
      'driving': '0',
      'walking': '1',
      'riding': '2',
      'bus': '3',
    };
    final t = modeMap[mode] ?? '0';

    String waypointStr = '';
    if (waypoints.isNotEmpty) {
      final waypointParts = <String>[];
      for (int i = 0; i < waypoints.length; i++) {
        final wp = waypoints[i];
        waypointParts.add(
            'lat=${wp.lat}&lon=${wp.lng}&name=${Uri.encodeComponent(wp.name)}');
      }
      waypointStr =
          '&waypoints=${Uri.encodeComponent(waypointParts.join('|'))}';
    }

    final url = Uri.encodeComponent(
      'amapuri://route/plan/?sid=&slat=$startLat&slon=$startLng&sname=${startName ?? ''}&did=&dlat=$endLat&dlon=$endLng&dname=${endName ?? ''}&dev=0&t=$t$waypointStr',
    );

    final uri = Uri.parse(
        'androidamap://openFeature?featureName=routeplan&sourceApplication=bucketwater.oms&callRouter=true&router=$url');

    debugPrint('高德地图导航URL: $uri');

    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } else {
      final fallbackUri = Uri.parse(
          'amapuri://route/plan/?slat=$startLat&slon=$startLng&sname=${startName ?? '我的位置'}&dlat=$endLat&dlon=$endLng&dname=${endName ?? '目的地'}&dev=0&t=$t$waypointStr');
      if (await url_launcher.canLaunchUrl(fallbackUri)) {
        await url_launcher.launchUrl(fallbackUri,
            mode: url_launcher.LaunchMode.externalApplication);
      } else {
        await openGaodeMap(lat: endLat, lng: endLng, stationName: endName);
      }
    }
  }

  static Future<void> navigateWithBaidu({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startName,
    String? endName,
    String mode = 'driving',
  }) async {
    final bdStart = _gcj02ToBd09(startLat, startLng);
    final bdEnd = _gcj02ToBd09(endLat, endLng);

    final modeMap = {
      'driving': 'driving',
      'walking': 'walking',
      'riding': 'riding',
    };
    final routeType = modeMap[mode] ?? 'driving';

    final url =
        'baidumap://map/direction?origin=latlng:${bdStart['lat']},${bdStart['lng']}|name:${startName ?? '我的位置'}&destination=latlng:${bdEnd['lat']},${bdEnd['lng']}|name:${endName ?? '目的地'}&mode=$routeType&src=andr.bucketwater.oms';

    final uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } else {
      await openBaiduMap(lat: endLat, lng: endLng, stationName: endName);
    }
  }

  static Future<void> navigateWithBaiduWaypoints({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required List<Waypoint> waypoints,
    String? startName,
    String? endName,
    String mode = 'driving',
  }) async {
    final bdStart = _gcj02ToBd09(startLat, startLng);
    final bdEnd = _gcj02ToBd09(endLat, endLng);

    String waypointStr = '';
    if (waypoints.isNotEmpty) {
      final waypointParts = <String>[];
      for (final wp in waypoints) {
        final bdWp = _gcj02ToBd09(wp.lat, wp.lng);
        waypointParts
            .add('latlng:${bdWp['lat']},${bdWp['lng']}|name:${wp.name}');
      }
      waypointStr =
          '&waypoints=${Uri.encodeComponent(waypointParts.join('|'))}';
    }

    final modeMap = {
      'driving': 'driving',
      'walking': 'walking',
      'riding': 'riding',
    };
    final routeType = modeMap[mode] ?? 'driving';

    final url =
        'baidumap://map/direction?origin=latlng:${bdStart['lat']},${bdStart['lng']}|name:${startName ?? '我的位置'}&destination=latlng:${bdEnd['lat']},${bdEnd['lng']}|name:${endName ?? '目的地'}&mode=$routeType$waypointStr&src=andr.bucketwater.oms';

    final uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } else {
      await openBaiduMap(lat: endLat, lng: endLng, stationName: endName);
    }
  }

  static Future<void> navigateWithTencentWaypoints({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required List<Waypoint> waypoints,
    String? startName,
    String? endName,
    String mode = 'driving',
  }) async {
    String waypointStr = '';
    if (waypoints.isNotEmpty) {
      final waypointParts = <String>[];
      for (final wp in waypoints) {
        waypointParts
            .add('${wp.lat},${wp.lng};${Uri.encodeComponent(wp.name)}');
      }
      waypointStr =
          '&waypoints=${Uri.encodeComponent(waypointParts.join(';'))}';
    }

    final modeMap = {
      'driving': 'drive',
      'walking': 'walk',
      'riding': 'bike',
    };
    final routeType = modeMap[mode] ?? 'drive';

    final url =
        'qqmap://map/routeplan?type=$routeType&from=${startName ?? '我的位置'}&fromcoord=$startLat,$startLng&to=${endName ?? '目的地'}&tocoord=$endLat,$endLng$waypointStr&referer=OB4BZ-D4KW3-BXU93-CHQGZ-BDDTZ-BKF58';

    final uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } else {
      await openTencentMap(lat: endLat, lng: endLng, stationName: endName);
    }
  }

  static Future<void> navigateWithAppleMapsWaypoints({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required List<Waypoint> waypoints,
    String? startName,
    String? endName,
  }) async {
    String waypointStr = '';
    if (waypoints.isNotEmpty) {
      final waypointParts = <String>[];
      for (final wp in waypoints) {
        waypointParts.add('${wp.lat},${wp.lng}');
      }
      waypointStr = '${waypointParts.join(',')},';
    }

    final url =
        'http://maps.apple.com/?saddr=$startLat,$startLng&daddr=$waypointStr$endLat,$endLng&dirflg=d';

    final uri = Uri.parse(url);
    await url_launcher.launchUrl(uri,
        mode: url_launcher.LaunchMode.externalApplication);
  }

  static Map<String, double> _gcj02ToBd09(double lat, double lng) {
    const double x = 63709904.8;
    final double z = math.sqrt(lng * lng + lat * lat) +
        0.00002 * math.sin(lat * math.pi / 180);
    final double theta =
        math.atan2(lat, lng) + 0.000003 * math.cos(lng * math.pi / 180);

    final double bdLng = z * math.cos(theta) + 0.0065;
    final double bdLat = z * math.sin(theta) + 0.006;

    return {'lat': bdLat, 'lng': bdLng};
  }
}

class Waypoint {
  final double lat;
  final double lng;
  final String name;
  final String? address;

  Waypoint({
    required this.lat,
    required this.lng,
    required this.name,
    this.address,
  });
}

class _NavigationBottomSheet extends StatelessWidget {
  final double lat;
  final double lng;
  final String stationName;
  final String? address;

  const _NavigationBottomSheet({
    required this.lat,
    required this.lng,
    required this.stationName,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stationName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (address != null)
                            Text(
                              address!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '选择导航应用',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavAppButton(
                      context: context,
                      icon: 'A',
                      name: '高德地图',
                      color: Colors.blue,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openGaodeMap(
                            lat: lat,
                            lng: lng,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildNavAppButton(
                      context: context,
                      icon: 'B',
                      name: '百度地图',
                      color: Colors.orange,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openBaiduMap(
                            lat: lat,
                            lng: lng,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildNavAppButton(
                      context: context,
                      icon: 'T',
                      name: '腾讯地图',
                      color: Colors.green,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openTencentMap(
                            lat: lat,
                            lng: lng,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildNavAppButton(
                      context: context,
                      icon: '🍎',
                      name: '苹果地图',
                      color: Colors.grey,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openAppleMaps(
                            lat: lat,
                            lng: lng,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (address != null)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        MapService.copyAddressToClipboard(address!);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('地址已复制到剪贴板'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('复制地址'),
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavAppButton({
    required BuildContext context,
    required String icon,
    required String name,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressNavigationBottomSheet extends StatelessWidget {
  final String address;
  final String? stationName;

  const _AddressNavigationBottomSheet({
    required this.address,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stationName ?? '目的地',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '选择导航应用（地址导航）',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '使用详细地址进行导航',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavAppButton(
                      context: context,
                      icon: 'A',
                      name: '高德地图',
                      color: Colors.blue,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openGaodeMapWithAddress(
                            address: address,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildNavAppButton(
                      context: context,
                      icon: 'B',
                      name: '百度地图',
                      color: Colors.orange,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openBaiduMapWithAddress(
                            address: address,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildNavAppButton(
                      context: context,
                      icon: 'T',
                      name: '腾讯地图',
                      color: Colors.green,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openTencentMapWithAddress(
                            address: address,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildNavAppButton(
                      context: context,
                      icon: '🍎',
                      name: '苹果地图',
                      color: Colors.grey,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await MapService.openAppleMapsWithAddress(
                            address: address,
                            stationName: stationName,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('打开失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      MapService.copyAddressToClipboard(address);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('地址已复制到剪贴板'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('复制地址'),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavAppButton({
    required BuildContext context,
    required String icon,
    required String name,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaypointNavigationBottomSheet extends StatefulWidget {
  final List<Waypoint> waypoints;

  const _WaypointNavigationBottomSheet({
    required this.waypoints,
  });

  @override
  State<_WaypointNavigationBottomSheet> createState() =>
      _WaypointNavigationBottomSheetState();
}

class _WaypointNavigationBottomSheetState
    extends State<_WaypointNavigationBottomSheet> {
  double? _currentLat;
  double? _currentLng;
  String _selectedMode = 'driving';

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final locationData = await MapService.getCurrentPosition();
    if (mounted && locationData != null) {
      setState(() {
        _currentLat = locationData.latitude;
        _currentLng = locationData.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '多站配送导航',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '共 ${widget.waypoints.length} 个站点',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWaypointList(),
                const SizedBox(height: 16),
                _buildModeSelector(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildNavButton(
                        icon: 'A',
                        name: '高德地图',
                        color: Colors.blue,
                        onTap: _navigateWithGaode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNavButton(
                        icon: 'B',
                        name: '百度地图',
                        color: Colors.orange,
                        onTap: _navigateWithBaidu,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNavButton(
                        icon: 'T',
                        name: '腾讯地图',
                        color: Colors.green,
                        onTap: _navigateWithTencent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.waypoints.length,
        itemBuilder: (context, index) {
          final wp = widget.waypoints[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.green
                        : (index == widget.waypoints.length - 1
                            ? Colors.red
                            : Colors.blue),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wp.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (wp.address != null)
                        Text(
                          wp.address!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        const Text(
          '出行方式:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModeChip('driving', '驾车', Icons.directions_car),
                const SizedBox(width: 8),
                _buildModeChip('walking', '步行', Icons.directions_walk),
                const SizedBox(width: 8),
                _buildModeChip('riding', '骑行', Icons.directions_bike),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(String mode, String label, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required String icon,
    required String name,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateWithGaode() async {
    Navigator.pop(context);

    if (widget.waypoints.isEmpty) return;

    final endPoint = widget.waypoints.last;
    final middlePoints = widget.waypoints.length > 2
        ? widget.waypoints.sublist(1, widget.waypoints.length - 1)
        : <Waypoint>[];

    try {
      await MapService.navigateWithGaodeWaypoints(
        startLat: _currentLat ?? 25.2810,
        startLng: _currentLng ?? 110.2900,
        startName: '我的位置',
        endLat: endPoint.lat,
        endLng: endPoint.lng,
        endName: endPoint.name,
        waypoints: middlePoints,
        mode: _selectedMode,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('高德地图导航失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateWithBaidu() async {
    Navigator.pop(context);

    if (widget.waypoints.isEmpty) return;

    final endPoint = widget.waypoints.last;
    final middlePoints = widget.waypoints.length > 2
        ? widget.waypoints.sublist(1, widget.waypoints.length - 1)
        : <Waypoint>[];

    try {
      await MapService.navigateWithBaiduWaypoints(
        startLat: _currentLat ?? 25.2810,
        startLng: _currentLng ?? 110.2900,
        startName: '我的位置',
        endLat: endPoint.lat,
        endLng: endPoint.lng,
        endName: endPoint.name,
        waypoints: middlePoints,
        mode: _selectedMode,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('百度地图导航失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateWithTencent() async {
    Navigator.pop(context);

    if (widget.waypoints.isEmpty) return;

    final endPoint = widget.waypoints.last;
    final middlePoints = widget.waypoints.length > 2
        ? widget.waypoints.sublist(1, widget.waypoints.length - 1)
        : <Waypoint>[];

    try {
      await MapService.navigateWithTencentWaypoints(
        startLat: _currentLat ?? 25.2810,
        startLng: _currentLng ?? 110.2900,
        startName: '我的位置',
        endLat: endPoint.lat,
        endLng: endPoint.lng,
        endName: endPoint.name,
        waypoints: middlePoints,
        mode: _selectedMode,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('腾讯地图导航失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
