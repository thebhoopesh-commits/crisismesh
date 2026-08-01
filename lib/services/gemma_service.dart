import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import '../utils/prompts.dart';

final gemmaServiceProvider = Provider<GemmaService>((ref) {
  return GemmaService();
});

class GemmaService {
  bool _initialized = false;
  bool get isReady => _initialized;

  Future<void> initialize({
    required Function(int, String) onProgress,
  }) async {
    print("AI DEBUG: Setting model path...");
    const String modelPath = '/data/data/com.example.crisismesh/files/model.litertlm';
    
    print("AI DEBUG: Calling FlutterGemma.installModel...");
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.litertlm,
    ).fromFile(modelPath).install();

    print("AI DEBUG: Install finished!");
    _initialized = true;
  }

  Future<Map<String, dynamic>> chatResponse({
    required String text,
    required bool hasImage,
  }) async {
    if (!_initialized) {
      throw StateError('GemmaService not initialized');
    }

    final String prompt = triageUserPrompt(text: text, hasImage: hasImage);
    final String fullPrompt = triageSystemPrompt + "\n\n" + prompt;

    // Call the actual on-device Gemma LLM!
    print("AI DEBUG: Getting active model...");
    final model = await FlutterGemma.getActiveModel(maxTokens: 512); // Reduced from 1024 for speed
    print("AI DEBUG: Creating session...");
    final session = await model.createSession();
    print("AI DEBUG: Adding query chunk...");
    await session.addQueryChunk(Message(text: fullPrompt, isUser: true));
    print("AI DEBUG: Getting response...");
    final String rawResponse = await session.getResponse();
    print("AI DEBUG: Response received: $rawResponse");

    try {
      String cleanJson = rawResponse;
      if (cleanJson.contains('```json')) {
        cleanJson = cleanJson.split('```json')[1].split('```')[0].trim();
      } else if (cleanJson.contains('```')) {
        cleanJson = cleanJson.split('```')[1].split('```')[0].trim();
      }

      final Map<String, dynamic> parsed = jsonDecode(cleanJson);
      
      return {
        "reply": parsed['reply'] ?? "I have logged this information.",
        "chips": List<String>.from(parsed['chips'] ?? ["Continue"]),
        "flag_urgent": parsed['flag_urgent'] ?? false,
        "in_scope": parsed['in_scope'] ?? true
      };
    } catch (e) {
      return {
        "reply": "Error generating response.",
        "chips": ["Retry"],
        "flag_urgent": false,
        "in_scope": true
      };
    }
  }
}