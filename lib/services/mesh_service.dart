import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident.dart';
import '../models/triage_response.dart'; // Import TriageResponse

/// 📡 Mesh Service — Real P2P Off-Grid Sync Engine (Bluetooth / Wi-Fi Direct).
class MeshService {
  MeshService({math.Random? rng}) : _rng = rng ?? math.Random();
  final math.Random _rng;

  final String userName = \"Node-${math.Random().nextInt(1000)}\";
  final Strategy strategy = Strategy.P2P_CLUSTER;

  final Map<String, MeshPeer> _peers = {};

  Function(List<MeshPeer>)? onPeersUpdated;
  // Update signature to handle detailed payloads if necessary, or assume a structured string input for simplicity here.
  Function(dynamic payload) onMessageReceived; 
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // ... (rest of initialization logic remains the same) ...

    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    try {
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();
      await Nearby().stopAllEndpoints();
      await Future.delayed(const Duration(milliseconds: 500));

      bool a = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: \"com.example.crisismesh\",
      );

      bool d = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: \"com.example.crisismesh\",
      );
      print(\"📡 Mesh Initialized. Advertising: $a, Discovering: $d\");
    } catch (e) {
      print(\"📡 Mesh Error: $e\");
    }
  }

  // ... (rest of _onEndpointFound, _onEndpointLost, connection handlers remain the same) ...

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    print(\"📡 Mesh: Connection initiated with ${info.endpointName} ($id). Accepting...\");
    Nearby().acceptConnection(
      id,
      onPayloadRecieved: (endpointId, payload) {
        // Update payload handling to accept structured types if possible, or process raw bytes/string
        if (payload is String) {
          print(\"📡 Mesh: Received text payload from $endpointId: $payload\");
          onMessageReceived?.call(payload);
        } else if (payload.type == PayloadType.BYTES) {
           // Assume the full structured JSON response will be sent as bytes/string encoded
          String text = utf8.decode(payload.bytes!);
          print(\"📡 Mesh: Received raw payload from $endpointId: $text\");
          onMessageReceived?.call(text);
        }
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
    );
  }

  // ... (rest of _onConnectionResult and _onDisconnected remain the same) ...


  /// 📡 Broadcasts a structured triage report across connected mesh peers.
  /// The data is serialized into a JSON string to ensure cross-platform readability/parsing.
  Future<int> broadcast(TriageResponse response) async {
    // Serialize TriageResponse to JSON map, then convert that map to a JSON string.
    final Map<String, dynamic> payloadData = response.toJson();
    final String jsonPayload = jsonEncode(payloadData);

    int count = 0;
    for (String id in _peers.keys) {
      print(\"📡 Mesh: Broadcasting structured triage data to $id... Payload: $jsonPayload\");
      try {
        // Send a simple string payload encoding the entire TriageResponse JSON
        Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonPayload))); 
        count++;
      } catch (e) {
        print(\"📡 Mesh Error broadcasting to $id: $e\");
      }
    }
    return count;
  }
}

final Provider<MeshService> meshServiceProvider =
    Provider<MeshService>((_) => MeshService());