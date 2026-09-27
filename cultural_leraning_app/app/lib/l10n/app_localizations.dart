import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Master localization mapping derived from your codebase scan
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Camera
      'scanSign': 'Scan Sign',
      'switchCamera': 'Switch Camera',
      'chooseGallery': 'Choose image from gallery',
      'alignSign': 'Align sign inside box',
      'analyzingGemini': 'Analyzing cultural context via Gemini...',
      'detectedText': 'Detected Text',
      'culturalContext': 'Cultural Context & Mindset',

      // QA Screen
      'qaTitle': 'Community Q&A & Secure AI Guide',
      'qaSubtitle':
          'Ask cultural etiquette questions. Answers are generated securely via Firebase.',
      'optionalNameHint': 'Your Optional Name (e.g., Alex)',
      'askQuestionHint': 'Ask a cultural etiquette question...',
      'recentDiscussions': 'Recent Community Discussions',
      'noQuestionsYet': 'No questions yet for this country.',

      // Profile Screen
      'profileTitle': 'Personalization & Profile',
      'profileSubtitle': 'Configure your learner persona stored locally.',
      'proficiencyLevel': 'Proficiency Level',
      'primaryIntent': 'Primary Travel / Learning Intent',
      'personaSaved': 'Persona preferences saved to LocalStorage!',
      'savePreferences': 'Save Preferences',

      // Scenarios & Home Screen
      'culturalScenarios': 'Cultural Scenarios',
      'filteredByScenario': 'Filtered by Scenario active',
      'clearFilter': 'Clear filter',
      'noFlashcardsScenario': 'No flashcards found for this scenario.',
      'showAllCards': 'Show All Cards',
      'tapCardFlip': '💡 Tap card to flip translation',

      // Shell Navigation Labels
      'navFlashcards': 'Flashcards',
      'navScenarios': 'Scenarios',
      'navCommunity': 'Community',
      'navProfile': 'Profile',

      // Desktop Presentation
      'desktopDashboard': '🖥️ Desktop Presentation Dashboard (Live Sync)',
      'destroySession': 'Destroy Session',
      'activeSessionStats': 'Active Session Stats',
      'liveLogs': 'Live Community Q&A Logs',
    },
    'es': {
      // General & Camera
      'scanSign': 'Escanear Señal',
      'switchCamera': 'Cambiar Cámara',
      'chooseGallery': 'Elegir imagen de galería',
      'alignSign': 'Alinea la señal dentro del recuadro',
      'analyzingGemini': 'Analizando contexto cultural vía Gemini...',
      'detectedText': 'Texto Detectado',
      'culturalContext': 'Contexto Cultural y Mentalidad',

      // QA Screen
      'qaTitle': 'Preguntas y Respuestas de la Comunidad y Guía de IA',
      'qaSubtitle':
          'Haz preguntas de etiqueta cultural. Las respuestas se generan de forma segura.',
      'optionalNameHint': 'Tu Nombre Opcional (ej. Alex)',
      'askQuestionHint': 'Haz una pregunta de etiqueta cultural...',
      'recentDiscussions': 'Discusiones Recientes de la Comunidad',
      'noQuestionsYet': 'Aún no hay preguntas para este país.',

      // Profile Screen
      'profileTitle': 'Personalización y Perfil',
      'profileSubtitle':
          'Configura tu persona de aprendizaje guardada localmente.',
      'proficiencyLevel': 'Nivel de Competencia',
      'primaryIntent': 'Intención Principal de Viaje / Aprendizaje',
      'personaSaved': '¡Preferencias guardadas en el almacenamiento local!',
      'savePreferences': 'Guardar Preferencias',

      // Scenarios & Home Screen
      'culturalScenarios': 'Escenarios Culturales',
      'filteredByScenario': 'Filtrado por Escenario activo',
      'clearFilter': 'Borrar filtro',
      'noFlashcardsScenario': 'No se encontraron tarjetas para este escenario.',
      'showAllCards': 'Mostrar Todas las Tarjetas',
      'tapCardFlip': '💡 Toca la tarjeta para ver traducción',

      // Shell Navigation Labels
      'navFlashcards': 'Tarjetas',
      'navScenarios': 'Escenarios',
      'navCommunity': 'Comunidad',
      'navProfile': 'Perfil',

      // Desktop Presentation
      'desktopDashboard':
          '🖥️ Panel de Presentación de Escritorio (Sincronización)',
      'destroySession': 'Destruir Sesión',
      'activeSessionStats': 'Estadísticas de Sesión Activa',
      'liveLogs': 'Registros de Preguntas y Respuestas en Vivo',
    },
    'ja': {
      // General & Camera
      'scanSign': '看板をスキャン',
      'switchCamera': 'カメラを切り替える',
      'chooseGallery': 'ギャラリーから画像を選択',
      'alignSign': '枠内に看板を合わせてください',
      'analyzingGemini': 'Geminiで文化的背景を分析中...',
      'detectedText': '検出されたテキスト',
      'culturalContext': '文化的背景とマインドセット',

      // QA Screen
      'qaTitle': 'コミュニティQ&A・セキュアAIガイド',
      'qaSubtitle': '文化的エチケットについての質問を入力してください。',
      'optionalNameHint': 'お名前（任意）',
      'askQuestionHint': '文化的エチケットについて質問する...',
      'recentDiscussions': '最近のコミュニティディスカッション',
      'noQuestionsYet': 'この国の質問はまだありません。',

      // Profile Screen
      'profileTitle': 'パーソナライゼーションとプロフィール',
      'profileSubtitle': 'ローカルに保存される学習者のペルソナを設定します。',
      'proficiencyLevel': '習熟度レベル',
      'primaryIntent': '主な渡航・学習の目的',
      'personaSaved': '設定がローカルストレージに保存されました！',
      'savePreferences': '設定を保存',

      // Scenarios & Home Screen
      'culturalScenarios': '文化シナリオ',
      'filteredByScenario': 'アクティブなシナリオでフィルタリング中',
      'clearFilter': 'フィルターをクリア',
      'noFlashcardsScenario': 'このシナリオのフラッシュカードが見つかりません。',
      'showAllCards': 'すべてのカードを表示',
      'tapCardFlip': '💡 タップして翻訳を表示',

      // Shell Navigation Labels
      'navFlashcards': 'カード',
      'navScenarios': 'シナリオ',
      'navCommunity': 'コミュニティ',
      'navProfile': 'プロフィール',

      // Desktop Presentation
      'desktopDashboard': '🖥️ デスクトッププレゼンテーションダッシュボード',
      'destroySession': 'セッションを破棄',
      'activeSessionStats': 'アクティブセッション統計',
      'liveLogs': 'ライブコミュニティQ&Aログ',
    },
    'ms': {
      // General & Camera
      'scanSign': 'Imbas Tanda',
      'switchCamera': 'Tukar Kamera',
      'chooseGallery': 'Pilih imej dari galeri',
      'alignSign': 'Selaraskan tanda di dalam kotak',
      'analyzingGemini': 'Menganalisis konteks budaya melalui Gemini...',
      'detectedText': 'Teks Dikesan',
      'culturalContext': 'Konteks Budaya & Minda',

      // QA Screen
      'qaTitle': 'Soal Jawab Komuniti & Panduan AI Selamat',
      'qaSubtitle':
          'Tanya soalan etika budaya. Jawapan dijana secara selamat melalui Firebase.',
      'optionalNameHint': 'Nama Pilihan Anda (cth., Alex)',
      'askQuestionHint': 'Tanya soalan etika budaya...',
      'recentDiscussions': 'Perbincangan Komuniti Terkini',
      'noQuestionsYet': 'Tiada soalan lagi untuk negara ini.',

      // Profile Screen
      'profileTitle': 'Pemperibadian & Profil',
      'profileSubtitle':
          'Konfigurasikan persona pembelajar anda yang disimpan secara lokal.',
      'proficiencyLevel': 'Tahap Kemahiran',
      'primaryIntent': 'Niat Utama Perjalanan / Pembelajaran',
      'personaSaved': 'Keutamaan persona berjaya disimpan ke Storan Lokal!',
      'savePreferences': 'Simpan Keutamaan',

      // Scenarios & Home Screen
      'culturalScenarios': 'Senario Budaya',
      'filteredByScenario': 'Ditapis mengikut Senario aktif',
      'clearFilter': 'Kosongkan penapis',
      'noFlashcardsScenario': 'Tiada kad imbas ditemui untuk senario ini.',
      'showAllCards': 'Tunjukkan Semua Kad',
      'tapCardFlip': '💡 Ketik kad untuk pusingkan terjemahan',

      // Shell Navigation Labels
      'navFlashcards': 'Kad Imbas',
      'navScenarios': 'Senario',
      'navCommunity': 'Komuniti',
      'navProfile': 'Profil',

      // Desktop Presentation
      'desktopDashboard':
          '🖥️ Papan Pemuka Persembahan Desktop (Penyegerakan Langsung)',
      'destroySession': 'Musnahkan Sesi',
      'activeSessionStats': 'Statistik Sesi Aktif',
      'liveLogs': 'Log Soal Jawab Komuniti Langsung',
    },
  };

  /// Detects browser language dynamically.
  /// If the browser language is unlisted, it auto-registers an English baseline
  /// so future reads hit memory instantly without redundant translation calls.
  static String getBrowserLanguageCode() {
    try {
      final Locale browserLocale = PlatformDispatcher.instance.locale;
      final String code = browserLocale.languageCode.toLowerCase();

      if (_localizedValues.containsKey(code)) {
        return code;
      } else {
        debugPrint(
            '🌐 [Localization] Browser language "$code" not registered. Auto-registering fallback dictionary.');
        _localizedValues[code] = Map.from(_localizedValues['en']!);
        return code;
      }
    } catch (e) {
      debugPrint(
          "⚠️ [Localization] Language detection error, defaulting to 'en': $e");
      return 'en';
    }
  }

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      true; // Allows dynamic browser languages to load

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
