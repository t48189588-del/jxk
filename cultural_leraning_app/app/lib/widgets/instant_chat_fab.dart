import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';
import '../services/gemini_service.dart';
import '../services/instant_chat_service.dart';

class InstantChatFab extends StatelessWidget {
  const InstantChatFab({super.key});

  void _openChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InstantChatModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiryLimit = DateTime.now().subtract(const Duration(minutes: 15));

    return StreamBuilder<QuerySnapshot>(
      // Listen for active sessions to display notification badge indicators
      stream: FirebaseFirestore.instance
          .collection('instant_chat_sessions')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(expiryLimit))
          .snapshots(),
      builder: (context, snapshot) {
        final hasActiveChat =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Positioned(
          bottom: 24,
          right: 24,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                elevation: 4,
                onPressed: () => _openChatDialog(context),
                child: const Text('💬', style: TextStyle(fontSize: 24)),
              ),
              if (hasActiveChat)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class InstantChatModal extends StatefulWidget {
  const InstantChatModal({super.key});

  @override
  State<InstantChatModal> createState() => _InstantChatModalState();
}

class _InstantChatModalState extends State<InstantChatModal> {
  final TextEditingController _messageController = TextEditingController();
  String? _sessionId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final id = await InstantChatService.getOrCreateActiveSession();
    if (mounted) {
      setState(() {
        _sessionId = id;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sessionId == null) return;
    _messageController.clear();

    await InstantChatService.sendMessage(
      sessionId: _sessionId!,
      senderName:
          'Traveler_${DateTime.now().millisecond.toString().padRight(3, '0')}',
      messageText: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = AppLocalizations.getBrowserLanguageCode();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('15-Min Live Cultural Chat',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('instant_chat_sessions')
                        .doc(_sessionId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Center(
                            child: Text('No messages yet. Say hello!',
                                style: TextStyle(color: Colors.grey)));
                      }

                      return ListView.builder(
                        reverse: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;
                          final sender = data['senderName'] ?? 'Anon';
                          final originalText = data['originalText'] ?? '';
                          final senderLang = data['senderLang'] ?? 'en';
                          final translations =
                              data['translations'] as Map<String, dynamic>? ??
                                  {};

                          // Translation Resolution
                          String displayText = originalText;
                          if (senderLang != currentLang) {
                            if (translations.containsKey(currentLang)) {
                              displayText = translations[currentLang];
                            } else {
                              // Trigger lazy translation via Gemini background worker
                              _translateChatMessage(
                                  docId, originalText, currentLang);
                            }
                          }

                          return ListTile(
                            title: Text(sender,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange)),
                            subtitle: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(displayText,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87)),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepOrange),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _translateChatMessage(
      String msgId, String text, String targetLang) async {
    try {
      final translated = await GeminiService.askCulturalAssistant(
        "Translate this chat message accurately into language code '$targetLang'. Return ONLY the translation text.",
        text,
      );

      await FirebaseFirestore.instance
          .collection('instant_chat_sessions')
          .doc(_sessionId)
          .collection('messages')
          .doc(msgId)
          .set({
        'translations': {targetLang: translated}
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
