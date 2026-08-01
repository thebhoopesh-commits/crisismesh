import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';
import '../repositories/incident_repository.dart';

/// 🗂️ Triage Provider — owns the priority feed state and sort order.
///
/// UI widgets consume this directly to render the dashboard feed.
/// Sorting defaults to priority (RED pinned to top).
class TriageNotifier extends StateNotifier<List<Incident>> {
  TriageNotifier(this._repository) : super(const <Incident>[]) {
    _init();
  }

  final IncidentRepository _repository;

  Future<void> _init() async {
    final List<Incident> feed = await _repository.bootstrapFeed();
    state = feed..sort(_compareByPriority);
  }

  Future<Incident?> classifyDraft({
    required String text,
    required bool hasImage,
  }) {
    return _repository.classifyDraft(
      text: text,
      hasImage: hasImage,
    );
  }

  Future<Incident> confirmDraft(Incident draft) async {
    final Incident saved = await _repository.commitDraft(draft);
    state = <Incident>[saved, ...state]..sort(_compareByPriority);
    return saved;
  }

  void markDispatched(String id) {
    state = <Incident>[
      for (final Incident i in state)
        if (i.id == id) i.copyWith(status: IncidentStatus.dispatched) else i,
    ];
  }

  void markResolved(String id) {
    state = state.where((Incident i) => i.id != id).toList(growable: false);
  }

  void seed(List<Incident> incoming) {
    if (incoming.isEmpty) return;
    final Map<String, Incident> map = <String, Incident>{
      for (final Incident i in state) i.id: i,
    };
    for (final Incident i in incoming) {
      map[i.id] = i;
    }
    state = map.values.toList(growable: false)..sort(_compareByPriority);
  }

  static int _compareByPriority(Incident a, Incident b) {
    final int p = a.priority.sortRank.compareTo(b.priority.sortRank);
    if (p != 0) return p;
    return b.createdAt.compareTo(a.createdAt);
  }
}

final StateNotifierProvider<TriageNotifier, List<Incident>> triageProvider =
    StateNotifierProvider<TriageNotifier, List<Incident>>((ref) {
  final IncidentRepository repo = ref.watch(incidentRepositoryProvider);
  return TriageNotifier(repo);
});

/// Sort order for the priority feed.
enum TriageSort { priority, time }

class TriageSortNotifier extends StateNotifier<TriageSort> {
  TriageSortNotifier() : super(TriageSort.priority);

  void toggle() {
    state = state == TriageSort.priority ? TriageSort.time : TriageSort.priority;
  }
}

final StateNotifierProvider<TriageSortNotifier, TriageSort> triageSortProvider =
    StateNotifierProvider<TriageSortNotifier, TriageSort>(
        (ref) => TriageSortNotifier());

/// Reactive list of priority-sorted incidents.
final Provider<List<Incident>> sortedIncidentsProvider =
    Provider<List<Incident>>((ref) {
  final List<Incident> incidents = ref.watch(triageProvider);
  final TriageSort sort = ref.watch(triageSortProvider);
  final List<Incident> copy = <Incident>[...incidents];
  copy.sort((a, b) {
    if (sort == TriageSort.priority) {
      final int p = a.priority.sortRank.compareTo(b.priority.sortRank);
      if (p != 0) return p;
    }
    return b.createdAt.compareTo(a.createdAt);
  });
  return copy;
});

/// Lookup a single incident by id.
final incidentByIdProvider =
    Provider.family<Incident?, String>((ref, id) {
  final List<Incident> incidents = ref.watch(triageProvider);
  for (final Incident i in incidents) {
    if (i.id == id) return i;
  }
  return null;
});
