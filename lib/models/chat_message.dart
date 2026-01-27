class ChatMessage {
  final String text;
  final String role; // ← NEW: "user" or "model"
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });

  bool get isUserMessage => role == "user";
}