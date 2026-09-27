import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class InstantChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Initialize or join an active global 15-minute chat session
  static Future<String> getOrCreateActiveSession() async {
    final now = DateTime.now();
    final expiryLimit = now.subtract(const Duration(minutes: 15));

    // Look for an active session created within the last 15 minutes
    final querySnapshot = await _firestore
        .collection('instant_chat_sessions')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(expiryLimit))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      // Create a fresh 15-minute session
      final docRef = await _firestore.collection('instant_chat_sessions').add({
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(minutes: 15))),
        'initiatorLang': AppLocalizations.getBrowserLanguageCode(),
      });
      return docRef.id;
    }
  }

  // 2. Send a message into the active session
  static Future<void> sendMessage({
    required String sessionId,
    required String senderName,
    required String messageText,
  }) async {
    final String senderLang = AppLocalizations.getBrowserLanguageCode();

    await _firestore
        .collection('instant_chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .add({
      'senderName': senderName,
      'originalText': messageText,
      'senderLang': senderLang,
      'timestamp': FieldValue.serverTimestamp(),
      'translations':
          {}, // Will be lazily populated per reader's browser language
    });
  }
}
