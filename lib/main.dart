import "package:chat_ui_lab/screens/chat_screen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:chat_ui_lab/models/chat_message.dart";
import "package:chat_ui_lab/widgets/message_bubble.dart";
import "package:chat_ui_lab/widgets/input_bar.dart";
import "package:chat_ui_lab/theme/tokyo_night.dart";
import "package:flutter_gemini/flutter_gemini.dart";

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    Gemini.init(apiKey: dotenv.env["API_KEY"] ?? "<API_KEY>", enableDebugging: kDebugMode);
  } catch (e) {
    if (kDebugMode) {
      print("Error: $e");
    }
  }
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat UI App",
      // theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ChatScreen(),
      // theme: tokyoNightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
