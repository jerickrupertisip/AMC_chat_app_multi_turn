import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class SettingsDialog extends StatelessWidget {
  final TextEditingController apiKeyController;

  const SettingsDialog({super.key, required this.apiKeyController});

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 150),
                          child: TextField(
                            controller: apiKeyController,
                            decoration: const InputDecoration(
                              labelText: "Gemini API Key",
                              hintText: "Enter your key",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          String apiKey = apiKeyController.text;
                          if (apiKey.isNotEmpty) {
                            Gemini.reInitialize(apiKey: apiKey, enableDebugging: kDebugMode);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Apply"),
                      ),
                    ],
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
