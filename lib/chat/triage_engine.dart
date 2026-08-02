import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

abstract class TriageEngine {
  Future<(String, List<String>)> respond(String input);
}

class LiteRTGemmaEngine implements TriageEngine {
  static const platform = MethodChannel('com.crisismesh.ai');
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final result = await platform.invokeMethod('initGemma');
      if (result == true) {
        _isInitialized = true;
      }
    } catch (e) {
      print("Failed to initialize Gemma LiteRT: $e");
    }
  }

  @override
  Future<(String, List<String>)> respond(String input) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final prompt = '''<start_of_turn>user
You are CrisisMesh-AI, an expert emergency medical triage assistant operating entirely offline during a disaster.
Your objective is to provide immediate, life-saving, and practical first-aid instructions based on the emergency report.
Rules:
1. Be extremely concise, authoritative, and calm.
2. Provide step-by-step actionable survival advice.
3. If the situation is life-threatening (e.g., arterial bleeding, cardiac arrest, severe burns), state "CRITICAL EMERGENCY" at the very beginning.
4. Assume hospitals are inaccessible. Provide the best possible field-expedient medical advice.
5. Do not use filler words or pleasantries.

Emergency Report: $input<end_of_turn>
<start_of_turn>model
''';
      final String aiReplyText = await platform.invokeMethod('generateResponse', {
        'prompt': prompt
      });
      return (aiReplyText, <String>['Need more info', 'Thanks']);
    } catch (e) {
      return ("Error generating response: $e", <String>[]);
    }
  }
}
