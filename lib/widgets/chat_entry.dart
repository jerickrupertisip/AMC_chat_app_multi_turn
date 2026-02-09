import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatEntry extends StatefulWidget {
  final Function(int) onClick;

  String title;
  int session_id;

  ChatEntry({
    required this.session_id,
    required this.title,
    required this.onClick,
  });

  @override
  State<ChatEntry> createState() => _ChatEntryState();
}

class _ChatEntryState extends State<ChatEntry> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      onTap: () {
        widget.onClick(widget.session_id);
      },
    );
  }
}
