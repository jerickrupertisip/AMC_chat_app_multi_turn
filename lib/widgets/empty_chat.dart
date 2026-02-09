import 'package:chat_ui_lab/models/Persona.dart';
import 'package:chat_ui_lab/services/gemini_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyChat extends StatelessWidget {
  final Function(int) onPersonaClicked;

  const EmptyChat({Key? key, required this.onPersonaClicked}) : super(key: key);

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
          SizedBox(height: 16),
          Column(
            children: GeminiService.personas.asMap().entries.map((value) {
              int persona_id = value.key;
              Persona persona = value.value;
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(persona.name),
                onTap: () {
                  onPersonaClicked(persona_id);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
