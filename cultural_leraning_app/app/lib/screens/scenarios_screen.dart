import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'mobile_shell.dart';

class ScenariosScreen extends StatelessWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final country = appState.currentCountry;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cultural Scenarios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
              'Select a scenario for ${country.name} to filter flashcards instantly.',
              style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Dynamically adjust grid columns based on browser width
                int crossAxisCount = constraints.maxWidth > 1100
                    ? 4
                    : (constraints.maxWidth > 700 ? 3 : 2);

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: country.scenarios.length,
                  itemBuilder: (context, index) {
                    final scenario = country.scenarios[index];
                    final isSelected =
                        appState.selectedScenarioId == scenario.id;

                    return InkWell(
                      onTap: () {
                        appState.setScenario(isSelected ? null : scenario.id);
                        MobileShell.switchTab(context, 0);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepOrange.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepOrange
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.bookmark_border,
                              color: isSelected
                                  ? Colors.deepOrange
                                  : Colors.grey.shade700,
                              size: 36,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              scenario.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.deepOrange.shade900
                                    : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
