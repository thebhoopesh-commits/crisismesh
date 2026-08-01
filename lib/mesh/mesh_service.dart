import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class MeshService extends ChangeNotifier {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String userName = "Responder Node";
  
  bool isAdvertising = false;
  bool isDiscovering = false;

  List<String> connectedPeers = [];
  Map<String, String> discoveredPeers = {}; // endpointId -> name

  Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    bool allGranted = true;
    statuses.forEach((key, value) {
      if (!value.isGranted) {
        allGranted = false;
        if (kDebugMode) print('Permission denied: $key');
      }
    });
    return allGranted;
  }

  Future<void> startMesh() async {
    bool hasPerms = await checkAndRequestPermissions();
    if (!hasPerms) {
      if (kDebugMode) print("Permissions not granted for Mesh Networking");
      return;
    }

    try {
      await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      isAdvertising = true;
      notifyListeners();
      
      await startDiscovery();
    } catch (e) {
      if (kDebugMode) print("Error starting advertiser: $e");
    }
  }

  Future<void> startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (endpointId, name, serviceId) {
          discoveredPeers[endpointId] = name;
          notifyListeners();
          
          Nearby().requestConnection(
            userName,
            endpointId,
            onConnectionInitiated: _onConnectionInit,
            onConnectionResult: _onConnectionResult,
            onDisconnected: _onDisconnected,
          );
        },
        onEndpointLost: (endpointId) {
          discoveredPeers.remove(endpointId);
          notifyListeners();
        },
      );
      isDiscovering = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error starting discovery: $e");
    }
  }

  void _onConnectionInit(String endpointId, ConnectionInfo info) {
    Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES) {
          String message = String.fromCharCodes(payload.bytes!);
          if (kDebugMode) print("Received payload from $endpointId: $message");
        }
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      if (!connectedPeers.contains(endpointId)) {
        connectedPeers.add(endpointId);
      }
      notifyListeners();
    } else if (status == Status.REJECTED || status == Status.ERROR) {
      connectedPeers.remove(endpointId);
      notifyListeners();
    }
  }

  void _onDisconnected(String endpointId) {
    connectedPeers.remove(endpointId);
    discoveredPeers.remove(endpointId);
    notifyListeners();
  }

  Future<void> broadcastData(Map<String, dynamic> data) async {
    final payload = Payload.forBytes(utf8.encode(jsonEncode(data)));
    for (String endpointId in connectedPeers) {
      await Nearby().sendPayload(payload, endpointId);
    }
  }

  Future<void> stopMesh() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints();
    isAdvertising = false;
    isDiscovering = false;
    connectedPeers.clear();
    discoveredPeers.clear();
    notifyListeners();
  }
}
