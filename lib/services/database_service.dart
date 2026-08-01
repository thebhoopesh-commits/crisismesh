import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';

/// 💾 Database Service — Offline Persistent DB (Hive / Isar / SQLite).
///
/// In-memory implementation that mirrors the API the storage layer
/// will eventually expose. Swap with Hive/Isar once persistence is wired.
class DatabaseService {
  DatabaseService() : _store = <String, Incident>{};

  final Map<String, Incident> _store;

  Future<List<Incident>> allIncidents() async {
    final List<Incident> list = _store.values.toList(growable: false);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> save(Incident incident) async {
    _store[incident.id] = incident;
  }

  Future<Incident?> get(String id) async => _store[id];

  Future<void> delete(String id) async {
    _store.remove(id);
  }
}

final Provider<DatabaseService> databaseServiceProvider =
    Provider<DatabaseService>((_) => DatabaseService());