import 'package:flutter/cupertino.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatMessage extends Content {
  ChatMessage({
    required String text,
    required String role,
    this.isError = false,
    this.isInstruction = false,
  }) : super(role: role, parts: [TextPart(text)]);

  ChatMessage.fromContent({
    required Content content,
    this.isError = false,
    this.isInstruction = false,
  }) : super(parts: content.parts, role: content.role);

  ChatMessage.fromParts({
    required List<Part> parts,
    required String role,
    this.isError = false,
    this.isInstruction = false,
  }) : super(parts: parts, role: role);

  bool isError = false;
  bool isInstruction = false;

  bool get isUserMessage => role == "user";

  Map<String, dynamic> toSaveJson() {
    return {
      'role': role,
      'isError': isError,
      'isInstruction': isInstruction,
      // Map only the TextParts to a list of strings
      'parts': parts?.whereType<TextPart>().map((p) => p.text).toList() ?? [],
    };
  }

  factory ChatMessage.fromSaveJson(Map<String, dynamic> json) {
    return ChatMessage.fromParts(
      role: json['role'] ?? 'user',
      isError: json['isError'] ?? false,
      isInstruction: json['isInstruction'] ?? false,
      // Reconstruct the parts list by wrapping each string back into a TextPart
      parts:
          (json['parts'] as List?)
              ?.map((text) => TextPart(text.toString()))
              .toList() ??
          [],
    );
  }

  void append(Content message) {
    Part? part = parts?.first;
    if (part is TextPart) {
      part.text +=
          message.parts?.map((toElement) {
            if (toElement is TextPart) {
              return toElement.text;
            } else {
              return "";
            }
          }).join() ??
          "";
    }
  }
}
