import 'package:flutter/services.dart';

class LocationPermission {
  final String value;
  const LocationPermission._(this.value);
  
  static const denied = LocationPermission._('denied');
  static const deniedForever = LocationPermission._('deniedForever');
  static const always = LocationPermission._('always');
  static const whileInUse = LocationPermission._('whileInUse');
  
  bool operator ==(Object other) =>
      other is LocationPermission && other.value == value;
  
  @override
  int get hashCode => value.hashCode;
}

class Position {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double altitudeAccuracy;
  final double heading;
  final double speed;
  final double speedAccuracy;
  final DateTime timestamp;

  Position({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.altitudeAccuracy,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
    required this.timestamp,
  });
}

class LocationSettings {
  final LocationAccuracy accuracy;
  final Duration? timeLimit;

  const LocationSettings({
    this.accuracy = LocationAccuracy.best,
    this.timeLimit,
  });
}

class LocationAccuracy {
  final int value;
  const LocationAccuracy._(this.value);
  
  static const lowest = LocationAccuracy._(1);
  static const low = LocationAccuracy._(2);
  static const medium = LocationAccuracy._(3);
  static const high = LocationAccuracy._(4);
  static const best = LocationAccuracy._(5);
  static const bestForNavigation = LocationAccuracy._(6);
}

class Geolocator {
  static Future<bool> isLocationServiceEnabled() async {
    return true;
  }

  static Future<LocationPermission> checkPermission() async {
    return LocationPermission.always;
  }

  static Future<LocationPermission> requestPermission() async {
    return LocationPermission.always;
  }

  static Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return Position(
      latitude: 0.0,
      longitude: 0.0,
      altitude: 0.0,
      accuracy: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      timestamp: DateTime.now(),
    );
  }

  static double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371000;
    final dLat = _toRadians(endLatitude - startLatitude);
    final dLng = _toRadians(endLongitude - startLongitude);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(startLatitude)) *
            _cos(_toRadians(endLatitude)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  static double _sin(double x) => _taylorSin(x);
  static double _cos(double x) => _taylorSin(x + 1.5707963267948966);
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  static double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 1.5707963267948966;
    if (x == 0 && y < 0) return -1.5707963267948966;
    return 0;
  }
  static double _atan(double x) {
    double result = x;
    double term = x;
    for (int n = 1; n < 20; n++) {
      term *= -x * x * (2 * n - 1) / (2 * n + 1);
      result += term / (2 * n + 1);
    }
    return result;
  }
  static double _taylorSin(double x) {
    while (x > 3.141592653589793) x -= 6.283185307179586;
    while (x < -3.141592653589793) x += 6.283185307179586;
    double result = x;
    double term = x;
    for (int n = 1; n < 10; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }
}
