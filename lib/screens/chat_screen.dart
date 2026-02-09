import "package:chat_ui_lab/models/chat_session.dart";
import "package:chat_ui_lab/widgets/empty_chat.dart";
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
  ChatSession? activeSession = null;

  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // void removeErrorMessages() {
  //   setState(() {
  //     messages.removeWhere((element) {
  //       return element.isError;
  //     });
  //   });
  // }
  //
  // void addTemporaryMessage(String text, String role) {
  //   setState(() {
  //     messages.add(ChatMessage(text: text, role: role));
  //   });
  //   scrollToBottom();
  // }
  //
  // void removeMessageInstruction() {
  //   setState(() {
  //     messages.removeWhere((element) {
  //       return element.isInstruction;
  //     });
  //   });
  // }
  //
  // void addAIInstruction() {
  //   setState(() {
  //     var content = ChatMessage(
  //       text: GeminiService.instruction,
  //       role: "user",
  //       isInstruction: true,
  //     );
  //     messages.add(content);
  //   });
  //   scrollToBottom();
  // }
  //
  // void addUserMessage(String message) {
  //   setState(() {
  //     var content = ChatMessage(text: message, role: "user");
  //     messages.add(content);
  //   });
  //   scrollToBottom();
  // }
  //
  // void addErrorMessage(String message) {
  //   setState(() {
  //     var content = ChatMessage.fromParts(
  //       role: "model",
  //       parts: [TextPart(GeminiService.instruction), TextPart(message)],
  //       isError: true,
  //     );
  //     messages.add(content);
  //   });
  //   scrollToBottom();
  // }
  //
  // void addAIMessage(Content content) {
  //   setState(() {
  //     ChatMessage msg = ChatMessage.fromContent(content: content);
  //     messages.add(msg);
  //   });
  //   scrollToBottom();
  // }

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
    activeSession ??= new ChatSession(title: "1 Chat", messages: []);

    ChatSession? session = activeSession;
    if (session != null) {
      try {
        setState(() {
          _isLoading = true;
          session.removeErrorMessages();
          session.addAIInstruction();
          session.addUserMessage(user_prompt);
          scrollToBottom();
        });

        var response = await Gemini.instance.chat(session.messages);

        setState(() {
          Content? content = response?.content;
          if (content != null) {
            session.addAIMessage(content);
          }

          session.removeMessageInstruction();
        });
      } catch (e) {
        session.addErrorMessage("❌ Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatSession? session = activeSession;
    return Scaffold(
      appBar: AppBar(
        title: const Text("🤖 AI Chat - Multi-Turn Week 4"),
        backgroundColor: Colors.teal[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: (session == null || session.messages.isEmpty)
                ? EmptyChat()
                : ListView.builder(
                    controller: scrollController,
                    itemCount: session.visibleMessages.length,
                    itemBuilder: (context, index) {
                      final msg = session.visibleMessages[index];
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
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: []),
      ),
    );
  }
}
