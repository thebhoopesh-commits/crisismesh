import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';

/// 📍 Location Service — GPS Sensor & Spatial Calculations.
///
/// Thin wrapper around `geolocator` (in production). Returns the current
/// AppLocation and exposes basic haversine helpers used by the Maps Agent.
class LocationService {
  LocationService({math.Random? rng}) : _rng = rng ?? math.Random();
  final math.Random _rng;
  AppLocation? _cached;

  Future<AppLocation?> current() async {
    // Simulate GPS lock latency.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final double lat = 37.7749 + (_rng.nextDouble() - 0.5) * 0.02;
    final double lng = -122.4194 + (_rng.nextDouble() - 0.5) * 0.02;
    _cached = AppLocation(latitude: lat, longitude: lng, accuracy: 6.0);
    return _cached;
  }

  double distanceMeters(AppLocation a, AppLocation b) {
    return _haversine(a.latitude, a.longitude, b.latitude, b.longitude);
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000.0;
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;
}

final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((_) => LocationService());