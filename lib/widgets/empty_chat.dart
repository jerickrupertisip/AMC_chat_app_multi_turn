import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text("Start chatting!"),
          Text(
            "Multi-turn means Gemini remembers context 🧠",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
