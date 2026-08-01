import 'package:intl/intl.dart';

import '../models/location.dart';

/// 🛠️ Helpers — Formatters & Coordinate Math.
///
/// Stateless utility functions used across screens and widgets.

/// Formats an ISO date string into a short tactical timestamp.
String formatTacticalTime(DateTime dt) {
  return DateFormat('MMM d • HH:mm:ss').format(dt.toLocal());
}

/// Returns `°N/S/E/W` formatted GPS coordinate.
String formatCoordinate(double value, {required bool isLatitude}) {
  final String suffix = isLatitude
      ? (value >= 0 ? 'N' : 'S')
      : (value >= 0 ? 'E' : 'W');
  return '${value.abs().toStringAsFixed(5)}° $suffix';
}

/// Formats an [AppLocation] into a one-line coordinate string.
String formatLocation(AppLocation loc) {
  return '${formatCoordinate(loc.latitude, isLatitude: true)}'
      '  ${formatCoordinate(loc.longitude, isLatitude: false)}';
}

/// Truncates a string with an ellipsis if it exceeds [max].
String truncate(String input, {int max = 80}) {
  if (input.length <= max) return input;
  return '${input.substring(0, max)}…';
}

/// Returns a stable hash for a string — used to position markers on the
/// offline map widget without a real geo projection.
int stableHash(String input) {
  int hash = 5381;
  for (int i = 0; i < input.length; i++) {
    hash = ((hash << 5) + hash + input.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return hash;
}
