class Flashcard {
  final String id;
  final String phrase;
  final String pronunciation;
  final String translation;
  final String scenarioId;
  final String imageUrl;
  final String culturalNote;

  Flashcard({
    required this.id,
    required this.phrase,
    required this.pronunciation,
    required this.translation,
    required this.scenarioId,
    required this.imageUrl,
    required this.culturalNote,
  });
}

class Scenario {
  final String id;
  final String title;
  final String icon;
  final String description;

  Scenario(
      {required this.id,
      required this.title,
      required this.icon,
      required this.description});
}

class CountryData {
  final String id;
  final String name;
  final String flagEmoji;
  final List<Scenario> scenarios;
  final List<Flashcard> flashcards;

  CountryData({
    required this.id,
    required this.name,
    required this.flagEmoji,
    required this.scenarios,
    required this.flashcards,
  });
}

class QAPost {
  final String id;
  final String user;
  final String question;
  final String answer;
  final String countryId;
  final DateTime timestamp;

  QAPost({
    required this.id,
    required this.user,
    required this.question,
    required this.answer,
    required this.countryId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'question': question,
        'answer': answer,
        'countryId': countryId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory QAPost.fromJson(Map<String, dynamic> json) => QAPost(
        id: json['id'],
        user: json['user'],
        question: json['question'],
        answer: json['answer'],
        countryId: json['countryId'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

// Robust Pre-populated Datasets
final Map<String, CountryData> kCountriesDataset = {
  'japan': CountryData(
    id: 'japan',
    name: 'Japan',
    flagEmoji: '🇯🇵',
    scenarios: [
      Scenario(
          id: 'commute',
          title: 'Train Commuting',
          icon: 'train',
          description: 'Etiquette on subways and Shinkansen'),
      Scenario(
          id: 'store',
          title: 'Convenience Store',
          icon: 'store',
          description: 'Interacting at Lawson, 7-Eleven, or FamilyMart'),
      Scenario(
          id: 'dining',
          title: 'Izakaya & Dining',
          icon: 'restaurant',
          description: 'Ordering food and saying Kampai'),
      Scenario(
          id: 'sakura',
          title: 'Sakura Season',
          icon: 'local_florist',
          description: 'Cherry blossom viewing etiquette'),
    ],
    flashcards: [
      Flashcard(
        id: 'jp_1',
        phrase: 'こんにちは',
        pronunciation: 'Konnichiwa',
        translation: 'Hello / Good afternoon',
        scenarioId: 'store',
        imageUrl:
            'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80',
        culturalNote:
            'Used during daytime hours when greeting acquaintances or staff.',
      ),
      Flashcard(
        id: 'jp_2',
        phrase: 'ありがとうございます',
        pronunciation: 'Arigatou gozaimasu',
        translation: 'Thank you very much',
        scenarioId: 'store',
        imageUrl:
            'https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=800&q=80',
        culturalNote:
            'Polite form used in shops, restaurants, and professional settings.',
      ),
      Flashcard(
        id: 'jp_3',
        phrase: 'すみません',
        pronunciation: 'Sumimasen',
        translation: 'Excuse me / I am sorry',
        scenarioId: 'commute',
        imageUrl:
            'https://images.unsplash.com/photo-1528164344705-475426879c0d?auto=format&fit=crop&w=800&q=80',
        culturalNote:
            'Extremely versatile: used to get attention, apologize, or show gratitude.',
      ),
      Flashcard(
        id: 'jp_4',
        phrase: '乾杯！',
        pronunciation: 'Kampai!',
        translation: 'Cheers!',
        scenarioId: 'dining',
        imageUrl:
            'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=800&q=80',
        culturalNote: 'Raise your glass together after everyone is served.',
      ),
    ],
  ),
  'malaysia': CountryData(
    id: 'malaysia',
    name: 'Malaysia',
    flagEmoji: '🇲🇾',
    scenarios: [
      Scenario(
          id: 'market',
          title: 'Night Market',
          icon: 'shopping_basket',
          description: 'Navigating local hawker stalls'),
      Scenario(
          id: 'greeting',
          title: 'Polite Greetings',
          icon: 'handshake',
          description: 'Multicultural greetings across communities'),
    ],
    flashcards: [
      Flashcard(
        id: 'my_1',
        phrase: 'Terima kasih',
        pronunciation: 'Te-ree-mah kah-seh',
        translation: 'Thank you',
        scenarioId: 'market',
        imageUrl:
            'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&w=800&q=80',
        culturalNote: 'Standard Malay expression of gratitude.',
      ),
      Flashcard(
        id: 'my_2',
        phrase: 'Selamat pagi',
        pronunciation: 'Se-la-mat pah-gee',
        translation: 'Good morning',
        scenarioId: 'greeting',
        imageUrl:
            'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?auto=format&fit=crop&w=800&q=80',
        culturalNote: 'Used universally in morning hours.',
      ),
    ],
  ),
};
