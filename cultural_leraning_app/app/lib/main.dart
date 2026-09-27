import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_state.dart';
import 'screens/mobile_shell.dart';
import 'l10n/app_localizations.dart'; // <-- Added localization import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable offline persistence for Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print("Firebase Init Error: $e");
  }

  // Detect and log browser language on startup
  final detectedLang = AppLocalizations.getBrowserLanguageCode();
  print('🚀 [App] Initialized with browser language: $detectedLang');

  runApp(
    // ProviderScope enables Riverpod providers (like signAnalyzerStateProvider)
    const ProviderScope(
      child: CulturalLearningApp(),
    ),
  );
}

class CulturalLearningApp extends StatelessWidget {
  const CulturalLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialLang = AppLocalizations.getBrowserLanguageCode();

    // Wrapped in provider.ChangeNotifierProvider to avoid naming conflicts with Riverpod's Provider
    return provider.ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Travel link',
        debugShowCheckedModeBanner: false,
        locale: Locale(initialLang),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('ja', 'JP'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const MobileShell(),
      ),
    );
  }
}
