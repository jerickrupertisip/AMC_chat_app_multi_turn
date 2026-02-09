import "package:chat_ui_lab/models/persona.dart";
import "package:chat_ui_lab/models/chat_session.dart";
import "package:chat_ui_lab/services/storage_service.dart";
import "package:chat_ui_lab/widgets/chat_session_entry.dart";
import "package:chat_ui_lab/widgets/empty_chat.dart";
import "package:chat_ui_lab/widgets/settings_dialog.dart";
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
  Map<int, List<ChatSession>> sessions = {};
  Map<int, int> sessionsActiveSession = {};
  int activeSessionID = -1;
  int activePersonaID = -1;
  int selectedPersonaID = 0;

  StorageService storageService = StorageService();

  List<ChatSession>? get chatSessions => sessions[activePersonaID];

  ChatSession? get activeSession =>
      activeSessionID >= 0 ? (chatSessions?[activeSessionID]) : null;

  final ScrollController scrollController = ScrollController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _chatInputController = TextEditingController();
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
        // title: "Persona: $activePersonaID, Session: $activeSessionID",
        title: "",
        messages: [],
        personaID: selectedPersonaID,
        sessionID: currentLength,
      );
      chatSessions.add(session);
      return session;
    }
    return null;
  }

  void unsentLastUserMessage() {
    ChatSession? session = activeSession;
    if (session != null && session.messages.length >= 2) {
      int index = session.messages.lastIndexWhere((session) {
        return session.isUserMessage;
      });
      if (index >= 0) {
        setState(() {
          var msg = session.messages[index];
          msg.isError = true;
          var first = msg.parts?.first;
          if (first != null && first is TextPart) {
            _chatInputController.text = first.text;
          }
        });
      }
    }
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
          _chatInputController.clear();
        });

        if (session.title.isEmpty) {
          var titleResponse = await Gemini.instance.prompt(
            parts: [
              TextPart(GeminiService.chatTitleInstruction),
              TextPart(session.personaInstruction),
              TextPart(userPrompt),
            ],
          );
          setState(() {
            Content? content = titleResponse?.content;
            if (content != null) {
              var title =
                  (content.parts?.map((part) {
                            if (part is TextPart) {
                              return part.text;
                            }
                            return "";
                          }).join() ??
                          "")
                      .trim();
              if (title.isEmpty) {
                session.title = "New Chat";
              } else {
                session.title = title;
              }
            }
          });
        }

        var response = await Gemini.instance.chat(session.messages);

        setState(() {
          Content? content = response?.content;
          if (content != null) {
            session.addAIMessage(content);
            _chatInputController.clear();
          }
        });
        // session.addAIMessage(
        //   Content(parts: [TextPart("AI Response")], role: "model"),
        // );
      } on GeminiException catch (e) {
        int? realStatusCode = e.statusCode;
        Object? message = e.message;

        if (realStatusCode == -1 && message is String) {
          // Regex looks for "status code of " followed by digits
          final match = RegExp(r"status code of (\d+)").firstMatch(message);
          if (match != null) {
            realStatusCode = int.parse(match.group(1)!);
          }
        }

        switch (realStatusCode) {
          case 400:
            session.addErrorMessage(
              "❌ Unauthorized: Your API Key is likely invalid or expired.",
            );
            break;
          case 403:
            session.addErrorMessage(
              "❌ Unauthorized: Your API key doesn't have the required permissions.",
            );
            break;
          case 429:
            session.addErrorMessage(
              "❌ Rate Limit: You are sending requests too fast. Slow down!",
            );
            break;
          case 500:
          case 503:
            session.addErrorMessage(
              "❌ Server Error: Gemini is currently overloaded or down.",
            );
            break;
          case 504:
            session.addErrorMessage(
              "❌ Deadline Exceeded: Your prompt is too large to be processed in time.",
            );
            break;
          default:
            session.addErrorMessage("❌ Error ${e.statusCode}: ${e.message}");
        }
        unsentLastUserMessage();
      } catch (e) {
        session.addErrorMessage("❌ Error: $e");
        unsentLastUserMessage();
      } finally {
        session.removeMessageInstruction();
        setState(() => _isLoading = false);
        storageService.saveSessions(sessions);
      }
    }
  }

  void handlePersonaClick(int personaID) {
    selectedPersonaID = personaID;
  }

  void onPersonaSelected(int? personaID) {
    selectedPersonaID = personaID ?? selectedPersonaID;
  }

  void onChatSessionClick(int personaID, int sessionID) {
    setState(() {
      activePersonaID = personaID;
      activeSessionID = sessionID;
    });
    Navigator.pop(context);
  }

  void recalculateSessionIndexes() {
    sessions.forEach((personaID, sessions) {
      sessions.asMap().forEach((sessionID, session) {
        session.sessionID = sessionID;
      });
    });
  }

  void onChatSessionDelete(int personaID, int sessionID) {
    setState(() {
      var list = sessions[personaID];
      if (list != null) {
        list.removeAt(sessionID);
        if (list.isEmpty) {
          sessions.remove(personaID);
          recalculateSessionIndexes();
          storageService.saveSessions(sessions);
        }
      }
    });
  }

  void _initData() async {
    var sessions = await storageService.loadSessions();
    setState(() {
      this.sessions = sessions;
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
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
                ? EmptyChat(onPersonaSelected: onPersonaSelected)
                : ListView.builder(
                    controller: scrollController,
                    itemCount: session.visibleMessages.length,
                    itemBuilder: (context, index) {
                      final msg = session.visibleMessages[index];
                      return MessageBubble(message: msg);
                    },
                  ),
          ),
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
          Row(
            children: [
              Expanded(
                child: InputBar(
                  onSendMessage: handleSend,
                  textController: _chatInputController,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          // Ensures content doesn't hit status bars or notches
          child: Column(
            children: [
              // 1. TOP SECTION (Fixed)
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("New Chat"),
                onTap: () {
                  setState(() => toEmptyChat());
                  Navigator.pop(context);
                },
              ),
              const Divider(),

              // 2. MIDDLE SECTION (Scrollable)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...sessions.entries.map((entry) {
                      int personaID = entry.key;
                      List<ChatSession> personaSessions = entry.value;
                      return ExpansionTile(
                        title: Text(
                          GeminiService.personas[personaID].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: personaSessions.asMap().entries.map((
                          sessionEntry,
                        ) {
                          int sessionID = sessionEntry.key;
                          ChatSession session = sessionEntry.value;
                          return ChatSessionEntry(
                            session: session,
                            title: session.title,
                            onClick: onChatSessionClick,
                            onDelete: onChatSessionDelete,
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // 3. BOTTOM SECTION (Fixed at the bottom)
              const Divider(),
              SettingsDialog(apiKeyController: _apiKeyController),
            ],
          ),
        ),
      ),
    );
  }
}
