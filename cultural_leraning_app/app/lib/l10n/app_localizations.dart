class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Cultural Link PWA',
      'home': 'Home',
      'scenarios': 'Scenarios',
      'qa': 'Community Q&A',
      'profile': 'Profile',
      'presentationMode': 'Presentation Mode',
      'welcomeHeading': 'Explore World Cultures',
      'welcomeSubtitle':
          'Interactive learning, scenarios, and community guidance.',
      'searchPlaceholder': 'Search cultural guides...',
      'askButton': 'Ask AI Assistant',
    },
    'es': {
      'appTitle': 'Enlace Cultural PWA',
      'home': 'Inicio',
      'scenarios': 'Escenarios',
      'qa': 'Preguntas y Respuestas',
      'profile': 'Perfil',
      'presentationMode': 'Modo Presentación',
      'welcomeHeading': 'Explora Culturas del Mundo',
      'welcomeSubtitle':
          'Aprendizaje interactivo, escenarios y guía comunitaria.',
      'searchPlaceholder': 'Buscar guías culturales...',
      'askButton': 'Preguntar al Asistente IA',
    },
    'ja': {
      'appTitle': 'カルチュラル・リンク PWA',
      'home': 'ホーム',
      'scenarios': 'シナリオ',
      'qa': 'コミュニティQ&A',
      'profile': 'プロフィール',
      'presentationMode': 'プレゼンテーションモード',
      'welcomeHeading': '世界の文化を探索する',
      'welcomeSubtitle': 'インタラクティブな学習、シナリオ、コミュニティガイド。',
      'searchPlaceholder': '文化ガイドを検索...',
      'askButton': 'AIアシスタントに質問する',
    },
    'fr': {
      'appTitle': 'Lien Culturel PWA',
      'home': 'Accueil',
      'scenarios': 'Scénarios',
      'qa': 'Q&A Communautaire',
      'profile': 'Profil',
      'presentationMode': 'Mode Présentation',
      'welcomeHeading': 'Explorez les Cultures du Monde',
      'welcomeSubtitle':
          'Apprentissage interactif, scénarios et conseils communautaires.',
      'searchPlaceholder': 'Rechercher des guides culturels...',
      'askButton': 'Demander à l\'Assistant IA',
    },
  };

  static String get(String key, String langCode) {
    if (_localizedValues.containsKey(langCode) &&
        _localizedValues[langCode]!.containsKey(key)) {
      return _localizedValues[langCode]![key]!;
    }
    // Fallback to English if translation is missing
    return _localizedValues['en']?[key] ?? key;
  }
}
