import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera init error: $e');
  }
  runApp(const CulturalSuiteApp());
}

class CulturalSuiteApp extends StatelessWidget {
  const CulturalSuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cultural Micro-Apps Suite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // Heritage brown/cultural tone
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD2691E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MasterHubScreen(),
    );
  }
}

class MasterHubScreen extends StatefulWidget {
  const MasterHubScreen({super.key});

  @override
  State<MasterHubScreen> createState() => _MasterHubScreenState();
}

class _MasterHubScreenState extends State<MasterHubScreen> {
  int _currentSubApp = 0;
  bool _isDesktopPresentationMode = false;

  final List<String> _subAppTitles = [
    'Sub App 0: Cultural PWA & Presentation',
    'Sub App 1: Cultural Cooking Helper',
    'Sub App 2: Cultural Posture & Ergonomics',
    'Sub App 3: Cultural Artifact & Tool Sorter',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;

    final Widget activeAppWidget = switch (_currentSubApp) {
      0 => const CulturalLearningPWAScreen(),
      1 => const CulturalCookingHelperScreen(),
      2 => const CulturalPostureSystemScreen(),
      3 => const CulturalToolSorterScreen(),
      _ => const CulturalLearningPWAScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_subAppTitles[_currentSubApp]),
        actions: [
          IconButton(
            icon: Icon(
              _isDesktopPresentationMode
                  ? Icons.phone_iphone
                  : Icons.desktop_windows,
            ),
            tooltip: 'Toggle Mobile Frame / Desktop Presentation',
            onPressed: () {
              setState(() {
                _isDesktopPresentationMode = !_isDesktopPresentationMode;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentSubApp,
              onDestinationSelected: (index) =>
                  setState(() => _currentSubApp = index),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.school),
                  label: Text('Culture Hub'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.soup_kitchen),
                  label: Text('Cooking'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.accessibility),
                  label: Text('Posture'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.handyman),
                  label: Text('Tool Sorter'),
                ),
              ],
            ),
          if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: _isDesktopPresentationMode && isWideScreen
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 430),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.brown, width: 8),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black26,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: activeAppWidget,
                      ),
                    )
                  : activeAppWidget,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _currentSubApp,
              onDestinationSelected: (index) =>
                  setState(() => _currentSubApp = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.school),
                  label: 'Culture',
                ),
                NavigationDestination(
                  icon: Icon(Icons.soup_kitchen),
                  label: 'Kitchen',
                ),
                NavigationDestination(
                  icon: Icon(Icons.accessibility),
                  label: 'Posture',
                ),
                NavigationDestination(
                  icon: Icon(Icons.handyman),
                  label: 'Tools',
                ),
              ],
            ),
    );
  }
}

// =========================================================================
// CAM-PERMISSION MIXIN FOR LOCAL HARDWARE/BROWSER CAPTURE
// =========================================================================
mixin CameraPermissionMixin<T extends StatefulWidget> on State<T> {
  bool isCameraGranted = false;
  CameraController? cameraController;
  String camError = '';

  Future<void> initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => isCameraGranted = true);
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        try {
          await cameraController!.initialize();
          setState(() {});
        } catch (e) {
          setState(() => camError = 'Camera init failed: $e');
        }
      } else {
        setState(() => camError = 'No camera sensors available.');
      }
    } else {
      setState(() {
        isCameraGranted = false;
        camError = 'Camera access denied by user.';
      });
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}

// =========================================================================
// SUB APP 0: CULTURAL LEARNING PWA & DESKTOP PRESENTATION MODE
// =========================================================================
class CulturalLearningPWAScreen extends StatefulWidget {
  const CulturalLearningPWAScreen({super.key});

  @override
  State<CulturalLearningPWAScreen> createState() =>
      _CulturalLearningPWAScreenState();
}

class _CulturalLearningPWAScreenState extends State<CulturalLearningPWAScreen> {
  String selectedCountry = 'Japan';
  String selectedScenario = 'All';
  int activeTab =
      0; // 0: Flashcards, 1: Scenarios Grid, 2: Community Q&A, 3: Profile Questionnaire

