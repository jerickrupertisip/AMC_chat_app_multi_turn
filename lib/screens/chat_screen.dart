import 'package:flutter/material.dart';
import 'package:chat_ui_lab/models/chat_message.dart';
import 'package:chat_ui_lab/widgets/message_bubble.dart';
import 'package:chat_ui_lab/widgets/input_bar.dart';

import 'package:chat_ui_lab/services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();

  void addMessage(String text, bool isUser) {
    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUserMessage: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> handleSend(String text) async {
    addMessage(text, true); // User message

    // 🔥 LOADING
    addMessage('🤖 AI Thinking...', false);

    try {
      // 🔥 REAL GEMINI CALL
      final aiResponse = await GeminiService.sendMessage(text);

      // Remove loading message
      setState(() {
        messages.removeLast(); // Remove "AI Thinking..."
      });

      addMessage(aiResponse, false); // Real response
    } catch (e) {
      setState(() {
        messages.removeLast(); // Remove loading
      });
      addMessage('❌ Error: $e', false);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat UI ✅')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text('Send message to start!'))
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: messages[messages.length - 1 - index],
                      );
                    },
                  ),
          ),
          InputBar(onSendMessage: handleSend),
        ],
      ),
    );
  }
}
