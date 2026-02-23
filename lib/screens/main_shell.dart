import 'package:flutter/material.dart';
import 'package:event_app/screens/home_screen.dart';
import 'package:event_app/screens/reels_screen.dart';
import 'package:event_app/screens/events_map_screen.dart';
import 'package:event_app/screens/notifications_screen.dart';

/// Main scaffold with bottom nav: Home | Reels | Map | Notifications.
class MainShell extends StatefulWidget {
  final List<String> selectedInterests;

  const MainShell({super.key, required this.selectedInterests});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(selectedInterests: widget.selectedInterests),
          ReelsScreen(isVisible: _currentIndex == 1),
          const EventsMapScreen(),
          const NotificationsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library), label: 'Reels'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      ),
    );
  }
}
