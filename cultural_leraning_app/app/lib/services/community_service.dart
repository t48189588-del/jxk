import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Q&A FORUM METHODS ---

  // Post a question and save Gemini's answer
  static Future<void> saveQAPost({
    required String question,
    required String answer,
  }) async {
    await _db.collection('qa_posts').add({
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream stream of Q&A posts for real-time forum UI
  static Stream<QuerySnapshot> getQAPostsStream() {
    return _db
        .collection('qa_posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- 15-MINUTE EPHEMERAL CHAT METHODS ---

  // Send an ephemeral message
  static Future<void> sendEphemeralMessage({
    required String sender,
    required String message,
  }) async {
    await _db.collection('ephemeral_chat').add({
      'sender': sender,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream active ephemeral chat messages (updates in real-time)
  static Stream<QuerySnapshot> getEphemeralChatStream() {
    return _db
        .collection('ephemeral_chat')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
