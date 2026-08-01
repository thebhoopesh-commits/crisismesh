import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/incident.dart';
import '../providers/mesh_provider.dart' show MeshPeer;

/// 📡 Mesh Service — Real P2P Off-Grid Sync Engine (Bluetooth / Wi-Fi Direct).
class MeshService {
  MeshService({math.Random? rng}) : _rng = rng ?? math.Random();
  final math.Random _rng;
  
  final String userName = "Node-${math.Random().nextInt(1000)}";
  final Strategy strategy = Strategy.P2P_CLUSTER;
  
  final Map<String, MeshPeer> _peers = {};
  
  Function(List<MeshPeer>)? onPeersUpdated;
  Function(String text)? onMessageReceived;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Request all necessary permissions for Nearby Connections
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
        serviceId: "com.example.crisismesh",
      );

      bool d = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: "com.example.crisismesh",
      );
      print("📡 Mesh Initialized. Advertising: $a, Discovering: $d");
    } catch (e) {
      print("📡 Mesh Error: $e");
    }
  }

  void _onEndpointFound(String id, String name, String serviceId) {
    print("📡 Mesh: Found endpoint $name ($id). Requesting connection...");
    Nearby().requestConnection(
      userName,
      id,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
  }

  void _onEndpointLost(String? id) {
    if (id == null) return;
    print("📡 Mesh: Lost endpoint $id");
    _peers.remove(id);
    onPeersUpdated?.call(_peers.values.toList());
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    print("📡 Mesh: Connection initiated with ${info.endpointName} ($id). Accepting...");
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES) {
          String text = utf8.decode(payload.bytes!);
          print("📡 Mesh: Received payload from $endpointId: $text");
          onMessageReceived?.call(text);
        }
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
    );
  }

  void _onConnectionResult(String id, Status status) {
    print("📡 Mesh: Connection result for $id: $status");
    if (status == Status.CONNECTED) {
      _peers[id] = MeshPeer(
        id: id,
        callsign: "Node-${id.substring(0, 4)}",
        role: "Relay",
        transport: "Wi-Fi Direct",
        distance: 20 + _rng.nextInt(100).toDouble(),
        signalStrength: 75 + _rng.nextInt(25), // Strong signal for connected peer
        batteryPercent: 40 + _rng.nextInt(60),
        angleRad: _rng.nextDouble() * 2 * math.pi,
        radiusFraction: 0.2 + _rng.nextDouble() * 0.4,
      );
      onPeersUpdated?.call(_peers.values.toList());
    }
  }

  void _onDisconnected(String id) {
    print("📡 Mesh: Disconnected from $id");
    _peers.remove(id);
    onPeersUpdated?.call(_peers.values.toList());
  }

  List<MeshPeer> bootstrapPeers() {
    return _peers.values.toList();
  }

  Future<List<MeshPeer>> rescan() async {
    Nearby().stopDiscovery();
    await Future.delayed(const Duration(milliseconds: 500));
    await Nearby().startDiscovery(
      userName,
      strategy,
      onEndpointFound: _onEndpointFound,
      onEndpointLost: _onEndpointLost,
      serviceId: "com.example.crisismesh",
    );
    return _peers.values.toList();
  }

  Future<int> broadcast(Incident incident) async {
    int count = 0;
    for (String id in _peers.keys) {
      print("📡 Mesh: Broadcasting to $id...");
      try {
        Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(incident.summary)));
        count++;
      } catch (e) {
        print("📡 Mesh Error broadcasting to $id: $e");
      }
    }
    return count;
  }
}

final Provider<MeshService> meshServiceProvider =
    Provider<MeshService>((_) => MeshService());