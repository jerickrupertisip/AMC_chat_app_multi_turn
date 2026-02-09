import "package:chat_ui_lab/models/Persona.dart";
import "package:chat_ui_lab/models/chat_session.dart";
import "package:chat_ui_lab/widgets/chat_entry.dart";
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
  List<ChatSession> sessions = [];
  int activeSessionID = -1;

  ChatSession? get activeSession =>
      activeSessionID == -1 ? null : sessions[activeSessionID];
  int selectedPersonaID = 0;

  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
    if (activeSessionID < 0 || sessions.isEmpty) {
      sessions.add(
        ChatSession(
          title: "${sessions.length} Chat [$selectedPersonaID]",
          messages: [],
          persona_id: selectedPersonaID,
        ),
      );
      activeSessionID = sessions.length - 1;
    }

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

        // var response = await Gemini.instance.chat(session.messages);
        //
        // setState(() {
        //   Content? content = response?.content;
        //   if (content != null) {
        //     session.addAIMessage(content);
        //   }
        // });
        session.addAIMessage(Content(
          role: "model",
          parts: [TextPart("AI Response")],
        ));
      } catch (e) {
        session.addErrorMessage("❌ Error: $e");
      } finally {
        session.removeMessageInstruction();
        setState(() => _isLoading = false);
      }
    }
  }

  void handlePersonaClick(int personaID) {
    selectedPersonaID = personaID;
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
                ? EmptyChat(onPersonaClicked: handlePersonaClick)
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
        child: ListView(
          padding: EdgeInsets.all(12),
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text("New Chat"),
              onTap: () {
                setState(() {
                  activeSessionID = -1;
                });
              },
            ),
            // Padding(padding: EdgeInsets.all(12), child: Text("New Chat", on)),
            ...GeminiService.personas.asMap().entries.map((value) {
              int id = value.key;
              Persona persona = value.value;
              List<ChatSession> personaSessions = sessions.where((session) {
                return session.persona_id == id;
              }).toList();

              return ExpansionTile(
                title: Text(
                  persona.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: personaSessions.asMap().entries.map((value) {
                  int sessionID = value.key;
                  print("Session ID: $sessionID");
                  ChatSession session = value.value;
                  return ChatEntry(
                    session_id: sessionID,
                    title: session.title,
                    onClick: (id) {
                      print("clicked Session ID: $id");
                      if (activeSessionID != id) {
                        setState(() {
                          activeSessionID = id;
                        });
                      }
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
