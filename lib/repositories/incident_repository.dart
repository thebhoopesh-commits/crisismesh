import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';
import '../models/location.dart';
import '../services/gemma_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/mesh_service.dart';

/// 🗄️ Incident Repository — Unified Data Pipeline Layer.
///
/// Single source of truth. Orchestrates saving to the local DB,
/// classifying via Gemma, grabbing coordinates from the GPS service,
/// and broadcasting to peers via the mesh service.
class IncidentRepository {
  IncidentRepository({
    required GemmaService gemma,
    required DatabaseService database,
    required LocationService location,
    required MeshService mesh,
  })  : _gemma = gemma,
        _database = database,
        _location = location,
        _mesh = mesh;

  final GemmaService _gemma;
  final DatabaseService _database;
  final LocationService _location;
  final MeshService _mesh;

  Future<List<Incident>> bootstrapFeed() async {
    final List<Incident> cached = await _database.allIncidents();
    return cached;
  }

  Future<Incident?> classifyDraft({
    required String text,
    required bool hasImage,
  }) async {
    if (text.trim().isEmpty && !hasImage) return null;
    return _gemma.classifyTriage(text: text, hasImage: hasImage);
  }

  Future<Incident> commitDraft(Incident draft) async {
    final AppLocation? loc = await _location.current();
    final Incident withLocation = loc == null
        ? draft
        : draft.copyWith(
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
    await _database.save(withLocation);
    await _mesh.broadcast(withLocation);
    return withLocation;
  }
}

final Provider<IncidentRepository> incidentRepositoryProvider =
    Provider<IncidentRepository>((ref) {
  return IncidentRepository(
    gemma: ref.watch(gemmaServiceProvider),
    database: ref.watch(databaseServiceProvider),
    location: ref.watch(locationServiceProvider),
    mesh: ref.watch(meshServiceProvider),
  );
});