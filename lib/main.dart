import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_shell.dart';
import 'screens/interests_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final selectedInterests = prefs.getStringList('selectedInterests') ?? [];

    if (!isLoggedIn) return const WelcomeScreen();
    if (selectedInterests.isEmpty) return const InterestsScreen();
    return MainShell(selectedInterests: selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zed Events',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const WelcomeScreen();
        },
      ),
    );
  }
}