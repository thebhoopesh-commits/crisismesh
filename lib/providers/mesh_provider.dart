import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../services/mesh_service.dart';

/// 📡 Mesh Provider — Manages Peer Connection Node States.
///
/// UI consumers (e.g. MeshStatusHeader, MeshNetworkScreen) watch this to
/// render peer counts, signal strength, and live sync stats.

class MeshPeer {
  const MeshPeer({
    required this.id,
    required this.callsign,
    required this.role,
    required this.transport,
    required this.distance,
    required this.signalStrength,
    required this.batteryPercent,
    required this.angleRad,
    required this.radiusFraction,
  });

  final String id;
  final String callsign;
  final String role;
  final String transport; // BT / Wi-Fi Direct / LoRa
  final double distance;
  final int signalStrength; // 0-100
  final int batteryPercent; // 0-100
  final double angleRad; // position on radar
  final double radiusFraction; // 0-1

  Color get signalColor {
    if (signalStrength >= 70) return TacticalColors.offgridStatus;
    if (signalStrength >= 40) return TacticalColors.priorityYellow;
    return TacticalColors.priorityRed;
  }
}

class MeshSyncStats {
  const MeshSyncStats({
    required this.peers,
    required this.kbPerSecond,
    required this.syncsPerMinute,
  });

  final int peers;
  final double kbPerSecond;
  final int syncsPerMinute;
}

class MeshNotifier extends StateNotifier<List<MeshPeer>> {
  MeshNotifier(this._service) : super(_service.bootstrapPeers()) {
    _service.onPeersUpdated = (List<MeshPeer> peers) {
      state = List.from(peers);
    };
  }

  final MeshService _service;

  Future<void> rescan() async {
    state = await _service.rescan();
  }
}

final StateNotifierProvider<MeshNotifier, List<MeshPeer>> meshProvider =
    StateNotifierProvider<MeshNotifier, List<MeshPeer>>((ref) {
  final MeshService service = ref.watch(meshServiceProvider);
  return MeshNotifier(service);
});

/// Aggregate stats derived from the peer list — keeps UI widgets trivial.
final Provider<MeshSyncStats> meshSyncStatsProvider = Provider<MeshSyncStats>((ref) {
  final List<MeshPeer> peers = ref.watch(meshProvider);
  if (peers.isEmpty) {
    return const MeshSyncStats(peers: 0, kbPerSecond: 0, syncsPerMinute: 0);
  }
  final double avgSignal =
      peers.map((MeshPeer p) => p.signalStrength).reduce((a, b) => a + b) /
          peers.length;
  final double kbPerSecond = 0.4 + (avgSignal / 100) * 6.2;
  final int syncsPerMinute =
      math.max(2, (avgSignal / 10).round() + peers.length);
  return MeshSyncStats(
    peers: peers.length,
    kbPerSecond: kbPerSecond,
    syncsPerMinute: syncsPerMinute,
  );
});