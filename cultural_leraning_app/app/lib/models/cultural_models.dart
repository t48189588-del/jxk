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
          description: 'jp on subways and Shinkansen'),
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
          description: 'Cherry blossom viewing jp'),
    ],
    flashcards: [
      Flashcard(
        id: 'jp_1',
        phrase: '電車やバスでの通話は控えましょう',
        pronunciation: 'Densha ya basu de no tsuwa wa hikaemashou',
        translation: 'Do not make phone calls on trains or buses',
        scenarioId: 'commute',
        imageUrl: 'assets/images/1.png',
        culturalNote:
            'This is a way to respect other passengers quiet time and privacy in crowded vehicles.',
      ),
      Flashcard(
        id: 'jp_2',
        phrase: '家に入る時は靴を脱ぎましょう',
        pronunciation: 'Ie ni hairu toki wa kutsu o nugimashou',
        translation: 'Take off your shoes when entering a home',
        scenarioId: 'housing',
        imageUrl: 'assets/images/2.png',
        culturalNote:
            'Prevents dirt from outside and keeps tatami mats or indoor flooring clean.',
      ),
      Flashcard(
        id: 'jp_3',
        phrase: 'いただきます',
        pronunciation: 'Itadakimasu',
        translation: 'Say “Itadakimasu” before eating',
        scenarioId: 'dining',
        imageUrl: 'assets/images/3.png',
        culturalNote:
            'Expresses gratitude toward the food, ingredients, and people who prepared the meal.',
      ),
      Flashcard(
        id: 'jp_4',
        phrase: 'ごちそうさまでした',
        pronunciation: 'Gochisousama deshita',
        translation: 'Say “Gochisosama deshita” after eating',
        scenarioId: 'dining',
        imageUrl: 'assets/images/4.png',
        culturalNote:
            'Shows appreciation to the preparers and indicates that the meal has finished.',
      ),
      Flashcard(
        id: 'jp_5',
        phrase: '箸を立てない',
        pronunciation: 'Hashi o tatenai',
        translation: 'Do not stick chopsticks vertically into food',
        scenarioId: 'dining',
        imageUrl: 'assets/images/5.png',
        culturalNote:
            'Known as Tate-bashi; it is associated with Buddhist funeral rituals and avoided during meals.',
      ),
      Flashcard(
        id: 'jp_6',
        phrase: '温泉に入る前に体を洗いましょう',
        pronunciation: 'Onsen ni hairu mae ni karada o araimashou',
        translation: 'Wash your body before entering an onsen',
        scenarioId: 'onsen',
        imageUrl: 'assets/images/6.png',
        culturalNote:
            'Keeping the shared bathtub water clean is an essential part of Japanese bathing etiquette.',
      ),
      Flashcard(
        id: 'jp_7',
        phrase: '湯船にタオルを入れない',
        pronunciation: 'Yubune ni taoru o irenai',
        translation: 'Do not put your towel in the bathtub',
        scenarioId: 'onsen',
        imageUrl: 'assets/images/7.png',
        culturalNote:
            'Prevents dirt or soap from getting into the shared bathwater; place towels outside instead.',
      ),
      Flashcard(
        id: 'jp_8',
        phrase: '列に割り込まない',
        pronunciation: 'Retsuni warikomanai',
        translation: 'Do not cut in line',
        scenarioId: 'public',
        imageUrl: 'assets/images/8.png',
        culturalNote:
            'Shows respect for other people waiting time and order at stations, events, and shops.',
      ),
      Flashcard(
        id: 'jp_9',
        phrase: 'ゴミを持ち帰りましょう',
        pronunciation: 'Gomi o mochikaerimashou',
        translation: 'Take your trash with you',
        scenarioId: 'public',
        imageUrl: 'assets/images/9.png',
        culturalNote:
            'Due to few public bins, managing and packing out your own waste helps keep public spaces clean.',
      ),
      Flashcard(
        id: 'jp_10',
        phrase: 'お邪魔します',
        pronunciation: 'Ojama shimasu',
        translation: 'Say “Ojama shimasu” when entering someone’s home',
        scenarioId: 'housing',
        imageUrl: 'assets/images/10.png',
        culturalNote:
            'Literally means "I am disturbing you" and expresses respect when entering personal space.',
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
