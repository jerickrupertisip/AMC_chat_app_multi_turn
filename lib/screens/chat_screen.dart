import "package:flutter/material.dart";
import "package:chat_ui_lab/models/chat_message.dart";
import "package:chat_ui_lab/widgets/message_bubble.dart";
import "package:chat_ui_lab/widgets/input_bar.dart";
import "package:chat_ui_lab/services/gemini_service.dart";
import "package:flutter_gemini/flutter_gemini.dart";

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];

  ChatMessage get aiChatMessage => messages.last;

  List<ChatMessage> get visibleMessages => messages.where((m) {
    return !m.isInstruction;
  }).toList();
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void removeErrorMessages() {
    setState(() {
      messages.removeWhere((element) {
        return element.isError;
      });
    });
  }

  void addTemporaryMessage(String text, String role) {
    setState(() {
      messages.add(ChatMessage(text: text, role: role));
    });
    scrollToBottom();
  }

  void removeMessageInstruction() {
    setState(() {
      messages.removeWhere((element) {
        return element.isInstruction;
      });
    });
  }

  void addAIInstruction() {
    setState(() {
      var content = ChatMessage(
        text: GeminiService.instruction,
        role: "user",
        isInstruction: true,
      );
      messages.add(content);
    });
    scrollToBottom();
  }

  void addUserMessage(String message) {
    setState(() {
      var content = ChatMessage(text: message, role: "user");
      messages.add(content);
    });
    scrollToBottom();
  }

  void addErrorMessage(String message) {
    setState(() {
      var content = ChatMessage.fromParts(
        role: "model",
        parts: [TextPart(GeminiService.instruction), TextPart(message)],
        isError: true,
      );
      messages.add(content);
    });
    scrollToBottom();
  }

  void addAIMessage(Content content) {
    setState(() {
      ChatMessage msg = ChatMessage.fromContent(content: content);
      messages.add(msg);
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

  Future<void> handleSend(String user_prompt) async {
    try {
      setState(() => _isLoading = true);

      removeErrorMessages();
      addAIInstruction();
      addUserMessage(user_prompt);

      var v = await Gemini.instance.chat(messages);
      if (content != null) {
        addAIMessage(content);
      }

      removeMessageInstruction();
    } catch (e) {
      addErrorMessage("❌ Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🤖 AI Chat - Multi-Turn Week 4"),
        backgroundColor: Colors.teal[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
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
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: visibleMessages.length,
                    itemBuilder: (context, index) {
                      final msg = visibleMessages[index];
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
                  Text("🤖 Thinking with context..."),
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
