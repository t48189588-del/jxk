import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

final signAnalyzerStateProvider = StateNotifierProvider<SignAnalyzerNotifier,
    AsyncValue<SignAnalysisResult?>>((ref) {
  return SignAnalyzerNotifier();
});

class SignAnalyzerNotifier
    extends StateNotifier<AsyncValue<SignAnalysisResult?>> {
  SignAnalyzerNotifier() : super(const AsyncValue.data(null));

  Future<void> captureAndAnalyze({
    required Uint8List imageBytes,
    required String targetCountry,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Automatically grab the device default UI language (e.g., 'en', 'ja', 'es', etc.)
      final deviceLanguage = ui.PlatformDispatcher.instance.locale.languageCode;

      final result = await GeminiService.analyzeSign(
        imageBytes: imageBytes,
        targetCountry: targetCountry,
        userDeviceLanguage: deviceLanguage,
      );

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
