import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart'; // ← NEW

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void addMessage(String text, String role) {
    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          role: role, // "user" or "model"
          timestamp: DateTime.now(),
        ),
      );
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🔥 MULTI-TURN HANDLER
  Future<void> handleSend(String text) async {
    // Add user message
    addMessage(text, "user");

    setState(() => _isLoading = true);

    try {
      // 🔥 SEND ENTIRE HISTORY TO GEMINI
      final aiResponse = await GeminiService.sendMultiTurnMessage(
        messages, // ← Entire conversation!
      );

      // Add AI response
      addMessage(aiResponse, "model"); // ← role: "model"
    } catch (e) {
      addMessage('❌ Error: $e', "model");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Chat - Multi-Turn Week 4'),
        backgroundColor: Colors.teal[600],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat, size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Start chatting!'),
                        Text(
                          'Multi-turn means Gemini remembers context 🧠',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(message: msg);
                    },
                  ),
          ),

          // Loading
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 12),
                  Text('🤖 Thinking with context...'),
                ],
              ),
            ),

          // Input
          InputBar(onSendMessage: handleSend),
        ],
      ),
    );
  }
}
