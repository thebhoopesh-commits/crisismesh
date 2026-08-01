enum Sender { ai, me }

class ChatMessage {
  final Sender from;
  final String text;
  final bool isImage;

  ChatMessage({
    required this.from,
    required this.text,
    this.isImage = false,
  });
}
