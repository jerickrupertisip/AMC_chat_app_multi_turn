import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatSessionEntry extends StatefulWidget {
  final Function(int, int) onClick;

  String title;
  int persona_id;
  int session_id;

  ChatSessionEntry({
    required this.persona_id,
    required this.session_id,
    required this.title,
    required this.onClick,
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
    );
  }
}
