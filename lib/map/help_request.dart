import 'package:latlong2/latlong.dart';

enum Severity { critical, urgent, stable }

class HelpRequest {
  final String id;
  final String name;
  final String condition;
  final String distance;
  final String reportedAgo;
  final int hops;
  final Severity severity;
  final LatLng position;

  HelpRequest({
    required this.id,
    required this.name,
    required this.condition,
    required this.distance,
    required this.reportedAgo,
    required this.hops,
    required this.severity,
    required this.position,
  });
}
