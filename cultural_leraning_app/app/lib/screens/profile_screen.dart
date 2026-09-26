import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _proficiency;
  late String _intent;

  final List<String> _proficiencyOptions = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];
  // Ensure default values match items list precisely
  final List<String> _intentOptions = [
    'Travel',
    'Business',
    'Culture & Media',
    'Relocation'
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppState>(context, listen: false).userProfile;

    // Validate or fallback to valid items
    String loadedProficiency = profile['proficiency'] ?? 'Beginner';
    _proficiency = _proficiencyOptions.contains(loadedProficiency)
        ? loadedProficiency
        : 'Beginner';

    String loadedIntent = profile['intent'] ?? 'Travel';
    _intent = _intentOptions.contains(loadedIntent) ? loadedIntent : 'Travel';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personalization & Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Configure your learner persona stored locally.',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          const Text('Proficiency Level',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _proficiency,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _proficiencyOptions.map((val) {
              return DropdownMenuItem(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _proficiency = val);
            },
          ),
          const SizedBox(height: 20),
          const Text('Primary Travel / Learning Intent',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _intent,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _intentOptions.map((val) {
              return DropdownMenuItem(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _intent = val);
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                appState.updateProfile({
                  'proficiency': _proficiency,
                  'intent': _intent,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Persona preferences saved to LocalStorage!')),
                );
              },
              child: const Text('Save Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
