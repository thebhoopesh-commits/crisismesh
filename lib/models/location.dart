/// 🌍 AppLocation — GPS Lat/Lng Data Class.
///
/// Plain data shape shared between the location service, mesh service,
/// and the incident repository's commit pipeline.
class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
    this.altitude = 0,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;

  @override
  String toString() =>
      'AppLocation(lat=$latitude, lng=$longitude, acc=$accuracy)';
}