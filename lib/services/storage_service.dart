import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_gemini_chat/models/chat_session.dart';

class StorageService {
  static const String _chatSessionsKey = 'chat_history_sessions';

  // SAVE: Map -> JSON String -> SharedPreferences
  Future<void> saveSessions(Map<int, List<ChatSession>> sessions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // JSON keys must be Strings, so we convert the int personaID keys
    final Map<String, dynamic> dataToSave = sessions.map(
      (key, value) =>
          MapEntry(key.toString(), value.map((s) => s.toSaveJson()).toList()),
    );

    // Encode the entire map to a single JSON string
    final String encodedData = jsonEncode(dataToSave);
    await prefs.setString(_chatSessionsKey, encodedData);
  }

  // LOAD: SharedPreferences -> JSON String -> Map
  Future<Map<int, List<ChatSession>>> loadSessions() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(_chatSessionsKey);

      if (encodedData == null || encodedData.isEmpty) {
        return {};
      }

      final Map<String, dynamic> decoded = jsonDecode(encodedData);

      return decoded.map((key, value) {
        final List<dynamic> list = value as List;
        return MapEntry(
          int.parse(key),
          list.map((item) => ChatSession.fromSaveJson(item)).toList(),
        );
      });
    } catch (e) {
      // If something goes wrong (e.g., corrupted JSON), return an empty map
      return {};
    }
  }

  // Optional: Clear all sessions
  Future<void> clearSessions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatSessionsKey);
  }
}
