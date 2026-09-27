import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Added for safe random generation
import '../providers/app_state.dart';
import '../services/gemini_service.dart';
// Inside your QAScreen submission handler:
import '../services/sync_service.dart';

import '../l10n/app_localizations.dart'; // --- LOCALIZATION --- Import localization class

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion(AppState appState) async {
    final text = _questionController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // FIX: Replaced DateTime.now().second with Random int to avoid Int64 dart2js crash
    final randomSuffix = Random().nextInt(9000) + 1000;
    final userName = _nameController.text.trim().isEmpty
        ? 'Traveler_$randomSuffix'
        : _nameController.text.trim();

    final currentCountryName = appState.currentCountry.name;

    try {
      final culturalContext =
          "Country: $currentCountryName. Local cultural etiquette, laws, and social expectations.";

      final aiAnswer = await GeminiService.askCulturalAssistant(
        culturalContext,
        text,
      );

      // After getting the AI answer and preparing to save to Firestore:
      final docRef =
          await FirebaseFirestore.instance.collection('qa_posts').add({
        'user': userName,
        'question': text,
        'answer': aiAnswer,
        'countryId': appState.selectedCountryId,
        'timestamp': FieldValue.serverTimestamp(),
      });

// Sync and localize immediately using your SyncService
      await SyncService.localizeAndSyncQADocument(
        documentId: docRef.id,
        question: text,
        answer: aiAnswer,
        countryId: appState.selectedCountryId,
        user: userName,
      );

      _questionController.clear();
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question posted & answered by AI securely!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('DEBUG ERROR: $e');
      print('STACKTRACE: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Background helper to translate legacy documents on-the-fly
  Future<void> _translateAndSaveDocument({
    required String docId,
    required String originalQuestion,
    required String originalAnswer,
    required String targetLang,
  }) async {
    try {
      // Use Gemini Service to translate the question & answer into targetLang
      final translatedQ = await GeminiService.askCulturalAssistant(
        "Translate the following text accurately into language code '$targetLang'. Return ONLY the translated text without extra explanation.",
        originalQuestion,
      );

      final translatedA = await GeminiService.askCulturalAssistant(
        "Translate the following text accurately into language code '$targetLang'. Return ONLY the translated text without extra explanation.",
        originalAnswer,
      );

      // Save the translation map back to Firestore
      await FirebaseFirestore.instance.collection('qa_posts').doc(docId).set({
        'translations': {
          targetLang: {
            'question': translatedQ,
            'answer': translatedA,
          }
        }
      }, SetOptions(merge: true));

      // Refresh UI if screen is still active
      if (mounted) setState(() {});
    } catch (e) {
      print('Background lazy translation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(
        context); // --- LOCALIZATION --- Initialize localizer

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.translate('qaTitle') ?? 'Community Q&A & Secure AI Guide',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.translate('qaSubtitle') ??
                'Ask cultural etiquette questions. Answers are generated securely via Firebase.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n?.translate('optionalNameHint') ??
                  'Your Optional Name (e.g., Alex)',
              hintStyle: const TextStyle(fontSize: 13),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: l10n?.translate('qaSubtitle') ??
                        'Ask a cultural etiquette question...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _submitQuestion(appState),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed:
                    _isSubmitting ? null : () => _submitQuestion(appState),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.translate('recentDiscussions') ??
                'Recent Community Discussions',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Real-time Firestore Stream Builder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('qa_posts')
                  .where('countryId', isEqualTo: appState.selectedCountryId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading posts: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('No questions yet for this country.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final user = data['user'] ?? 'Anonymous';

                    final String currentLang =
                        AppLocalizations.getBrowserLanguageCode();
                    final translations =
                        data['translations'] as Map<String, dynamic>?;

                    final bool hasTranslation = translations != null &&
                        translations[currentLang] != null;

                    final String question = hasTranslation
                        ? (translations[currentLang]['question'] ??
                            data['question'] ??
                            '')
                        : (data['question'] ?? '');

                    final String answer = hasTranslation
                        ? (translations[currentLang]['answer'] ??
                            data['answer'] ??
                            '')
                        : (data['answer'] ?? '');

                    // SAFE LAZY TRIGGER: Use WidgetsBinding to schedule the background translation
                    // AFTER the current frame finishes rendering, preventing build-cycle crashes.
                    if (!hasTranslation &&
                        currentLang != 'en' &&
                        data['question'] != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _translateAndSaveDocument(
                          docId: docId,
                          originalQuestion: data['question'],
                          originalAnswer: data['answer'] ?? '',
                          targetLang: currentLang,
                        );
                      });
                    }

                    final timestamp = data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp).toDate()
                        : DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(user,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                        fontSize: 13)),
                                Text(
                                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(question,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(height: 1),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    answer,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
