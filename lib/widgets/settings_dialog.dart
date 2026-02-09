import 'package:chat_ui_lab/services/gemini_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class SettingsDialog extends StatelessWidget {
  final TextEditingController apiKeyController;
  final TextEditingController geminiModelController;
  final Function() onClearChats;

  const SettingsDialog({
    super.key,
    required this.apiKeyController,
    required this.geminiModelController,
    required this.onClearChats,
  });

  Row newInputSetting({
    required String? labelText,
    required String hintText,
    required TextEditingController controller,
    required Function() onPressed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 380),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(onPressed: onPressed, child: const Text("Apply")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("Settings"),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Settings"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  newInputSetting(
                    labelText: "Gemini API Key",
                    hintText: "Enter your key",
                    controller: apiKeyController,
                    onPressed: () {
                      String apiKey = apiKeyController.text;
                      if (apiKey.isNotEmpty) {
                        Gemini.reInitialize(
                          apiKey: apiKey,
                          enableDebugging: kDebugMode,
                        );
                        Navigator.pop(context);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  newInputSetting(
                    labelText:
                        "Gemini Model Identifier (eg. gemini-2.5-flash-lite)",
                    hintText: "Model Identifier",
                    controller: geminiModelController,
                    onPressed: () {
                      GeminiService.model = geminiModelController.text;
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onClearChats();
                    },
                    child: Text("Clear Chats"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
