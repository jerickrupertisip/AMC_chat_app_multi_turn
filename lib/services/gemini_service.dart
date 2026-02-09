import "dart:convert";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gemini/flutter_gemini.dart";
import "package:http/http.dart" as http;
import "package:chat_ui_lab/models/chat_message.dart";

class GeminiService {
  static final String apiKey =
      dotenv.env["API_KEY"] ??
      "<API_KEY>"; // ← Replace with your actual API key!
  static const String model = "gemini-2.5-flash-lite";
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent";

  // 🔥 SYSTEM PROMPT - FLUTTER ONLY
  static const String instruction =
      """You are a Flutter development expert assistant. 
You ONLY answer questions about Flutter, Dart, and mobile app development.

RULES:
1. Answer questions about Flutter, Dart, Widgets, and UI development
2. Answer questions about state management (Provider, Riverpod, GetX)
3. Answer questions about API integration and REST calls
4. Answer questions about Firebase with Flutter
5. If someone asks about Python, JavaScript, Web Dev, or other topics -> RESPOND: "I"m specialized in Flutter development. Please ask me about Flutter, Dart, or mobile app development."
6. Be concise (2-3 sentences max)
7. Use emojis for clarity

SCOPE: Flutter, Dart, Mobile Apps ONLY""";
}
