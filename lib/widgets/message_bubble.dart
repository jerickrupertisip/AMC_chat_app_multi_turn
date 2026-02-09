import "package:flutter/material.dart";
import "package:flutter_gemini/flutter_gemini.dart";
import "package:ai_gemini_chat/models/chat_message.dart";

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUserMessage ? Colors.blue[300] : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: message.parts?.map((toElement) {
            if (toElement is TextPart) {
              return Text(toElement.text);
            } else {
              return Text("<Non text part>");
            }
          }).toList() ?? [Text("None")],
        ),
      ),
    );
  }
}
