import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  static final String apiKey =
      dotenv.env["API_KEY"] ??
      "<API_KEY>"; // ← Replace with your actual API key!
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  // 🔥 SYSTEM PROMPT - FLUTTER ONLY
  static const String systemPrompt =
      '''You are a Flutter development expert assistant. 
You ONLY answer questions about Flutter, Dart, and mobile app development.

RULES:
1. Answer questions about Flutter, Dart, Widgets, and UI development
2. Answer questions about state management (Provider, Riverpod, GetX)
3. Answer questions about API integration and REST calls
4. Answer questions about Firebase with Flutter
5. If someone asks about Python, JavaScript, Web Dev, or other topics -> RESPOND: "I'm specialized in Flutter development. Please ask me about Flutter, Dart, or mobile app development."
6. Be concise (2-3 sentences max)
7. Use emojis for clarity

SCOPE: Flutter, Dart, Mobile Apps ONLY''';

  static List<Map<String, dynamic>> _formatMessages(
    List<ChatMessage> messages,
  ) {
    return messages.map((msg) {
      return {
        'role': msg.role,
        'parts': [
          {'text': msg.text},
        ],
      };
    }).toList();
  }

  static Future<String> sendMultiTurnMessage(
    List<ChatMessage> conversationHistory,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': _formatMessages(conversationHistory),
          'system_instruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'generationConfig': {
            'temperature': 0.7,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 2250,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']['message'] ?? 'Unknown error';
        return 'Error: ${response.statusCode} - $errorMessage';
      }
    } catch (e) {
      return 'Network Error: $e';
    }
  }
}
