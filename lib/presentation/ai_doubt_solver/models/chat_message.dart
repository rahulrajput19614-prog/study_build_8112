// lib/presentation/ai_doubt_solver/models/chat_message.dart

/// Simple model class for chat messages in AI Doubt Solver.
class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({
    required this.message,
    required this.isUser,
  });
}
