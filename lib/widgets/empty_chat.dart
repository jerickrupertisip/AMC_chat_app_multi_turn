import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:ai_gemini_chat/models/persona.dart";
import "package:ai_gemini_chat/services/gemini_service.dart";

class EmptyChat extends StatelessWidget {
  final Function(int?) onPersonaSelected;

  const EmptyChat({Key? key, required this.onPersonaSelected})
    : super(key: key);

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
          DropdownMenu<int>(
            initialSelection: 0,
            requestFocusOnTap: false,
            label: Text("Select Persona"),
            dropdownMenuEntries: GeminiService.personas.asMap().entries.map((
              value,
            ) {
              int personaID = value.key;
              Persona persona = value.value;
              return DropdownMenuEntry(value: personaID, label: persona.name);
            }).toList(),
            onSelected: (value) {
              onPersonaSelected(value);
            },
          ),
        ],
      ),
    );
  }
}
