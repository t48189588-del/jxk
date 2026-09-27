import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart'; // --- LOCALIZATION --- Import localization class
import 'home_screen.dart';
import 'scenarios_screen.dart';
import 'qa_screen.dart';
import 'profile_screen.dart';
import 'desktop_presentation_screen.dart';
import 'sign_capture_screen.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MobileShellState>();
    state?.setTab(index);
  }

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScenariosScreen(),
    const QAScreen(),
    const ProfileScreen(),
  ];

  // Helper method to open the sign scanner with the current active country
  void _openSignScanner(BuildContext context, AppState appState) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignCaptureScreen(
          targetCountry: appState
              .currentCountry.name, // Passes current country dynamically!
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(
        context); // --- LOCALIZATION --- Initialize localizer

    if (appState.isPresentationMode) {
      return const DesktopPresentationScreen();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 768;

        // Desktop App Bar
        PreferredSizeWidget? desktopAppBar = isDesktop
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                title: Row(
                  children: [
                    Text(appState.currentCountry.flagEmoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(
                      'Travel link — ${appState.currentCountry.name}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  // --- 2. Camera Scan Action Button for Desktop ---
                  IconButton(
                    icon:
                        const Icon(Icons.camera_alt, color: Colors.deepOrange),
                    tooltip: l10n?.translate('scanSign') ??
                        'Scan Sign & Cultural Context', // --- LOCALIZATION ---
                    onPressed: () => _openSignScanner(context, appState),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.desktop_windows,
                        color: Colors.deepOrange),
                    tooltip: l10n?.translate('launchPresentation') ??
                        'Launch Presentation Mode', // --- LOCALIZATION ---
                    onPressed: () => appState.togglePresentationMode(),
                  ),
                  const SizedBox(width: 16),
                ],
              )
            : null;

        // Mobile AppBar
        AppBar? mobileAppBar = !isDesktop
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                title: Row(
                  children: [
                    Text(appState.currentCountry.flagEmoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Travel link (${appState.currentCountry.name})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  // --- 3. Camera Scan Action Button for Mobile ---
                  IconButton(
                    icon:
                        const Icon(Icons.camera_alt, color: Colors.deepOrange),
                    tooltip: l10n?.translate('scanSign') ??
                        'Scan Sign', // --- LOCALIZATION ---
                    onPressed: () => _openSignScanner(context, appState),
                  ),
                  IconButton(
                    icon: const Icon(Icons.desktop_windows,
                        color: Colors.deepOrange),
                    tooltip: l10n?.translate('launchPresentation') ??
                        'Launch Presentation Mode', // --- LOCALIZATION ---
                    onPressed: () => appState.togglePresentationMode(),
                  ),
                ],
              )
            : null;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: desktopAppBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme:
                      const IconThemeData(color: Colors.deepOrange, size: 28),
                  selectedLabelTextStyle: const TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  backgroundColor: Colors.white,
                  elevation: 2,
                  destinations: [
                    // --- LOCALIZATION --- Removed const to support dynamic translation strings
                    NavigationRailDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: Text(l10n?.translate('navFlashcards') ??
                          'Flashcards'), // --- LOCALIZATION ---
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.grid_view_rounded),
                      selectedIcon: const Icon(Icons.grid_view),
                      label: Text(l10n?.translate('navScenarios') ??
                          'Scenarios'), // --- LOCALIZATION ---
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.forum_outlined),
                      selectedIcon: const Icon(Icons.forum),
                      label: Text(l10n?.translate('navCommunity') ??
                          'Community'), // --- LOCALIZATION ---
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: const Icon(Icons.person),
                      label: Text(l10n?.translate('navProfile') ??
                          'Profile'), // --- LOCALIZATION ---
                    ),
                  ],
                ),
                const VerticalDivider(
                    thickness: 1, width: 1, color: Colors.grey),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _screens[_currentIndex],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: mobileAppBar,
          body: _screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => setState(() => _currentIndex = index),
              items: [
                // --- LOCALIZATION --- Removed const to allow runtime translated labels
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home),
                    label: l10n?.translate('navFlashcards') ??
                        'Flashcards'), // --- LOCALIZATION ---
                BottomNavigationBarItem(
                    icon: const Icon(Icons.grid_view_rounded),
                    activeIcon: const Icon(Icons.grid_view),
                    label: l10n?.translate('navScenarios') ??
                        'Scenarios'), // --- LOCALIZATION ---
                BottomNavigationBarItem(
                    icon: const Icon(Icons.forum_outlined),
                    activeIcon: const Icon(Icons.forum),
                    label: l10n?.translate('navCommunity') ??
                        'Community'), // --- LOCALIZATION ---
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person),
                    label: l10n?.translate('navProfile') ??
                        'Profile'), // --- LOCALIZATION ---
              ],
            ),
          ),
        );
      },
    );
  }
}
