import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';

class SignAnalysisResult {
  final String originalText;
  final String translation;
  final String culturalContext;

  SignAnalysisResult({
    required this.originalText,
    required this.translation,
    required this.culturalContext,
  });

  factory SignAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SignAnalysisResult(
      originalText: json['originalText'] ?? '',
      translation: json['translation'] ?? '',
      culturalContext: json['culturalContext'] ?? '',
    );
  }
}

class GeminiService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // 1. Text-based cultural assistant query (Routed securely via Cloud Functions)
  static Future<String> askCulturalAssistant(
      String culturalContext, String userQuery) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('askCulturalAssistant');

      final result = await callable.call(<String, dynamic>{
        'culturalContext': culturalContext,
        'userQuery': userQuery,
      });

      return result.data['result'] as String? ?? "No response generated.";
    } catch (e) {
      return "Network error: $e";
    }
  }

  // 2. Multimodal sign analyzer (Routed securely via Cloud Functions)
  static Future<SignAnalysisResult> analyzeSign({
    required Uint8List imageBytes,
    required String targetCountry,
    required String userDeviceLanguage,
    String?
        apiKeyOverride, // Kept for method compatibility if needed, though bypassed safely server-side
  }) async {
    try {
      // Convert image bytes to Base64 string for safe transport across the network
      final String base64Image = base64Encode(imageBytes);

      final HttpsCallable callable = _functions.httpsCallable('analyzeSign');

      final result = await callable.call(<String, dynamic>{
        'imageBase64': base64Image,
        'targetCountry': targetCountry,
        'userDeviceLanguage': userDeviceLanguage,
      });

      final Map<String, dynamic> jsonResponse =
          Map<String, dynamic>.from(result.data);

      return SignAnalysisResult.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Failed to analyze sign securely: $e');
    }
  }
}
