import "package:flutter/material.dart";

class InputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final TextEditingController textController;

  const InputBar({
    Key? key,
    required this.onSendMessage,
    required this.textController,
  }) : super(key: key);

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  @override
  void dispose() {
    widget.textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    String text = widget.textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.textController,
              decoration: InputDecoration(
                hintText: "Type Your Message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: Colors.blue,
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
