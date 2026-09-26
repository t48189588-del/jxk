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
    'intent': 'Travel',
    'interests': ['Food & Dining', 'Etiquette']
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

    // Load Q&A posts
    final postsJson = prefs.getString('qa_posts');
    if (postsJson != null) {
      final List decoded = jsonDecode(postsJson);
      _qaPosts = decoded.map((e) => QAPost.fromJson(e)).toList();
    }

    // Load User Profile
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _userProfile = jsonDecode(profileJson);
    }
    notifyListeners();
  }

  Future<void> savePost(QAPost post) async {
    _qaPosts.insert(0, post);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'qa_posts', jsonEncode(_qaPosts.map((e) => e.toJson()).toList()));
  }

  Future<void> updateProfile(Map<String, dynamic> newProfile) async {
    _userProfile = newProfile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_userProfile));
  }

  void setCountry(String countryId) {
    _selectedCountryId = countryId;
    _selectedScenarioId = null; // Reset scenario filter on country change
    notifyListeners();
  }

  void setScenario(String? scenarioId) {
    _selectedScenarioId = scenarioId;
    notifyListeners();
  }

  void togglePresentationMode() {
    _isPresentationMode = !_isPresentationMode;
    notifyListeners();
  }

  // Auto-AI Fallback Generator for Community Q&A matching HTML behavior
  String generateAIAnswer(String question, String countryName) {
    final q = question.toLowerCase();
    if (q.contains('tip') || q.contains('tipping')) {
      return 'Auto-AI Assistant: Tipping is generally not expected or practiced in $countryName. Excellent service is considered standard cultural hospitality!';
    } else if (q.contains('train') ||
        q.contains('subway') ||
        q.contains('commute')) {
      return 'Auto-AI Assistant: On public transit in $countryName, keep your phone on silent mode, avoid loud phone calls, and queue orderly at platform markers.';
    } else if (q.contains('eat') ||
        q.contains('food') ||
        q.contains('restaurant')) {
      return 'Auto-AI Assistant: Pay attention to local dining rules—such as placing chopsticks on rests, waiting for everyone to be served before eating, or slurping noodles respectfully.';
    }
    return 'Auto-AI Assistant: Great question regarding $countryName culture! Local community guidelines recommend observing local peers or checking regional travel guides for authentic etiquette.';
  }
}
