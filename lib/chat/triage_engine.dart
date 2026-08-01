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
      final prompt = "You are an AI medical assistant offline triage bot. Keep your answers extremely short and concise, providing only emergency actionable advice.\n\nUser: $input\nAI:";
      final String aiReplyText = await platform.invokeMethod('generateResponse', {
        'prompt': prompt
      });
      return (aiReplyText, <String>['Need more info', 'Thanks']);
    } catch (e) {
      return ("Error generating response: $e", <String>[]);
    }
  }
}
