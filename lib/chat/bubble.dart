import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.from == Sender.me;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4), // 4px tail corner
            bottomRight: Radius.circular(isMe ? 4 : 16), // 4px tail corner
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildContent(context, isMe),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMe) {
    if (message.isImage) {
      return Container(
        height: 150,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey),
        ),
      );
    }
    
    return Text(
      message.text,
      style: TextStyle(
        color: isMe ? Colors.white : AppColors.text,
        fontSize: 16,
      ),
    );
  }
}
