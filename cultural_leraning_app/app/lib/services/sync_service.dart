import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cultural_models.dart';

class AppState extends ChangeNotifier {
  String _selectedCountryId = 'japan';
  String? _selectedScenarioId;
  bool _isPresentationMode = false;
  Map<String, dynamic> _userProfile = {
    'proficiency': 'Beginner',
    'intent': 'Travel'
  };
  List<QAPost> _qaPosts = [];

  String get selectedCountryId => _selectedCountryId;
  String? get selectedScenarioId => _selectedScenarioId;
  bool get isPresentationMode => _isPresentationMode;
  Map<String, dynamic> get userProfile => _userProfile;
  List<QAPost> get qaPosts => _qaPosts;

  CountryData get currentCountry =>
      kCountriesDataset[_selectedCountryId] ?? kCountriesDataset['japan']!;

  List<Flashcard> get filteredFlashcards {
    var cards = currentCountry.flashcards;
    if (_selectedScenarioId != null) {
      cards = cards.where((c) => c.scenarioId == _selectedScenarioId).toList();
    }
    return cards;
  }

  AppState() {
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('qa_posts');
    if (postsJson != null) {
      final List decoded = jsonDecode(postsJson);
      _qaPosts = decoded.map((e) => QAPost.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> savePost(QAPost post) async {
    _qaPosts.insert(0, post);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'qa_posts', jsonEncode(_qaPosts.map((e) => e.toJson()).toList()));
  }

  void setCountry(String countryId) {
    _selectedCountryId = countryId;
    _selectedScenarioId = null;
    notifyListeners();
  }

  void setScenario(String? scenarioId) {
    _selectedScenarioId = scenarioId;
    notifyListeners();
  }

  void updateProfile(Map<String, dynamic> newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }

  void togglePresentationMode() {
    _isPresentationMode = !_isPresentationMode;
    notifyListeners();
  }

  // Auto-AI Fallback Generator for Community Q&A
  String generateAIAnswer(String question, String countryId) {
    final q = question.toLowerCase();
    if (q.contains('tip') || q.contains('etiquette')) {
      return 'AI Assistant: Always respect local customs, bow slightly when greeting in Japan, and observe modest dress codes in public areas.';
    } else if (q.contains('food') || q.contains('eat')) {
      return 'AI Assistant: Local dining features vibrant street food culture. Remember to use appropriate utensils and try regional specialties!';
    }
    return 'AI Assistant: Great question about $countryId! Local community guidelines recommend checking official travel handbooks or asking local guides for authentic insights.';
  }
}
