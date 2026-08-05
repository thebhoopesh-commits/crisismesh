import 'package:flutter_test/flutter_test.dart';
import 'package:crisismesh/models/triage_response.dart'; // The DTO we created

void main() {
  group('TriageResponse DTO Unit Tests', () {
    // Test 1: Basic TriageChip deserialization and structure
    test('TriageChip factory can deserialize complex JSON inputs', () {
      // Simulate the maximum complexity: action, payload, and label
      final jsonMap = {
        'label': 'LOCATE_AND_SECURE', // Unique identifier on UI
        'action': 'locate',         // Must match enum name
        'payload': {'area': 'hospital', 'sector': 4} // Type-safe additional context
      };
      final chip = TriageChip.fromJson(jsonMap);

      expect(chip.label, 'LOCATE_AND_SECURE');
      expect(chip.action, ChipAction.locate);
      expect(chip.payload!['area'], 'hospital');
    });
    
    // Test 2: Full TriageResponse Roundtrip serialization and deserialization
    test('TriageResponse DTO can serialize to clean internal map', () {
      final chip1 = TriageChip(label: "CPR", action: ChipAction.continue_);
      final chip2 = TriageChip(label: "Get help NOW!", action: ChipAction.escalate, payload: {'call_number': 911});

      final originalResponse = TriageResponse(
        reply: "Apply deep, regular compressions.",
        chips: [chip1, chip2],
        flagUrgent: true,
        inScope: true,
      );

      // Check the internal Dart representation via toJson()
      final mockJson = originalResponse.toJson(); 

      // Simulate reading/deserializing this map back from network input (from Gemma Service)
      final TriageResponse reconstructedResponse = TriageResponse.fromJson(mockJson);

      // Assertions on reconstruction to ensure data integrity
      expect(reconstructedResponse.reply, 'Apply deep, regular compressions.');
      expect(reconstructedResponse.flagUrgent, isTrue);
      expect(reconstructedResponse.chips.length, 2);
      
      // Check the escalated chip's state was preserved during roundtrip
      final restoredChip2 = reconstructedResponse.chips[1];
      expect((restoredChip2 as TriageChip).action, ChipAction.escalate);
    });

    // Test 3: Handling of default/edge cases (missing data)
    test('TriageResponse handles partial JSON input gracefully', () {
      final jsonMap = {
        'reply': "Initial assessment.",
        // Note: 'chips', 'flag_urgent', and 'in_scope' are missing or null in this test scenario.
        'chips': [], // Empty list provided explicitly
        'flag_urgent': false, // Explicitly set to default/safer value
      };

      final TriageResponse response = TriageResponse.fromJson(jsonMap);

      expect(response.reply, 'Initial assessment.');
      expect(response.chips, isEmpty); 
      expect(response.flagUrgent, isFalse);
    });
  });
}