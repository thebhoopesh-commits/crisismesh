import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import 'help_request.dart';
import 'pin_marker.dart';
import 'detail_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<HelpRequest> _dummyRequests = [
    HelpRequest(
      id: '1',
      name: 'Maria L.',
      condition: 'Trapped under debris — leg injury, conscious',
      distance: '120 m',
      reportedAgo: '2m ago',
      hops: 2,
      severity: Severity.critical,
      position: const LatLng(37.7749, -122.4194),
    ),
    HelpRequest(
      id: '2',
      name: 'Sam K.',
      condition: 'Deep laceration, bleeding controlled',
      distance: '90 m',
      reportedAgo: '5m ago',
      hops: 1,
      severity: Severity.urgent,
      position: const LatLng(37.7752, -122.4180),
    ),
    HelpRequest(
      id: '3',
      name: 'Family of 4',
      condition: 'Sheltering in place, no injuries',
      distance: '150 m',
      reportedAgo: '10m ago',
      hops: 3,
      severity: Severity.stable,
      position: const LatLng(37.7735, -122.4185),
    ),
  ];

  void _showDetailSheet(HelpRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DetailSheet(request: req),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(37.7749, -122.4194),
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.crisismesh',
                // Mocking flutter_map_tile_caching for now
              ),
              MarkerLayer(
                markers: _dummyRequests.map((req) {
                  return Marker(
                    point: req.position,
                    width: 50,
                    height: 50,
                    child: PinMarker(
                      severity: req.severity,
                      onTap: () => _showDetailSheet(req),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Badge: "Offline map · cached"
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done_outlined, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text('Offline map · cached', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        onPressed: () {
          // TODO: locate me with geolocator
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
