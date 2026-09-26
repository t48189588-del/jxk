import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';
import 'scenarios_screen.dart';
import 'qa_screen.dart';
import 'profile_screen.dart';
import 'desktop_presentation_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.isPresentationMode) {
      return const DesktopPresentationScreen();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 768;

        // Common App Bar / Header content for desktop web
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
                      'Cultural Hub — ${appState.currentCountry.name}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.desktop_windows,
                        color: Colors.deepOrange),
                    tooltip: 'Launch Presentation Mode',
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
                      'Cultural Hub (${appState.currentCountry.name})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.desktop_windows,
                        color: Colors.deepOrange),
                    tooltip: 'Launch Presentation Mode',
                    onPressed: () => appState.togglePresentationMode(),
                  ),
                ],
              )
            : null;

        if (isDesktop) {
          // Responsive Web Layout (Sidebar + Full Screen Content)
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
                  // Fixed property name from selectedTextStyle to selectedLabelTextStyle
                  selectedLabelTextStyle: const TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  backgroundColor: Colors.white,
                  elevation: 2,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Flashcards'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      selectedIcon: Icon(Icons.grid_view),
                      label: Text('Scenarios'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.forum_outlined),
                      selectedIcon: Icon(Icons.forum),
                      label: Text('Community'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
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

        // Mobile Layout (Bottom Nav)
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
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Flashcards'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_rounded),
                    activeIcon: Icon(Icons.grid_view),
                    label: 'Scenarios'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.forum_outlined),
                    activeIcon: Icon(Icons.forum),
                    label: 'Community'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile'),
              ],
            ),
          ),
        );
      },
    );
  }
}
