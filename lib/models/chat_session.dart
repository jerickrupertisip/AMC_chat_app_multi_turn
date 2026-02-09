import 'package:chat_ui_lab/models/chat_message.dart';
import 'package:chat_ui_lab/services/gemini_service.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatSession {
  final String title;
  final List<ChatMessage> messages;
  final int persona_id;

  String get personaInstruction =>
      GeminiService.personas[persona_id].instruction;
  String get personaName =>
      GeminiService.personas[persona_id].name;

  List<ChatMessage> get visibleMessages => messages.where((m) {
    return !m.isInstruction;
  }).toList();

  ChatSession({
    required this.title,
    required this.messages,
    required this.persona_id,
  });

  void removeErrorMessages() {
    messages.removeWhere((element) {
      return element.isError;
    });
  }

  void addTemporaryMessage(String text, String role) {
    messages.add(ChatMessage(text: text, role: role));
  }

  void removeMessageInstruction() {
    messages.removeWhere((element) {
      return element.isInstruction;
    });
  }

  void addAIInstruction() {
    var content = ChatMessage(
      text: personaInstruction,
      role: "user",
      isInstruction: true,
    );
    messages.add(content);
  }

  void addUserMessage(String message) {
    var content = ChatMessage(text: message, role: "user");
    messages.add(content);
  }

  void addErrorMessage(String message) {
    var content = ChatMessage.fromParts(
      role: "model",
      parts: [TextPart(personaInstruction), TextPart(message)],
      isError: true,
    );
    messages.add(content);
  }

  void addAIMessage(Content content) {
    ChatMessage msg = ChatMessage.fromContent(content: content);
    messages.add(msg);
  }
}
