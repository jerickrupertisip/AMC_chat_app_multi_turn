import "package:chat_ui_lab/models/chat_message.dart";
import "package:chat_ui_lab/services/gemini_service.dart";
import "package:flutter_gemini/flutter_gemini.dart";

class ChatSession {
  String title;
  bool generateNewTitle = true;
  final List<ChatMessage> messages;
  final int personaID;
  int sessionID;

  String get personaInstruction =>
      GeminiService.personas[personaID].instruction;

  String get personaName => GeminiService.personas[personaID].name;

  bool get hasTitle => title.isNotEmpty;

  List<ChatMessage> get visibleMessages => messages.where((m) {
    return !m.isInstruction;
  }).toList();

  ChatSession({
    this.title = "",
    required this.messages,
    required this.personaID,
    required this.sessionID,
  });

  Map<String, dynamic> toSaveJson() {
    return {
      "title": title,
      "personaID": personaID,
      "sessionID": sessionID,
      "messages": messages.map((m) => m.toSaveJson()).toList(),
    };
  }

  factory ChatSession.fromSaveJson(Map<String, dynamic> json) {
    var chat = ChatSession(
      title: json["title"] ?? "",
      personaID: json["personaID"] ?? 0,
      sessionID: json["sessionID"] ?? 0,
      messages:
          (json["messages"] as List?)
              ?.map((m) => ChatMessage.fromSaveJson(m))
              .toList() ??
          [],
    );
    return chat;
  }

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
      parts: [TextPart(message)],
      isError: true,
    );
    messages.add(content);
  }

  void addAIMessage(Content content) {
    ChatMessage msg = ChatMessage.fromContent(content: content);
    messages.add(msg);
  }
}