  // Mock Country Database with Unsplash Placeholders & Phrases
  final Map<String, List<Map<String, String>>> countryDatasets = {
    'Japan': [
      {
        'phrase': 'Konnichiwa',
        'translation': 'Hello',
        'pronunciation': 'Kohn-nee-chee-wah',
        'scenario': 'At School',
        'img': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26',
      },
      {
        'phrase': 'Arigatou',
        'translation': 'Thank you',
        'pronunciation': 'Ah-ree-gah-toh',
        'scenario': 'Convenience Store',
        'img': 'https://images.unsplash.com/photo-1542051841857-5f90071e7989',
      },
      {
        'phrase': 'Sumimasen',
        'translation': 'Excuse me / Sorry',
        'pronunciation': 'Soo-mee-mah-sen',
        'scenario': 'Asking Directions',
        'img': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
      },
      {
        'phrase': 'Sakura',
        'translation': 'Cherry Blossom',
        'pronunciation': 'Sah-koo-rah',
        'scenario': 'Sakura Season',
        'img': 'https://images.unsplash.com/photo-1522383225653-ed111181a951',
      },
    ],
    'Malaysia': [
      {
        'phrase': 'Selamat Pagi',
        'translation': 'Good Morning',
        'pronunciation': 'Se-la-mat Pa-gi',
        'scenario': 'During Commuting',
        'img': 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07',
      },
      {
        'phrase': 'Terima Kasih',
        'translation': 'Thank you',
        'pronunciation': 'Te-ri-ma Ka-sih',
        'scenario': 'Convenience Store',
        'img': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc',
      },
      {
        'phrase': 'Tumpang Lalu',
        'translation': 'Excuse me',
        'pronunciation': 'Tum-pang La-lu',
        'scenario': 'Asking Directions',
        'img': 'https://images.unsplash.com/photo-1569154941061-e231b4725ef1',
      },
    ],
    'Panama': [
      {
        'phrase': '¡Xopa / Qué xopa!',
        'translation': 'What’s up?',
        'pronunciation': 'Soh-pah',
        'scenario': 'At School',
        'img': 'https://images.unsplash.com/photo-1512813098764-bd80373e4b7c',
      },
      {
        'phrase': 'Muchas Gracias',
        'translation': 'Thank you very much',
        'pronunciation': 'Moo-chas Grah-syahs',
        'scenario': 'Convenience Store',
        'img': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
      },
      {
        'phrase': 'Disculpe',
        'translation': 'Excuse me',
        'pronunciation': 'Dees-kool-peh',
        'scenario': 'Asking Directions',
        'img': 'https://images.unsplash.com/photo-1569154941061-e231b4725ef1',
      },
    ],
  };

  final List<String> scenariosList = [
    'All',
    'At School',
    'During Commuting',
    'Convenience Store',
    'Asking Directions',
    'Sakura Season',
  ];

  // Community Q&A State
  final List<Map<String, String>> qaList = [
    {
      'q':
          'What is the customary greeting when entering a traditional tea house?',
      'a':
          'Auto-AI Answer: Bow slightly and gently slide open the shoji door while greeting staff with regional respect.',
    },
  ];
  final TextEditingController qaController = TextEditingController();

  // Persona State
  String userProficiency = 'Beginner';
  String travelIntent = 'Tourism';

  // Desktop Presentation Mode Overlay Toggle
  bool showPresentationModal = false;

  @override
  Widget build(BuildContext context) {
    final cards = countryDatasets[selectedCountry] ?? [];
    final filteredCards = selectedScenario == 'All'
        ? cards
        : cards.where((c) => c['scenario'] == selectedScenario).toList();

    return Scaffold(
      body: Column(
        children: [
          // Top Country Pill Selector & Desktop Presentation Trigger Bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: countryDatasets.keys.map((country) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(country),
                            selected: selectedCountry == country,
                            onSelected: (selected) {
                              if (selected)
                                setState(() => selectedCountry = country);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.present_to_all, size: 16),
                  label: const Text('Desktop View'),
                  onPressed: () => setState(() => showPresentationModal = true),
                ),
              ],
            ),
          ),

