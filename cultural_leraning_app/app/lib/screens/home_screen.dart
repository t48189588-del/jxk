import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cultural_models.dart'; // Added missing import
import '../providers/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final flashcards = appState.filteredFlashcards;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Country Selector Pill Bar
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: kCountriesDataset.keys.map((id) {
                final country = kCountriesDataset[id]!;
                final isSelected = appState.selectedCountryId == id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text('${country.flagEmoji} ${country.name}'),
                    selected: isSelected,
                    selectedColor: Colors.deepOrange.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.deepOrange.shade900
                          : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _isFlipped = false);
                      appState.setCountry(id);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Active Scenario Banner if filtered
          if (appState.selectedScenarioId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtered by Scenario active',
                    style: TextStyle(
                        color: Colors.deepOrange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => appState.setScenario(null),
                    child: const Text('Clear filter',
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 12,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          // Flashcards View
          Expanded(
            child: flashcards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No flashcards found for this scenario.',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => appState.setScenario(null),
                          child: const Text('Show All Cards'),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    itemCount: flashcards.length,
                    onPageChanged: (_) => setState(() => _isFlipped = false),
                    itemBuilder: (context, index) {
                      final card = flashcards[index];
                      return GestureDetector(
                        onTap: () => setState(() => _isFlipped = !_isFlipped),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(card.imageUrl,
                                          fit: BoxFit.cover),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                              '${index + 1} / ${flashcards.length}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isFlipped
                                            ? card.translation
                                            : card.phrase,
                                        style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isFlipped
                                            ? 'Translation (Tap to flip back)'
                                            : card.pronunciation,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: _isFlipped
                                                ? Colors.deepOrange
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          card.culturalNote,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                          '💡 Tap card to flip translation',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
