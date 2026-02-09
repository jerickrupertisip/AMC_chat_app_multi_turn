import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatSessionEntry extends StatefulWidget {
  final Function(int, int) onClick;
  final Function(int, int) onDelete;

  String title;
  int persona_id;
  int session_id;

  ChatSessionEntry({
    required this.persona_id,
    required this.session_id,
    required this.title,
    required this.onClick,
    required this.onDelete,
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
        widget.onClick(widget.persona_id, widget.session_id);
      },
      // The action goes here
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () {
          widget.onDelete(widget.persona_id, widget.session_id);
        },
      ),
    );
  }
}