          // Main View Tabs
          Expanded(
            child: Stack(
              children: [
                IndexedStack(
                  index: activeTab,
                  children: [
                    // Screen 0: Flashcards
                    _buildFlashcardView(filteredCards),
                    // Screen 1: Scenarios Grid
                    _buildScenariosGrid(),
                    // Screen 2: Community Q&A with Auto-AI fallback
                    _buildCommunityQAView(),
                    // Screen 3: Personalization & Profile Builder
                    _buildProfileBuilderView(),
                  ],
                ),
                if (showPresentationModal) _buildDesktopPresentationOverlay(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeTab,
        onTap: (idx) => setState(() => activeTab = idx),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Flashcards'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Scenarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Community Q&A',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFlashcardView(List<Map<String, String>> cards) {
    if (cards.isEmpty) {
      return const Center(
        child: Text(
          'No flashcards found for this scenario. Try selecting "All".',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                card['img']!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['phrase']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pronunciation: ${card['pronunciation']}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Translation: ${card['translation']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text('Scenario: ${card['scenario']}'),
                      backgroundColor: Colors.amber.shade100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScenariosGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: scenariosList.length,
      itemBuilder: (context, index) {
        final sc = scenariosList[index];
        return InkWell(
          onTap: () {
            setState(() {
              selectedScenario = sc;
              activeTab = 0; // jump to flashcards with filter applied
            });
          },
          child: Card(
            elevation: 3,
            color: selectedScenario == sc ? Colors.brown.shade100 : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityQAView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: qaList.length,
            itemBuilder: (context, index) {
              final item = qaList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q: ${item['q']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item['a']}',
                        style: TextStyle(color: Colors.brown.shade800),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qaController,
                  decoration: const InputDecoration(
                    hintText: 'Ask a cultural question...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (qaController.text.trim().isNotEmpty) {
                    setState(() {
                      String q = qaController.text.trim();
                      String aiAnswer =
                          'Auto-AI Answer: Regarding "$q", local traditions emphasize polite reverence, mindful observation of local customs, and asking elders for guidance.';
                      qaList.add({'q': q, 'a': aiAnswer});
                      qaController.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileBuilderView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Cultural Learner Persona Builder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Select your proficiency level:'),
        DropdownButton<String>(
          value: userProficiency,
          items: [
            'Beginner',
            'Intermediate',
            'Advanced',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) =>
              setState(() => userProficiency = val ?? 'Beginner'),
        ),
        const SizedBox(height: 20),
        const Text('Primary Travel / Cultural Interest:'),
        DropdownButton<String>(
          value: travelIntent,
          items: [
            'Tourism',
            'Business Protocol',
            'Heritage Study',
            'Culinary Arts',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => travelIntent = val ?? 'Tourism'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Persona saved locally! Tagged for $userProficiency in $travelIntent.',
                ),
              ),
            );
          },
          child: const Text('Save Local Persona Profile'),
        ),
      ],
    );
  }

  Widget _buildDesktopPresentationOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: math.min(MediaQuery.of(context).size.width * 0.85, 700),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🖥️ Desktop Presentation Dashboard',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.monitor),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Text('Active Country Focus: $selectedCountry'),
              Text('Selected Scenario Filter: $selectedScenario'),
              Text('Current Learner Persona: $userProficiency / $travelIntent'),
              Text('Community Q&A Active Log Count: ${qaList.length} posts'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        setState(() => showPresentationModal = false),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        qaList.clear();
                        showPresentationModal = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Presentation session data wiped cleanly.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Destroy Session'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// SUB APP 1: CULTURAL COOKING HELPER
// =========================================================================
class CulturalCookingHelperScreen extends StatefulWidget {
  const CulturalCookingHelperScreen({super.key});

  @override
  State<CulturalCookingHelperScreen> createState() =>
      _CulturalCookingHelperScreenState();
}

class _CulturalCookingHelperScreenState
    extends State<CulturalCookingHelperScreen>
    with CameraPermissionMixin {
  int cookStep = 1;
  String? chosenRecipe;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                camError.isNotEmpty
                    ? camError
                    : 'Camera permission needed for ingredient recognition.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: initCamera,
                child: const Text('Grant Camera Access'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: switch (cookStep) {
        1 => _buildCameraCaptureScreen(),
        2 => _buildRecognizedIngredientsScreen(),
        _ => _buildRecipeDetailScreen(),
      },
    );
  }

  Widget _buildCameraCaptureScreen() {
    return Column(
      children: [
        Expanded(
          child:
              cameraController != null && cameraController!.value.isInitialized
              ? CameraPreview(cameraController!)
              : const Center(child: CircularProgressIndicator()),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Local Ingredients Pile'),
            onPressed: () => setState(() => cookStep = 2),
          ),
        ),
      ],
    );
  }

  Widget _buildRecognizedIngredientsScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recognized Heritage Ingredients:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('🌿 Lemongrass')),
            Chip(label: Text('🥥 Fresh Coconut Milk')),
            Chip(label: Text('🧄 Galangal Root')),
            Chip(label: Text('🌶️ Bird’s Eye Chili')),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Top 2 Cultural Recipe Matches:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Traditional Nyonya Laksa Broth'),
            subtitle: const Text(
              'Match: 96% | Time: 40 mins | Heritage Classic',
            ),
            onTap: () => setState(() {
              chosenRecipe = 'Traditional Nyonya Laksa Broth';
              cookStep = 3;
            }),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Aromatic Rendang Spice Stew'),
            subtitle: const Text('Match: 89% | Time: 60 mins | Slow-cooked'),
            onTap: () => setState(() {
              chosenRecipe = 'Aromatic Rendang Spice Stew';
              cookStep = 3;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeDetailScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            'Selected Recipe: $chosenRecipe',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '⏱️ Timing: 40 mins total preparation and simmer time',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const Text(
            '🔥 Techniques: Rempah pounding, oil extraction, slow simmering',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            'Step 1: Pound galangal, lemongrass, and chili into a smooth aromatic paste.\n\n'
            'Step 2: Sauté the paste in warm wok oil until fragrant and oil separates.\n\n'
            'Step 3: Pour in fresh coconut milk and simmer gently until rich and creamy.',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => cookStep = 1),
            child: const Text('Scan New Ingredients'),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// SUB APP 2: CULTURAL POSTURE & ERGONOMICS SYSTEM
// =========================================================================
class CulturalPostureSystemScreen extends StatefulWidget {
  const CulturalPostureSystemScreen({super.key});

  @override
  State<CulturalPostureSystemScreen> createState() =>
      _CulturalPostureSystemScreenState();
}

class _CulturalPostureSystemScreenState
    extends State<CulturalPostureSystemScreen>
    with CameraPermissionMixin {
  bool showCorrectOverlay = false;
  String reminderInterval = 'Every 30 min';
  bool reminderActive = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                camError.isNotEmpty
                    ? camError
                    : 'Camera needed for posture/ergonomics tracking.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: initCamera,
                child: const Text('Grant Camera Access'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture & Ergonomic Guide'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () =>
                setState(() => showCorrectOverlay = !showCorrectOverlay),
            child: Text(
              showCorrectOverlay
                  ? 'Hide Correct Guide'
                  : 'Show Correct Posture',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            Center(child: CameraPreview(cameraController!))
          else
            const Center(child: CircularProgressIndicator()),

          // Skeleton / Joint Overlay Painter
          CustomPaint(
            painter: CulturalPosturePainter(isCorrect: showCorrectOverlay),
            child: Container(),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showCorrectOverlay
                          ? '✅ Ideal Ergonomic Alignment (Spine vertical, neck upright).'
                          : '⚠️ Actual Posture Detected: Forward head tilt observed during study.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Reminder:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: reminderInterval,
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(color: Colors.white),
                          items:
                              [
                                    'Every 30 min',
                                    'Every 45 min',
                                    'Every 1 hour',
                                    'Every 2 hour',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(
                            () => reminderInterval = val ?? 'Every 30 min',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CulturalPosturePainter extends CustomPainter {
  final bool isCorrect;
  const CulturalPosturePainter({required this.isCorrect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCorrect ? Colors.greenAccent : Colors.deepOrangeAccent
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Head joint
    canvas.drawCircle(Offset(center.dx, center.dy - 110), 20, paint);
    // Spine line
    canvas.drawLine(
      Offset(center.dx, center.dy - 90),
      Offset(center.dx, center.dy + 90),
      paint,
    );
    // Shoulder line
    canvas.drawLine(
      Offset(center.dx - 70, center.dy - 40),
      Offset(center.dx + 70, center.dy - 40),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CulturalPosturePainter oldDelegate) {
    return oldDelegate.isCorrect != isCorrect;
  }
}

// =========================================================================
// SUB APP 3: CULTURAL TOOL & ARTIFACT SORTER
// =========================================================================
class CulturalToolSorterScreen extends StatefulWidget {
  const CulturalToolSorterScreen({super.key});

  @override
  State<CulturalToolSorterScreen> createState() =>
      _CulturalToolSorterScreenState();
}

class _CulturalToolSorterScreenState extends State<CulturalToolSorterScreen>
    with CameraPermissionMixin {
  String? inspectedTool;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                camError.isNotEmpty
                    ? camError
                    : 'Camera needed for artifact edge detection.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: initCamera,
                child: const Text('Grant Camera Access'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            Center(child: CameraPreview(cameraController!))
          else
            const Center(child: CircularProgressIndicator()),

          // Interactive Edge Hotspot
          GestureDetector(
            onTapDown: (details) {
              setState(() {
                inspectedTool =
                    'Traditional Hand-Forged Chisel (Tansu Carving Tool): Used for intricate woodworking and joinery.';
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 160,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyanAccent, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Tap Edge',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (inspectedTool != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                elevation: 6,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        inspectedTool!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() => inspectedTool = null),
                        child: const Text('Close Popup'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
