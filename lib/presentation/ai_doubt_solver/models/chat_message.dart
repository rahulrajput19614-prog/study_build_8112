class ChatMessage {
  final String text;        // message text
  final bool isUser;        // user ne bheja ya AI ne
  final bool isError;       // error message hai ya nahi
  final DateTime timestamp; // kab bheja gaya

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
