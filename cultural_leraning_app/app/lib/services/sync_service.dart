import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reads the user's current browser language and localizes/updates
  /// a target Q&A document in Firestore with language metadata.
  static Future<void> localizeAndSyncQADocument({
    required String documentId,
    required String question,
    required String answer,
    required String countryId,
    String? user,
  }) async {
    try {
      // 1. Read the client's browser language using our localization engine
      final String detectedLangCode = AppLocalizations.getBrowserLanguageCode();

      debugPrint(
          '🌐 [SyncService] Detected client browser language: $detectedLangCode');
      debugPrint(
          '📤 [SyncService] Updating Firestore document $documentId with language context.');

      // 2. Reference the specific document in your 'qa_posts' collection
      final DocumentReference docRef =
          _firestore.collection('qa_posts').doc(documentId);

      // 3. Write/Update the fields including language-specific metadata or localized payloads
      await docRef.set(
          {
            'question': question,
            'answer': answer,
            'countryId': countryId,
            'user': user ?? 'Anonymous',
            'timestamp': FieldValue.serverTimestamp(),
            // Add localized sync tracking fields to optimize future database reads
            'originalBrowserLanguage': detectedLangCode,
            'isLocalizedSync': true,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(
              merge:
                  true)); // Merge ensures we don't overwrite untouched fields

      debugPrint(
          '✅ [SyncService] Successfully synchronized & localized document: $documentId');
    } catch (e) {
      debugPrint(
          '❌ [SyncService] Error writing localized fields to Firestore: $e');
    }
  }
}
