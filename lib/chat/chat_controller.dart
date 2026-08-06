import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_message.dart';
import 'triage_engine.dart';
import '../models/triage_response.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final gemmaService = ref.read(gemmaServiceProvider);
  return ChatController(LiteRTGemmaEngine(gemmaService));
});

class ChatState {
  final List<ChatMessage> messages;
  final List<TriageChip> suggestionChips;
  final bool isTyping;

  ChatState({
    required this.messages,
    required this.suggestionChips,
    required this.isTyping,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<TriageChip>? suggestionChips,
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
          suggestionChips: [
            const TriageChip(label: 'Not breathing', action: ChipAction.continue_),
            const TriageChip(label: 'Bleeding', action: ChipAction.continue_),
            const TriageChip(label: 'Unconscious', action: ChipAction.continue_),
          ],
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
    final response = await _engine.respond(text, isImage: isImage);

    final aiMsg = ChatMessage(from: Sender.ai, text: response.reply);

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
      suggestionChips: response.chips,
    );
  }
}