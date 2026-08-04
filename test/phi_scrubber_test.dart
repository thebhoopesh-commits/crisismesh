import 'package:test/test.dart';
import 'package:crisismesh/utils/phi_scrubber.dart';

void main() {
  group('PhiScrubber', () {
    test('basic name + phone + address', () {
      final input = "Sarah Johnson, 555-0199, chest pain at 123 Main St";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("[NAME], [PHONE], chest pain at [ADDRESS]"));
      expect(result.redactionCount, equals(3));
      expect(result.redactionMap["Sarah Johnson"], equals("[NAME]"));
      expect(result.redactionMap["555-0199"], equals("[PHONE]"));
      expect(result.redactionMap["123 Main St"], equals("[ADDRESS]"));
    });

    test('preserves clinical terms', () {
      final input = "BP 180/120, HR 110, temp 102.5, chest pain";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals(input)); // no changes
      expect(result.hasRedactions, isFalse);
    });

    test('preserves "Patient" but scrubs name after', () {
      final input = "Patient John Doe";
      final result = PhiScrubber.scrub(input);
      
      // "Patient" is not capitalized as a name start in our regex, "John Doe" is
      expect(result.cleanText, contains("Patient"));
      expect(result.cleanText, contains("[NAME]"));
    });

    test('handles DOB', () {
      final input = "My DOB 03/15/1980, allergic to penicillin";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("My [DATE], allergic to penicillin"));
    });

    test('handles email', () {
      final input = "Contact dr.smith@hospital.edu for records";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("Contact [EMAIL] for records"));
    });

    test('handles SSN', () {
      final input = "SSN: 123-45-6789";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("SSN: [SSN]"));
    });

    test('handles MRN', () {
      final input = "MRN: A1B2C3D4";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("[MRN]"));
    });

    test('handles UK phone', () {
      final input = "Call +44 20 7946 0958";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("Call [PHONE]"));
    });

    test('handles AU phone', () {
      final input = "Call 04 1234 5678";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("Call [PHONE]"));
    });

    test('handles ZIP codes', () {
      final input = "ZIP 90210 and V5K 0A1 and SW1A 1AA and 2000";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("ZIP [ZIP] and [ZIP] and [ZIP] and [ZIP]"));
    });

    test('empty input', () {
      final result = PhiScrubber.scrub("");
      expect(result.cleanText, equals(""));
      expect(result.hasRedactions, isFalse);
    });

    test('scrubPhi convenience function', () {
      final clean = scrubPhi("John Doe 555-1234");
      expect(clean, equals("[NAME] [PHONE]"));
    });

    test('redactionSummary groups by type', () {
      final input = "John Doe, Jane Smith, 555-1111, 555-2222";
      final result = PhiScrubber.scrub(input);
      
      expect(result.redactionSummary["name"], equals(2));
      expect(result.redactionSummary["phone"], equals(2));
    });

    test('preserves drug names', () {
      final input = "Taking lisinopril and metformin";
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals(input));
    });

    test('handles overlapping patterns - MRN before SSN', () {
      // MRN pattern is more specific, should match first
      final input = "MRN: 1234567890"; // Could also match generic SSN
      final result = PhiScrubber.scrub(input);
      
      expect(result.cleanText, equals("[MRN]"));
      expect(result.matches.any((m) => m.type == "mrn"), isTrue);
    });
  });
}
