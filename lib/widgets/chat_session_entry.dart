import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ai_gemini_chat/models/chat_session.dart';

class ChatSessionEntry extends StatefulWidget {
  final Function(int, int) onClick;
  final Function(int, int) onDelete;

  String title;
  ChatSession session;

  ChatSessionEntry({
    required this.title,
    required this.onClick,
    required this.onDelete,
    required this.session,
  });

  @override
  State<ChatSessionEntry> createState() => _ChatSessionEntryState();
}

class _ChatSessionEntryState extends State<ChatSessionEntry> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      onTap: () {
        widget.onClick(widget.session.personaID, widget.session.sessionID);
      },
      // The action goes here
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () {
          widget.onDelete(widget.session.personaID, widget.session.sessionID);
        },
      ),
    );
  }
}
