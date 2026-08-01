import '../app_theme.dart';
import 'package:flutter/material.dart';

/// 🚦 Triage Priority — RED / YELLOW / GREEN status with color tokens.
///
/// The single source of priority data across the UI. All widgets read
/// `color` and `sortRank` from here so the badge, map pin, and card stripe
/// stay in sync.
enum TriagePriority {
  red,
  yellow,
  green;

  Color get color {
    switch (this) {
      case TriagePriority.red:
        return TacticalColors.priorityRed;
      case TriagePriority.yellow:
        return TacticalColors.priorityYellow;
      case TriagePriority.green:
        return TacticalColors.priorityGreen;
    }
  }

  int get sortRank {
    switch (this) {
      case TriagePriority.red:
        return 0;
      case TriagePriority.yellow:
        return 1;
      case TriagePriority.green:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case TriagePriority.red:
        return 'RED';
      case TriagePriority.yellow:
        return 'YELLOW';
      case TriagePriority.green:
        return 'GREEN';
    }
  }
}

/// Lifecycle of an incident in the field.
enum IncidentStatus {
  draft,
  active,
  dispatched,
  resolved;

  String get label {
    switch (this) {
      case IncidentStatus.draft:
        return 'DRAFT';
      case IncidentStatus.active:
        return 'ACTIVE';
      case IncidentStatus.dispatched:
        return 'DISPATCHED';
      case IncidentStatus.resolved:
        return 'RESOLVED';
    }
  }
}

/// 🚨 Incident — Unified Triage & Patient Incident Model.
///
/// Immutable data contract. Mutations always return a new instance via
/// [[copyWith]] to keep Riverpod state diffing straightforward.
class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.summary,
    required this.priority,
    required this.status,
    required this.locationLabel,
    required this.createdAt,
    required this.notes,
    required this.supplies,
    required this.vitals,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final String summary;
  final TriagePriority priority;
  final IncidentStatus status;
  final String locationLabel;
  final DateTime createdAt;
  final String notes;
  final List<String> supplies;
  final Map<String, String> vitals;
  final double? latitude;
  final double? longitude;

  Incident copyWith({
    String? id,
    String? title,
    String? summary,
    TriagePriority? priority,
    IncidentStatus? status,
    String? locationLabel,
    DateTime? createdAt,
    String? notes,
    List<String>? supplies,
    Map<String, String>? vitals,
    double? latitude,
    double? longitude,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      locationLabel: locationLabel ?? this.locationLabel,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      supplies: supplies ?? this.supplies,
      vitals: vitals ?? this.vitals,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String get relativeTime {
    final Duration delta = DateTime.now().difference(createdAt);
    if (delta.inSeconds < 60) return '${delta.inSeconds}s ago';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}