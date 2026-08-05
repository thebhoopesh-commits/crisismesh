import 'package:flutter/foundation.dart';

// Enum defines actionable types for suggestions/chips
enum ChipAction { continue_, escalate, locate, dismiss }

/// TriageChip represents a single, tappable suggestion button in the UI.
@immutable
class TriageChip {
  final String label;              // Display text (e.g., "Started compressions")
  final ChipAction action;         // Defines what happens when tapped
  final Map<String, dynamic>? payload;// Optional data needed for the action (e.g., user ID, resource type)

  const TriageChip({
    required this.label,
    this.action = ChipAction.continue_,
    this.payload,
  });

  // Factory constructor to deserialize from JSON (used after GemmaService call)
  factory TriageChip.fromJson(Map<String, dynamic> json) {
    return TriageChip(
      label: json['label'] as String? ?? '',
      action: ChipAction.values.byName(json['action'] as String? ?? 'continue'),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  // Method to serialize the object for network/mesh broadcast (Dart-side JSON)
  Map<String, dynamic> toJson() => {
        'label': label,
        'action': action.name, // Use enum name string for serialization compatibility
        if (payload != null) 'payload': payload,
      };
}


/// TriageResponse is the full, type-safe object containing model output 
/// from Gemma, representing a complete state of the current triage assessment.
@immutable
class TriageResponse {
  final String reply;            // The main textual summary response (e.g., "Apply direct pressure.")
  final List<TriageChip> chips; // Structured follow-up suggestions/chips
  final bool flagUrgent;         // True if immediate emergency action required
  final bool inScope;            // True if the condition falls within our app's scope

  const TriageResponse({
    required this.reply,
    required this.chips,
    required this.flagUrgent,
    required this.inScope,
  });

  // Factory constructor for deserializing JSON output from the AI model (via const-decode)
  factory TriageResponse.fromJson(Map<String, dynamic> json) {
    return TriageResponse(
      reply: json['reply'] as String? ?? '',
      chips: (json['chips'] as List<dynamic>?)
              ?.map((c) => TriageChip.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      flagUrgent: json['flag_urgent'] as bool? ?? false,
      inScope: json['in_scope'] as bool? ?? true,
    );
  }

  // Method to serialize the object for external systems (e.g., Mesh broadcast)
  Map<String, dynamic> toJson() => {
        'reply': reply,
        'chips': chips.map((c) => c.toJson()).toList(),
        'flag_urgent': flagUrgent,
        'in_scope': inScope,
      };
}