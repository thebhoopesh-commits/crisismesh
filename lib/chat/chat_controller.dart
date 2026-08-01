import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_message.dart';
import 'triage_engine.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(LiteRTGemmaEngine());
});

class ChatState {
  final List<ChatMessage> messages;
  final List<String> suggestionChips;
  final bool isTyping;

  ChatState({
    required this.messages,
    required this.suggestionChips,
    required this.isTyping,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<String>? suggestionChips,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      suggestionChips: suggestionChips ?? this.suggestionChips,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final TriageEngine _engine;

  ChatController(this._engine)
      : super(ChatState(
          messages: [
            ChatMessage(
              from: Sender.ai,
              text: 'Emergency Triage active. Describe the injury or send a photo.',
            )
          ],
          suggestionChips: ['Not breathing', 'Bleeding', 'Unconscious'],
          isTyping: false,
        ));

  Future<void> sendMessage(String text, {bool isImage = false}) async {
    // Add user message
    final userMsg = ChatMessage(from: Sender.me, text: text, isImage: isImage);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      suggestionChips: [],
    );

    // Get response from engine
    final String prompt = isImage ? "I just uploaded an image but you cannot see it. Ask me to describe the injury." : text;
    final response = await _engine.respond(prompt);
    final String aiReplyText = response.$1;
    final List<String> nextChips = response.$2;

    final aiMsg = ChatMessage(from: Sender.ai, text: aiReplyText);
    
    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
      suggestionChips: nextChips,
    );
  }
}

