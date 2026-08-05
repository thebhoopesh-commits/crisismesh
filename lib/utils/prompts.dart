// lib/utils/prompts.dart

import 'package:crisismesh/models/triage_response.dart'; // Import the newly created models

/// JSONSchema defined by TriageResponse DTO. 
/// This string must be used in both Dart's toJson() for validation and 
/// Kotlin's ConstrainedDecodingConfig builder. It ensures schema adherence 
/// at the hardware/runtime level (LiteRT + Mediapipe).
const String TRIAGE_JSON_SCHEMA = """
{
  "type": "object",
  "required": ["reply", "chips", "flag_urgent", "in_scope"],
  "properties": {
    "reply": {"description": "The concise verbal/textual assessment reply.", "type": "string"},
    "chips": {
      "description": "A list of structured follow-up suggestions for the operator.", 
      "type": "array", 
      "items": {
        "type": "object",
        "required": ["label", "action"],
        "properties": {
          "label": {"type": "string"},
          "action": {"type": "string", "enum": ["continue_","escalate","locate","dismiss"]}, 
          "payload": {"type": "object"} 
        }
      }
    },
    "flag_urgent": {"description": "Boolean indicating immediate life-threatening action required.", "type": "boolean"},
    "in_scope": {"description": "Confirms the condition type is within CrisisMesh's mandated scope.", "type": "boolean"}
  }
}
""";