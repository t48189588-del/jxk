import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class DesktopPresentationScreen extends StatelessWidget {
  const DesktopPresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('🖥️ Desktop Presentation Dashboard (Live Sync)'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text('Destroy Session',
                style: TextStyle(color: Colors.white)),
            onPressed: () => appState.togglePresentationMode(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                color: Colors.blueGrey[800],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Session Stats',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white54),
                      const SizedBox(height: 12),
                      Text(
                          'Selected Country: ${appState.currentCountry.name} ${appState.currentCountry.flagEmoji}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                          'Active Scenario: ${appState.selectedScenarioId ?? "None (All Cards)"}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                          'User Proficiency: ${appState.userProfile['proficiency']}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Travel Intent: ${appState.userProfile['intent']}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Card(
                color: Colors.blueGrey[800],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Community Q&A Logs',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white54),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: appState.qaPosts.length,
                          itemBuilder: (context, index) {
                            final post = appState.qaPosts[index];
                            return ListTile(
                              title: Text(post.question,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(post.answer,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              trailing: Text(post.user,
                                  style: const TextStyle(color: Colors.amber)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
