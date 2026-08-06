import 'package:crisismesh/models/triage_response.dart';
import 'package:crisismesh/services/gemma_service.dart';
import 'package:crisismesh/utils/phi_scrubber.dart';

abstract class TriageEngine {
  Future<TriageResponse> respond(String input, {bool isImage = false});
}

class LiteRTGemmaEngine implements TriageEngine {
  final GemmaService _gemmaService;

  LiteRTGemmaEngine(this._gemmaService);

  @override
  Future<TriageResponse> respond(String input, {bool isImage = false}) async {
    // Phase 1: PHI Scrubbing - remove PII before sending to model
    final sanitized = PhiScrubber.scrub(input);

    // Debug logging (only in debug builds)
    assert(() {
      if (sanitized.hasRedactions) {
        print('[PHI Scrubber] Redacted: ${sanitized.redactionSummary}');
        print('[PHI Scrubber] Clean text: ${sanitized.cleanText}');
      }
      return true;
    }());

    try {
      final response = await _gemmaService.chatResponse(
        text: sanitized.cleanText,
        hasImage: isImage,
      );

      return TriageResponse.fromJson(response);
    } catch (e) {
      return TriageResponse(
        reply: 'Error generating response: $e',
        chips: [
          const TriageChip(label: 'Retry', action: ChipAction.continue_),
        ],
        flagUrgent: false,
        inScope: true,
      );
    }
  }
}