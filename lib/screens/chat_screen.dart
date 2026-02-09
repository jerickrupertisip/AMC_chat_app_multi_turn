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
  // Map<int, List<ChatSession>> sessions = {
  //   for (int i = 0; i < GeminiService.personas.length; i++) i: [],
  // };
  Map<int, List<ChatSession>> sessions = {};
  Map<int, int> sessionsActiveSession = {};
  int activeSessionID = -1;
  int activePersonaID = -1;
  int selectedPersonaID = 0;

  List<ChatSession>? get chatSessions => sessions[activePersonaID];

  ChatSession? get activeSession =>
      activeSessionID >= 0 ? (chatSessions?[activeSessionID]) : null;

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

  bool get noActiveChat => activePersonaID == -1 && activeSessionID == -1;

  bool get hasActiveChat => activePersonaID >= 0 && activeSessionID >= 0;

  void toEmptyChat() {
    activeSessionID = -1;
    activePersonaID = -1;
  }

  ChatSession? newEmptyChat() {
    if (noActiveChat) {
      if (!sessions.containsKey(selectedPersonaID)) {
        sessions[selectedPersonaID] = [];
      }
    }

    var chatSessions = sessions[selectedPersonaID];
    if (chatSessions != null) {
      int currentLength = chatSessions.length;
      activeSessionID = currentLength;
      activePersonaID = selectedPersonaID;
      var session = ChatSession(
        title: "Persona [$selectedPersonaID]: Session[$currentLength]",
        messages: [],
        personaID: selectedPersonaID,
      );
      chatSessions.add(session);
      return session;
    }
    return null;
  }

  Future<void> handleSend(String userPrompt) async {
    ChatSession? session = hasActiveChat ? activeSession : newEmptyChat();

    if (session != null) {
      try {
        setState(() {
          _isLoading = true;
          session.removeErrorMessages();
          session.addAIInstruction();
          session.addUserMessage(userPrompt);
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
        session.addAIMessage(
          Content(role: "model", parts: [TextPart("AI Response")]),
        );
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
            child: session == null
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
          Column(
            children: [
              InputBar(onSendMessage: handleSend),
            ],
          ),
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
                  toEmptyChat();
                });
              },
            ),
            // Padding(padding: EdgeInsets.all(12), child: Text("New Chat", on)),
            ...sessions.entries.map((value) {
              int personaID = value.key;
              List<ChatSession> personaSessions = value.value;

              return ExpansionTile(
                title: Text(
                  GeminiService.personas[personaID].name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: personaSessions.asMap().entries.map((value) {
                  int sessionID = value.key;
                  ChatSession session = value.value;
                  return ChatSessionEntry(
                    persona_id: personaID,
                    session_id: sessionID,
                    title: session.title,
                    onClick: (pID, sID) {
                      print("[$pID][$sID]");
                      setState(() {
                        activePersonaID = pID;
                        activeSessionID = sID;
                      });
                    },
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
